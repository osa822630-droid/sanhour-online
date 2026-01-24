class User {
  final String id;
  final String name;
  final String email;
  final String userType;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.userType,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      userType: map['userType'],
    );
  }
}
