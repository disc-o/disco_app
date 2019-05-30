import 'package:disco_app/rsa_key_helper.dart';

RsaKeyHelper helper = RsaKeyHelper();

String pub = '''
-----BEGIN PUBLIC KEY-----
MIIBCgKCAQEAgZVs2G1v5kLkwxAT5fr/jPH6hZRTWEBOMb+W+15qB/Yo2DHK9epufVt+oYosFW9H1DEOveos0IBLnAz4WTYrrtUFkF9drnKpkutdiRAIhSZkBHwXbYmO/TmcmTpArVZKrlgoKhFIuhGQNnnTGY9KKsP9kmYGeyluM1Ldfs2IY8QS8hOSZjNY9r1mvbg+w/MMpSGF3Y0c1+IYzdPQZTSjWGeKk+OXPYYQX5I5XwhTngMr91T7SQtodptg7oxzW56JwnleciRoKpifXxnkAQ9xICHhu2oKjdOQbXzL/oMGGx60AFd8nv0svc7KSSN4csrbAIIWROvgNrhk+jU0QnElvwIDAQAB
-----END PUBLIC KEY-----
''';
String priv = '''
-----BEGIN PRIVATE KEY-----
MIIFogIBAAKCAQEAgZVs2G1v5kLkwxAT5fr/jPH6hZRTWEBOMb+W+15qB/Yo2DHK9epufVt+oYosFW9H1DEOveos0IBLnAz4WTYrrtUFkF9drnKpkutdiRAIhSZkBHwXbYmO/TmcmTpArVZKrlgoKhFIuhGQNnnTGY9KKsP9kmYGeyluM1Ldfs2IY8QS8hOSZjNY9r1mvbg+w/MMpSGF3Y0c1+IYzdPQZTSjWGeKk+OXPYYQX5I5XwhTngMr91T7SQtodptg7oxzW56JwnleciRoKpifXxnkAQ9xICHhu2oKjdOQbXzL/oMGGx60AFd8nv0svc7KSSN4csrbAIIWROvgNrhk+jU0QnElvwKCAQBUXiIwwwfA5jqk2Znq+UFa1c0jHVAqPCvs7e1yGaV1K4qqP7kB5TEswt4udJSBHCOq/om3kni9A1q27ibfhopoWN83gS+wPY00T7NlYp/5eOZTmStzsMT9D35qsOedM3qKCnGT+g7cvkSjgyuzD3zdXR+CKpT7qRzLo578SPsM4JWxwrQdZY2j255yuAxFxsbfoYsPwTp7OAaRiip7UcxsWbLL/+3GO4135l8UgNvxFVFKt2juc7IKxMi62qfjcdhRhhhveUJ6utuN+r5Cz4PDYfNZYbZWt+4pm2N5BDdesWFL+ONCWPolivMPTWMrMJr+HrWvFWa2eRkpg32S2irRAoIBAFReIjDDB8DmOqTZmer5QVrVzSMdUCo8K+zt7XIZpXUriqo/uQHlMSzC3i50lIEcI6r+ibeSeL0DWrbuJt+GimhY3zeBL7A9jTRPs2Vin/l45lOZK3OwxP0Pfmqw550zeooKcZP6Dty+RKODK7MPfN1dH4IqlPupHMujnvxI+wzglbHCtB1ljaPbnnK4DEXGxt+hiw/BOns4BpGKKntRzGxZssv/7cY7jXfmXxSA2/EVUUq3aO5zsgrEyLrap+Nx2FGGGG95Qnq62436vkLPg8Nh81lhtl
-----END PRIVATE KEY-----
''';

main(List<String> args) {
  var publicKey = helper.parsePublicKeyFromPem(pub);
  var cipherText = helper.encrypt('Hello world', publicKey);
  var privateKey = helper.parsePrivateKeyFromPem(priv);
  print(helper.decrypt(cipherText, privateKey));
}