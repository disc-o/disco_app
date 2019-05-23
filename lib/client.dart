class Client {
  String id;
  String name;

  /// [secret] is after SHA-256 crypt hash as specified by "Unix crypt using SHA-256 and SHA-512" (version: 0.4 2008-04-03)
  String secret;

  bool isTrusted;
  String publicKey;

  Client({this.id, this.name, this.secret, this.isTrusted, this.publicKey});

  @override
  String toString() {
    return '[Client] $id $name';
  }
}