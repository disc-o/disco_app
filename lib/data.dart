import 'package:disco_app/client.dart';
import 'package:disco_app/user.dart';

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