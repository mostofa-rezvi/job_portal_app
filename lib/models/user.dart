class User {
  int? id; // Made nullable for new users before insertion
  final String username;
  final String email;
  final String password;

  // Constructor for new users (without ID)
  User({required this.username, required this.email, required this.password});

  // Factory constructor to create User from a database map (with ID)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      username: map['username'],
      email: map['email'],
      password: map['password'],
    )..id = map['id']; // Assign ID after creation
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id, // Include id in toMap for updates, or null for inserts
      'username': username,
      'email': email,
      'password': password,
    };
  }
}