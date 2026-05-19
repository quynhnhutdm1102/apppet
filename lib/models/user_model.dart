class UserModel {
  final String name;
  final String email;
  final String password;

  UserModel({required this.name, required this.email, required this.password});

  Map<String, dynamic> toMap() {
    return {'name': name, 'email': email, 'password': password};
  }

  factory UserModel.fromMap(Map data) {
    return UserModel(
      name: data['name'],
      email: data['email'],
      password: data['password'],
    );
  }
}
