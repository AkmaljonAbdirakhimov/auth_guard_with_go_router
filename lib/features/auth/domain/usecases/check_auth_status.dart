import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class CheckAuthStatus {
  final AuthRepository repository;

  CheckAuthStatus(this.repository);

  Future<Either<Failure, User?>> checkInitial() {
    return repository.checkInitialStatus();
  }

  Stream<User?> watch() {
    return repository.authStateChanges();
  }
}
