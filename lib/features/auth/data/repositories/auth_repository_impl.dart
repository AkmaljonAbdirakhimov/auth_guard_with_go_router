import 'dart:async';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;
  final AuthRemoteDataSource remoteDataSource;
  final _authController = StreamController<User?>.broadcast();

  AuthRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  }) {
    _initAuth();
  }

  Future<void> _initAuth() async {
    final status = await checkInitialStatus();
    status.fold(
      (failure) => _authController.add(null),
      (user) => _authController.add(user),
    );
  }

  @override
  Future<Either<Failure, User?>> checkInitialStatus() async {
    try {
      final user = await localDataSource.getLastUser();
      return Right(user);
    } on CacheException {
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Stream<User?> authStateChanges() => _authController.stream;

  @override
  Future<Either<Failure, void>> sendOtp(String phoneNumber) async {
    try {
      await remoteDataSource.sendOtp(phoneNumber);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, User>> verifyOtp(
      String phoneNumber, String otp) async {
    try {
      final userModel = await remoteDataSource.verifyOtp(phoneNumber, otp);
      await localDataSource.cacheUser(userModel);
      _authController.add(userModel);
      return Right(userModel);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearUser();
      _authController.add(null);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  void dispose() {
    _authController.close();
  }
}
