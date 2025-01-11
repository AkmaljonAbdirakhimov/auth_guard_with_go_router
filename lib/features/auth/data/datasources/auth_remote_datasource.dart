import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<void> sendOtp(String phoneNumber);
  Future<UserModel> verifyOtp(String phoneNumber, String otp);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<void> sendOtp(String phoneNumber) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<UserModel> verifyOtp(String phoneNumber, String otp) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    if (otp.length == 6) {
      return UserModel(
        phoneNumber: phoneNumber,
        isAuthenticated: true,
      );
    }
    throw Exception('Invalid OTP');
  }
}
