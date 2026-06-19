import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/role_picker_screen.dart';
import 'screens/sender_home_screen.dart';
import 'screens/carrier_setup_screen.dart';

class LoadRunnerApp extends StatelessWidget {
  const LoadRunnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LoadRunner',
      initialRoute: '/login',
      routes: {
  '/login': (_) => const LoginScreen(),
  '/role': (_) => const RolePickerScreen(),
  '/sender': (_) => const SenderHomeScreen(),
  '/carrier': (_) => const CarrierSetupScreen(),
},
    );
  }
}