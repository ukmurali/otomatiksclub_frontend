class User {
  final String id;
  final String username;
  final String firstName;
  final String lastName;
  final String mobileNumber;
  final String role;

  User({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.mobileNumber,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      mobileNumber: json['mobileNumber'],
      role: json['role'],
    );
  }

  @override
  String toString() => username; // Makes it easier to display usernames
}
