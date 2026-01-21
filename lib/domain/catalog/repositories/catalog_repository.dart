import '../../../core/result/result.dart';
import '../entities/lookup_item_snapshot.dart';
import '../entities/lookup_type.dart';

abstract class CatalogRepository {
  Future<Result<List<LookupItemSnapshot>>> getActiveLookups(LookupType type);
}


