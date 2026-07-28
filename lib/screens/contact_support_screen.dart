import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  Future<void> _sendSupportEmail(
      BuildContext context,
      ) async {
    final l10n = AppLocalizations.of(context)!;

    final uri = Uri(
      scheme: 'mailto',
      path: 'teretmegs@gmail.com',
      queryParameters: {
        'subject': l10n.contactSupportEmailSubject,
      },
    );

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

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
        borderRadius: BorderRadius.circular(16),
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
          l10n.contactSupportTitle,
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
              Image.asset(
                'assets/logo_login3.png',
                height: 150,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.contactSupportHeading,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.contactSupportDescription,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              InkWell(
                onTap: () => _sendSupportEmail(context),
                borderRadius: BorderRadius.circular(16),
                child: infoCard(
                  icon: Icons.email_outlined,
                  title: l10n.contactSupportEmailTitle,
                  text: 'teretmegs@gmail.com',
                ),
              ),
              infoCard(
                icon: Icons.schedule_outlined,
                title: l10n.contactSupportResponseTimeTitle,
                text: l10n.contactSupportResponseTimeText,
              ),
              infoCard(
                icon: Icons.info_outline,
                title: l10n.contactSupportMessageInfoTitle,
                text: l10n.contactSupportMessageInfoText,
              ),
              const SizedBox(height: 28),
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