import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 24,
        bottom: 10,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget sectionText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        height: 1.6,
        color: Colors.black87,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          l10n.termsTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 18,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/logo_login3.png',
                      height: 170,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.termsTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              sectionTitle(l10n.termsGeneralTitle),
              sectionText(l10n.termsGeneralText),
              sectionTitle(l10n.termsPlatformRoleTitle),
              sectionText(l10n.termsPlatformRoleText),
              sectionTitle(l10n.termsFeeTitle),
              sectionText(l10n.termsFeeText),
              sectionTitle(l10n.termsUnlockContactTitle),
              sectionText(l10n.termsUnlockContactText),
              sectionTitle(l10n.termsRefundTitle),
              sectionText(l10n.termsRefundText),
              sectionTitle(l10n.termsCancellationTitle),
              sectionText(l10n.termsCancellationText),
              sectionTitle(l10n.termsTransportResponsibilityTitle),
              sectionText(l10n.termsTransportResponsibilityText),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}