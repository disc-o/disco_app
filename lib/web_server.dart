export 'package:angel_framework/angel_framework.dart';
export 'package:angel_framework/http.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:angel_framework/angel_framework.dart';
import 'package:angel_framework/http.dart';
import 'package:angel_oauth2/angel_oauth2.dart' as oauth2;
import 'package:angel_oauth2/angel_oauth2.dart';
import 'package:corsac_jwt/corsac_jwt.dart' as jwt;
import 'package:http_parser/http_parser.dart';

import 'package:disco_app/client.dart';
import 'package:disco_app/user.dart';
import 'package:disco_app/widgets/drawer.dart';
import 'package:disco_app/database_helper.dart' as db;
import 'package:disco_app/util.dart' as util;
import 'package:disco_app/data.dart' as data;
import 'package:disco_app/rsa_key_helper.dart' as rsa;

var htmlType = MediaType('text', 'html', {'charset': 'utf-8'});

var _issuer = 'http://127.0.0.1:3000';
var _audience = 'http://127.0.0.1:3000';
var _trustedClient = 'trusted_client';
// var _infiniteDuration = 0;
_AuthServer authServer;
var _rsaHelper = rsa.RsaKeyHelper();

List<int> _parseListOfInt(String encoded) {
  try {
    List t = jsonDecode(encoded);
    List<int> k = List();
    for (var p in t) {
      if (p is int) k.add(p);
    }
    return k;
  } catch (e) {
    throw AngelHttpException.badRequest();
  }
}

Future<String> _getParam(RequestContext req, String name, String state,
    {bool body = false, bool throwIfEmpty = true}) async {
  Map<String, dynamic> data;

  if (body == true) {
    data = await req.parseBody().then((_) => req.bodyAsMap);
  } else {
    data = req.queryParameters;
  }

  var value = data.containsKey(name) ? data[name]?.toString() : null;

  if (value?.isNotEmpty != true && throwIfEmpty) {
    throw AuthorizationException(
      ErrorResponse(
        ErrorResponse.invalidRequest,
        'Missing required parameter "$name".',
        state,
      ),
      statusCode: 400,
    );
  }

  return value;
}

Future<String> _getParamFromMap(
    Map<String, dynamic> body, String name, String state,
    {bool throwIfEmpty = true}) async {
  var value = body.containsKey(name) ? body[name]?.toString() : null;

  if (value?.isNotEmpty != true && throwIfEmpty) {
    throw AuthorizationException(
      ErrorResponse(
        ErrorResponse.invalidRequest,
        'Missing required parameter "$name".',
        state,
      ),
      statusCode: 400,
    );
  }

  return value;
}

bool _scopeIsKeyB(String scopes) {
  // Just make sure you don't have multiple 'key_b' =)
  return scopes.split(' ').where((t) => t == 'key_b').length == 1;
}

List<String> _parseScopes(String scopes) {
  return scopes.split('+');
}

// Future<Iterable<String>> _getScopes(RequestContext req,
//     {bool body = false}) async {
//   Map<String, dynamic> data;

//   if (body == true) {
//     data = await req.parseBody().then((_) => req.bodyAsMap);
//   } else {
//     data = req.queryParameters;
//   }

//   return data['scope']?.toString()?.split(' ') ?? [];
// }

Future closeWebServer(Future<AngelHttp> http) async {
  AngelHttp t = await http;
  if (t != null) {
    t.close();
    print('Stopped HTTP server');
  } else {
    print("The server doesn't exist");
  }
}

Future<AngelHttp> startWebServer(BuildContext context,
    {int port = 3000}) async {
  var app = Angel();
  authServer = _AuthServer(context);
  var _rgxBearer = RegExp(r'^[Bb]earer');
  AngelHttp http;

  http = AngelHttp(app);
  await http.startServer('localhost', 3000);
  print('Started HTTP server at ${http.server.address}:${http.server.port}');

  data.keyPair =
      await _rsaHelper.computeRSAKeyPair(_rsaHelper.getSecureRandom());
  print('Generated key pair');

  // --------------- below is for testing purposes

  data.publicKeyInPemPKCS1 =
      _rsaHelper.encodePublicKeyToPemPKCS1(data.keyPair.publicKey);
  var my1 = jsonEncode({
    "state": "a random string",
    "client_id": "IKEA's ID",
    "client_secret": "secret",
    "client_name": "IKEA",
    "is_trusted": false,
    "challenge": "decrypted encrypted c"
  });
  var my2 = jsonEncode({
    "client_id": "IKEA's ID",
    "client_secret": "secret",
    "response_type": "token",
    "redirect_uri": "https://ikea.com/redirect",
    "scope": "key_b+address",
  });
  var cipherText = _rsaHelper.encrypt(my1, data.keyPair.publicKey);
  var encoded = jsonEncode(cipherText);
  print(encoded);
  print(jsonEncode(_rsaHelper.encrypt(my2, data.keyPair.publicKey)));
  print(_rsaHelper.decrypt(_parseListOfInt(encoded), data.keyPair.privateKey));

  // above is for testing purposes ---------------

  FutureOr<bool> invokeUserToIssueKeyB(Map<String, dynamic> tokenRecord) async {
    // Get information about the token, pop up confirmation window, request for consent, return the requested data
    var cr = (await db.DatabaseHelper.instance
        .selectClientByClientId(tokenRecord['client_id']))[0];
    Client client = Client(name: cr['client_name']);
    return await openGrantKeyBDrawer(context, client, tokenRecord['scopes']) ==
        true;
  }

  app.get('/', (req, res) {
    res
      ..contentType = htmlType
      ..write('Hello');
  });

  app.group('/auth', (router) async {
    router
      ..get('/authorize', (req, res) async {
        await authServer.authorizationEndpoint(req, res);
      })
      ..post('register', (req, res) async {
        await authServer.registerNewClient(req, res);
      });
  });

  app.fallback((req, res) async {
    var state = '';
    var query = req.queryParameters;
    state = query['state']?.toString() ?? '';

    var authToken =
        req.headers.value('authorization')?.replaceAll(_rgxBearer, '')?.trim();

    if (authToken == null) {
      throw AngelHttpException.forbidden();
    } else {
      var list = await db.DatabaseHelper.instance.selectTokenByJwt(authToken);
      if (list.isEmpty) {
        throw AngelHttpException.forbidden();
      } else if (list.length > 1) {
        // This shouldn't happen...
        throw AngelHttpException.badRequest();
      } else {
        var tokenRecord = list[0];
        if (_scopeIsKeyB(tokenRecord['scopes'].toString())) {
          // issue Key B
          if (await invokeUserToIssueKeyB(tokenRecord)) {
            var signSecret = util.generateCryptoRandomString();
            var builder = jwt.JWTBuilder();
            var signer = jwt.JWTHmacSha256Signer(signSecret);
            var expireDuration = Duration(minutes: 1);
            var scopeString = tokenRecord['scopes']
                .toString()
                .split(' ')
                .where((t) => t != 'key_b')
                .join(' ');
            builder
              ..issuer = _issuer
              ..expiresAt = DateTime.now().add(expireDuration)
              ..issuedAt = DateTime.now()
              ..audience =
                  _audience // where this jwt is valid for, i.e. the resource endpoint
              ..subject = _trustedClient
              ..setClaim('scopes', scopeString);
            String signedJwt = builder.getSignedToken(signer).toString();
            await db.DatabaseHelper.instance.insertToTokenTable(
                signedJwt,
                signSecret,
                tokenRecord[
                    'client_id'], // this is strange but keep it this way for now
                scopeString,
                expireDuration.inSeconds);
            res
              ..contentType =
                  MediaType('application', 'json', {'charset': 'utf-8'})
              ..write(jsonEncode({
                'access_token': signedJwt,
                'token_type': 'bearer',
                'state': state,
                'expires_in': expireDuration.inSeconds,
                'scope': scopeString
              }));
          } else {
            throw oauth2.AuthorizationException(
              oauth2.ErrorResponse(oauth2.ErrorResponse.unauthorizedClient,
                  'User rejected your request', ''),
              statusCode: 404,
            );
          }
        } else {
          // return data using Key B
          Client client;

          var id = req.queryParameters['client_id'];
          var secret = req.queryParameters['client_secret'];

          if (id == null || secret == null) {
            throw AuthorizationException(
              ErrorResponse(
                ErrorResponse.unauthorizedClient,
                'No client_id or client_secret in query params.',
                state,
              ),
              statusCode: 400,
            );
          } else {
            var clientId = id.toString(), clientSecret = secret.toString();

            client = await authServer.findClient(clientId);

            if (client == null) {
              throw AuthorizationException(
                ErrorResponse(
                  ErrorResponse.unauthorizedClient,
                  'Invalid "client_id" parameter.',
                  state,
                ),
                statusCode: 400,
              );
            }

            if (!client.isTrusted) {
              throw AuthorizationException(
                ErrorResponse(
                  ErrorResponse.unauthorizedClient,
                  'Untrusted client.',
                  state,
                ),
                statusCode: 400,
              );
            }

            if (!await authServer.verifyClient(client, clientSecret)) {
              throw AuthorizationException(
                ErrorResponse(
                  ErrorResponse.unauthorizedClient,
                  'Invalid "client_secret" parameter.',
                  state,
                ),
                statusCode: 400,
              );
            }
          }

          if (await openGrantDataAccessDrawer(
              context, client, tokenRecord['scopes'].toString())) {
            Map<String, dynamic> resp = Map();
            List<String> scopes = _parseScopes(tokenRecord['scopes']);
            for (String s in scopes) {
              resp[s] = data.getUserData(s);
            }
            res
              ..contentType =
                  MediaType('application', 'json', {'charset': 'utf-8'})
              ..write(jsonEncode(resp));
          } else {
            throw oauth2.AuthorizationException(
              oauth2.ErrorResponse(oauth2.ErrorResponse.unauthorizedClient,
                  'User rejected your request', ''),
              statusCode: 404,
            );
          }
        }
      }
    }
  });

  return http;
}

class _AuthServer extends oauth2.AuthorizationServer<Client, User> {
  int expiresIn = 3600;
  BuildContext context; // for notifying the user
  _AuthServer(this.context);

  FutureOr<bool> invokeUserToReviewScopes(
      Client client, Iterable<String> scopes) async {
    try {
      return await openScopeReviewDrawer(context, client, scopes) == true;
    } catch (e) {
      return false;
    }
  }

  Future<void> registerNewClient(
      RequestContext req, ResponseContext res) async {
    String state = '';
    try {
      await req.parseBody();
      var rawData =
          _parseListOfInt(await _getParam(req, 'data', state, body: true));
      var rawJsonString = _rsaHelper.decrypt(rawData, data.keyPair.privateKey);
      var body = jsonDecode(rawJsonString);
      state = body['state']?.toString() ?? '';
      var clientId = await _getParamFromMap(body, 'client_id', state);
      try {
        var client = await authServer.findClient(clientId);
        if (client != null) {
          throw AuthorizationException(ErrorResponse(
            ErrorResponse.invalidRequest,
            'Registered yourself more than once',
            state,
          ));
        }
      } on AngelHttpException {
        rethrow;
      }
      var clientName = body['client_name']?.toString() ?? '';
      var clientSecret = await _getParamFromMap(body, 'client_secret', state);
      bool isTrusted =
          await _getParamFromMap(body, 'is_trusted', state) == 'true'
              ? true
              : false;
      bool isCertified = await checkCertificate(req, body);
      // await req.parseBody();
      bool accepted = await openRegisterVerificationDrawer(
              context, clientName, isCertified, isTrusted) ==
          true;
      if (accepted) {
        String saltedPassword = util.addSalt(clientSecret);
        // print(util.matchedPassword(clientSecret, saltedPassword));
        db.DatabaseHelper.instance
            .insertClient(clientId, clientName, saltedPassword, isTrusted);
      } else {
        throw AuthorizationException(ErrorResponse(
          ErrorResponse.unauthorizedClient,
          'Rejected client "$clientId".',
          state,
        ));
      }
    } on AngelHttpException {
      rethrow;
    } catch (e) {
      print(e);
    }
  }

  FutureOr<bool> checkCertificate(RequestContext req, Map body) async {
    try {
      data.challengeFromClient = body['challenge'];
      print(data.challengeFromClient);
      return data.challengeFromClient == data.challengeFromServer;
    } catch (e) {
      throw AuthorizationException(ErrorResponse(
          ErrorResponse.invalidRequest, 'No challenge found in body', ''));
    }
  }

  @override
  Future<void> authorizationEndpoint(
      RequestContext req, ResponseContext res) async {
    String state = '';

    try {
      var query = req.queryParameters;
      state = query['state']?.toString() ?? '';
      List<int> rawData = _parseListOfInt(query['data']);
      if (rawData == null) {
        throw AuthorizationException(ErrorResponse(
          ErrorResponse.invalidRequest,
          'Invalid data query parameter',
          state,
        ));
      }
      Map<String, dynamic> body;
      try {
        var rawJsonString =
            _rsaHelper.decrypt(rawData, data.keyPair.privateKey);
        body = jsonDecode(rawJsonString);
        print(body);
      } catch (e) {
        if (rawData == null) {
          throw AuthorizationException(ErrorResponse(
            ErrorResponse.invalidRequest,
            e.toString(),
            state,
          ));
        }
      }
      var responseType = await _getParamFromMap(body, 'response_type', state);

      // req.container.registerLazySingleton<Pkce>((_) {
      //   return Pkce.fromJson(req.queryParameters, state: state);
      // });

      if (responseType == 'code' || responseType == 'token') {
        // Ensure client ID
        var clientId = await _getParamFromMap(body, 'client_id', state);

        // Find client
        var client = await findClient(clientId);

        if (client == null) {
          throw AuthorizationException(ErrorResponse(
            ErrorResponse.unauthorizedClient,
            'Unknown client "$clientId".',
            state,
          ));
        }

        // Grab redirect URI
        var redirectUri = await _getParamFromMap(body, 'redirect_uri', state);

        // Grab scopes
        var rawScopes = await _getParamFromMap(body, 'scope', state);
        print(rawScopes);
        var scopes = _parseScopes(rawScopes);

        return await requestAuthorizationCode(client, redirectUri, scopes,
            state, req, res, responseType == 'token');
      }

      throw AuthorizationException(
          ErrorResponse(
            ErrorResponse.invalidRequest,
            'Invalid or no "response_type" parameter provided',
            state,
          ),
          statusCode: 400);
    } on AngelHttpException {
      rethrow;
    } catch (e, st) {
      throw AuthorizationException(
        ErrorResponse(
          ErrorResponse.serverError,
          'Internal server error',
          state,
        ),
        error: e,
        statusCode: 500,
        stackTrace: st,
      );
    }
  }

  @override
  FutureOr<void> requestAuthorizationCode(
      Client client,
      String redirectUri,
      Iterable<String> scopes,
      String state,
      RequestContext req,
      ResponseContext res,
      bool implicit) async {
    if (implicit) {
      var query = req.queryParameters;
      List<int> rawData = _parseListOfInt(query['data']);
      Map<String, dynamic> body;
      var rawJsonString = _rsaHelper.decrypt(rawData, data.keyPair.privateKey);
      body = jsonDecode(rawJsonString);
      // First verify the identity of client requesting for token
      var clientSecret = await _getParamFromMap(body, 'client_secret', state);
      if (!util.matchedPassword(clientSecret, client.secret)) {
        throw oauth2.AuthorizationException(
          oauth2.ErrorResponse(oauth2.ErrorResponse.unauthorizedClient,
              'Invalid client secret', state),
          statusCode: 404,
        );
      } else {
        // Now that the request has the correct client_secret, checking its certificate is not necessary.
        if (await invokeUserToReviewScopes(client, scopes)) {
          var signSecret = util.generateCryptoRandomString();
          var builder = jwt.JWTBuilder();
          var signer = jwt.JWTHmacSha256Signer(signSecret);
          var expireDuration = Duration(minutes: 1);
          builder
            ..issuer = _issuer
            ..expiresAt = DateTime.now().add(expireDuration)
            ..issuedAt = DateTime.now()
            ..audience =
                _audience // where this jwt is valid for, i.e. the resource endpoint
            ..subject = client.id
            ..setClaim('scopes', scopes.toList());
          String signedJwt = builder.getSignedToken(signer).toString();
          await db.DatabaseHelper.instance.insertToTokenTable(
              signedJwt,
              signSecret,
              client.id,
              scopes.reduce((a, b) => a + ' ' + b),
              expireDuration.inSeconds);
          Uri uri = super.completeImplicitGrant(
              oauth2.AuthorizationTokenResponse(signedJwt,
                  expiresIn: expireDuration.inSeconds, scope: scopes),
              Uri.parse(redirectUri));
          // I should redirect here... but for some unknown reason the client cannot
          // receive the redirects, so instead I write the data back...
          // res..redirect(uri);
          print(uri);
          // res..json({uri: uri});
          res
            ..contentType =
                MediaType('application', 'json', {'charset': 'utf-8'})
            ..write(jsonEncode({
              'access_token': signedJwt,
              'token_type': 'bearer',
              'expires_in': expireDuration.inSeconds,
              'scope': scopes
            }));
        } else {
          throw oauth2.AuthorizationException(
            oauth2.ErrorResponse(oauth2.ErrorResponse.unauthorizedClient,
                'User rejected your request', state),
            statusCode: 404,
          );
        }
      }
    } else {
      // According to https://www.oauth.com/oauth2-servers/access-tokens/access-token-response/
      // the error response should be one of:
      // invalid_request, invalid_client, invalid_grant, invalid_scope, unauthorized_client, unsupported_grant_type
      throw AuthorizationException(
        ErrorResponse(
          oauth2.ErrorResponse.unsupportedResponseType,
          'Only implicit auth method is supported.',
          state,
        ),
        statusCode: 500,
      );
    }
  }

  @override
  FutureOr<Client> findClient(String clientId) async {
    var list =
        await db.DatabaseHelper.instance.selectClientByClientId(clientId);
    if (list.length != 1) {
      return null;
    } else {
      var res = list[0];
      return Client(
          id: res['client_id'],
          name: res['client_name'],
          secret: res['client_secret'],
          isTrusted: res['is_trusted'] == 1,
          publicKey: res['public_key'] ?? '');
    }
  }

  @override
  FutureOr<bool> verifyClient(Client client, String clientSecret) async {
    var list =
        await db.DatabaseHelper.instance.selectClientByClientId(client.id);
    if (list.length != 1) {
      throw oauth2.AuthorizationException(
        oauth2.ErrorResponse(
            oauth2.ErrorResponse.unauthorizedClient, 'Invalid client', ''),
        statusCode: 404,
      );
    } else {
      var saltedSecret = list[0]['client_secret'];
      return util.matchedPassword(clientSecret, saltedSecret);
    }
  }
}
