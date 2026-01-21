import '../../../core/result/result.dart';
import '../entities/config_snapshot.dart';

abstract class ConfigRepository {
  Future<Result<ConfigSnapshot>> getCurrentConfig();
}


