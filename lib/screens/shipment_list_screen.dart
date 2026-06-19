import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../services/token_storage.dart';
import 'login_screen.dart';
import 'role_picker_screen.dart';
import 'shipment_details_screen.dart';
import 'user_profile_screen.dart';
class ShipmentListScreen extends StatefulWidget {
  const ShipmentListScreen({super.key});

  @override
  State<ShipmentListScreen> createState() => _ShipmentListScreenState();
}

class _ShipmentListScreenState extends State<ShipmentListScreen> {
  bool isLoading = true;
  String errorMessage = '';
  List<dynamic> shipments = [];

  Timer? refreshTimer;
  Timer? timerRefresh;

  @override
  void initState() {
    super.initState();
    fetchShipments();

    refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
          (_) => fetchShipments(silent: true),
    );

    timerRefresh = Timer.periodic(
      const Duration(seconds: 30),
          (_) {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    timerRefresh?.cancel();
    super.dispose();
  }

  Future<void> goToRolePicker() async {
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const RolePickerScreen()),
          (route) => false,
    );
  }

  Future<void> fetchShipments({bool silent = false}) async {
    if (!mounted) return;

    if (!silent) {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });
    }

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

      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/shipments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final list = data is List ? data : [];

        setState(() {
          shipments = list.where((item) {
            if (item is! Map) return false;

            final status = readString(item, ['status'], fallback: 'aktivan')
                .toLowerCase()
                .trim();

            return status == 'aktivan' ||
                status == 'active' ||
                status == 'open' ||
                status == 'prihvaceno' ||
                status == 'prihvaćeno' ||
                status == 'accepted' ||
                status == 'offer_accepted';
          }).toList();

          isLoading = false;
        });
      } else {
        if (!silent) {
          setState(() {
            errorMessage = 'Greška pri dohvaćanju tereta.';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (!silent) {
        setState(() {
          errorMessage = 'Greška konekcije sa serverom.';
          isLoading = false;
        });
      }
    }
  }

  bool isNewShipment(Map item) {
    final createdAt = item['createdAt'];
    if (createdAt == null) return false;

    try {
      final created = DateTime.parse(createdAt);
      final now = DateTime.now();

      return now.difference(created).inMinutes <= 60;
    } catch (_) {
      return false;
    }
  }

  String readString(Map item, List<String> keys, {String fallback = '-'}) {
    for (final key in keys) {
      final value = item[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return fallback;
  }

  int? readInt(Map item, List<String> keys) {
    for (final key in keys) {
      final value = item[key];
      if (value == null) continue;

      final parsed = int.tryParse(value.toString());
      if (parsed != null) return parsed;
    }
    return null;
  }

  String formatRoute(Map item) {
    final from = readString(item, ['mjesto_utovara']);
    final to = readString(item, ['mjesto_istovara']);
    return '$from → $to';
  }

  String formatLicitacijaTimer(Map item) {
    final raw = readString(
      item,
      ['licitacija_zavrsava_at', 'licitacijaZavrsavaAt'],
      fallback: '',
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

  String formatNacinUtovara(Map item) {
    final value = readString(
      item,
      ['nacin_utovara', 'nacinUtovara', 'loadingType'],
      fallback: '',
    );

    final lower = value.toLowerCase().trim();

    if (lower.contains('vili') || lower.contains('stroj')) {
      return 'STROJNO';
    }

    if (lower.contains('ruč') ||
        lower.contains('ruc') ||
        lower.contains('manual')) {
      return 'RUČNO';
    }

    return '';
  }

  Color nacinUtovaraColor(String value) {
    if (value == 'STROJNO') return Colors.deepOrange;
    if (value == 'RUČNO') return Colors.blueGrey;
    return Colors.grey;
  }

  Widget smartBadge({
    required String text,
    required Color color,
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 4, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 2),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSmartBadges(
      Map item,
      int ponude,
      int pregledi,
      String rok,
      String trajanjeLicitacije,
      bool isNew,
      bool licitacijaZavrsena,
      bool accepted,
      ) {
    final nacinUtovara = formatNacinUtovara(item);

    return Wrap(
      spacing: 4,
      runSpacing: 2,
      children: [
        if (isNew)
          smartBadge(
            text: 'NOVO',
            color: Colors.red,
            icon: Icons.fiber_new,
          ),
        smartBadge(
          text: accepted
              ? 'PRIHVAĆENO'
              : licitacijaZavrsena
              ? 'ZAVRŠENA'
              : 'AKTIVAN',
          color: accepted
              ? Colors.orange
              : licitacijaZavrsena
              ? Colors.red
              : Colors.green,
        ),
        if (trajanjeLicitacije != '-')
          smartBadge(
            text: 'Licitacija $trajanjeLicitacije',
            color: Colors.deepPurple,
            icon: Icons.timer_outlined,
          ),
        if (rok != '-') smartBadge(text: rok, color: Colors.orange),
        if (nacinUtovara.isNotEmpty)
          smartBadge(
            text: nacinUtovara,
            color: nacinUtovaraColor(nacinUtovara),
            icon: nacinUtovara == 'STROJNO'
                ? Icons.precision_manufacturing_outlined
                : Icons.pan_tool_alt_outlined,
          ),
        smartBadge(
          text: '$ponude ponuda',
          color: Colors.teal,
          icon: Icons.gavel,
        ),
        smartBadge(text: '👁 $pregledi', color: Colors.indigo),
      ],
    );
  }

  Widget buildShipmentCard(Map item) {
    final id = readInt(item, ['id']) ?? 0;
    final isNew = isNewShipment(item);

    final status = readString(item, ['status'], fallback: 'aktivan')
        .toLowerCase()
        .trim();

    final accepted = status == 'prihvaceno' ||
        status == 'prihvaćeno' ||
        status == 'accepted' ||
        status == 'offer_accepted';

    final naziv = readString(item, ['naziv_tereta', 'title'], fallback: 'Teret');
    final tezina = readString(item, ['tezina_kg'], fallback: '');
    final datum = readString(item, ['datum_utovara'], fallback: '');

    final ponude = readInt(item, ['offersCount', 'broj_ponuda']) ?? 0;
    final lowestOffer = readInt(item, ['lowestOffer']);

    final pregledi = readInt(item, ['viewsCount', 'broj_pregleda']) ?? 0;
    final rok = readString(item, ['rok_utovara'], fallback: '-');
    final trajanjeLicitacije = readString(
      item,
      ['trajanje_licitacije', 'trajanjeLicitacije'],
      fallback: '-',
    );
    final senderId = readInt(item, ['senderId']);
    final senderName = readString(item, ['senderName'], fallback: 'Naručitelj');
    final senderRatingAverage = readString(
      item,
      ['senderRatingAverage'],
      fallback: '',
    );
    final senderRatingsCount = readInt(item, ['senderRatingsCount']) ?? 0;
    final timerText = formatLicitacijaTimer(item);
    final licitacijaZavrsena = timerText == 'Licitacija završena';

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        elevation: 0.7,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ShipmentDetailsScreen(shipmentId: id),
              ),
            ).then((_) => fetchShipments(silent: true));
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatRoute(item),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  naziv,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (senderId != null && senderRatingAverage.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserProfileScreen(
                            userId: senderId,
                            userName: senderName,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Text(
                        '👤 $senderName ⭐ $senderRatingAverage ($senderRatingsCount)',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  '$tezina kg • $datum',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
                if (lowestOffer != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    accepted
                        ? 'Prihvaćena ponuda: $lowestOffer €'
                        : 'Trenutna najniža ponuda: $lowestOffer €',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.teal,
                    ),
                  ),
                ],
                if (timerText.isNotEmpty && !accepted) ...[
                  const SizedBox(height: 4),
                  Text(
                    timerText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: licitacijaZavrsena
                          ? Colors.red
                          : Colors.deepOrange,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                buildSmartBadges(
                  item,
                  ponude,
                  pregledi,
                  rok,
                  trajanjeLicitacije,
                  isNew,
                  licitacijaZavrsena,
                  accepted,
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ShipmentDetailsScreen(shipmentId: id),
                        ),
                      ).then((_) => fetchShipments(silent: true));
                    },
                    icon: const Icon(Icons.inventory_2_outlined, size: 18),
                    label: const Text('Detalji tereta'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista tereta'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            errorMessage,
            textAlign: TextAlign.center,
          ),
        ),
      )
          : RefreshIndicator(
        onRefresh: fetchShipments,
        child: ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: shipments.length,
          itemBuilder: (context, index) {
            final item = shipments[index];
            if (item is Map) return buildShipmentCard(item);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}