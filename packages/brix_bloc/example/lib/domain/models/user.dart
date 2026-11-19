import 'package:brix/core.dart';

/// The signed-in user. Add the fields your API sends.
class User {
  const User({required this.id, required this.name, required this.email});

  factory User.fromJson(Json json) => User(
    id: json.string('id'),
    name: json.string('name'),
    email: json.string('email'),
  );

  final String id;
  final String name;
  final String email;

  Map<String, Object?> toJson() => {'id': id, 'name': name, 'email': email};
}
