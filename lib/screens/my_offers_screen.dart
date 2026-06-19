import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../services/token_storage.dart';
import 'login_screen.dart';
import 'shipment_details_screen.dart';

class MyOffersScreen extends StatefulWidget {
  const MyOffersScreen({super.key});

  @override
  State<MyOffersScreen> createState() => _MyOffersScreenState();
}

class _MyOffersScreenState extends State<MyOffersScreen> {
  bool isLoading = true;
  String errorMessage = '';
  List<dynamic> offers = [];

  @override
  void initState() {
    super.initState();
    fetchMyOffers();
  }

  Future<void> fetchMyOffers() async {
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
        Uri.parse('${AppConfig.baseUrl}/my-offers'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        setState(() {
          offers = decoded is List ? decoded : [];
          isLoading = false;
        });
        return;
      }

      if (response.statusCode == 401) {
        _goToLogin('Sesija je istekla. Prijavite se ponovno.');
        return;
      }

      String message = 'Greška pri dohvaćanju mojih ponuda.';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['message'] != null) {
          message = decoded['message'].toString();
        }
      } catch (_) {}

      setState(() {
        errorMessage = message;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Greška konekcije sa serverom.';
        isLoading = false;
      });
    }
  }

  void _goToLogin(String message) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(errorMessage: message),
      ),
          (route) => false,
    );
  }

  String _text(dynamic value, [String fallback = '—']) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    if (text.isEmpty) return fallback;
    return text;
  }

  double? _number(dynamic value) {
    if (value == null) return null;
    return double.tryParse(value.toString().replaceAll(',', '.'));
  }

  String _priceText(dynamic value) {
    if (value == null) return '—';
    final number = _number(value);
    if (number == null) return '${value.toString()} €';

    if (number == number.roundToDouble()) {
      return '${number.toInt()} €';
    }
    return '${number.toStringAsFixed(2)} €';
  }

  dynamic _lowestOfferValue(dynamic offer, dynamic shipment) {
    return offer['lowestOffer'] ??
        offer['lowest_offer'] ??
        offer['lowestAmount'] ??
        offer['lowest_amount'] ??
        shipment['lowestOffer'] ??
        shipment['lowest_offer'] ??
        shipment['lowestAmount'] ??
        shipment['lowest_amount'];
  }

  bool _isMyOfferLowest(dynamic myOfferValue, dynamic lowestOfferValue) {
    final myOffer = _number(myOfferValue);
    final lowestOffer = _number(lowestOfferValue);

    if (myOffer == null || lowestOffer == null) return false;

    return myOffer <= lowestOffer;
  }

  bool _isAcceptedOffer(String status) {
    final s = status.toLowerCase().trim();

    return s == 'accepted' ||
        s == 'prihvacena' ||
        s == 'prihvaćena' ||
        s == 'prihvaceno' ||
        s == 'prihvaćeno';
  }

  bool _isRejectedOffer(String status) {
    final s = status.toLowerCase().trim();

    return s == 'rejected' ||
        s == 'odbijena' ||
        s == 'odbijeno' ||
        s == 'nadmaseno' ||
        s == 'nadmašeno';
  }

  bool _isCompletedShipment(String status) {
    final s = status.toLowerCase().trim();

    return s == 'completed' ||
        s == 'zavrseno' ||
        s == 'završeno';
  }

  bool _isAcceptedShipment(String status) {
    final s = status.toLowerCase().trim();

    return s == 'accepted' ||
        s == 'prihvaceno' ||
        s == 'prihvaćeno' ||
        s == 'offer_accepted';
  }

  bool _isExpiredShipment(String status) {
    final s = status.toLowerCase().trim();

    return s == 'licitacija_zavrsena' ||
        s == 'licitacija završena' ||
        s == 'expired' ||
        s == 'isteklo';
  }

  String _offerDisplayStatus({
    required String offerStatus,
    required String shipmentStatus,
    required bool isLowest,
  }) {
    if (_isCompletedShipment(shipmentStatus)) {
      return 'Licitacija završena';
    }

    if (_isAcceptedOffer(offerStatus)) {
      return 'Prihvaćena';
    }

    if (_isRejectedOffer(offerStatus)) {
      return 'Nadmašena';
    }

    if (_isExpiredShipment(shipmentStatus)) {
      return 'Licitacija završena';
    }

    if (isLowest) {
      return 'Najniža';
    }

    return 'Nadmašena';
  }

  Color _offerDisplayColor(String label) {
    switch (label) {
      case 'Prihvaćena':
        return Colors.green;
      case 'Najniža':
        return Colors.green;
      case 'Nadmašena':
        return Colors.orange;
      case 'Završeno':
        return Colors.blue;
      case 'Licitacija završena':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  String _shipmentStatusText(String status) {
    final s = status.toLowerCase().trim();

    if (s == 'active' || s == 'aktivan' || s == 'open') {
      return 'Aktivan';
    }

    if (_isAcceptedShipment(status)) {
      return 'Prijevoz dogovoren';
    }

    if (_isCompletedShipment(status)) {
      return 'Prijevoz dogovoren';
    }

    if (_isExpiredShipment(status)) {
      return 'Licitacija završena';
    }

    return status == '—' ? '—' : status;
  }

  Color _shipmentStatusColor(String status) {
    final s = status.toLowerCase().trim();

    if (s == 'active' || s == 'aktivan' || s == 'open') {
      return Colors.green;
    }

    if (_isAcceptedShipment(status)) {
      return Colors.orange;
    }

    if (_isCompletedShipment(status)) {
      return Colors.blue;
    }

    if (_isExpiredShipment(status)) {
      return Colors.red;
    }

    return Colors.blueGrey;
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    FontWeight valueWeight = FontWeight.w600,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.blueGrey.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontWeight: valueWeight,
                      color: valueColor ?? Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.28)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  Widget _buildOfferCard(dynamic rawOffer) {
    final offer = rawOffer is Map
        ? Map<String, dynamic>.from(rawOffer)
        : <String, dynamic>{};

    final rawShipment = offer['shipment'];
    final shipment = rawShipment is Map
        ? Map<String, dynamic>.from(rawShipment)
        : <String, dynamic>{};

    final shipmentId = shipment['id'];
    final offerStatus = _text(offer['status'], 'active');
    final shipmentStatus = _text(shipment['status'], '—');

    final mjestoUtovara = _text(shipment['mjesto_utovara']);
    final mjestoIstovara = _text(shipment['mjesto_istovara']);
    final nazivTereta = _text(shipment['naziv_tereta'], 'Teret');
    final mojaPonuda = _priceText(offer['amount']);
    final offersCount = shipment['offersCount'] ?? 0;
    final lowestOfferValue = _lowestOfferValue(offer, shipment);
    final poruka = _text(offer['message'], '');
    final tezina =
    shipment['tezina_kg'] != null ? '${shipment['tezina_kg']} kg' : '—';

    final isLowest = _isMyOfferLowest(offer['amount'], lowestOfferValue);

    final displayStatus = _offerDisplayStatus(
      offerStatus: offerStatus,
      shipmentStatus: shipmentStatus,
      isLowest: isLowest,
    );

    final displayColor = _offerDisplayColor(displayStatus);

    final isAccepted = _isAcceptedOffer(offerStatus);
    final isRejected = _isRejectedOffer(offerStatus);

    final isCommissionPaid = offer['commissionPaid'] == true ||
        offer['commission_paid'] == true ||
        offer['provizijaPlacena'] == true ||
        offer['provizija_placena'] == true;

    return Material(
        color: Colors.white,
        elevation: 0.7,
        borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildStatusChip(displayStatus, displayColor),
                _buildStatusChip(
                  'Teret: ${_shipmentStatusText(shipmentStatus)}',
                  _shipmentStatusColor(shipmentStatus),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '$mjestoUtovara → $mjestoIstovara',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              nazivTereta,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.blueGrey.shade800,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.euro,
              label: 'Moja ponuda',
              value: mojaPonuda,
              valueColor: displayColor,
              valueWeight: FontWeight.w800,
            ),
            _buildInfoRow(
              icon: Icons.trending_down,
              label: 'Broj ponuda',
              value: offersCount.toString(),
              valueColor: isLowest ? Colors.green : Colors.orange,
              valueWeight: FontWeight.w800,
            ),
            _buildInfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Utovar',
              value: 'Po dogovoru',
            ),
            _buildInfoRow(
              icon: Icons.scale_outlined,
              label: 'Težina',
              value: tezina,
            ),
            if (poruka.isNotEmpty && poruka != '—')
              _buildInfoRow(
                icon: Icons.message_outlined,
                label: 'Moja poruka',
                value: poruka,
              ),
            if (isAccepted && !isCommissionPaid)
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.35)),
                ),
                child: const Text(
                  '🔒 Ponuda je prihvaćena. Otvori detalje tereta i otključaj kontakt.',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ),
            if (isAccepted && isCommissionPaid)
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Kontakt otključan — možete započeti dogovor.',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.green,
                  ),
                ),
              ),
            const SizedBox(height: 6),
            if (isRejected)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: const Text(
                  'Drugi prijevoznik je odabran za ovaj prijevoz.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: shipmentId == null
                      ? null
                      : () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ShipmentDetailsScreen(
                          shipmentId: shipmentId,
                        ),
                      ),
                    );

                    if (!mounted) return;
                    fetchMyOffers();
                  },
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Detalji tereta'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey.shade900,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 54,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 14),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: fetchMyOffers,
                child: const Text('Pokušaj ponovno'),
              ),
            ],
          ),
        ),
      );
    }

    if (offers.isEmpty) {
      return RefreshIndicator(
        onRefresh: fetchMyOffers,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
          children: const [
            Icon(
              Icons.local_shipping_outlined,
              size: 70,
              color: Colors.blueGrey,
            ),
            SizedBox(height: 16),
            Text(
              'Još nemaš nijednu ponudu.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Kad pošalješ ponudu na neki teret, ovdje će se prikazati.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchMyOffers,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: offers.length,
        itemBuilder: (context, index) {
          return _buildOfferCard(offers[index]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Moje ponude',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Osvježi',
            onPressed: fetchMyOffers,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
}