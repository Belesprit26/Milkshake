import 'package:get_it/get_it.dart';

import 'register_data.dart';
import 'register_domain.dart';
import 'register_presentation.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupLocator() async {
  registerDomain(getIt);
  await registerData(getIt);
  registerPresentation(getIt);
}


