import 'dart:convert';
import 'dart:io';
import 'dart:math';

export 'package:pointycastle/api.dart';
import 'package:convert/convert.dart' as conv;
import 'package:disco_app/rsa_key_helper.dart';
import 'package:encrypt/encrypt.dart';
import 'package:crypt/crypt.dart';
import 'package:corsac_jwt/corsac_jwt.dart' as jwt;

import 'package:disco_app/data.dart' as data;
import 'package:pointycastle/pointycastle.dart';

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

class SymmetricEncrypted {
  String keyBase64, ivBase64, encryptedBase64;
  SymmetricEncrypted(this.keyBase64, this.ivBase64, this.encryptedBase64);
  SymmetricEncrypted.asymEncrypted(
      SymmetricEncrypted se, RsaKeyHelper helper, PublicKey publicKey) {
    this.keyBase64 = helper.encryptAsymmetric(se.keyBase64, publicKey);
    this.ivBase64 = helper.encryptAsymmetric(se.ivBase64, publicKey);
    this.encryptedBase64 = se.encryptedBase64;
  }

  @override
  String toString() {
    return "[SymmetricEncrypted]\nkey: $keyBase64\niv:$ivBase64\nencrypted: $encryptedBase64";
  }
}

SymmetricEncrypted encryptSymmetric(String text) {
  final key = Key.fromBase64(
      base64Encode(List<int>.generate(16, (i) => _random.nextInt(256))));
  final iv = IV.fromBase64(
      base64Encode(List<int>.generate(16, (i) => _random.nextInt(256))));
  final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
  final encrypted = encrypter.encrypt(text, iv: iv);
  return SymmetricEncrypted(key.base64, iv.base64, encrypted.base64);
}

String decryptSymmetric(SymmetricEncrypted enc) {
  final encrypter =
      Encrypter(AES(Key.fromBase64(enc.keyBase64), mode: AESMode.cbc));
  return encrypter.decrypt(Encrypted.fromBase64(enc.encryptedBase64),
      iv: IV.fromBase64(enc.ivBase64));
}

String decryptAsymmetricallyEncryptedSE(
    SymmetricEncrypted enc, RsaKeyHelper helper, PrivateKey privateKey) {
  var keyBase64 = helper.decryptAsymmetric(enc.keyBase64, privateKey);
  var ivBase64 = helper.decryptAsymmetric(enc.ivBase64, privateKey);
  return decryptSymmetric(
      SymmetricEncrypted(keyBase64, ivBase64, enc.encryptedBase64));
}

main(List<String> args) async {
  var enc = encryptSymmetric('hello');
  print(enc.keyBase64);
  print(enc.ivBase64);
  print(enc.encryptedBase64);

  // // encode token
  // var builder = jwt.JWTBuilder();
  // var signer = jwt.JWTHmacSha256Signer('secret');
  // builder
  //   ..issuer = 'https://api.foobar.com'
  //   ..expiresAt = DateTime.now().add(new Duration(
  //       minutes:
  //           3)) // the number of seconds (not milliseconds) since Epoch referring to RFC 7519
  //   ..setClaim('data', {'userId': 233});
  // var token = builder.getSignedToken(signer);
  // print(token);
  // var decodedToken = jwt.JWT.parse(token.toString());
  // print(decodedToken.verify(jwt.JWTHmacSha256Signer('asd')));
}
