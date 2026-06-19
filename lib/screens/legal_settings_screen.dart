import 'package:flutter/material.dart';

import 'about_app_screen.dart';
import 'contact_support_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_screen.dart';

class LegalSettingsScreen extends StatelessWidget {
  const LegalSettingsScreen({super.key});

  Widget buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required BuildContext context,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple.withValues(alpha: 0.1),
          child: Icon(
            icon,
            color: Colors.deepPurple,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Postavke i informacije',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            buildTile(
              icon: Icons.description_outlined,
              title: 'Uvjeti korištenja',
              subtitle: 'Pravila korištenja platforme TeReT',
              context: context,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TermsScreen(),
                  ),
                );
              },
            ),
            buildTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Pravila privatnosti',
              subtitle: 'Zaštita i obrada podataka korisnika',
              context: context,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PrivacyPolicyScreen(),
                  ),
                );
              },
            ),
            buildTile(
              icon: Icons.mail_outline,
              title: 'Kontakt',
              subtitle: 'Kontakt informacije i podrška',
              context: context,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ContactSupportScreen(),
                  ),
                );
              },
            ),
            buildTile(
              icon: Icons.info_outline,
              title: 'O aplikaciji',
              subtitle: 'Informacije o TeReT aplikaciji',
              context: context,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AboutAppScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            const Center(
              child: Text(
                '© M.E.G.S. HR',
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}