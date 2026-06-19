import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Uvjeti korištenja',
          style: TextStyle(
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

                    const Text(
                      'Uvjeti korištenja',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              sectionTitle('1. Opće odredbe'),

              sectionText(
                'TeReT je digitalna platforma koja povezuje naručitelje prijevoza i prijevoznike. '
                    'TeReT ne sudjeluje u organizaciji niti izvršenju prijevoza, već omogućuje korisnicima međusobno povezivanje i dogovor.',
              ),

              sectionTitle('2. Uloga platforme'),

              sectionText(
                'TeReT nije prijevoznik niti špediter. TeReT ne djeluje kao ugovorna strana u prijevozu '
                    'te ne preuzima odgovornost za izvršenje prijevoza, kašnjenja, otkazivanja, štetu na robi '
                    'ili netočne podatke korisnika niti sporove između korisnika. '
                    'Svi dogovori o prijevozu sklapaju se isključivo između naručitelja i prijevoznika.',
              ),

              sectionTitle('3. Naknada za korištenje platforme'),

              sectionText(
                'Platforma TeReT potpuno je besplatna za korištenje i nema nikakve članarine ni kotizacije. '
                    'Naknada se plaća po zaključenom poslu, a to je u onom trenutku kad naručitelj prihvati ponudu prijevoznika. '
                    'Prijevoznik plaća naknadu u iznosu od 5% dogovorene cijene prijevoza.',
              ),

              sectionTitle('4. Otključavanje kontakt podataka'),

              sectionText(
                'Kontakt podaci naručitelja i prijevoznika dostupni su tek nakon uspješne naplate naknade putem Stripe sustava. '
                    'Nakon otključavanja kontakt podataka smatra se da je usluga platforme izvršena.',
              ),

              sectionTitle('5. Povrat naknade'),

              sectionText(
                'Nakon otključavanja kontakt podataka plaćena naknada se ne vraća. '
                    'Naknada se odnosi na uslugu povezivanja korisnika putem platforme TeReT, '
                    'neovisno o tome je li prijevoz kasnije realiziran.',
              ),

              sectionTitle('6. Otkazivanje prijevoza'),

              sectionText(
                'U slučaju otkazivanja prijevoza od strane naručitelja ili prijevoznika, '
                    'TeReT ne snosi nikakvu odgovornost. Korisnici su odgovorni za posljedice otkazivanja, '
                    'uključujući eventualne međusobne dogovore.',
              ),

              sectionTitle('7. Odgovornost za prijevoz'),

              sectionText(
                'Za izvršenje prijevoza, stanje robe, vrijeme isporuke i sve ostale detalje odgovorni su isključivo naručitelj i prijevoznik. '
                    'TeReT ne sudjeluje u prijevozu niti preuzima odgovornost za eventualnu štetu.',
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}