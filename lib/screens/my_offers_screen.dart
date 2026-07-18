import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../services/token_storage.dart';
import 'login_screen.dart';
import 'shipment_details_screen.dart';
import 'send_offer_screen.dart';

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

      setState(() {
        errorMessage = 'Greška pri dohvaćanju mojih ponuda.';
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

  Future<void> _hideOfferFromHistory(int offerId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ukloniti iz povijesti?'),
        content: const Text(
          'Ponuda će nestati iz vašeg popisa, ali neće biti trajno obrisana iz sustava.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Odustani'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ukloni'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      _goToLogin('Niste prijavljeni. Prijavite se ponovno.');
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('${AppConfig.baseUrl}/offers/$offerId/hide'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          offers.removeWhere((item) {
            if (item is Map) {
              return '${item['id']}' == '$offerId';
            }
            return false;
          });
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ponuda je uklonjena iz povijesti.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Uklanjanje nije uspjelo.'),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Greška konekcije sa serverom.'),
        ),
      );
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
    return text.isEmpty ? fallback : text;
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

  bool _isActiveShipment(String status) {
    final s = status.toLowerCase().trim();

    return s == 'active' || s == 'aktivan' || s == 'open';
  }

  bool _canHideOffer({
    required String offerStatus,
    required String shipmentStatus,
  }) {
    if (_isRejectedOffer(offerStatus)) return true;
    if (_isExpiredShipment(shipmentStatus)) return true;
    if (_isCompletedShipment(shipmentStatus)) return true;

    if (_isAcceptedShipment(shipmentStatus) && !_isAcceptedOffer(offerStatus)) {
      return true;
    }

    return false;
  }

  String _offerDisplayStatus({
    required String offerStatus,
    required String shipmentStatus,
    required bool isLowest,
  }) {
    if (_isAcceptedShipment(shipmentStatus) ||
        _isCompletedShipment(shipmentStatus) ||
        _isExpiredShipment(shipmentStatus)) {
      return 'Završeno';
    }

    if (_isAcceptedOffer(offerStatus)) {
      return 'Prihvaćena';
    }

    if (isLowest) {
      return 'Najniža';
    }

    return 'Nadmašena';
  }

  Color _offerDisplayColor(String label) {
    switch (label) {
      case 'Prihvaćena':
      case 'Najniža':
        return Colors.green;
      case 'Nadmašena':
        return Colors.orange;
      case 'Završeno':
        return Colors.grey;
      case 'Licitacija završena':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  String _shipmentStatusText(String status) {
    if (_isActiveShipment(status)) return 'Aktivan';
    if (_isAcceptedShipment(status)) return 'Ponuda prihvaćena';
    if (_isCompletedShipment(status)) return 'Korisnici povezani';
    if (_isExpiredShipment(status)) return 'Licitacija završena';

    return status == '—' ? '—' : status;
  }

  Color _shipmentStatusColor(String status) {
    if (_isActiveShipment(status)) return Colors.green;
    if (_isAcceptedShipment(status)) return Colors.orange;
    if (_isCompletedShipment(status)) return Colors.blue;
    if (_isExpiredShipment(status)) return Colors.red;

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

    final offerId = offer['id'] is int
        ? offer['id'] as int
        : int.tryParse('${offer['id']}') ?? 0;

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
    final isShipmentActive = _isActiveShipment(shipmentStatus);

    final canSendNewOffer = isShipmentActive && !isLowest;

    final canHideOffer = offerId > 0 &&
        _canHideOffer(
          offerStatus: offerStatus,
          shipmentStatus: shipmentStatus,
        );

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
            if (isAccepted && !isRejected && !isCommissionPaid)
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: shipmentId == null
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
                child: Container(
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
              ),
            if (isAccepted && !isRejected && isCommissionPaid)
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: shipmentId == null
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
                child: Container(
                  width: double.infinity,
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
              ),
            const SizedBox(height: 6),
            if (canSendNewOffer)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.local_offer),
                  label: const Text('Pošalji novu ponudu'),
                  onPressed: shipmentId == null
                      ? null
                      : () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SendOfferScreen(
                          shipmentId: shipmentId,
                        ),
                      ),
                    );

                    if (!mounted) return;
                    fetchMyOffers();
                  },
                ),
              ),
            if (isRejected)
              Column(
                children: [
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
                  ),
                ],
              ),
            if (canHideOffer) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _hideOfferFromHistory(offerId),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Ukloni iz povijesti'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
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
              'Još niste poslali nijednu ponudu.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Kad pošaljete ponudu za neki teret, ovdje će biti prikazane sve vaše ponude.',
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
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: offers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
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