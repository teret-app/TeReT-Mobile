import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Pravila privatnosti'),
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

                    const Text(
                      'Pravila privatnosti',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              sectionTitle('1. Prikupljanje podataka'),

              sectionText(
                'TeReT prikuplja osnovne podatke korisnika potrebne za korištenje platforme, uključujući ime i prezime, broj telefona, email adresu te podatke o prijevozu i objavljenim teretima.',
              ),

              sectionTitle('2. Korištenje podataka'),

              sectionText(
                'Prikupljeni podaci koriste se isključivo za omogućavanje komunikacije između naručitelja prijevoza i prijevoznika te za funkcioniranje platforme.',
              ),

              sectionTitle('3. Dijeljenje podataka'),

              sectionText(
                'Kontakt podaci korisnika nisu javno dostupni. Podaci se otključavaju tek nakon prihvaćanja ponude i uspješne naplate platforme.',
              ),

              sectionTitle('4. Sigurnost podataka'),

              sectionText(
                'TeReT poduzima razumne tehničke i organizacijske mjere kako bi zaštitio korisničke podatke od neovlaštenog pristupa, gubitka ili zlouporabe.',
              ),

              sectionTitle('5. Email verifikacija'),

              sectionText(
                'Radi sigurnosti i zaštite korisnika, TeReT koristi verifikaciju email adrese prilikom registracije računa.',
              ),

              sectionTitle('6. Kolačići i tehnički podaci'),

              sectionText(
                'Aplikacija može prikupljati tehničke podatke potrebne za rad sustava, sigurnost i poboljšanje korisničkog iskustva.',
              ),

              sectionTitle('7. Prava korisnika'),

              sectionText(
                'Korisnici imaju pravo zatražiti izmjenu ili brisanje svojih podataka u skladu s važećim zakonima i pravilima zaštite privatnosti.',
              ),

              sectionTitle('8. Kontakt'),

              sectionText(
                'Za sva pitanja vezana uz privatnost i zaštitu podataka korisnici se mogu obratiti putem kontakt opcije unutar aplikacije.',
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}