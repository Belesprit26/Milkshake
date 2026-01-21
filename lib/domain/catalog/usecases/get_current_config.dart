import '../../../core/result/result.dart';
import '../entities/config_snapshot.dart';
import '../repositories/config_repository.dart';

class GetCurrentConfig {
  const GetCurrentConfig(this._repo);

  final ConfigRepository _repo;

  Future<Result<ConfigSnapshot>> call() => _repo.getCurrentConfig();
}


