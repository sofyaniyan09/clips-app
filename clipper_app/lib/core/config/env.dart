import 'package:flutter/foundation.dart';

class Env {
  // Gunakan 10.0.2.2 jika menggunakan Android Emulator, 
  // atau 127.0.0.1/localhost jika menggunakan Chrome/iOS Simulator.
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    } else {
      return 'http://127.0.0.1:8000';
    }
  }
}
