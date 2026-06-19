import 'package:flutter/material.dart';

import '../screens/login_screen.dart';
import 'token_storage.dart';

class LogoutHelper {
  static Future<void> logout(BuildContext context) async {
    await TokenStorage.clearAll();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }
}