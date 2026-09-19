import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    throw UnsupportedError(
      'Firebase options are configured for the web target. '
      'Run flutterfire configure to add native platform options.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBJyJcfNvohFcLDFkXdBTaUaBcWM4Rxs7M',
    appId: '1:307973162720:web:3b3d5f9fb249654ba8b285',
    messagingSenderId: '307973162720',
    projectId: 'heathcare-management-e148a',
    authDomain: 'heathcare-management-e148a.firebaseapp.com',
    storageBucket: 'heathcare-management-e148a.firebasestorage.app',
    measurementId: 'G-8JHJ5NP08P',
  );
}
