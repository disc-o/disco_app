class Client {
  String id;
  String name;

  Client({this.id, this.name});

  @override
  String toString() {
    return '[Client] ${id} ${name}';
  }
}