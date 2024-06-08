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
    apiKey: 'AIzaSyBwFyxUYLjgLb9tBPZlLLw9dOfDKNA6rS0',
    appId: '1:349104298564:web:ab62c00fdf31c6b2e0ba11',
    messagingSenderId: '349104298564',
    projectId: 'vehiclerentingproject',
    authDomain: 'vehiclerentingproject.firebaseapp.com',
    storageBucket: 'vehiclerentingproject.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBAQanbszFZ5an3HLzqial47_OJcAQh8yE',
    appId: '1:349104298564:android:ba9faa43faa5ab5fe0ba11',
    messagingSenderId: '349104298564',
    projectId: 'vehiclerentingproject',
    storageBucket: 'vehiclerentingproject.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAaNIhh2HDP1xWORZdDFvl7w-7Au60D-jM',
    appId: '1:349104298564:ios:1b3a323e5857014ee0ba11',
    messagingSenderId: '349104298564',
    projectId: 'vehiclerentingproject',
    storageBucket: 'vehiclerentingproject.appspot.com',
    iosBundleId: 'com.example.vehiclerent',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAaNIhh2HDP1xWORZdDFvl7w-7Au60D-jM',
    appId: '1:349104298564:ios:1b3a323e5857014ee0ba11',
    messagingSenderId: '349104298564',
    projectId: 'vehiclerentingproject',
    storageBucket: 'vehiclerentingproject.appspot.com',
    iosBundleId: 'com.example.vehiclerent',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBwFyxUYLjgLb9tBPZlLLw9dOfDKNA6rS0',
    appId: '1:349104298564:web:df372828105d51dde0ba11',
    messagingSenderId: '349104298564',
    projectId: 'vehiclerentingproject',
    authDomain: 'vehiclerentingproject.firebaseapp.com',
    storageBucket: 'vehiclerentingproject.appspot.com',
  );
}
