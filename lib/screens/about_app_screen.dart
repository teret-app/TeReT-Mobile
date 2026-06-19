import 'package:flutter/material.dart';

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
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.withValues(alpha: 0.10),
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
          'Info',
          style: TextStyle(fontWeight: FontWeight.w700),
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
                  border: Border.all(color: Colors.grey.shade300),
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
                    const Text(
                      'Digitalna platforma za objavu tereta, slanje ponuda i jednostavniji dogovor prijevoza.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
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
                title: 'Svrha aplikacije',
                text:
                'TeReT povezuje naručitelje prijevoza i prijevoznike na jednom mjestu. Naručitelj objavljuje teret, a prijevoznici šalju svoje ponude.',
              ),
              infoCard(
                icon: Icons.gavel_outlined,
                title: 'Licitacija prijevoza',
                text:
                'Prijevoznici mogu dati ponudu za objavljeni teret, a naručitelj bira ponudu koja mu najviše odgovara.',
              ),
              infoCard(
                icon: Icons.lock_outline,
                title: 'Zaštita kontakta',
                text:
                'Kontakt podaci nisu javno dostupni. Broj telefona i puni podaci prikazuju se tek nakon prihvaćanja ponude i otključavanja kontakta.',
              ),
              infoCard(
                icon: Icons.security_outlined,
                title: 'Sigurnost i privatnost',
                text:
                'Aplikacija je napravljena tako da štiti podatke korisnika i prikazuje samo informacije potrebne za dogovor prijevoza.',
              ),
              infoCard(
                icon: Icons.support_agent_outlined,
                title: 'Korisnička podrška',
                text:
                'Za pomoć, prijavu problema ili pitanja možete kontaktirati podršku na: teretmegs@gmail.com',
              ),
              infoCard(
                icon: Icons.verified_outlined,
                title: 'Verzija aplikacije',
                text: 'MVP verzija 1.0.0',
              ),
              const SizedBox(height: 18),
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