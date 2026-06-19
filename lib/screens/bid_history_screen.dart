import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../services/token_storage.dart';
import 'login_screen.dart';

class BidHistoryScreen extends StatefulWidget {
  final int shipmentId;

  const BidHistoryScreen({
    super.key,
    required this.shipmentId,
  });

  @override
  State<BidHistoryScreen> createState() => _BidHistoryScreenState();
}

class _BidHistoryScreenState extends State<BidHistoryScreen> {
  bool isLoading = true;
  String errorMessage = '';

  Map<String, dynamic>? data;
  List<dynamic> bidHistory = [];

  @override
  void initState() {
    super.initState();
    fetchBidHistory();
  }

  Future<void> fetchBidHistory() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final token = await TokenStorage.getToken();

      if (token == null || token.isEmpty) {
        _goToLogin('Niste prijavljeni. Prijavite se ponovno.');
        return;
      }

      final response = await http.get(
        Uri.parse(
          '${AppConfig.baseUrl}/shipments/${widget.shipmentId}/bid-history',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final decoded =
      response.body.isNotEmpty ? jsonDecode(response.body) : null;

      if (response.statusCode == 401) {
        await TokenStorage.clearToken();
        _goToLogin('Sesija je istekla. Prijavite se ponovno.');
        return;
      }

      if (response.statusCode != 200) {
        if (!mounted) return;

        setState(() {
          errorMessage =
          decoded is Map && decoded['message'] != null
              ? decoded['message'].toString()
              : 'Došlo je do pogreške pri dohvaćanju tijeka licitacije.';
          isLoading = false;
        });

        return;
      }

      final mapData =
      decoded is Map<String, dynamic>
          ? decoded
          : Map<String, dynamic>.from(decoded as Map);

      if (!mounted) return;

      setState(() {
        data = mapData;
        bidHistory =
        mapData['bidHistory'] is List
            ? mapData['bidHistory']
            : [];

        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        errorMessage =
        'Došlo je do pogreške. Provjerite vezu s backendom.';
        isLoading = false;
      });
    }
  }

  void _goToLogin(String message) {
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(errorMessage: message),
      ),
          (route) => false,
    );
  }

  String formatAmount(dynamic value) {
    final number = double.tryParse(
      value?.toString().replaceAll(',', '.') ?? '',
    );

    if (number == null) return '-';

    if (number == number.roundToDouble()) {
      return '${number.toInt()} €';
    }

    return '${number.toStringAsFixed(2)} €';
  }

  String formatDate(dynamic value) {
    if (value == null || value.toString().isEmpty) return '';

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

  String _formatStatus(dynamic value) {
    final status = (value ?? '').toString().toLowerCase().trim();

    if (status == 'aktivan' ||
        status == 'active' ||
        status == 'open') {
      return 'Aktivan';
    }

    if (status == 'prihvaceno' ||
        status == 'prihvaćeno' ||
        status == 'accepted' ||
        status == 'offer_accepted') {
      return 'Prihvaćena ponuda';
    }

    if (status == 'zavrseno' ||
        status == 'završeno' ||
        status == 'completed') {
      return 'Završeno';
    }

    if (status.isEmpty) return '-';

    return value.toString();
  }

  String _carrierTitle(Map<String, dynamic> bid) {
    final isMyOffer = bid['isMyOffer'] == true;

    final carrierName =
    (bid['carrierName'] ?? '').toString().trim();

    final carrierCompany =
    (bid['carrierCompany'] ?? '').toString().trim();

    if (isMyOffer) {
      return 'Vaša ponuda';
    }

    if (carrierCompany.isNotEmpty &&
        carrierCompany != 'Drugi prijevoznik') {
      return carrierCompany;
    }

    if (carrierName.isNotEmpty &&
        carrierName != 'Drugi prijevoznik') {
      return carrierName;
    }

    return 'Prijevoznik';
  }

  String _carrierRatingText(Map<String, dynamic> bid) {
    final averageRating =
        bid['carrierAverageRating'] ??
            bid['averageRating'];

    final ratingsCount =
        bid['carrierRatingsCount'] ??
            bid['ratingsCount'] ??
            0;

    if (averageRating == null ||
        averageRating.toString().trim().isEmpty) {
      return '';
    }

    return '⭐ $averageRating ($ratingsCount ocjena)';
  }

  Widget _summaryCard() {
    final lowestOffer = data?['lowestOffer'];
    final myOfferAmount = data?['myOfferAmount'];

    final offersCount =
        data?['offersCount'] ?? bidHistory.length;

    final shipmentStatus = data?['shipmentStatus'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sažetak licitacije',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            _summaryRow(
              'Trenutna najniža ponuda',
              formatAmount(lowestOffer),
            ),

            _summaryRow(
              'Broj ponuda',
              offersCount.toString(),
            ),

            if (myOfferAmount != null)
              _summaryRow(
                'Vaša ponuda',
                formatAmount(myOfferAmount),
              ),

            if (shipmentStatus != null)
              _summaryRow(
                'Status tereta',
                _formatStatus(shipmentStatus),
              ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bidCard(dynamic item, int index) {
    final bid = Map<String, dynamic>.from(item as Map);

    final isLowest = bid['isLowest'] == true;
    final isMyOffer = bid['isMyOffer'] == true;
    final isAccepted = bid['isAccepted'] == true;
    final isRejected = bid['isRejected'] == true;

    final carrierRatingText = _carrierRatingText(bid);

    String badgeText = '';
    Color badgeColor = Colors.grey;

    if (isAccepted && index == 0) {
      badgeText = 'PRIHVAĆENO';
      badgeColor = Colors.green;
    } else if (isRejected) {
      badgeText = 'ODBIJENO';
      badgeColor = Colors.red;
    } else if (isLowest) {
      badgeText = 'NAJNIŽA';
      badgeColor = Colors.orange;
    } else if (isMyOffer) {
      badgeText = 'VAŠA';
      badgeColor = Colors.blueGrey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              child: Text('${index + 1}'),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              _carrierTitle(bid),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),

                            if (carrierRatingText
                                .isNotEmpty) ...[
                              const SizedBox(height: 3),

                              Text(
                                carrierRatingText,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight:
                                  FontWeight.w600,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      if (badgeText.isNotEmpty)
                        Container(
                          padding:
                          const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor
                                .withOpacity(0.12),
                            borderRadius:
                            BorderRadius.circular(
                              20,
                            ),
                            border: Border.all(
                              color: badgeColor,
                            ),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              color: badgeColor,
                              fontSize: 10,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    formatAmount(bid['amount']),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    formatDate(bid['createdAt']),
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),

                  if ((bid['message'] ?? '')
                      .toString()
                      .trim()
                      .isNotEmpty) ...[
                    const SizedBox(height: 8),

                    Text(
                      bid['message'].toString(),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.red,
            ),
          ),
        ),
      );
    }

    if (bidHistory.isEmpty) {
      return RefreshIndicator(
        onRefresh: fetchBidHistory,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            SizedBox(height: 80),
            Center(
              child: Text(
                'Još nema ponuda za ovaj teret.',
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchBidHistory,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _summaryCard(),

          const Text(
            'Tijek licitacije',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          ...bidHistory.asMap().entries.map(
                (entry) =>
                _bidCard(entry.value, entry.key),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tijek licitacije'),
        actions: [
          IconButton(
            onPressed: fetchBidHistory,
            icon: const Icon(Icons.refresh),
            tooltip: 'Osvježi',
          ),
        ],
      ),
      body: _body(),
    );
  }
}