import '../../../core/result/result.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class SignUpWithEmailPassword {
  const SignUpWithEmailPassword(this._repo);
  final AuthRepository _repo;

  Future<Result<AuthUser>> call({
    required String email,
    required String password,
  }) {
    return _repo.signUpWithEmailPassword(email: email, password: password);
  }
}


