class User {
  final String id;
  final String email;
  final String? name;
  final String? authToken;

  User({
    required this.id,
    required this.email,
    this.name,
    this.authToken,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      authToken: json['authToken'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'authToken': authToken,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? authToken,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      authToken: authToken ?? this.authToken,
    );
  }
}
