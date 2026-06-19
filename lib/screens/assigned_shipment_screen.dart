import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../services/token_storage.dart';
import 'login_screen.dart';
import 'rating_screen.dart';

class AssignedShipmentScreen extends StatefulWidget {
  final int shipmentId;

  const AssignedShipmentScreen({
    super.key,
    required this.shipmentId,
  });

  @override
  State<AssignedShipmentScreen> createState() => _AssignedShipmentScreenState();
}

class _AssignedShipmentScreenState extends State<AssignedShipmentScreen> {
  Map<String, dynamic>? shipment;
  bool isLoading = true;
  bool isConfirmingDelivery = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchShipment();
  }

  Future<void> fetchShipment() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final token = await TokenStorage.getToken();

      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/shipments/${widget.shipmentId}'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          shipment = Map<String, dynamic>.from(data);
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        setState(() {
          isLoading = false;
          errorMessage = 'Sesija je istekla. Prijavite se ponovno.';
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = data['message']?.toString() ?? 'Greška kod učitavanja tereta.';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Greška: $e';
      });
    }
  }

  Future<void> confirmDelivery() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Jesi li siguran?'),
          content: const Text(
            'Potvrdom označavaš da je prijevoz obavljen.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Odustani'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Prijevoz obavljen'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

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

    if (!mounted) return;

    setState(() {
      isConfirmingDelivery = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/shipments/${widget.shipmentId}/confirm-delivery'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      String message = 'Prijevoz je označen kao obavljen.';

      try {
        final body = jsonDecode(response.body);
        if (body is Map && body['message'] != null) {
          message = body['message'].toString();
        }
      } catch (_) {}

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

      if (response.statusCode == 200) {
        await fetchShipment();

        if (!mounted) return;

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RatingScreen(
              shipmentId: widget.shipmentId,
              ratedUserLabel: 'prijevoznika',
            ),
          ),
        );

        await fetchShipment();
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Greška konekcije sa serverom.')),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        isConfirmingDelivery = false;
      });
    }
  }

  String formatValue(dynamic value, {String fallback = 'Nije navedeno'}) {
    if (value == null) return fallback;

    final text = value.toString().trim();

    if (text.isEmpty || text == 'null') return fallback;

    return text;
  }

  String formatPrice(dynamic value) {
    if (value == null) return 'Nije navedeno';

    final number = double.tryParse(value.toString());

    if (number == null) return '${value.toString()} €';

    if (number == number.roundToDouble()) {
      return '${number.toInt()} €';
    }

    return '${number.toStringAsFixed(2)} €';
  }

  String formatDate(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return 'Nije navedeno';
    }

    try {
      final dt = DateTime.parse(value.toString()).toLocal();
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final year = dt.year.toString();

      return '$day.$month.$year';
    } catch (_) {
      return value.toString();
    }
  }

  String yesNo(dynamic value) {
    if (value == true) return 'Da';
    if (value == false) return 'Ne';

    final text = value?.toString().toLowerCase().trim() ?? '';

    if (text == 'true') return 'Da';
    if (text == 'false') return 'Ne';

    return 'Nije navedeno';
  }

  String buildCarrierName(Map<String, dynamic> acceptedOffer) {
    final firstName = acceptedOffer['firstName']?.toString().trim() ?? '';
    final lastName = acceptedOffer['lastName']?.toString().trim() ?? '';
    final fullName = '$firstName $lastName'.trim();

    if (fullName.isNotEmpty) return fullName;

    final name = acceptedOffer['name']?.toString().trim() ?? '';
    if (name.isNotEmpty) return name;

    final email = acceptedOffer['carrierEmail']?.toString().trim() ??
        acceptedOffer['email']?.toString().trim() ??
        '';

    if (email.isNotEmpty) return email;

    return 'Prijevoznik';
  }

  bool isCompletedStatus() {
    final status = (shipment?['status'] ?? '').toString().toLowerCase().trim();

    return status == 'zavrseno' ||
        status == 'završeno' ||
        status == 'completed';
  }

  Map<String, dynamic>? resolveAcceptedOffer(Map<String, dynamic> data) {
    if (data['acceptedOffer'] is Map<String, dynamic>) {
      return data['acceptedOffer'] as Map<String, dynamic>;
    }

    if (data['accepted_offer'] is Map<String, dynamic>) {
      return Map<String, dynamic>.from(data['accepted_offer']);
    }

    if (data['selectedOffer'] is Map<String, dynamic>) {
      return Map<String, dynamic>.from(data['selectedOffer']);
    }

    if (data['selected_offer'] is Map<String, dynamic>) {
      return Map<String, dynamic>.from(data['selected_offer']);
    }

    if (data['winningOffer'] is Map<String, dynamic>) {
      return Map<String, dynamic>.from(data['winningOffer']);
    }

    if (data['winning_offer'] is Map<String, dynamic>) {
      return Map<String, dynamic>.from(data['winning_offer']);
    }

    return null;
  }

  List<dynamic> extractImages() {
    if (shipment == null) return [];

    final rawImages = shipment!['slike'] ??
        shipment!['images'] ??
        shipment!['imageUrls'] ??
        shipment!['photos'];

    if (rawImages == null) return [];

    if (rawImages is List) {
      return rawImages
          .where((image) => image != null && image.toString().trim().isNotEmpty)
          .toList();
    }

    if (rawImages is String) {
      final value = rawImages.trim();

      if (value.isEmpty) return [];

      try {
        final decoded = jsonDecode(value);

        if (decoded is List) {
          return decoded
              .where((image) => image != null && image.toString().trim().isNotEmpty)
              .toList();
        }
      } catch (_) {
        return [value];
      }
    }

    return [];
  }

  String? buildImageUrl(String value) {
    final clean = value.trim();

    if (clean.isEmpty) return null;

    if (clean.startsWith('http://') || clean.startsWith('https://')) {
      return clean;
    }

    if (clean.startsWith('/uploads/')) {
      return '${AppConfig.baseUrl}$clean';
    }

    if (clean.startsWith('uploads/')) {
      return '${AppConfig.baseUrl}/$clean';
    }

    return null;
  }

  Uint8List? tryDecodeBase64Image(String value) {
    try {
      String clean = value.trim();

      if (clean.startsWith('data:image')) {
        final commaIndex = clean.indexOf(',');

        if (commaIndex != -1) {
          clean = clean.substring(commaIndex + 1);
        }
      }

      return base64Decode(clean);
    } catch (_) {
      return null;
    }
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget infoTile({
    required String label,
    required String value,
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueGrey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.blue.shade700, size: 20),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget confirmDeliveryButton() {
    if (isCompletedStatus()) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Prijevoz je označen kao obavljen.',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isConfirmingDelivery ? null : confirmDelivery,
        icon: isConfirmingDelivery
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : const Icon(Icons.task_alt),
        label: Text(
          isConfirmingDelivery ? 'Potvrđujem...' : 'Prijevoz obavljen',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade700,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget buildImageGallery(List images) {
    if (images.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final imageValue = images[index].toString();
          final base64Bytes = tryDecodeBase64Image(imageValue);
          final imageUrl = buildImageUrl(imageValue);

          return GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) {
                  return Dialog(
                    insetPadding: const EdgeInsets.all(12),
                    child: Container(
                      color: Colors.black,
                      padding: const EdgeInsets.all(8),
                      child: base64Bytes != null
                          ? InteractiveViewer(
                        child: Image.memory(
                          base64Bytes,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image, color: Colors.white, size: 48),
                        ),
                      )
                          : imageUrl != null
                          ? InteractiveViewer(
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image, color: Colors.white, size: 48),
                        ),
                      )
                          : const SizedBox(
                        height: 250,
                        child: Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 140,
                color: Colors.grey.shade200,
                child: base64Bytes != null
                    ? Image.memory(
                  base64Bytes,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                  const Icon(Icons.image_not_supported, size: 34),
                )
                    : imageUrl != null
                    ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                  const Icon(Icons.image_not_supported, size: 34),
                )
                    : const Icon(Icons.image, size: 34),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final acceptedOffer =
    shipment == null ? null : resolveAcceptedOffer(shipment!);

    final images = extractImages();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Dodijeljeni teret'),
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 52,
              ),
              const SizedBox(height: 12),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: fetchShipment,
                child: const Text('Pokušaj ponovno'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                        (route) => false,
                  );
                },
                child: const Text('Idi na prijavu'),
              ),
            ],
          ),
        ),
      )
          : shipment == null
          ? const Center(
        child: Text(
          'Teret nije pronađen.',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      )
          : RefreshIndicator(
        onRefresh: fetchShipment,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.shade600,
                      Colors.teal.shade600,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isCompletedStatus()
                              ? 'Prijevoz obavljen'
                              : 'Teret je dodijeljen',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      formatValue(
                        shipment!['naziv_tereta'] ??
                            shipment!['nazivTereta'] ??
                            shipment!['title'],
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${formatValue(shipment!['mjesto_utovara'] ?? shipment!['mjestoUtovara'] ?? shipment!['pickupCity'])} → ${formatValue(shipment!['mjesto_istovara'] ?? shipment!['mjestoIstovara'] ?? shipment!['deliveryCity'])}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              sectionTitle('Podaci o prijevozniku'),
              if (acceptedOffer != null) ...[
                infoTile(
                  label: 'Prijevoznik',
                  value: buildCarrierName(acceptedOffer),
                  icon: Icons.person_outline,
                ),
                infoTile(
                  label: 'Email',
                  value: formatValue(
                    acceptedOffer['carrierEmail'] ?? acceptedOffer['email'],
                  ),
                  icon: Icons.email_outlined,
                ),
                infoTile(
                  label: 'Telefon',
                  value: formatValue(
                    acceptedOffer['carrierPhone'] ??
                        acceptedOffer['phone'] ??
                        acceptedOffer['brojTelefona'],
                    fallback: 'Telefon još nije dostupan',
                  ),
                  icon: Icons.phone_outlined,
                ),
                infoTile(
                  label: 'Prihvaćena cijena',
                  value: formatPrice(
                    acceptedOffer['amount'] ?? acceptedOffer['price'],
                  ),
                  icon: Icons.euro_outlined,
                ),
              ] else ...[
                infoTile(
                  label: 'Status',
                  value: 'Ponuda je prihvaćena, ali detalji prijevoznika trenutno nisu dostupni.',
                  icon: Icons.info_outline,
                ),
              ],

              const SizedBox(height: 8),
              confirmDeliveryButton(),
              const SizedBox(height: 18),

              sectionTitle('Osnovni podaci o teretu'),
              infoTile(
                label: 'Naziv tereta',
                value: formatValue(
                  shipment!['naziv_tereta'] ??
                      shipment!['nazivTereta'] ??
                      shipment!['title'],
                ),
                icon: Icons.inventory_2_outlined,
              ),
              infoTile(
                label: 'Opis',
                value: formatValue(
                  shipment!['opis_tereta'] ??
                      shipment!['opis'] ??
                      shipment!['description'],
                ),
                icon: Icons.description_outlined,
              ),
              infoTile(
                label: 'Datum utovara',
                value: formatDate(
                  shipment!['datum_utovara'] ??
                      shipment!['datumUtovara'] ??
                      shipment!['datum'] ??
                      shipment!['pickupDate'],
                ),
                icon: Icons.calendar_today_outlined,
              ),
              infoTile(
                label: 'Mjesto utovara',
                value: formatValue(
                  shipment!['mjesto_utovara'] ??
                      shipment!['mjestoUtovara'] ??
                      shipment!['pickupCity'],
                ),
                icon: Icons.upload_outlined,
              ),
              infoTile(
                label: 'Adresa utovara',
                value: formatValue(
                  shipment!['adresa_utovara'] ??
                      shipment!['adresaUtovara'] ??
                      shipment!['pickupAddress'],
                ),
                icon: Icons.location_on_outlined,
              ),
              infoTile(
                label: 'Mjesto istovara',
                value: formatValue(
                  shipment!['mjesto_istovara'] ??
                      shipment!['mjestoIstovara'] ??
                      shipment!['deliveryCity'],
                ),
                icon: Icons.download_outlined,
              ),
              infoTile(
                label: 'Adresa istovara',
                value: formatValue(
                  shipment!['adresa_istovara'] ??
                      shipment!['adresaIstovara'] ??
                      shipment!['deliveryAddress'],
                ),
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 8),

              sectionTitle('Dimenzije i logistika'),
              infoTile(
                label: 'Težina (kg/lb)',
                value: formatValue(
                  shipment!['tezina_kg/lb'] ??
                      shipment!['tezina'] ??
                      shipment!['weight'],
                ),
                icon: Icons.scale_outlined,
              ),
              infoTile(
                label: 'Dužina (cm/in)',
                value: formatValue(
                  shipment!['duzina_cm/in'] ??
                      shipment!['duzina'] ??
                      shipment!['length'],
                ),
                icon: Icons.straighten_outlined,
              ),
              infoTile(
                label: 'Širina (cm/in)',
                value: formatValue(
                  shipment!['sirina_cm/in'] ??
                      shipment!['sirina'] ??
                      shipment!['width'],
                ),
                icon: Icons.straighten_outlined,
              ),
              infoTile(
                label: 'Visina (cm/in)',
                value: formatValue(
                  shipment!['visina_cm/in'] ??
                      shipment!['visina'] ??
                      shipment!['height'],
                ),
                icon: Icons.height_outlined,
              ),
              infoTile(
                label: 'Način utovara',
                value: formatValue(
                  shipment!['nacin_utovara'] ??
                      shipment!['nacinUtovara'] ??
                      shipment!['loadingType'],
                ),
                icon: Icons.precision_manufacturing_outlined,
              ),
              infoTile(
                label: 'Prilaz za tegljač',
                value: yesNo(
                  shipment!['prilaz_za_tegljac'] ??
                      shipment!['prilazZaTegljac'] ??
                      shipment!['pristupZaSleper'] ??
                      shipment!['truckAccess'],
                ),
                icon: Icons.local_shipping_outlined,
              ),
              infoTile(
                label: 'Tip lokacije utovara',
                value: formatValue(
                  shipment!['tip_lokacije_utovara'] ??
                      shipment!['tipLokacijeUtovara'] ??
                      shipment!['pickupLocationType'],
                ),
                icon: Icons.apartment_outlined,
              ),
              infoTile(
                label: 'Kat utovara',
                value: formatValue(
                  shipment!['kat_utovara'] ??
                      shipment!['katUtovara'] ??
                      shipment!['pickupFloor'],
                ),
                icon: Icons.layers_outlined,
              ),
              infoTile(
                label: 'Lift na utovaru',
                value: yesNo(
                  shipment!['lift_na_utovaru'] ??
                      shipment!['liftUtovar'] ??
                      shipment!['pickupElevator'],
                ),
                icon: Icons.elevator_outlined,
              ),
              infoTile(
                label: 'Treba li pomoć vozača',
                value: yesNo(
                  shipment!['treba_pomoc_vozaca'] ??
                      shipment!['pomocVozaca'] ??
                      shipment!['driverHelp'],
                ),
                icon: Icons.handshake_outlined,
              ),
              infoTile(
                label: 'Carina',
                value: yesNo(
                  shipment!['carina'] ?? shipment!['customs'],
                ),
                icon: Icons.assignment_outlined,
              ),
              const SizedBox(height: 8),

              if (!isCompletedStatus() && images.isNotEmpty) ...[
                sectionTitle('Slike tereta'),
                buildImageGallery(images),
                const SizedBox(height: 16),
              ],

            ],
          ),
        ),
      ),
    );
  }
}
