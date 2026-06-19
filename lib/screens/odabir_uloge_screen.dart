import 'package:flutter/material.dart';

import 'register_screen.dart';

class OdabirUlogeScreen extends StatelessWidget {
  const OdabirUlogeScreen({super.key});

  void _goToRegister(BuildContext context, String role) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterScreen(role: role),
      ),
    );
  }

  Widget _roleButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String role,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _goToRegister(context, role),
        icon: Icon(icon),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          textStyle: const TextStyle(fontSize: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Odabir uloge'),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                children: [
                  // ✅ LOGO
                  Image.asset(
                    'assets/logo_login3.png',
                    height: 180,
                  ),
                  const SizedBox(height: 24),

                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Text(
                            'Kako želite koristiti aplikaciju?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 30),

                          _roleButton(
                            context: context,
                            title: 'Naručitelj prijevoza',
                            icon: Icons.inventory_2,
                            role: 'sender',
                          ),

                          const SizedBox(height: 16),

                          _roleButton(
                            context: context,
                            title: 'Prijevoznik',
                            icon: Icons.local_shipping,
                            role: 'carrier',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}