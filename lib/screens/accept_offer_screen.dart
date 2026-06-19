import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../services/token_storage.dart';
import 'assigned_shipment_screen.dart';

class AcceptOfferScreen extends StatefulWidget {
  final int shipmentId;
  final Map<String, dynamic> offer;

  const AcceptOfferScreen({
    super.key,
    required this.shipmentId,
    required this.offer,
  });

  @override
  State<AcceptOfferScreen> createState() => _AcceptOfferScreenState();
}

class _AcceptOfferScreenState extends State<AcceptOfferScreen> {
  bool isSubmitting = false;

  String formatPrice(dynamic value) {
    if (value == null) return 'Nije navedeno';

    final number = double.tryParse(value.toString());
    if (number == null) return '$value €';

    if (number == number.roundToDouble()) {
      return '${number.toInt()} €';
    }

    return '${number.toStringAsFixed(2)} €';
  }

  String formatDate(dynamic value) {
    if (value == null) return 'Nije navedeno';

    try {
      final dt = DateTime.parse(value.toString()).toLocal();
      final d = dt.day.toString().padLeft(2, '0');
      final m = dt.month.toString().padLeft(2, '0');
      final y = dt.year.toString();
      final h = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');

      return '$d.$m.$y u $h:$min';
    } catch (_) {
      return value.toString();
    }
  }

  String carrierName() {
    final first = widget.offer['firstName'] ?? '';
    final last = widget.offer['lastName'] ?? '';
    final full = '$first $last'.trim();

    if (full.isNotEmpty) return full;

    return widget.offer['email'] ??
        widget.offer['carrierEmail'] ??
        'Prijevoznik';
  }

  Future<void> acceptOffer() async {
    setState(() {
      isSubmitting = true;
    });

    try {
      final token = await TokenStorage.getToken();

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/offers/${widget.offer['id']}/accept'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return;

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AssignedShipmentScreen(
              shipmentId: widget.shipmentId,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Greška kod prihvaćanja'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Greška: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  Future<void> confirmAccept() async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Prihvati ponudu'),
        content: const Text(
          'Jeste li sigurni da želite prihvatiti ovu ponudu?',
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

    if (confirm == true) {
      acceptOffer();
    }
  }

  Widget infoCard(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final price =
        formatPrice(widget.offer['amount'] ?? widget.offer['price']);

    final date = formatDate(widget.offer['createdAt']);

    final name = carrierName();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prihvati ponudu'),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF5F7FB),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF1565C0),
                          Color(0xFF1E88E5),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Ponuda',
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          price,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  infoCard(
                    Icons.person,
                    'Prijevoznik',
                    name,
                  ),
                  infoCard(
                    Icons.schedule,
                    'Vrijeme ponude',
                    date,
                  ),
                  if (widget.offer['message'] != null)
                    infoCard(
                      Icons.message,
                      'Napomena',
                      widget.offer['message'],
                    ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Nakon prihvaćanja ponude teret će biti dodijeljen ovom prijevozniku i ostale ponude će biti zatvorene.',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : confirmAccept,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'PRIHVATI PONUDU',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          )
        ],
      ),
    );
  }
}