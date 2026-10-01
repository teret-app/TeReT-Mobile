import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import 'about_app_screen.dart';
import 'contact_support_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_screen.dart';

class LegalSettingsScreen extends StatelessWidget {
  final bool updateAvailable;

  const LegalSettingsScreen({
    super.key,
    this.updateAvailable = false,
  });
  Future<void> openPlayStore() async {
    final uri = Uri.parse(
      'https://play.google.com/store/apps/details?id=com.megs.teret',
    );

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }
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
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple.withValues(
            alpha: 0.1,
          ),
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text(
          l10n.legalSettingsTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (updateAvailable)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.orange.shade300,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dostupno je ažuriranje',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Dostupna je novija verzija TeReT aplikacije.',
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: openPlayStore,
                        icon: const Icon(Icons.system_update),
                        label: const Text('Ažuriraj'),
                      ),
                    ),
                  ],
                ),
              ),
            buildTile(
              icon: Icons.description_outlined,
              title: l10n.legalSettingsTermsTitle,
              subtitle: l10n.legalSettingsTermsSubtitle,
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
              title: l10n.legalSettingsPrivacyTitle,
              subtitle: l10n.legalSettingsPrivacySubtitle,
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
              title: l10n.legalSettingsContactTitle,
              subtitle: l10n.legalSettingsContactSubtitle,
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
              title: l10n.legalSettingsAboutTitle,
              subtitle: l10n.legalSettingsAboutSubtitle,
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