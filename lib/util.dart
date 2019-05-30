import 'dart:convert';
import 'dart:io';
import 'dart:math';

export 'package:pointycastle/api.dart';
import 'package:convert/convert.dart' as conv;
import 'package:encrypt/encrypt.dart';
import 'package:crypt/crypt.dart';
import 'package:corsac_jwt/corsac_jwt.dart' as jwt;

import 'package:disco_app/data.dart' as data;

Random _random = Random.secure();

String generateCryptoRandomString({int length = 32}) {
  var values = List<int>.generate(length, (i) => _random.nextInt(256));
  return conv.hex.encode(values);
}

bool matchedPassword(String secret, String saltedSecret) {
  var c = Crypt(saltedSecret);
  return c.match(secret);
}

String addSalt(String password) {
  return Crypt.sha256(password,
          rounds: 10000, salt: generateCryptoRandomString())
      .toString();
}

var _uidUrl = 'http://127.0.0.1:3001/uid';

Future<void> connectRemote() async {
  HttpClient client = HttpClient();
  var req = await client.postUrl(Uri.parse(_uidUrl));
  req.headers.set('content-type', 'application/json');
  req.add(utf8.encode(json.encode({
    'uid': data.referralCode,
    'proxy_url': data.proxyUrl,
    'public_key': data.publicKeyInPemPKCS1
  })));
  var resp = await req.close();
  print('challenge from disco server:');
  var recv = jsonDecode(await resp.transform(utf8.decoder).join());
  data.challengeFromServer = recv['challenge'];
  data.publicKeyFromClient = recv['public_key'];
  data.certificateFromClient = recv['certificate'];
}

main(List<String> args) async {
  // Symmetric

  final plainText = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit';
  final key = Key.fromUtf8('my 32 length key................');
  final iv = IV.fromLength(16);

  final encrypter = Encrypter(AES(key));

  final encrypted = encrypter.encrypt(plainText, iv: iv);
  final decrypted = encrypter.decrypt(encrypted, iv: iv);

  print(decrypted);
  print(encrypted.base64);

  // encode token
  var builder = jwt.JWTBuilder();
  var signer = jwt.JWTHmacSha256Signer('secret');
  builder
    ..issuer = 'https://api.foobar.com'
    ..expiresAt = DateTime.now().add(new Duration(
        minutes:
            3)) // the number of seconds (not milliseconds) since Epoch referring to RFC 7519
    ..setClaim('data', {'userId': 233});
  var token = builder.getSignedToken(signer);
  print(token);
  var decodedToken = jwt.JWT.parse(token.toString());
  print(decodedToken.verify(jwt.JWTHmacSha256Signer('asd')));
}
