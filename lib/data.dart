import 'package:disco_app/client.dart';
import 'package:disco_app/user.dart';
import "package:pointycastle/export.dart";

List<Client> clients = [
  Client(id: '1', name: 'client1'),
  Client(id: '2', name: 'client2')
];

List<User> users = [User(id: '1', name: 'user1')];

Map<String, dynamic> userData = {
  'name': 'Tan Yuanhong',
  'age': 19,
  'address': '12 Kent Ridge Dr, Singapore 119243',
  'mobile_phone': '85256676'
};

dynamic getUserData(String item) {
  return userData[item];
}

String proxyUrl = '';
String referralCode = '';

String challengeFromServer = '';
String challengeFromClient = '';

AsymmetricKeyPair<PublicKey, PrivateKey> keyPair;
String publicKeyInPemPKCS1;

String publicKeyFromClient;
String certificateFromClient;

String sampleCertificate = '''
                        -----BEGIN CERTIFICATE-----
                        MIIDGTCCAgECFDJp0BJ+af9z/rLYiT7P2f+xFmQKMA0GCSqGSIb3DQEBCwUAMEkx
                        CzAJBgNVBAYTAlNHMRIwEAYDVQQIDAlTaW5nYXBvcmUxEjAQBgNVBAcMCVNpbmdh
                        cG9yZTESMBAGA1UECgwJRHVtbXkgQ28uMB4XDTE5MDUyODEzMzcwMVoXDTIwMDUy
                        NzEzMzcwMVowSTELMAkGA1UEBhMCU0cxEjAQBgNVBAgMCVNpbmdhcG9yZTESMBAG
                        A1UEBwwJU2luZ2Fwb3JlMRIwEAYDVQQKDAlEdW1teSBDby4wggEiMA0GCSqGSIb3
                        DQEBAQUAA4IBDwAwggEKAoIBAQDJDtjJzwW7DjZb9SreSzYE1f8S9dWoWDD9ebom
                        DAeURUjxEp7Ww0Fr44iVqZnizilrzffrh+HxWTZSxkd42wIlzfvPdeXZYnelSBQq
                        C3wcfZeaY7sJEDciDtnsg6gAqInToiKnX7zKL7vJQULyND+0Z3NV8ET3NnTSew40
                        xRqxOqya3NIWaPexPcHA+kXsdgllIDUrXiyxVQT+f4g15QnTk7OVGSu2R0tUYI7B
                        rRJeJ/6gFpr7aY3ebdUQKSAPHh5fHcehO26ti0suYjlwA7wvjZzSuFXVVo8Flt/i
                        4Aqv65DuGqw/PWwn6xeaiZVAhY85RHqegkbdr1lX1wVwCNX5AgMBAAEwDQYJKoZI
                        hvcNAQELBQADggEBAIPTbCUmc818sz16y30akXM+IUF5s/Sc2Fq4ZIiF8qn13XiI
                        5s/M3IQz5RcrhU7+uAvspL4uVQZqH6ztZsnYSf+mQL563hWo0WUpx686D2ySPBnw
                        KPLsjagCmyfwRtaKpm3zn/wXZJDl4HalQMDHv7Uy1Uy0P9BIxpMvFCFVu0eoW/5R
                        pqLy6JtJtOFq/X0jvjRvdz1xYo19dx3FYk36sxzHm+yE4ch82jHU8tVW8+kYEDqF
                        nrSt9KK7vDxAWT1MMD4EuknrxifHrFfxTf9WVfhsXX4WTK/QfFgQwTsSZaw/ITK7
                        DlnX6jLae5qaZAsIOUjCViURMfSgSNVGR50S4ww=
                        -----END CERTIFICATE-----
                        ''';
String samplePublicKey =
    "-----BEGIN PUBLIC KEY-----\r\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyQ7Yyc8Fuw42W/Uq3ks2\r\nBNX/EvXVqFgw/Xm6JgwHlEVI8RKe1sNBa+OIlamZ4s4pa83364fh8Vk2UsZHeNsC\r\nJc37z3Xl2WJ3pUgUKgt8HH2XmmO7CRA3Ig7Z7IOoAKiJ06Iip1+8yi+7yUFC8jQ/\r\ntGdzVfBE9zZ00nsONMUasTqsmtzSFmj3sT3BwPpF7HYJZSA1K14ssVUE/n+INeUJ\r\n05OzlRkrtkdLVGCOwa0SXif+oBaa+2mN3m3VECkgDx4eXx3HoTturYtLLmI5cAO8\r\nL42c0rhV1VaPBZbf4uAKr+uQ7hqsPz1sJ+sXmomVQIWPOUR6noJG3a9ZV9cFcAjV\r\n+QIDAQAB\r\n-----END PUBLIC KEY-----\r\n";
