export 'package:angel_framework/angel_framework.dart';
export 'package:angel_framework/http.dart';

import 'dart:async';
import 'dart:io';

import 'package:angel_framework/angel_framework.dart';
import 'package:angel_framework/http.dart';
import 'package:angel_oauth2/angel_oauth2.dart' as oauth2;
// import 'package:angel_mustache/angel_mustache.dart';
import 'package:disco_app/client.dart';
import 'package:disco_app/user.dart';
import 'package:disco_app/data.dart' as data;
import 'package:http_parser/http_parser.dart';
import 'package:wifi/wifi.dart';
// import 'package:path_provider/path_provider.dart' as pp;
// import 'package:flutter/services.dart' show rootBundle;
import 'package:disco_app/pages/index_page.dart';
import 'package:disco_app/pages/query_response_page.dart';

Future closeWebServer(Future<AngelHttp> http) async {
  AngelHttp t = await http;
  if (t != null) {
    t.close();
    print('Stopped HTTP server');
  } else {
    print("The server doesn't exist");
  }
}

Future<AngelHttp> startWebServer({int port = 3000}) async {
  var app = Angel();
  var authServer = _AuthServer();
  var _rgxBearer = RegExp(r'^[Bb]earer ([^\n\s]+)$');
  var http = AngelHttp(app);

  // code below will print out the LAN address
  // print(await Wifi.ip);
  // use adb forward tcp:3000 tcp:3000 so that you can access localhost:3000 from your computer
  await http.startServer('localhost', 3000);
  // code below will listen on public network interface
  // await http.startServer(InternetAddress.anyIPv4, 3000);
  print('Started HTTP server at ${http.server.address}:${http.server.port}');

  var htmlType = MediaType('text', 'html', {'charset': 'utf-8'});

  app.get('/', (req, res) {
    final page = IndexPage(name: 'Yuanhong');
    res
      ..contentType = htmlType
      ..write(new IndexPageComponent(page: page).render());
  });

  app.get('/name/:name', (req, res) {
    final page = IndexPage(name: req.params['name']);
    res
      ..contentType = htmlType
      ..write(new IndexPageComponent(page: page).render());
  });

  app.get('/auth', (req, res) {
    var params = req.queryParameters;
    // print(req.queryParameters);
    final String response_type = params['response_type'];
    final String client_id = params['client_id'];
    final String redirect_url = params['redirect_url'];
    final page = QueryResponsePage(response_type, client_id, redirect_url);
    res
      ..contentType = htmlType
      ..write(QueryResponsePageComponent(page).render());
  });

  app.group('/auth', (router) {
    router
      ..get('/authorize', authServer.authorizationEndpoint)
      ..post('/token', authServer.tokenEndpoint);
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
  @override
  Future<void> authorizationEndpoint(RequestContext req, ResponseContext res) {
    // TODO: implement authorizationEndpoint
    res
      ..contentType = MediaType('text', 'html', {'charset': 'utf-8'})
      ..write('<h1>This is authorization endpoint<h1>');
    return super.authorizationEndpoint(req, res);
  }

  @override
  Future tokenEndpoint(RequestContext req, ResponseContext res) {
    // TODO: implement tokenEndpoint
    return super.tokenEndpoint(req, res);
  }

  @override
  FutureOr<Client> findClient(String clientId) {
    for (var c in data.clients) {
      if (c.id == clientId) {
        return c;
      }
    }
    return null;
  }

  @override
  FutureOr<bool> verifyClient(Client client, String clientSecret) {
    return client.name == clientSecret;
  }

  @override
  FutureOr<void> requestAuthorizationCode(
      Client client,
      String redirectUri,
      Iterable<String> scopes,
      String state,
      RequestContext req,
      ResponseContext res,
      bool implicit) {
    // TODO: implement requestAuthorizationCode
    throw UnimplementedError();
    return super.requestAuthorizationCode(
        client, redirectUri, scopes, state, req, res, implicit);
  }

  @override
  FutureOr<oauth2.AuthorizationTokenResponse> exchangeAuthorizationCodeForToken(
      Client client,
      String authCode,
      String redirectUri,
      RequestContext req,
      ResponseContext res) {
    // TODO: implement exchangeAuthorizationCodeForToken
    throw UnimplementedError();
    return super.exchangeAuthorizationCodeForToken(
        client, authCode, redirectUri, req, res);
  }
}
