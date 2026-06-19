import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../config.dart';
import '../services/token_storage.dart';
import 'login_screen.dart';
import 'my_shipments_screen.dart';
import 'notifications_screen.dart';
import 'legal_settings_screen.dart';
class SenderHomeScreen extends StatefulWidget {
  const SenderHomeScreen({super.key});

  @override
  State<SenderHomeScreen> createState() => _SenderHomeScreenState();
}

class _SenderHomeScreenState extends State<SenderHomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  int unreadCount = 0;
  Timer? notificationTimer;

  final TextEditingController nazivTeretaController = TextEditingController();
  final TextEditingController opisTeretaController = TextEditingController();

  final TextEditingController mjestoUtovaraController = TextEditingController();
  final TextEditingController adresaUtovaraController = TextEditingController();

  final TextEditingController mjestoIstovaraController = TextEditingController();
  final TextEditingController adresaIstovaraController = TextEditingController();

  final TextEditingController tezinaController = TextEditingController();
  final TextEditingController brojPaletaController = TextEditingController();

  final TextEditingController duzinaController = TextEditingController();
  final TextEditingController sirinaController = TextEditingController();
  final TextEditingController visinaController = TextEditingController();

  final TextEditingController katUtovaraController = TextEditingController();
  final TextEditingController brojTelefonaController = TextEditingController();

  String? odabranoTrajanjeLicitacije;
  String? odabraniRokPreuzimanja;
  String? odabraniNacinUtovara;
  String? odabraniTipLokacijeUtovara;
  String? odabraniTipLokacijeIstovara;

  bool prilazZaTegljac = false;
  bool trebaPomocVozaca = false;
  bool liftNaUtovaru = false;

  bool isLoading = false;

  List<XFile> odabraneSlike = [];

  final List<String> trajanjeLicitacijeOpcije = [
    '6 sati',
    '12 sati',
    '24 sata',
  ];

  final List<String> rokPreuzimanjaOpcije = [
    '24 sata',
    '48 sati',
    '72 sata',
    'Po dogovoru',
  ];

  final List<String> nacinUtovaraOpcije = ['Ručno', 'Strojno'];

  final List<String> tipLokacijeOpcije = [
    'Zgrada',
    'Proizvodni pogon',
    'Skladište',
    'Kuća',
  ];

  @override
  void initState() {
    super.initState();
    loadUnreadCount();

    notificationTimer = Timer.periodic(
      const Duration(seconds: 10),
          (_) => loadUnreadCount(),
    );
  }

  Future<void> loadUnreadCount() async {
    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) return;

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/notifications'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final count = data is List
            ? data.where((n) => n is Map && n['isRead'] == false).length
            : 0;

        if (!mounted) return;
        setState(() {
          unreadCount = count;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    notificationTimer?.cancel();

    nazivTeretaController.dispose();
    opisTeretaController.dispose();
    mjestoUtovaraController.dispose();
    adresaUtovaraController.dispose();
    mjestoIstovaraController.dispose();
    adresaIstovaraController.dispose();
    tezinaController.dispose();
    brojPaletaController.dispose();
    duzinaController.dispose();
    sirinaController.dispose();
    visinaController.dispose();
    katUtovaraController.dispose();
    brojTelefonaController.dispose();
    super.dispose();
  }

  Future<void> logout() async {
    await TokenStorage.clearAll();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  Future<void> otvoriGaleriju() async {
    if (odabraneSlike.length >= 5) {
      prikaziPoruku('Možete dodati maksimalno 5 slika.');
      return;
    }

    final List<XFile> slike = await _picker.pickMultiImage(imageQuality: 70);

    if (slike.isEmpty) return;

    final slobodnoMjesta = 5 - odabraneSlike.length;
    final zaDodati = slike.take(slobodnoMjesta).toList();

    setState(() {
      odabraneSlike.addAll(zaDodati);
    });

    if (slike.length > slobodnoMjesta) {
      prikaziPoruku('Dodano je samo prvih $slobodnoMjesta slika jer je maksimum 5.');
    }
  }

  Future<void> otvoriKameru() async {
    if (odabraneSlike.length >= 5) {
      prikaziPoruku('Možete dodati maksimalno 5 slika.');
      return;
    }

    final XFile? slika = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );

    if (slika == null) return;

    setState(() {
      odabraneSlike.add(slika);
    });
  }

  void ukloniSliku(int index) {
    setState(() {
      odabraneSlike.removeAt(index);
    });
  }

  Future<List<String>> pripremiSlikeBase64() async {
    final List<String> slikeBase64 = [];

    for (final slika in odabraneSlike) {
      final bytes = await File(slika.path).readAsBytes();
      slikeBase64.add(base64Encode(bytes));
    }

    return slikeBase64;
  }

  void prikaziPoruku(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  InputDecoration poljeDekoracija(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget buildImagePreview() {
    if (odabraneSlike.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Text(
          'Nema odabranih slika.',
          style: TextStyle(fontSize: 14),
        ),
      );
    }

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: odabraneSlike.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final slika = odabraneSlike[index];

          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(slika.path),
                  width: 130,
                  height: 110,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: InkWell(
                  onTap: () => ukloniSliku(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> objaviTeret() async {
    if (!_formKey.currentState!.validate()) return;

    if (odabranoTrajanjeLicitacije == null ||
        odabranoTrajanjeLicitacije!.trim().isEmpty) {
      prikaziPoruku('Odaberite trajanje licitacije.');
      return;
    }

    if (odabraniRokPreuzimanja == null ||
        odabraniRokPreuzimanja!.trim().isEmpty) {
      prikaziPoruku('Odaberite rok preuzimanja tereta.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final token = await TokenStorage.getToken();

      if (token == null || token.isEmpty) {
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
        );
        return;
      }

      final slikeBase64 = await pripremiSlikeBase64();

      final payload = {
        'naziv_tereta': nazivTeretaController.text.trim(),
        'opis_tereta': opisTeretaController.text.trim(),
        'mjesto_utovara': mjestoUtovaraController.text.trim(),
        'adresa_utovara': adresaUtovaraController.text.trim(),
        'mjesto_istovara': mjestoIstovaraController.text.trim(),
        'adresa_istovara': adresaIstovaraController.text.trim(),
        'trajanje_licitacije': odabranoTrajanjeLicitacije,
        'rok_preuzimanja': odabraniRokPreuzimanja,
        'tezina_kg': tezinaController.text.trim(),
        'broj_paleta': brojPaletaController.text.trim(),
        'duzina_cm': duzinaController.text.trim(),
        'sirina_cm': sirinaController.text.trim(),
        'visina_cm': visinaController.text.trim(),
        'nacin_utovara': odabraniNacinUtovara,
        'tip_lokacije_utovara': odabraniTipLokacijeUtovara,
        'tip_lokacije_istovara': odabraniTipLokacijeIstovara,
        'kat_utovara': katUtovaraController.text.trim(),
        'lift_na_utovaru': liftNaUtovaru,
        'prilaz_za_tegljac': prilazZaTegljac,
        'treba_pomoc_vozaca': trebaPomocVozaca,
        'broj_telefona': brojTelefonaController.text.trim(),
        'slike': slikeBase64,
      };

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/shipments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;

        prikaziPoruku('Teret je uspješno objavljen.');

        setState(() {
          nazivTeretaController.clear();
          opisTeretaController.clear();
          mjestoUtovaraController.clear();
          adresaUtovaraController.clear();
          mjestoIstovaraController.clear();
          adresaIstovaraController.clear();
          tezinaController.clear();
          brojPaletaController.clear();
          duzinaController.clear();
          sirinaController.clear();
          visinaController.clear();
          katUtovaraController.clear();
          brojTelefonaController.clear();

          odabranoTrajanjeLicitacije = null;
          odabraniRokPreuzimanja = null;
          odabraniNacinUtovara = null;
          odabraniTipLokacijeUtovara = null;
          odabraniTipLokacijeIstovara = null;

          prilazZaTegljac = false;
          trebaPomocVozaca = false;
          liftNaUtovaru = false;

          odabraneSlike = [];
        });
      } else if (response.statusCode == 401) {
        await TokenStorage.clearAll();
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
        );
      } else {
        prikaziPoruku(
          data is Map && data['message'] != null
              ? data['message'].toString()
              : 'Greška pri objavi tereta.',
        );
      }
    } catch (e) {
      prikaziPoruku('Greška konekcije sa serverom.');
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildTopActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: SizedBox(
        height: 52,
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 18),
          label: Text(
            label,
            textAlign: TextAlign.center,
          ),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildNotificationsButton() {
    return Expanded(
      child: SizedBox(
        height: 52,
        child: Stack(
          children: [
            Positioned.fill(
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  );
                  await loadUnreadCount();
                },
                icon: const Icon(Icons.notifications_none, size: 18),
                label: const Text(
                  'Pristigle ponude',
                  textAlign: TextAlign.center,
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 6,
                top: 5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Naručitelj prijevoza'),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LegalSettingsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.menu),
            label: const Text('Info'),
          ),
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  buildTopActionButton(
                    icon: Icons.list_alt_outlined,
                    label: 'Moje objave',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyShipmentsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  buildNotificationsButton(),
                ],
              ),
              const SizedBox(height: 18),
              Card(
                elevation: 1.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Brza objava tereta',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Unesite samo najvažnije podatke. Dodatne detalje možete dodati po želji.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      buildSectionTitle('Osnovno'),
                      TextFormField(
                        controller: nazivTeretaController,
                        decoration: poljeDekoracija('Naziv tereta'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Unesite naziv tereta.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: opisTeretaController,
                        maxLines: 3,
                        decoration: poljeDekoracija('Kratki opis tereta'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Unesite opis tereta.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      buildSectionTitle('Ruta'),
                      TextFormField(
                        controller: mjestoUtovaraController,
                        decoration: poljeDekoracija('Mjesto utovara'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Unesite mjesto utovara.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: adresaUtovaraController,
                        decoration: poljeDekoracija('Ulica i kućni broj utovara'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Unesite adresu utovara.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: mjestoIstovaraController,
                        decoration: poljeDekoracija('Mjesto istovara'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Unesite mjesto istovara.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: adresaIstovaraController,
                        decoration: poljeDekoracija('Ulica i kućni broj istovara'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Unesite adresu istovara.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      buildSectionTitle('Vrijeme i količina'),
                      DropdownButtonFormField<String>(
                        value: odabranoTrajanjeLicitacije,
                        decoration: poljeDekoracija('Trajanje licitacije'),
                        items: trajanjeLicitacijeOpcije
                            .map(
                              (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ),
                        )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            odabranoTrajanjeLicitacije = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Odaberite trajanje licitacije.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: odabraniRokPreuzimanja,
                        decoration: poljeDekoracija(
                          'Rok utovara nakon kraja licitacije',
                        ),
                        items: rokPreuzimanjaOpcije
                            .map(
                              (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ),
                        )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            odabraniRokPreuzimanja = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Odaberite rok preuzimanja tereta.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: tezinaController,
                        keyboardType: TextInputType.number,
                        decoration: poljeDekoracija('Težina (kg/lb)'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: brojPaletaController,
                        keyboardType: TextInputType.number,
                        decoration: poljeDekoracija('Broj paleta'),
                      ),
                      const SizedBox(height: 18),
                      buildSectionTitle('Kontakt'),
                      IntlPhoneField(
                        decoration: poljeDekoracija('Broj telefona'),
                        initialCountryCode: 'HR',
                        disableLengthCheck: true,
                        onChanged: (phone) {
                          brojTelefonaController.text = phone.completeNumber;
                        },
                        validator: (phone) {
                          if (phone == null || phone.number.trim().isEmpty) {
                            return 'Unesite broj telefona.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Text(
                          'Broj telefona prijevozniku neće biti vidljiv dok ne prihvatite ponudu.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        childrenPadding: EdgeInsets.zero,
                        title: const Text(
                          'Dodatni detalji (opcionalno)',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        children: [
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: odabraniTipLokacijeUtovara,
                            decoration: poljeDekoracija('Tip lokacije utovara'),
                            items: tipLokacijeOpcije
                                .map(
                                  (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ),
                            )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                odabraniTipLokacijeUtovara = value;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: odabraniTipLokacijeIstovara,
                            decoration: poljeDekoracija('Tip lokacije istovara'),
                            items: tipLokacijeOpcije
                                .map(
                                  (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ),
                            )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                odabraniTipLokacijeIstovara = value;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: odabraniNacinUtovara,
                            decoration: poljeDekoracija('Način utovara'),
                            items: nacinUtovaraOpcije
                                .map(
                                  (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ),
                            )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                odabraniNacinUtovara = value;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: katUtovaraController,
                            decoration: poljeDekoracija('Kat utovara'),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: duzinaController,
                                  keyboardType: TextInputType.number,
                                  decoration: poljeDekoracija('Dužina (cm/in)'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: sirinaController,
                                  keyboardType: TextInputType.number,
                                  decoration: poljeDekoracija('Širina (cm/in)'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: visinaController,
                            keyboardType: TextInputType.number,
                            decoration: poljeDekoracija('Visina (cm/in)'),
                          ),
                          const SizedBox(height: 8),
                          SwitchListTile(
                            value: liftNaUtovaru,
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Postoji lift na utovaru'),
                            onChanged: (value) {
                              setState(() {
                                liftNaUtovaru = value;
                              });
                            },
                          ),
                          SwitchListTile(
                            value: prilazZaTegljac,
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Prilaz za tegljač'),
                            onChanged: (value) {
                              setState(() {
                                prilazZaTegljac = value;
                              });
                            },
                          ),
                          SwitchListTile(
                            value: trebaPomocVozaca,
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Treba pomoć vozača'),
                            onChanged: (value) {
                              setState(() {
                                trebaPomocVozaca = value;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          buildSectionTitle('Slike tereta'),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: otvoriGaleriju,
                                  icon: const Icon(Icons.photo_library_outlined),
                                  label: const Text('Galerija'),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(48),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: otvoriKameru,
                                  icon: const Icon(Icons.photo_camera_outlined),
                                  label: const Text('Kamera'),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(48),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Odabrano slika: ${odabraneSlike.length}/5',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          buildImagePreview(),
                        ],
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : objaviTeret,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                              : const Text(
                            'Objavi teret',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}