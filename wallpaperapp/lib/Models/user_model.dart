class UserModel {
  final String name;
  final String profileImageUrl;
  final String email;
  final String phoneNumber;

  UserModel({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.profileImageUrl,

  });


  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      profileImageUrl: json['profileImageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
    };
  }
}
