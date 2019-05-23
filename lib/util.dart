export 'package:pointycastle/api.dart';

import 'dart:math';


import 'package:convert/convert.dart' as conv;

import 'package:encrypt/encrypt.dart';
import 'package:crypt/crypt.dart';

Random _random = Random.secure();

String generateCryptoRandomString({int length = 32}) {
  var values = List<int>.generate(length, (i) => _random.nextInt(256));
  return conv.hex.encode(values);
}

bool matchedPassword(String secret, String saltedSecret) {
  var c = Crypt(saltedSecret);
  return c.match(secret);
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

  // Hash
  // Use a crypto-random salt
  var c1 = new Crypt.sha256('password', rounds: 10000, salt: "mysalt");
  var c2 = new Crypt.sha256('password');
  print(c1.match('password'));
  print(c2.match('password'));
  var c3 = new Crypt(c1.toString());
  print(c3.match('password'));
  
}
