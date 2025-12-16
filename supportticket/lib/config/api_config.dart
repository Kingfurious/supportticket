import 'package:flutter/foundation.dart' show kIsWeb;

/// API configuration for backend server
class ApiConfig {
  // IMPORTANT: Update this URL based on your environment
  // 
  // For Android Emulator:
  // static const String baseUrl = 'http://10.0.2.2:3000/api';
  //
  // For iOS Simulator / Flutter Web:
  // static const String baseUrl = 'http://localhost:3000/api';
  //
  // For Physical Device (replace with your computer's IP address):
  // static const String baseUrl = 'http://192.168.1.100:3000/api';
  //
  // For Production:
  // static const String baseUrl = 'https://your-api-domain.com/api';
  
  // Automatically use localhost for web, otherwise use Android emulator address
  static const String baseUrl = kIsWeb 
      ? 'http://localhost:3000/api'  // Flutter Web uses localhost
      : 'http://10.0.2.2:3000/api';  // Android Emulator default
}

