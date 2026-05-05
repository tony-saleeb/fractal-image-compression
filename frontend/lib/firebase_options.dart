// File generated manually based on Firebase Console config
// Project: deepfract

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
    apiKey: 'AIzaSyDKlZlPkvn2o62OFig-BjKgiLMRqc0lF3s',
    appId: '1:292769921948:web:fb930135b8914732692659',
    messagingSenderId: '292769921948',
    projectId: 'deepfract',
    authDomain: 'deepfract.firebaseapp.com',
    storageBucket: 'deepfract.firebasestorage.app',
    measurementId: 'G-6M2R0GXKB4',
  );

  // Android config from google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA49V5UJgOuraUYNF5qVgl1a2_CuZ3EHE4',
    appId: '1:292769921948:android:bc45977485373122692659',
    messagingSenderId: '292769921948',
    projectId: 'deepfract',
    storageBucket: 'deepfract.firebasestorage.app',
  );

  // iOS configuration (Placeholder until Firebase CLI reconfiguration)
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDKlZlPkvn2o62OFig-BjKgiLMRqc0lF3s',
    appId: '1:292769921948:ios:fb930135b8914732692659',
    messagingSenderId: '292769921948',
    projectId: 'deepfract',
    storageBucket: 'deepfract.firebasestorage.app',
    iosBundleId: 'com.example.deepfract',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDKlZlPkvn2o62OFig-BjKgiLMRqc0lF3s',
    appId: '1:292769921948:web:fb930135b8914732692659',
    messagingSenderId: '292769921948',
    projectId: 'deepfract',
    storageBucket: 'deepfract.firebasestorage.app',
    iosBundleId: 'com.tony.deepfract',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDKlZlPkvn2o62OFig-BjKgiLMRqc0lF3s',
    appId: '1:292769921948:web:fb930135b8914732692659',
    messagingSenderId: '292769921948',
    projectId: 'deepfract',
    storageBucket: 'deepfract.firebasestorage.app',
  );
}
