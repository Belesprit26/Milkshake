import 'package:get_it/get_it.dart';

import '../domain/auth/repositories/auth_repository.dart';
import '../domain/auth/usecases/sign_in_with_email_password.dart';
import '../domain/auth/usecases/sign_out.dart';
import '../domain/auth/usecases/sign_up_with_email_password.dart';
import '../domain/catalog/repositories/catalog_repository.dart';
import '../domain/catalog/repositories/config_repository.dart';
import '../domain/catalog/usecases/get_active_lookups.dart';
import '../domain/catalog/usecases/get_current_config.dart';
import '../domain/orders/usecases/calculate_order_totals.dart';
import '../domain/users/repositories/user_profile_repository.dart';
import '../domain/users/usecases/upsert_user_profile.dart';

void registerDomain(GetIt getIt) {
  getIt.registerLazySingleton<CalculateOrderTotals>(() => const CalculateOrderTotals());

  getIt.registerLazySingleton<GetCurrentConfig>(
    () => GetCurrentConfig(getIt<ConfigRepository>()),
  );
  getIt.registerLazySingleton<GetActiveLookups>(
    () => GetActiveLookups(getIt<CatalogRepository>()),
  );

  getIt.registerLazySingleton<SignInWithEmailPassword>(
    () => SignInWithEmailPassword(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<SignUpWithEmailPassword>(
    () => SignUpWithEmailPassword(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<SignOut>(
    () => SignOut(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<UpsertUserProfile>(
    () => UpsertUserProfile(getIt<UserProfileRepository>()),
  );
}


