import '../../../core/result/result.dart';
import '../entities/lookup_item_snapshot.dart';
import '../entities/lookup_type.dart';
import '../repositories/catalog_repository.dart';

class GetActiveLookups {
  const GetActiveLookups(this._repo);

  final CatalogRepository _repo;

  Future<Result<List<LookupItemSnapshot>>> call(LookupType type) =>
      _repo.getActiveLookups(type);
}


