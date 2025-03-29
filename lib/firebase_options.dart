import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
      apiKey: "AIzaSyBfvGHqRNZVX4Mv9txkKSJufQ-mKN4HOGg",
      authDomain: "milvertonrealty-9d49f.firebaseapp.com",
      databaseURL: "https://milvertonrealty-9d49f-default-rtdb.firebaseio.com",
      projectId: "milvertonrealty-9d49f",
      storageBucket: "milvertonrealty-9d49f.firebasestorage.app",
      messagingSenderId: "694303179751",
      appId: "1:694303179751:web:c0be8a43e1251b9cb2b342",
      measurementId: "G-6CB5NNHVL7"
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBKYDJsXUAJwjunPc3_CDcjrzrvnwKBgjI',
    appId: '1:694303179751:android:8d7c23d669e7b69fb2b342',
    messagingSenderId: '694303179751',
    projectId: 'milvertonrealty-9d49f',
    storageBucket: 'milvertonrealty-9d49f.firebasestorage.app',

  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBQV9ONdu7-Tm0azlmkdFMZ_SAGgNriBLI',
    appId: '1:302704940049:ios:7b62511acd1287b156cdb0',
    messagingSenderId: '302704940049',
    projectId: 'reapp-d4d07',
    storageBucket: 'reapp-d4d07.appspot.com',
    iosBundleId: 'com.example.myApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBQV9ONdu7-Tm0azlmkdFMZ_SAGgNriBLI',
    appId: '1:302704940049:ios:6d3039219031aacf56cdb0',
    messagingSenderId: '302704940049',
    projectId: 'reapp-d4d07',
    storageBucket: 'reapp-d4d07.appspot.com',
    iosBundleId: 'com.example.myApp.RunnerTests',
  );
}
