import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../l10n/app_localizations.dart';
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

  String formatPrice(
      dynamic value,
      AppLocalizations l10n,
      ) {
    if (value == null) return l10n.notSpecified;

    final number = double.tryParse(value.toString());

    if (number == null) {
      return '$value €';
    }

    return '${number.toStringAsFixed(2)} €';
  }

  String formatDate(
      dynamic value,
      AppLocalizations l10n,
      ) {
    if (value == null) return l10n.notSpecified;

    try {
      final dt = DateTime.parse(value.toString()).toLocal();

      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final year = dt.year.toString();
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');

      return l10n.offerDateTime(
        day,
        month,
        year,
        hour,
        minute,
      );
    } catch (_) {
      return value.toString();
    }
  }

  String carrierName(AppLocalizations l10n) {
    final firstName = widget.offer['firstName']?.toString() ?? '';
    final lastName = widget.offer['lastName']?.toString() ?? '';

    final fullName = '$firstName $lastName'.trim();

    if (fullName.isNotEmpty) {
      return fullName;
    }

    return widget.offer['email']?.toString() ??
        widget.offer['carrierEmail']?.toString() ??
        l10n.carrier;
  }

  String responseErrorMessage(
      http.Response response,
      AppLocalizations l10n,
      ) {
    try {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic> && data['message'] != null) {
        return data['message'].toString();
      }
    } catch (_) {
      // Ako odgovor nije JSON, prikazuje se lokalizirana poruka.
    }

    return l10n.offerAcceptError;
  }

  Future<void> acceptOffer() async {
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      isSubmitting = true;
    });

    try {
      final token = await TokenStorage.getToken();

      final response = await http.post(
        Uri.parse(
          '${AppConfig.baseUrl}/offers/${widget.offer['id']}/accept',
        ),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return;

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
            content: Text(
              responseErrorMessage(response, l10n),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.generalError(error.toString()),
          ),
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

  Future<void> confirmAccept() async {
    final l10n = AppLocalizations.of(context)!;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.acceptOffer),
          content: Text(l10n.acceptOfferConfirmation),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(l10n.no),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(l10n.yes),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await acceptOffer();
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
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.blue,
          ),
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
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final price = formatPrice(
      widget.offer['amount'] ?? widget.offer['price'],
      l10n,
    );

    final date = formatDate(
      widget.offer['createdAt'],
      l10n,
    );

    final name = carrierName(l10n);

    final message = widget.offer['message']?.toString().trim();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.acceptOffer),
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
                        Text(
                          l10n.offer,
                          style: const TextStyle(
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
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  infoCard(
                    Icons.person,
                    l10n.carrier,
                    name,
                  ),
                  infoCard(
                    Icons.schedule,
                    l10n.offerTime,
                    date,
                  ),
                  if (message != null && message.isNotEmpty)
                    infoCard(
                      Icons.message,
                      l10n.note,
                      message,
                    ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      l10n.acceptOfferWarning,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : confirmAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                      : Text(
                    l10n.acceptOfferButton,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}