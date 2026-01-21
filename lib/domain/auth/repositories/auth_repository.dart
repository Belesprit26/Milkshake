import '../../../core/result/result.dart';
import '../entities/auth_user.dart';

abstract class AuthRepository {
  Stream<AuthUser?> authStateChanges();
  AuthUser? currentUser();

  Future<Result<String?>> getRole();

  Future<Result<AuthUser>> signInWithEmailPassword({
    required String email,
    required String password,
  });

  Future<Result<AuthUser>> signUpWithEmailPassword({
    required String email,
    required String password,
  });

  Future<Result<void>> signOut();
}


