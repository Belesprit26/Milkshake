import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/error/failure.dart';
import '../../../core/money/money.dart';
import '../../../core/result/result.dart';
import '../../../domain/catalog/entities/lookup_item_snapshot.dart';
import '../../../domain/catalog/entities/lookup_type.dart';
import '../../../domain/catalog/repositories/catalog_repository.dart';

/// Firestore-backed catalog/lookup repository.
///
/// Suggested collection: `lookups`
/// Fields per doc:
/// - type: "flavour" | "topping" | "consistency" | "store"
/// - name: string
/// - priceDeltaCents: number
/// - active: bool
class FirestoreCatalogRepository implements CatalogRepository {
  FirestoreCatalogRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<Result<List<LookupItemSnapshot>>> getActiveLookups(LookupType type) async {
    try {
      final typeStr = _typeToString(type);
      final q = await _firestore
          .collection('lookups')
          .where('type', isEqualTo: typeStr)
          .where('active', isEqualTo: true)
          .get();

      final items = <LookupItemSnapshot>[];
      for (final doc in q.docs) {
        final data = doc.data();
        final name = data['name'];
        if (name is! String || name.trim().isEmpty) continue;
        final cents = _readInt(data['priceDeltaCents'], fallback: 0);
        items.add(
          LookupItemSnapshot(
            id: doc.id,
            type: type,
            name: name,
            priceDelta: Money(cents),
          ),
        );
      }
      return Ok(items);
    } catch (e) {
      return Err(UnexpectedFailure('Failed to load lookups: $e'));
    }
  }

  String _typeToString(LookupType t) {
    return switch (t) {
      LookupType.flavour => 'flavour',
      LookupType.topping => 'topping',
      LookupType.consistency => 'consistency',
      LookupType.store => 'store',
    };
  }

  int _readInt(Object? value, {required int fallback}) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }
}


