import '../../../core/result/result.dart';
import '../entities/user_profile.dart';

abstract class UserProfileRepository {
  Future<Result<void>> upsertProfile(UserProfile profile);
}


