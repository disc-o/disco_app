export 'package:angel_framework/angel_framework.dart';
export 'package:angel_framework/http.dart';

import 'dart:async';

import 'package:angel_framework/angel_framework.dart';
import 'package:angel_framework/http.dart';
import 'package:angel_oauth2/angel_oauth2.dart' as oauth2;
import 'package:angel_oauth2/angel_oauth2.dart';
import 'package:disco_app/client.dart';
import 'package:disco_app/user.dart';
import 'package:disco_app/widgets/drawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:http_parser/http_parser.dart';
import 'package:disco_app/database_helper.dart' as db;
import 'package:disco_app/util.dart' as util;
// import 'package:disco_app/widgets/verification_drawer.dart' as verify;

class MyServer {}

var htmlType = MediaType('text', 'html', {'charset': 'utf-8'});

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

Future closeWebServer(Future<AngelHttp> http) async {
  AngelHttp t = await http;
  if (t != null) {
    t.close();
    print('Stopped HTTP server');
  } else {
    print("The server doesn't exist");
  }
}

// Future<AngelHttp> startWebServerWithContext(BuildContext context,
//     {int port = 3000}) async {
//   print(await cp.openVerificationDrawer(context, 'asd', 'asd'));
//   return await startWebServer(context, port: port);
// }

Future<AngelHttp> startWebServer(BuildContext context,
    {int port = 3000}) async {
  var app = Angel();
  var authServer = _AuthServer(context);
  var _rgxBearer = RegExp(r'^[Bb]earer ([^\n\s]+)$');
  var http = AngelHttp(app);

  try {
    // code below will print out the LAN address
    // print(await Wifi.ip);
    // use adb forward tcp:3000 tcp:3000 so that you can access localhost:3000 from your computer

    await http.startServer('localhost', 3000);

    // code below will listen on public network interface
    // await http.startServer(InternetAddress.anyIPv4, 3000);

    print('Started HTTP server at ${http.server.address}:${http.server.port}');
  } catch (e) {
    print(e);
  }

  app.group('/auth', (router) async {
    router
      ..get('/authorize', (req, res) async {
        await authServer.authorizationEndpoint(req, res);
      })
      ..get('register', (req, res) async {
        await authServer.registerNewClient(req, res);
      })
      ..post('/token', (req, res) async {
        await authServer.tokenEndpoint(req, res);
      });
  });

  app.fallback((req, res) {
    var authToken =
        req.headers.value('authorization')?.replaceAll(_rgxBearer, '')?.trim();

    if (authToken == null) {
      throw AngelHttpException.forbidden();
    } else {
      // TODO: The user has a token, now verify it.
      // It is up to you how to store and retrieve auth tokens within your application.
      // The purpose of `package:angel_oauth2` is to provide the transport
      // across which you distribute these tokens in the first place.
      throw UnimplementedError();
    }
  });

  return http;
}

class _AuthServer extends oauth2.AuthorizationServer<Client, User> {
  int expiresIn = 3600;
  BuildContext context; // for notifying the user
  _AuthServer(this.context);

  FutureOr<bool> invokeUserToReviewScope(
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
      var query = req.queryParameters;
      state = query['state']?.toString() ?? '';
      var clientId = await _getParam(req, 'client_id', state);
      var clientName = await _getParam(req, 'client_name', state);
      var clientSecret = await _getParam(req, 'client_secret', state);
      bool isTrusted =
          await _getParam(req, 'is_trusted', state) == 'true' ? true : false;
      bool isCertified = await checkCertificate(req);
      await req.parseBody();
      var publicKey = req.bodyAsMap['public_key'];
      bool accepted = await openRegisterVerificationDrawer(
          context, clientName, isCertified, isTrusted);
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

  FutureOr<bool> checkCertificate(RequestContext req) async {
    // TODO: Implement certificate check
    return true;
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
      // First verify the identity of client requesting for token
      var clientSecret = await _getParam(req, 'client_secret', state);
      print(clientSecret);
      print(client.secret);
      if (!util.matchedPassword(clientSecret, client.secret)) {
        throw oauth2.AuthorizationException(
          oauth2.ErrorResponse(oauth2.ErrorResponse.unauthorizedClient,
              'Invalid client secret', state),
          statusCode: 404,
        );
      } else {
        // Now that the request has the correct client_secret, checking its certificate is not necessary.
        if (await invokeUserToReviewScope(client, scopes)) {
          var token = util.generateCryptoRandomString();
          await db.DatabaseHelper.instance.insertToTokenTable(
              token, client.id, scopes.reduce((a, b) => a + b), expiresIn);
          res
            ..redirect(super.completeImplicitGrant(
                oauth2.AuthorizationTokenResponse(token,
                    expiresIn: expiresIn, scope: scopes),
                Uri(path: redirectUri)));
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
      throw oauth2.AuthorizationException(
        oauth2.ErrorResponse(
            oauth2.ErrorResponse.unauthorizedClient, 'Invalid client', ''),
        statusCode: 404,
      );
    } else {
      var res = list[0];
      return Client(
          id: res['client_id'],
          name: res['client_name'],
          secret: res['client_secret'],
          isTrusted: res['is_trusted'] == 1,
          publicKey: res['public_key'] ?? '');
    }
    // return Client(id: '0', name: 'client', secret: 'secret', isTrusted: false, publicKey: 'key');
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
    // return true;
  }
}
