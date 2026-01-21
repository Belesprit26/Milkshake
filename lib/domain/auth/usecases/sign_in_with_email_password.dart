import '../../../core/result/result.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class SignInWithEmailPassword {
  const SignInWithEmailPassword(this._repo);
  final AuthRepository _repo;

  Future<Result<AuthUser>> call({
    required String email,
    required String password,
  }) {
    return _repo.signInWithEmailPassword(email: email, password: password);
  }
}


