import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/error/failure.dart';
import '../../../core/money/money.dart';
import '../../../core/result/result.dart';
import '../../../domain/catalog/entities/lookup_item.dart';
import '../../../domain/catalog/entities/lookup_item_snapshot.dart';
import '../../../domain/catalog/entities/lookup_type.dart';
import '../../../domain/catalog/repositories/catalog_repository.dart';

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

  @override
  Future<Result<List<LookupItem>>> listLookups(LookupType type) async {
    try {
      final typeStr = _typeToString(type);
      final q = await _firestore
          .collection('lookups')
          .where('type', isEqualTo: typeStr)
          .get();

      final items = <LookupItem>[];
      for (final doc in q.docs) {
        final data = doc.data();
        final name = (data['name'] ?? '').toString();
        if (name.trim().isEmpty) continue;
        final cents = _readInt(data['priceDeltaCents'], fallback: 0);
        final active = data['active'] == true;
        final ts = data['updatedAt'] ?? data['seededAt'];
        final updatedAtMillis = ts is Timestamp ? ts.millisecondsSinceEpoch : 0;
        items.add(
          LookupItem(
            id: doc.id,
            type: type,
            name: name,
            priceDelta: Money(cents),
            active: active,
            updatedAtMillis: updatedAtMillis,
          ),
        );
      }
      return Ok(items);
    } catch (e) {
      return Err(UnexpectedFailure('Failed to load lookups: $e'));
    }
  }

  @override
  Future<Result<LookupItem>> createLookup({
    required LookupType type,
    required String name,
    required int priceDeltaCents,
    required String actorUid,
  }) async {
    try {
      final typeStr = _typeToString(type);
      final ref = _firestore.collection('lookups').doc();
      final now = FieldValue.serverTimestamp();

      await _firestore.runTransaction((tx) async {
        tx.set(ref, {
          'type': typeStr,
          'name': name,
          'priceDeltaCents': priceDeltaCents,
          'active': true,
          'createdAt': now,
          'updatedAt': now,
        });

        final auditRef = _firestore.collection('audit_events').doc();
        tx.set(auditRef, {
          'entityType': 'lookup',
          'entityId': ref.id,
          'action': 'create',
          'actorUid': actorUid,
          'at': now,
          'before': null,
          'after': {
            'type': typeStr,
            'name': name,
            'priceDeltaCents': priceDeltaCents,
            'active': true,
          },
        });
      });

      return Ok(
        LookupItem(
          id: ref.id,
          type: type,
          name: name,
          priceDelta: Money(priceDeltaCents),
          active: true,
          updatedAtMillis: 0,
        ),
      );
    } catch (e) {
      return Err(UnexpectedFailure('Failed to create lookup: $e'));
    }
  }

  @override
  Future<Result<LookupItem>> updateLookup({
    required String id,
    required LookupType type,
    required String name,
    required int priceDeltaCents,
    required bool active,
    required String actorUid,
  }) async {
    try {
      final typeStr = _typeToString(type);
      final ref = _firestore.collection('lookups').doc(id);
      final now = FieldValue.serverTimestamp();

      await _firestore.runTransaction((tx) async {
        final snap = await tx.get(ref);
        final before = snap.data();
        tx.set(
          ref,
          {
            'type': typeStr,
            'name': name,
            'priceDeltaCents': priceDeltaCents,
            'active': active,
            'updatedAt': now,
          },
          SetOptions(merge: true),
        );

        final auditRef = _firestore.collection('audit_events').doc();
        tx.set(auditRef, {
          'entityType': 'lookup',
          'entityId': id,
          'action': 'update',
          'actorUid': actorUid,
          'at': now,
          'before': before,
          'after': {
            'type': typeStr,
            'name': name,
            'priceDeltaCents': priceDeltaCents,
            'active': active,
          },
        });
      });

      return Ok(
        LookupItem(
          id: id,
          type: type,
          name: name,
          priceDelta: Money(priceDeltaCents),
          active: active,
          updatedAtMillis: 0,
        ),
      );
    } catch (e) {
      return Err(UnexpectedFailure('Failed to update lookup: $e'));
    }
  }

  @override
  Future<Result<void>> deactivateLookup({
    required String id,
    required String actorUid,
  }) async {
    try {
      final ref = _firestore.collection('lookups').doc(id);
      final now = FieldValue.serverTimestamp();

      await _firestore.runTransaction((tx) async {
        final snap = await tx.get(ref);
        final before = snap.data();
        tx.set(
          ref,
          {
            'active': false,
            'updatedAt': now,
          },
          SetOptions(merge: true),
        );
        final auditRef = _firestore.collection('audit_events').doc();
        tx.set(auditRef, {
          'entityType': 'lookup',
          'entityId': id,
          'action': 'deactivate',
          'actorUid': actorUid,
          'at': now,
          'before': before,
          'after': {'active': false},
        });
      });
      return const Ok(null);
    } catch (e) {
      return Err(UnexpectedFailure('Failed to delete lookup: $e'));
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


