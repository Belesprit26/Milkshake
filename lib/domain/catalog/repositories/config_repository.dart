import '../../../core/result/result.dart';
import '../entities/config_snapshot.dart';

abstract class ConfigRepository {
  Future<Result<ConfigSnapshot>> getCurrentConfig();

  Future<Result<int>> getCurrentConfigUpdatedAtMillis();

  Future<Result<void>> updateCurrentConfig({
    int? vatPercent,
    int? maxDrinks,
    int? baseDrinkPriceCents,
    required String actorUid,
  });
}


