import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;

/// API configuration for backend server
class ApiConfig {
  // Cloud Run production URL
  static const String _cloudRunBaseUrl =
      'https://support-ticket-backend-312841481940.asia-south1.run.app/api';

  // Local development URLs (currently pointing Android to production backend
  // so that emulator/physical devices can hit the Cloud Run API)
  static const String _localWebUrl = 'http://localhost:8080/api';
  static const String _localAndroidUrl =
      'https://support-ticket-backend-312841481940.asia-south1.run.app/api';

  /// Automatically picks the correct backend
  static String get baseUrl {
    if (kReleaseMode) {
      // ✅ Production (Google Cloud Run)
      return _cloudRunBaseUrl;
    }

    // ✅ Local development
    if (kIsWeb) {
      return _localWebUrl;
    } else {
      return _localAndroidUrl;
    }
  }
}
