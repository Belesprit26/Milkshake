import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'di/locator.dart';
import 'firebase_options.dart';
import 'presentation/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await setupLocator();
  runApp(const App());
}
