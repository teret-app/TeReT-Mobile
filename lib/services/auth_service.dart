import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config.dart';
import 'token_storage.dart';

class AuthService {
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email.trim(),
          'password': password.trim(),
          'role': role,
        }),
      );

      print('LOGIN URL: ${AppConfig.baseUrl}/login');
      print('LOGIN STATUS: ${response.statusCode}');
      print('LOGIN BODY: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['token'] != null) {
          await TokenStorage.saveToken(data['token']);
        }

        return {
          'success': true,
          'data': data,
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Prijava nije uspjela',
      };
    } catch (e) {
      print('LOGIN ERROR: $e');

      return {
        'success': false,
        'message': 'Greška konekcije sa serverom',
      };
    }
  }

  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String role,
    String? fullName,
    String? phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fullName': fullName?.trim() ?? '',
          'email': email.trim(),
          'phone': phone?.trim() ?? '',
          'password': password.trim(),
          'role': role,
        }),
      );

      print('REGISTER URL: ${AppConfig.baseUrl}/register');
      print('REGISTER STATUS: ${response.statusCode}');
      print('REGISTER BODY: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': data,
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Registracija nije uspjela',
      };
    } catch (e) {
      print('REGISTER ERROR: $e');

      return {
        'success': false,
        'message': 'Greška konekcije sa serverom',
      };
    }
  }

  static Future<void> logout() async {
    await TokenStorage.clearToken();
  }
}