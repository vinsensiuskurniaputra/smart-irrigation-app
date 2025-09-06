class SignupReqParams {
  final String username;
  final String password;
  final String name;
  final String email;

  SignupReqParams({required this.username, required this.password, required this.name, required this.email});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'username': username,
      'password': password,
      'name': name,
      'email': email,
    };
  }
}
