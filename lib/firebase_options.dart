import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA85oDeZSLdi1PNM2mM060owQfucVOn1X8',
    appId: '1:557963377518:web:5dee3cb34393c4d8541f7f',
    messagingSenderId: '557963377518',
    projectId: 'gsthethird-1f244',
    authDomain: 'gsthethird-1f244.firebaseapp.com',
    databaseURL: 'https://gsthethird-1f244-default-rtdb.firebaseio.com',
    storageBucket: 'gsthethird-1f244.appspot.com',
    measurementId: 'G-6TJGPJXZ4Q',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCS0DTQhwu5ty8b38Gmmpr-ynVOl01lxOs',
    appId: '1:557963377518:android:5a34444496fcf058541f7f',
    messagingSenderId: '557963377518',
    projectId: 'gsthethird-1f244',
    databaseURL: 'https://gsthethird-1f244-default-rtdb.firebaseio.com',
    storageBucket: 'gsthethird-1f244.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBUlJdJ_fBRIgfT4QuV5_jSaWwyKJDRHNk',
    appId: '1:557963377518:ios:481b1f1c303ffc50541f7f',
    messagingSenderId: '557963377518',
    projectId: 'gsthethird-1f244',
    databaseURL: 'https://gsthethird-1f244-default-rtdb.firebaseio.com',
    storageBucket: 'gsthethird-1f244.appspot.com',
    iosBundleId: 'com.example.milkshake',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA85oDeZSLdi1PNM2mM060owQfucVOn1X8',
    appId: '1:557963377518:web:ba2dd1ba03828807541f7f',
    messagingSenderId: '557963377518',
    projectId: 'gsthethird-1f244',
    authDomain: 'gsthethird-1f244.firebaseapp.com',
    databaseURL: 'https://gsthethird-1f244-default-rtdb.firebaseio.com',
    storageBucket: 'gsthethird-1f244.appspot.com',
    measurementId: 'G-M7CD3FRXF2',
  );
}
