import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../services/token_storage.dart';

class AdminShipmentDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> shipment;

  const AdminShipmentDetailsScreen({
    super.key,
    required this.shipment,
  });

  @override
  State<AdminShipmentDetailsScreen> createState() =>
      _AdminShipmentDetailsScreenState();
}

class _AdminShipmentDetailsScreenState
    extends State<AdminShipmentDetailsScreen> {
  bool isLoading = true;
  String errorMessage = '';
  List<dynamic> bidHistory = [];

  Map<String, dynamic> get shipment => widget.shipment;

  @override
  void initState() {
    super.initState();
    _loadBidHistory();
  }

  Future<void> _loadBidHistory() async {
    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Niste prijavljeni.';
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
          '${AppConfig.baseUrl}/shipments/${shipment['id']}/bid-history',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          if (data is List) {
            bidHistory = data;
          } else if (data is Map && data['bidHistory'] is List) {
            bidHistory = data['bidHistory'];
          } else {
            bidHistory = [];
          }

          isLoading = false;
        });
      } else {
        String message = 'Greška pri učitavanju tijeka licitacije.';

        try {
          final data = jsonDecode(response.body);
          if (data is Map && data['message'] != null) {
            message = data['message'].toString();
          }
        } catch (_) {}

        setState(() {
          errorMessage = message;
          isLoading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Greška pri povezivanju sa serverom.';
        isLoading = false;
      });
    }
  }

  String _formatDateTime(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return '-';
    }

    try {
      final date = DateTime.parse(value.toString()).toLocal();

      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();

      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');

      return '$day.$month.$year. $hour:$minute';
    } catch (_) {
      return value.toString();
    }
  }

  String _formatPrice(dynamic value) {
    final amount = double.tryParse('${value ?? ''}');

    if (amount == null) {
      return '-';
    }

    return '${amount.toStringAsFixed(2)} €';
  }

  @override
  Widget build(BuildContext context) {
    final pickup =
    '${shipment['drzava_utovara'] ?? ''} '
        '${shipment['mjesto_utovara'] ?? ''}'
        .trim();

    final delivery =
    '${shipment['drzava_istovara'] ?? ''} '
        '${shipment['mjesto_istovara'] ?? ''}'
        .trim();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalji tereta'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shipment['naziv_tereta']?.toString().isNotEmpty == true
                        ? shipment['naziv_tereta'].toString()
                        : 'Teret #${shipment['id']}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _detailRow(
                    'ID objave',
                    '${shipment['id'] ?? '-'}',
                  ),

                  _detailRow(
                    'ID naručitelja',
                    '${shipment['senderId'] ?? '-'}',
                  ),

                  _detailRow(
                    'Naručitelj',
                    '${shipment['senderName'] ?? 'Nepoznat korisnik'}',
                  ),

                  _detailRow(
                    'E-mail',
                    '${shipment['senderEmail'] ?? '-'}',
                  ),

                  _detailRow(
                    'Telefon',
                    '${shipment['senderPhone'] ?? '-'}',
                  ),

                  _detailRow(
                    'Utovar',
                    pickup,
                  ),

                  _detailRow(
                    'Istovar',
                    delivery,
                  ),

                  _detailRow(
                    'Status',
                    '${shipment['status'] ?? '-'}',
                  ),

                  _detailRow(
                    'Broj ponuda',
                    '${shipment['offersCount'] ?? 0}',
                  ),

                  _detailRow(
                    'Objavljeno',
                    _formatDateTime(shipment['createdAt']),
                  ),

                  _detailRow(
                    'Kraj licitacije',
                    _formatDateTime(shipment['auctionEndsAt']),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Tijek licitacije',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (errorMessage.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  errorMessage,
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            )
          else if (bidHistory.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Nema ponuda za ovu licitaciju.'),
                ),
              )
            else
              ...bidHistory.map((bid) {
                final carrierName =
                    bid['carrierName']?.toString().trim() ?? '';

                final company =
                    bid['carrierCompany']?.toString().trim() ?? '';

                final name = carrierName.isNotEmpty
                    ? carrierName
                    : 'Nepoznat prijevoznik';

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        if (company.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(company),
                        ],

                        const SizedBox(height: 10),

                        _detailRow(
                          'ID prijevoznika',
                          '${bid['carrierId'] ?? '-'}',
                        ),

                        _detailRow(
                          'Ponuda',
                          _formatPrice(bid['amount']),
                        ),

                        _detailRow(
                          'Vrijeme',
                          _formatDateTime(bid['createdAt']),
                        ),

                        _detailRow(
                          'Status',
                          '${bid['status'] ?? '-'}',
                        ),
                      ],
                    ),
                  ),
                );
              }),
        ],
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}