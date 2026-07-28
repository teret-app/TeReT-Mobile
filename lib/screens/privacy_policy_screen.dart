import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 22,
        bottom: 10,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget sectionText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          height: 1.6,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(l10n.privacyTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
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
                      l10n.privacyTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              sectionTitle(l10n.privacySection1Title),
              sectionText(l10n.privacySection1Text),

              sectionTitle(l10n.privacySection2Title),
              sectionText(l10n.privacySection2Text),

              sectionTitle(l10n.privacySection3Title),
              sectionText(l10n.privacySection3Text),

              sectionTitle(l10n.privacySection4Title),
              sectionText(l10n.privacySection4Text),

              sectionTitle(l10n.privacySection5Title),
              sectionText(l10n.privacySection5Text),

              sectionTitle(l10n.privacySection6Title),
              sectionText(l10n.privacySection6Text),

              sectionTitle(l10n.privacySection7Title),
              sectionText(l10n.privacySection7Text),

              sectionTitle(l10n.privacySection8Title),
              sectionText(l10n.privacySection8Text),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}