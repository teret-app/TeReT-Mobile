import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../services/token_storage.dart';
import 'login_screen.dart';
import 'my_shipments_screen.dart';

class DeliveryConfirmationScreen extends StatefulWidget {
  final int shipmentId;

  const DeliveryConfirmationScreen({
    super.key,
    required this.shipmentId,
  });

  @override
  State<DeliveryConfirmationScreen> createState() =>
      _DeliveryConfirmationScreenState();
}

class _DeliveryConfirmationScreenState
    extends State<DeliveryConfirmationScreen> {
  Map<String, dynamic>? shipment;
  bool isLoading = true;
  bool isSubmitting = false;
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
        Uri.parse(
          '${AppConfig.baseUrl}/shipments/${widget.shipmentId}/confirm-delivery',
        ),
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
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
          errorMessage =
              data['message']?.toString() ?? 'Greška kod učitavanja tereta.';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Greška: $e';
      });
    }
  }

  String formatValue(dynamic value, {String fallback = 'Nije navedeno'}) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    if (text.isEmpty || text == 'null') return fallback;
    return text;
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

  String formatPrice(dynamic value) {
    if (value == null) return 'Nije navedeno';

    final number = double.tryParse(value.toString());
    if (number == null) return '${value.toString()} €';

    if (number == number.roundToDouble()) {
      return '${number.toInt()} €';
    }

    return '${number.toStringAsFixed(2)} €';
  }

  bool isDelivered() {
    if (shipment == null) return false;

    final value = shipment!['delivered'] ??
        shipment!['isDelivered'] ??
        shipment!['deliveryConfirmed'] ??
        shipment!['status'];

    if (value == true) return true;

    final text = value?.toString().toLowerCase().trim() ?? '';
    return text == 'delivered' ||
        text == 'completed' ||
        text == 'zavrseno' ||
        text == 'dostavljeno' ||
        text == 'confirmed';
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

  Future<void> confirmDelivery() async {
    setState(() {
      isSubmitting = true;
    });

    try {
      final token = await TokenStorage.getToken();

      final response = await http.post(
        Uri.parse(
          '${AppConfig.baseUrl}/shipments/${widget.shipmentId}/confirm-delivery',
        ),
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['message']?.toString() ??
                  'Dostava je uspješno potvrđena.',
            ),
            backgroundColor: Colors.green,
          ),
        );

        await fetchShipment();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['message']?.toString() ??
                  'Greška kod potvrde dostave.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Greška: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  Future<void> showConfirmDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Potvrda dostave'),
        content: const Text(
          'Jeste li sigurni da je teret uspješno dostavljen na odredište?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Ne'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Da'),
          ),
        ],
      ),
    );

    if (result == true) {
      await confirmDelivery();
    }
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
        ],
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

  Widget actionButton({
    required String text,
    required VoidCallback? onPressed,
    required Color backgroundColor,
    IconData? icon,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final acceptedOffer = shipment == null ? null : resolveAcceptedOffer(shipment!);
    final delivered = isDelivered();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Potvrda dostave'),
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
                                  colors: delivered
                                      ? [
                                          Colors.green.shade600,
                                          Colors.teal.shade600,
                                        ]
                                      : [
                                          Colors.orange.shade600,
                                          Colors.deepOrange.shade500,
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: (delivered
                                            ? Colors.green
                                            : Colors.orange)
                                        .withValues(alpha: 0.18),
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
                                      Icon(
                                        delivered
                                            ? Icons.check_circle
                                            : Icons.local_shipping,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        delivered
                                            ? 'Dostava potvrđena'
                                            : 'Teret u prijevozu',
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
                                    '${formatValue(shipment!['mjestoUtovara'] ?? shipment!['pickupCity'])} → ${formatValue(shipment!['mjestoIstovara'] ?? shipment!['deliveryCity'])}',
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
                            sectionTitle('Podaci o teretu'),
                            infoTile(
                              label: 'Naziv tereta',
                              value: formatValue(
                                shipment!['nazivTereta'] ?? shipment!['title'],
                              ),
                              icon: Icons.inventory_2_outlined,
                            ),
                            infoTile(
                              label: 'Datum utovara',
                              value: formatDate(
                                shipment!['datumUtovara'] ??
                                    shipment!['datum'] ??
                                    shipment!['pickupDate'],
                              ),
                              icon: Icons.calendar_today_outlined,
                            ),
                            infoTile(
                              label: 'Mjesto utovara',
                              value: formatValue(
                                shipment!['mjestoUtovara'] ??
                                    shipment!['pickupCity'],
                              ),
                              icon: Icons.upload_outlined,
                            ),
                            infoTile(
                              label: 'Mjesto istovara',
                              value: formatValue(
                                shipment!['mjestoIstovara'] ??
                                    shipment!['deliveryCity'],
                              ),
                              icon: Icons.download_outlined,
                            ),
                            if (acceptedOffer != null) ...[
                              const SizedBox(height: 8),
                              sectionTitle('Dodijeljeni prijevoznik'),
                              infoTile(
                                label: 'Prijevoznik',
                                value: buildCarrierName(acceptedOffer),
                                icon: Icons.person_outline,
                              ),
                              infoTile(
                                label: 'Email',
                                value: formatValue(
                                  acceptedOffer['carrierEmail'] ??
                                      acceptedOffer['email'],
                                ),
                                icon: Icons.email_outlined,
                              ),
                              infoTile(
                                label: 'Telefon',
                                value: formatValue(
                                  acceptedOffer['carrierPhone'] ??
                                      acceptedOffer['phone'] ??
                                      acceptedOffer['brojTelefona'],
                                  fallback: 'Telefon nije dostupan',
                                ),
                                icon: Icons.phone_outlined,
                              ),
                              infoTile(
                                label: 'Dogovorena cijena',
                                value: formatPrice(
                                  acceptedOffer['amount'] ??
                                      acceptedOffer['price'],
                                ),
                                icon: Icons.euro_outlined,
                              ),
                            ],
                            const SizedBox(height: 8),
                            sectionTitle('Status'),
                            infoTile(
                              label: 'Status prijevoza',
                              value: delivered
                                  ? 'Dostava je potvrđena'
                                  : 'Čeka se potvrda dostave od naručitelja',
                              icon: delivered
                                  ? Icons.verified_outlined
                                  : Icons.timelapse_outlined,
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: delivered
                                    ? Colors.green.shade50
                                    : Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: delivered
                                      ? Colors.green.shade200
                                      : Colors.orange.shade200,
                                ),
                              ),
                              child: Text(
                                delivered
                                    ? 'Prijevoz je završen i potvrđen. Sljedeći korak može biti ocjenjivanje prijevoznika.'
                                    : 'Ako je teret stigao na odredište, kliknite na potvrdu dostave. Time se posao označava kao završen.',
                                style: const TextStyle(
                                  height: 1.45,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (!delivered)
                              actionButton(
                                text: isSubmitting
                                    ? 'Potvrđujem...'
                                    : 'POTVRDI DOSTAVU',
                                onPressed:
                                    isSubmitting ? null : showConfirmDialog,
                                backgroundColor: Colors.green.shade600,
                                icon: Icons.check_circle_outline,
                              ),
                            if (delivered) ...[
                              actionButton(
                                text: 'IDI NA MOJE TERETE',
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const MyShipmentsScreen(),
                                    ),
                                    (route) => false,
                                  );
                                },
                                backgroundColor: Colors.blue.shade600,
                                icon: Icons.list_alt_outlined,
                              ),
                            ],
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
    );
  }
}