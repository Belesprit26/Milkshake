import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../data/firebase/auth/firebase_auth_repository.dart';
import '../data/firebase/functions/firebase_payment_repository.dart';
import '../data/firebase/firestore/firestore_catalog_repository.dart';
import '../data/firebase/firestore/firestore_config_repository.dart';
import '../data/firebase/firestore/firestore_order_repository.dart';
import '../data/firebase/firestore/firestore_user_profile_repository.dart';
import '../domain/auth/repositories/auth_repository.dart';
import '../domain/catalog/repositories/catalog_repository.dart';
import '../domain/catalog/repositories/config_repository.dart';
import '../domain/orders/repositories/order_repository.dart';
import '../domain/payments/repositories/payment_repository.dart';
import '../domain/users/repositories/user_profile_repository.dart';

Future<void> registerData(GetIt getIt) async {
  getIt.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFunctions>(() => FirebaseFunctions.instance);

  getIt.registerLazySingleton<AuthRepository>(
    () => FirebaseAuthRepository(auth: getIt<FirebaseAuth>()),
  );

  getIt.registerLazySingleton<ConfigRepository>(
    () => FirestoreConfigRepository(firestore: getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<CatalogRepository>(
    () => FirestoreCatalogRepository(firestore: getIt<FirebaseFirestore>()),
  );

  getIt.registerLazySingleton<OrderRepository>(
    () => FirestoreOrderRepository(firestore: getIt<FirebaseFirestore>()),
  );

  getIt.registerLazySingleton<PaymentRepository>(
    () => FirebasePaymentRepository(functions: getIt<FirebaseFunctions>()),
  );

  getIt.registerLazySingleton<UserProfileRepository>(
    () => FirestoreUserProfileRepository(firestore: getIt<FirebaseFirestore>()),
  );
}


