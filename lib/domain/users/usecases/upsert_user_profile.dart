import '../../../core/result/result.dart';
import '../entities/user_profile.dart';
import '../repositories/user_profile_repository.dart';

class UpsertUserProfile {
  const UpsertUserProfile(this._repo);
  final UserProfileRepository _repo;

  Future<Result<void>> call(UserProfile profile) => _repo.upsertProfile(profile);
}


