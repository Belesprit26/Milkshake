import 'package:get_it/get_it.dart';

import 'register_data.dart';
import 'register_domain.dart';
import 'register_presentation.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupLocator() async {
  // Keep registrations in strict order:
  // - Domain (use cases)
  // - Data (repo implementations, datasources)
  // - Presentation (Blocs, controllers)
  registerDomain(getIt);
  await registerData(getIt);
  registerPresentation(getIt);
}


