import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.phoneNumber,
    required super.isAuthenticated,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      phoneNumber: json['phoneNumber'] as String,
      isAuthenticated: json['isAuthenticated'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'isAuthenticated': isAuthenticated,
    };
  }
}
