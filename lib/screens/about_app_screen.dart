import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  Widget infoCard({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.withValues(
              alpha: 0.10,
            ),
            child: Icon(
              icon,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
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
          l10n.aboutAppTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/logo_login3.png',
                      height: 130,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'TeReT',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.aboutAppDescription,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.45,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              infoCard(
                icon: Icons.local_shipping_outlined,
                title: l10n.aboutAppPurposeTitle,
                text: l10n.aboutAppPurposeText,
              ),
              infoCard(
                icon: Icons.gavel_outlined,
                title: l10n.aboutAppAuctionTitle,
                text: l10n.aboutAppAuctionText,
              ),
              infoCard(
                icon: Icons.lock_outline,
                title: l10n.aboutAppContactProtectionTitle,
                text: l10n.aboutAppContactProtectionText,
              ),
              infoCard(
                icon: Icons.security_outlined,
                title: l10n.aboutAppPrivacyTitle,
                text: l10n.aboutAppPrivacyText,
              ),
              infoCard(
                icon: Icons.support_agent_outlined,
                title: l10n.aboutAppSupportTitle,
                text: l10n.aboutAppSupportText,
              ),
              infoCard(
                icon: Icons.verified_outlined,
                title: l10n.aboutAppVersionTitle,
                text: l10n.aboutAppVersionText,
              ),
              const SizedBox(height: 18),
              Text(
                '© M.E.G.S. HR',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}