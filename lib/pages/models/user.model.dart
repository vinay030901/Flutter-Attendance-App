import 'dart:convert';

class User {
  String user;
  String password;
  List modelData;
  double lat = 0;
  double long = 0;

  String? id;

  User({
    required this.user,
    required this.password,
    required this.modelData,
    required this.lat,
    required this.long,
  });

  static User fromMap(Map<String, dynamic> user) {
    return User(
      user: user['user'],
      password: user['password'],
      modelData: jsonDecode(user['model_data']),
      lat: 0.0,
      long: 0.0,
    );
  }

  toMap() {
    return {
      'user': user,
      'password': password,
      'model_data': jsonEncode(modelData),
    };
  }
}
