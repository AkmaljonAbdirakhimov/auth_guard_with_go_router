import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class WatchAuthStatus implements StreamUseCase<User?, NoParams> {
  final AuthRepository repository;

  WatchAuthStatus(this.repository);

  @override
  Stream<User?> call(NoParams params) {
    return repository.authStateChanges();
  }
}
