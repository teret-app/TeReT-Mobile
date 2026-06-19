import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../services/token_storage.dart';
import 'login_screen.dart';
import 'shipment_details_screen.dart';
import 'shipment_offers_screen.dart';
import 'bid_history_screen.dart';

class MyShipmentsScreen extends StatefulWidget {
  const MyShipmentsScreen({super.key});

  @override
  State<MyShipmentsScreen> createState() => _MyShipmentsScreenState();
}

class _MyShipmentsScreenState extends State<MyShipmentsScreen> {
  bool isLoading = true;
  String errorMessage = '';
  List<dynamic> shipments = [];

  @override
  void initState() {
    super.initState();
    fetchShipments();
  }

  Future<void> fetchShipments() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = '';
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
      final start = DateTime.now();
      final res = await http.get(
        Uri.parse('${AppConfig.baseUrl}/my-shipments'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print(
        'MY SHIPMENTS API: ${DateTime.now().difference(start).inMilliseconds} ms',
      );
      if (!mounted) return;

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);

        setState(() {
          if (decoded is List) {
            shipments = decoded;
          } else if (decoded is Map && decoded['shipments'] is List) {
            shipments = decoded['shipments'];
          } else {
            shipments = [];
          }
          isLoading = false;
        });
      } else if (res.statusCode == 401) {
        await TokenStorage.clearToken();

        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
        );
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Greška pri dohvaćanju mojih objava.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = 'Greška konekcije sa serverom.';
      });
    }
  }

  Future<void> _repostShipment(int shipmentId) async {
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

    try {
      final res = await http.post(
        Uri.parse('${AppConfig.baseUrl}/shipments/$shipmentId/repost'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (!mounted) return;

      if (res.statusCode == 200 || res.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Teret je ponovno objavljen.'),
          ),
        );
        fetchShipments();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ponovna objava nije uspjela.'),
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

  String _text(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  bool _isActiveStatus(String status) {
    final s = status.toLowerCase().trim();

    return s == 'aktivan' || s == 'active' || s == 'open';
  }

  bool _isAcceptedStatus(String status) {
    final s = status.toLowerCase().trim();

    return s == 'prihvaceno' ||
        s == 'prihvaćeno' ||
        s == 'accepted' ||
        s == 'offer_accepted';
  }

  bool _isCompletedStatus(String status) {
    final s = status.toLowerCase().trim();

    return s == 'zavrseno' ||
        s == 'završeno' ||
        s == 'completed';
  }

  bool _isExpiredStatus(String status) {
    final s = status.toLowerCase().trim();

    return s == 'licitacija_zavrsena' ||
        s == 'licitacija završena' ||
        s == 'expired' ||
        s == 'isteklo';
  }

  String _statusLabel(String status) {
    final s = status.toLowerCase().trim();

    if (_isActiveStatus(status)) {
      return 'Aktivno';
    }

    if (_isAcceptedStatus(status)) {
      return 'Prijevoz dogovoren';
    }

    if (_isCompletedStatus(status)) {
      return 'Završeno';
    }

    if (_isExpiredStatus(status)) {
      return 'Licitacija završena';
    }

    return s.isEmpty ? 'Nepoznato' : status;
  }

  Color _statusColor(String status) {
    if (_isActiveStatus(status)) {
      return Colors.green;
    }

    if (_isAcceptedStatus(status)) {
      return Colors.orange;
    }

    if (_isCompletedStatus(status)) {
      return Colors.blue;
    }

    if (_isExpiredStatus(status)) {
      return Colors.red;
    }

    return Colors.grey;
  }

  String _formatMoney(dynamic value) {
    if (value == null) return '-';

    final number = num.tryParse(value.toString().replaceAll(',', '.'));

    if (number == null) return '$value €';

    if (number == number.roundToDouble()) {
      return '${number.toInt()} €';
    }

    return '${number.toStringAsFixed(2)} €';
  }

  String _formatLicitacijaTimer(Map<String, dynamic> shipment) {
    final raw = _text(
      shipment['licitacija_zavrsava_at'],
      '',
    );

    if (raw.isEmpty) return '';

    try {
      final end = DateTime.parse(raw).toLocal();
      final diff = end.difference(DateTime.now());

      if (diff.isNegative || diff.inSeconds <= 0) {
        return 'Licitacija završena';
      }

      final hours = diff.inHours;
      final minutes = diff.inMinutes.remainder(60);

      if (hours > 0) {
        return 'Još ${hours}h ${minutes}min';
      }

      return 'Još ${minutes}min';
    } catch (_) {
      return '';
    }
  }

  Future<void> _openShipmentDetails(int shipmentId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShipmentDetailsScreen(
          shipmentId: shipmentId,
          isSenderView: true,
        ),
      ),
    );

    if (!mounted) return;
    fetchShipments();
  }

  Future<void> _openShipmentOffers(int shipmentId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShipmentOffersScreen(
          shipmentId: shipmentId,
        ),
      ),
    );

    if (!mounted) return;
    fetchShipments();
  }

  Future<void> _openBidHistory(int shipmentId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BidHistoryScreen(
          shipmentId: shipmentId,
        ),
      ),
    );

    if (!mounted) return;
    fetchShipments();
  }

  Widget _buildBadge({
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildShipmentCard(Map<String, dynamic> shipment) {
    final int shipmentId = shipment['id'] is int
        ? shipment['id']
        : int.tryParse('${shipment['id']}') ?? 0;

    final String nazivTereta = _text(shipment['naziv_tereta'], 'Teret');
    final String mjestoUtovara = _text(shipment['mjesto_utovara'], '-');
    final String mjestoIstovara = _text(shipment['mjesto_istovara'], '-');
    final String status = _text(shipment['status'], '');

    final bool isAccepted = _isAcceptedStatus(status);
    final bool isCompleted = _isCompletedStatus(status);
    final bool isExpiredStatus = _isExpiredStatus(status);

    final String timerText = _formatLicitacijaTimer(shipment);
    final bool timerExpired = timerText == 'Licitacija završena';

    final String trajanjeLicitacije = _text(shipment['trajanje_licitacije'], '');

    final bool licitacijaZavrsena =
        timerExpired || isAccepted || isCompleted || isExpiredStatus;

    final String trajanjePrikaz = licitacijaZavrsena
        ? 'Licitacija završena'
        : (trajanjeLicitacije.isNotEmpty
        ? 'Licitacija: $trajanjeLicitacije'
        : 'Licitacija');

    final int offerCount = shipment['offersCount'] is int
        ? shipment['offersCount']
        : int.tryParse('${shipment['offersCount']}') ?? 0;

    final int views = shipment['viewsCount'] is int
        ? shipment['viewsCount']
        : int.tryParse('${shipment['viewsCount'] ?? shipment['views']}') ?? 0;

    final dynamic lowestOffer = shipment['lowestOffer'];

    final bool showTimerText =
        timerText.isNotEmpty && !isAccepted && !isCompleted && !isExpiredStatus;

    final bool showRepostButton =
        (timerExpired || isExpiredStatus) &&
            offerCount == 0 &&
            !isAccepted &&
            !isCompleted;

    final bool canOpenOffers = shipmentId > 0;
    final bool canOpenBidHistory = shipmentId > 0;

    return Material(
        color: Colors.white,
        elevation: 0.7,
        borderRadius: BorderRadius.circular(10),

      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    nazivTereta,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildBadge(
                  text: _statusLabel(status),
                  color: _statusColor(status),
                ),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              '$mjestoUtovara → $mjestoIstovara',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildBadge(
                  text: trajanjePrikaz,
                  color: licitacijaZavrsena ? Colors.red : Colors.blueGrey,
                ),
                _buildBadge(
                  text: 'Ponude: $offerCount',
                  color: Colors.deepPurple,
                ),
                _buildBadge(
                  text: 'Pregledi: $views',
                  color: Colors.blueGrey,
                ),
              ],
            ),
            if (showTimerText) ...[
              const SizedBox(height: 8),
              Text(
                timerText,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: timerExpired ? Colors.red : Colors.deepOrange,
                ),
              ),
            ],
            if (lowestOffer != null) ...[
              const SizedBox(height: 8),
              Text(
                'Najniža ponuda: ${_formatMoney(lowestOffer)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: shipmentId > 0
                        ? () => _openShipmentDetails(shipmentId)
                        : null,
                    child: const Text('Detalji'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: canOpenOffers
                        ? () => _openShipmentOffers(shipmentId)
                        : null,
                    child: const Text('Ponude'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: canOpenBidHistory
                    ? () => _openBidHistory(shipmentId)
                    : null,
                child: const Text('Tijek licitacije'),
              ),
            ),
            if (showRepostButton) ...[
              const SizedBox(height: 7),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: shipmentId > 0
                      ? () => _repostShipment(shipmentId)
                      : null,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Ponovno objavi'),
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
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage.isNotEmpty) {
      return RefreshIndicator(
        onRefresh: fetchShipments,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (shipments.isEmpty) {
      return RefreshIndicator(
        onRefresh: fetchShipments,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: const [
            SizedBox(height: 120),
            Center(
              child: Text(
                'Trenutno nemaš nijednu objavu.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchShipments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: shipments.length,
        itemBuilder: (context, index) {
          final item = shipments[index];

          if (item is Map<String, dynamic>) {
            return _buildShipmentCard(item);
          }

          if (item is Map) {
            return _buildShipmentCard(
              Map<String, dynamic>.from(item),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moje objave'),
      ),
      body: _buildBody(),
    );
  }
}