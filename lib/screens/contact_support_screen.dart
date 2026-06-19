import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
Future<void> _sendSupportEmail() async {
  final uri = Uri(
    scheme: 'mailto',
    path: 'teretmegs@gmail.com',
    queryParameters: {
      'subject': 'Podrška - TeReT',
    },
  );

  await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  );
}
class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

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
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.withOpacity(0.10),
            child: Icon(icon, color: Colors.blue),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Korisnička podrška',
          style: TextStyle(fontWeight: FontWeight.w700),
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
              const Text(
                'Kontakt i podrška',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Za pitanja, probleme s računom ili prijavu poteškoća u radu aplikacije možete se obratiti podršci.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              InkWell(
                onTap: _sendSupportEmail,
                borderRadius: BorderRadius.circular(16),
                child: infoCard(
                  icon: Icons.email_outlined,
                  title: 'Email podrška',
                  text: 'teretmegs@gmail.com',
                ),
              ),

              infoCard(
                icon: Icons.schedule_outlined,
                title: 'Vrijeme odgovora',
                text: 'Na upite odgovaramo u najkraćem mogućem roku.',
              ),
              infoCard(
                icon: Icons.info_outline,
                title: 'Što navesti u poruci',
                text:
                'Kod prijave problema navedite email računa, opis problema i po mogućnosti screenshot greške.',
              ),
              const SizedBox(height: 28),
              Text(
                '© M.E.G.S. EU',
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