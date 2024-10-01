// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDgzJ2wF66Evl4k9saHSLGe7IrSUjx3Vg0',
    appId: '1:6204950858:android:239af212417755149399b3',
    messagingSenderId: '6204950858',
    projectId: 'vaccine-management-c7c9c',
    databaseURL: 'https://vaccine-management-c7c9c-default-rtdb.firebaseio.com',
    storageBucket: 'vaccine-management-c7c9c.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBDw6sfFv3U7lC1VFCKh2D5NC9v7dQ8MUU',
    appId: '1:6204950858:ios:15f12933038ca3c99399b3',
    messagingSenderId: '6204950858',
    projectId: 'vaccine-management-c7c9c',
    databaseURL: 'https://vaccine-management-c7c9c-default-rtdb.firebaseio.com',
    storageBucket: 'vaccine-management-c7c9c.appspot.com',
    iosBundleId: 'com.example.vaccination',
  );

}