/// What the signup form sends. Add the fields your API needs.
class SignupRequest {
  const SignupRequest({
    required this.name,
    required this.email,
    required this.password,
  });

  final String name;
  final String email;
  final String password;

  Map<String, Object?> toJson() => {
    'name': name,
    'email': email,
    'password': password,
  };
}
