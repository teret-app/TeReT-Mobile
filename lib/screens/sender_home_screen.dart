import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../config.dart';
import '../utils/country_helper.dart';
import '../utils/phone_country_helper.dart';
import '../services/token_storage.dart';
import 'login_screen.dart';
import 'my_shipments_screen.dart';
import 'notifications_screen.dart';
import 'legal_settings_screen.dart';
import '../l10n/app_localizations.dart';
class SenderHomeScreen extends StatefulWidget {
  const SenderHomeScreen({super.key});

  @override
  State<SenderHomeScreen> createState() => _SenderHomeScreenState();
}
bool containsForbiddenContactInfo(String text) {
  final pattern = RegExp(
    r'(\+?\d[\d\s\-\/().]{6,}\d)|([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})|(whatsapp|viber|telegram|signal|messenger|facebook|instagram|gmail|mail|email|e-mail|nazovi|zovi|javi se|kontaktiraj|kontakt|mobitel|telefon|broj)',
    caseSensitive: false,
  );

  return pattern.hasMatch(text);
}
class _SenderHomeScreenState extends State<SenderHomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  int unreadCount = 0;
  Timer? notificationTimer;
  bool notificationsEnabled = true;
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
  final TextEditingController katIstovaraController = TextEditingController();
  final TextEditingController brojTelefonaController = TextEditingController();
  PhoneCountryOption selectedPhoneCountry = phoneCountryOptions.first;

  void capitalizeFirstLetter(
      String value,
      TextEditingController controller,
      ) {
    if (value.isEmpty) return;

    final firstNonSpace = value.indexOf(RegExp(r'\S'));

    if (firstNonSpace == -1) return;

    final newText =
        value.substring(0, firstNonSpace) +
            value[firstNonSpace].toUpperCase() +
            value.substring(firstNonSpace + 1);

    if (newText != value) {
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: newText.length,
        ),
      );
    }
  }

  String? odabranoTrajanjeLicitacije;
  String? odabraniRokPreuzimanja;
  String? odabraniNacinUtovara;
  String? odabraniTipLokacijeUtovara;
  String? odabraniTipLokacijeIstovara;
  late String odabranaDrzavaUtovara;
  late String odabranaDrzavaIstovara;
  bool prilazZaTegljac = false;
  bool trebaPomocVozaca = false;
  bool liftNaUtovaru = false;
  bool liftNaIstovaru = false;
  bool isLoading = false;

  List<XFile> odabraneSlike = [];

  final List<String> trajanjeLicitacijeOpcije = [
    '1 sat',
    '2 sata',
    '6 sati',
    '12 sati',
    '24 sata',
    '48 sati',
    '72 sata',
    '7 dana',
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
    'Gradilište',
    'Poslovni prostor',
  ];

  @override
  void initState() {
    super.initState();
    final countries = countryOptionsForDevice();

    odabranaDrzavaUtovara = countries.first.name;
    odabranaDrzavaIstovara = countries.first.name;


    loadUnreadCount();
    checkNotificationPermission();

    notificationTimer = Timer.periodic(
      const Duration(seconds: 10),
          (_) => loadUnreadCount(),
    );
  }
  Future<void> checkNotificationPermission() async {
    if (kIsWeb) return;

    final status = await Permission.notification.status;

    if (!mounted) return;

    setState(() {
      notificationsEnabled = status.isGranted;
    });
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
    katIstovaraController.dispose();
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
  Widget buildCountryDropdown({
    required String label,
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: poljeDekoracija(label),
      items: countryOptionsForDevice().map((country) {
        return DropdownMenuItem<String>(
          value: country.name,
          child: Text(
            '${country.flag} ${country.localizedName(
              Localizations.localeOf(context).languageCode,
            )}',
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
  Widget buildImagePreview() {
    final l10n = AppLocalizations.of(context)!;
    if (odabraneSlike.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          l10n.noImagesSelected,
          style: const TextStyle(fontSize: 14),
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
    debugPrint('KLIK NA PUBLISH SHIPMENT');

    final formIsValid =
        _formKey.currentState?.validate() ?? false;

    debugPrint('FORMA ISPRAVNA: $formIsValid');

    if (!formIsValid) {
      prikaziPoruku(
        AppLocalizations.of(context)!.checkShipmentData,
      );
      return;
    }

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
        'drzava_utovara': odabranaDrzavaUtovara,
        'mjesto_utovara': mjestoUtovaraController.text.trim(),
        'adresa_utovara': adresaUtovaraController.text.trim(),

        'drzava_istovara': odabranaDrzavaIstovara,
        'mjesto_istovara': mjestoIstovaraController.text.trim(),
        'adresa_istovara': adresaIstovaraController.text.trim(),
        'trajanje_licitacije': odabranoTrajanjeLicitacije,
        'rok_preuzimanja': odabraniRokPreuzimanja,
        'tezina_cca_kg': tezinaController.text.trim(),
        'broj_paleta': brojPaletaController.text.trim(),
        'duzina_cm': duzinaController.text.trim(),
        'sirina_cm': sirinaController.text.trim(),
        'visina_cm': visinaController.text.trim(),
        'nacin_utovara': odabraniNacinUtovara,
        'tip_lokacije_utovara': odabraniTipLokacijeUtovara,
        'tip_lokacije_istovara': odabraniTipLokacijeIstovara,
        'kat_utovara': katUtovaraController.text.trim(),
        'lift_na_utovaru': liftNaUtovaru,
        'lift_na_istovaru': liftNaIstovaru,
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

      dynamic data;

      try {
        data = response.body.trim().isNotEmpty
            ? jsonDecode(response.body)
            : null;
      } catch (_) {
        debugPrint('STATUS OBJAVE: ${response.statusCode}');
        debugPrint('ODGOVOR OBJAVE: ${response.body}');

        data = null;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;

        final l10n = AppLocalizations.of(context)!;

        prikaziPoruku(
          l10n.shipmentPublishedSuccessMessage,
        );

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
          katIstovaraController.clear();
          brojTelefonaController.clear();

          odabranoTrajanjeLicitacije = null;
          odabraniRokPreuzimanja = null;
          odabraniNacinUtovara = null;
          odabraniTipLokacijeUtovara = null;
          odabraniTipLokacijeIstovara = null;

          late String odabranaDrzavaUtovara;
          late String odabranaDrzavaIstovara;

          prilazZaTegljac = false;
          trebaPomocVozaca = false;
          liftNaUtovaru = false;
          liftNaIstovaru = false;
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
    } catch (e, stackTrace) {
      debugPrint('GREŠKA OBJAVE TERETA: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      final l10n = AppLocalizations.of(context)!;
      prikaziPoruku(l10n.serverConnectionError);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
  Widget buildTopActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Flexible(
      flex: 1,
      child: SizedBox(
        height: 52,
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 17),
          label: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
              ),
            ),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 10,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildNotificationsButton() {
    final l10n = AppLocalizations.of(context)!;
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
                icon: const Icon(
                  Icons.notifications_none,
                  size: 17,
                ),
                label: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    l10n.notifications,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
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
  String localizedAuctionDuration(
      AppLocalizations l10n,
      String value,
      ) {
    switch (value) {
      case '1 sat':
        return l10n.oneHour;
      case '2 sata':
        return l10n.twoHours;
      case '6 sati':
        return l10n.sixHours;
      case '12 sati':
        return l10n.twelveHours;
      case '24 sata':
        return l10n.twentyFourHours;
      case '48 sati':
        return l10n.fortyEightHours;
      case '72 sata':
        return l10n.seventyTwoHours;
      case '7 dana':
        return l10n.sevenDays;
      default:
        return value;
    }
  }
  String localizedLoadingDeadline(
      AppLocalizations l10n,
      String value,
      ) {
    switch (value) {
      case '24 sata':
        return l10n.twentyFourHours;
      case '48 sati':
        return l10n.fortyEightHours;
      case '72 sata':
        return l10n.seventyTwoHours;
      case 'Po dogovoru':
        return l10n.byAgreement;
      default:
        return value;
    }
  }
  String localizedLocationType(
      AppLocalizations l10n,
      String value,
      ) {
    switch (value) {
      case 'Zgrada':
        return l10n.building;
      case 'Proizvodni pogon':
        return l10n.productionFacility;
      case 'Skladište':
        return l10n.warehouse;
      case 'Kuća':
        return l10n.house;
      case 'Gradilište':
        return l10n.constructionSite;
      case 'Poslovni prostor':
        return l10n.businessPremises;
      default:
        return value;
    }
  }
  String localizedLoadingMethod(
      AppLocalizations l10n,
      String value,
      ) {
    switch (value) {
      case 'Ručno':
        return l10n.manualLoading;
      case 'Strojno':
        return l10n.machineLoading;
      default:
        return value;
    }
  }
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sender),
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
            label: Text(l10n.info),
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
                    label: l10n.myShipments,
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
                      Text(
                        l10n.publishShipment,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.shipmentPublishDescription,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      buildSectionTitle(l10n.basicInformation),
                      TextFormField(
                        controller: nazivTeretaController,
                        onChanged: (value) =>
                            capitalizeFirstLetter(value, nazivTeretaController),
                        decoration: poljeDekoracija(l10n.shipmentName),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Unesite naziv tereta.';
                          }
                          if (containsForbiddenContactInfo(value)) {
                            return 'Naziv ne smije sadržavati kontakt podatke.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: opisTeretaController,
                        onChanged: (value) =>
                            capitalizeFirstLetter(value, opisTeretaController),
                        maxLines: 3,
                        decoration: poljeDekoracija(l10n.shortShipmentDescription),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.enterShipmentDescription;
                          }
                          if (containsForbiddenContactInfo(value)) {
                            return l10n.shipmentDescriptionNoContactInfo;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      buildSectionTitle(l10n.route),
                      buildCountryDropdown(
                        label: l10n.loadingCountry,
                        value: odabranaDrzavaUtovara,
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            odabranaDrzavaUtovara = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: mjestoUtovaraController,
                        onChanged: (value) =>
                            capitalizeFirstLetter(value, mjestoUtovaraController),
                        decoration: poljeDekoracija(l10n.loadingCity),
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
                        onChanged: (value) =>
                            capitalizeFirstLetter(value, adresaUtovaraController),
                        decoration: poljeDekoracija(l10n.loadingAddress),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Unesite adresu utovara.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      buildCountryDropdown(
                        label: l10n.unloadingCountry,
                        value: odabranaDrzavaIstovara,
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            odabranaDrzavaIstovara = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: mjestoIstovaraController,
                        onChanged: (value) =>
                            capitalizeFirstLetter(value, mjestoIstovaraController),
                        decoration: poljeDekoracija(l10n.unloadingCity),
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
                        onChanged: (value) =>
                            capitalizeFirstLetter(value, adresaIstovaraController),
                        decoration: poljeDekoracija(l10n.unloadingAddress),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Unesite adresu istovara.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      buildSectionTitle(l10n.timeAndQuantity),
                      DropdownButtonFormField<String>(
                        value: odabranoTrajanjeLicitacije,
                        decoration: poljeDekoracija(l10n.auctionDuration),
                        items: trajanjeLicitacijeOpcije
                            .map(
                              (e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(
                              localizedAuctionDuration(l10n, e),
                            ),
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
                          l10n.loadingDeadlineAfterAuction,
                        ),
                        items: rokPreuzimanjaOpcije
                            .map(
                              (e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(
                              localizedLoadingDeadline(l10n, e),
                            ),
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
                        decoration: poljeDekoracija(l10n.approxWeight),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: brojPaletaController,
                        keyboardType: TextInputType.number,
                        decoration:poljeDekoracija(l10n.palletCount),
                      ),
                      const SizedBox(height: 18),
                      buildSectionTitle(l10n.contact),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButton<PhoneCountryOption>(
                            value: selectedPhoneCountry,
                            underline: const SizedBox.shrink(),
                            menuWidth: 300,
                            selectedItemBuilder: (context) {
                              return phoneCountryOptions.map((country) {
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '${country.flag} ${country.dialCode}',
                                  ),
                                );
                              }).toList();
                            },

                            items: phoneCountryOptions.map((country) {
                              final languageCode =
                                  Localizations.localeOf(context).languageCode;

                              return DropdownMenuItem<PhoneCountryOption>(
                                value: country,
                                child: SizedBox(
                                  width: 260,
                                  child: Row(
                                    children: [
                                      Text(
                                        country.flag,
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          country.localizedName(languageCode),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        country.dialCode,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),

                            onChanged: (country) {
                              if (country == null) return;

                              setState(() {
                                selectedPhoneCountry = country;
                              });
                            },
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: brojTelefonaController,
                              keyboardType: TextInputType.phone,
                              decoration: poljeDekoracija(l10n.phoneNumber),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Unesite broj telefona.';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
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
                            l10n.contactHiddenUntilAccepted,
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
                        title: Text(
                          l10n.additionalDetails,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        children: [
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: odabraniTipLokacijeUtovara,
                            decoration: poljeDekoracija(l10n.loadingLocationType),
                            items: tipLokacijeOpcije
                                .map(
                                  (e) => DropdownMenuItem<String>(
                                value: e,
                                child: Text(
                                  localizedLocationType(l10n, e),
                                ),
                              ),
                            )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                odabraniTipLokacijeUtovara = value;

                                if (value != 'Zgrada' &&
                                    value != 'Poslovni prostor') {
                                  katUtovaraController.clear();
                                  liftNaUtovaru = false;
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: odabraniTipLokacijeIstovara,
                            decoration: poljeDekoracija(l10n.unloadingLocationType),
                            items: tipLokacijeOpcije
                                .map(
                                  (e) => DropdownMenuItem<String>(
                                value: e,
                                child: Text(
                                  localizedLocationType(l10n, e),
                                ),
                              ),
                            )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                odabraniTipLokacijeIstovara = value;

                                if (value != 'Zgrada' &&
                                    value != 'Poslovni prostor') {
                                  katIstovaraController.clear();
                                  liftNaIstovaru = false;
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: odabraniNacinUtovara,
                            decoration: poljeDekoracija(l10n.loadingMethod),
                            items: nacinUtovaraOpcije
                                .map(
                                  (e) => DropdownMenuItem<String>(
                                value: e,
                                child: Text(
                                  localizedLoadingMethod(l10n, e),
                                ),
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
                          if (odabraniTipLokacijeUtovara == 'Zgrada' ||
                              odabraniTipLokacijeUtovara == 'Poslovni prostor') ...[
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: katUtovaraController,
                              keyboardType: TextInputType.number,
                              decoration: poljeDekoracija('Kat utovara'),
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
                          ],
                          if (odabraniTipLokacijeIstovara == 'Zgrada' ||
                              odabraniTipLokacijeIstovara == 'Poslovni prostor') ...[
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: katIstovaraController,
                              keyboardType: TextInputType.number,
                              decoration: poljeDekoracija('Kat istovara'),
                            ),
                            const SizedBox(height: 8),
                            SwitchListTile(
                              value: liftNaIstovaru,
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Postoji lift na istovaru'),
                              onChanged: (value) {
                                setState(() {
                                  liftNaIstovaru = value;
                                });
                              },
                            ),
                          ],
                          TextFormField(
                            controller: duzinaController,
                            keyboardType: TextInputType.number,
                            decoration: poljeDekoracija(l10n.length),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: sirinaController,
                            keyboardType: TextInputType.number,
                            decoration: poljeDekoracija(l10n.width),
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: visinaController,
                            keyboardType: TextInputType.number,
                            decoration: poljeDekoracija(l10n.height),
                          ),
                          const SizedBox(height: 8),

                          SwitchListTile(
                            title: Text(l10n.truckAccess),
                            value: prilazZaTegljac,
                            contentPadding: EdgeInsets.zero,

                            onChanged: (value) {
                              setState(() {
                                prilazZaTegljac = value;
                              });
                            },
                          ),
                          SwitchListTile(
                            value: trebaPomocVozaca,
                            contentPadding: EdgeInsets.zero,
                            title: Text(l10n.driverHelp),
                            onChanged: (value) {
                              setState(() {
                                trebaPomocVozaca = value;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          buildSectionTitle(l10n.shipmentImages),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: otvoriGaleriju,
                                  icon: const Icon(Icons.photo_library_outlined),
                                  label: Text(l10n.gallery),
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
                                  label: Text(l10n.camera),
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
                            l10n.selectedImages(odabraneSlike.length, 5),
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
                          onPressed: isLoading
                              ? null
                              : () async {
                            final potvrda = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(
                                  l10n.checkShipmentData,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                content: Text(
                                  l10n.checkShipmentDataMessage,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: Text(
                                      l10n.cancel,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () => Navigator.pop(context, true),
                                    child: Text(
                                      l10n.publishShipment,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (potvrda == true) {
                              objaviTeret();
                            }
                          },
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
                              : Text(
                            l10n.publishShipment,
                            style: const TextStyle(
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