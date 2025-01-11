import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Stream<User?> authStateChanges();
  Future<Either<Failure, User?>> checkInitialStatus();
  Future<Either<Failure, void>> sendOtp(String phoneNumber);
  Future<Either<Failure, User>> verifyOtp(String phoneNumber, String otp);
  Future<Either<Failure, void>> logout();
}
