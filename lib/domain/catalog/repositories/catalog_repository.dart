import '../../../core/result/result.dart';
import '../entities/lookup_item.dart';
import '../entities/lookup_item_snapshot.dart';
import '../entities/lookup_type.dart';

abstract class CatalogRepository {
  Future<Result<List<LookupItemSnapshot>>> getActiveLookups(LookupType type);

  Future<Result<List<LookupItem>>> listLookups(LookupType type);

  Future<Result<LookupItem>> createLookup({
    required LookupType type,
    required String name,
    required int priceDeltaCents,
    required String actorUid,
  });

  Future<Result<LookupItem>> updateLookup({
    required String id,
    required LookupType type,
    required String name,
    required int priceDeltaCents,
    required bool active,
    required String actorUid,
  });

  Future<Result<void>> deactivateLookup({
    required String id,
    required String actorUid,
  });
}


