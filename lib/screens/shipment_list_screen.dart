import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../l10n/app_localizations.dart';
import '../services/token_storage.dart';
import '../utils/country_helper.dart';
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
        if (mounted) {
          setState(() {});
        }
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
      MaterialPageRoute(
        builder: (_) => const RolePickerScreen(),
      ),
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

      if (!mounted) return;

      if (token == null || token.isEmpty) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
              (route) => false,
        );
        return;
      }
      final stopwatch = Stopwatch()..start();
      debugPrint('SHIPMENTS REQUEST START');
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/shipments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      stopwatch.stop();
      debugPrint(
        'SHIPMENTS REQUEST FINISHED: ${stopwatch.elapsedMilliseconds} ms',
      );
      if (!mounted) return;

      final dynamic data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final list = data is List ? data : <dynamic>[];

        setState(() {
          shipments = list.where((item) {
            if (item is! Map) return false;

            final status = readString(
              item,
              ['status'],
              fallback: 'aktivan',
            ).toLowerCase().trim();

            return status == 'aktivan' ||
                status == 'active' ||
                status == 'open' ||
                status == 'prihvaceno' ||
                status == 'prihvaćeno' ||
                status == 'accepted' ||
                status == 'offer_accepted';
          }).toList();

          isLoading = false;
          errorMessage = '';
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
      if (!mounted) return;

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
      final created = DateTime.parse(createdAt.toString());
      final now = DateTime.now();

      return now.difference(created).inMinutes <= 60;
    } catch (_) {
      return false;
    }
  }

  String readString(
      Map item,
      List<String> keys, {
        String fallback = '-',
      }) {
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

      if (parsed != null) {
        return parsed;
      }
    }

    return null;
  }

  num? readNumber(Map item, List<String> keys) {
    for (final key in keys) {
      final value = item[key];

      if (value == null) continue;

      final parsed = num.tryParse(
        value.toString().replaceAll(',', '.'),
      );

      if (parsed != null) {
        return parsed;
      }
    }

    return null;
  }

  String formatMoney(num? value) {
    if (value == null) return '-';

    return '${value.toStringAsFixed(2).replaceAll('.', ',')} €';
  }

  String formatRoute(Map item) {
    final fromCountry = readString(
      item,
      [
        'drzava_utovara',
        'drzavaUtovara',
        'country_utovara',
        'loadingCountry',
      ],
      fallback: '',
    );

    final toCountry = readString(
      item,
      [
        'drzava_istovara',
        'drzavaIstovara',
        'country_istovara',
        'unloadingCountry',
      ],
      fallback: '',
    );

    final from = readString(
      item,
      [
        'mjesto_utovara',
        'mjestoUtovara',
        'loadingPlace',
      ],
    );

    final to = readString(
      item,
      [
        'mjesto_istovara',
        'mjestoIstovara',
        'unloadingPlace',
      ],
    );

    return '${countryFlag(fromCountry)} $from → '
        '${countryFlag(toCountry)} $to';
  }

  String formatAuctionTimer(
      AppLocalizations l10n,
      Map item,
      ) {
    final raw = readString(
      item,
      [
        'licitacija_zavrsava_at',
        'licitacijaZavrsavaAt',
      ],
      fallback: '',
    );

    if (raw.isEmpty) return '';

    try {
      final end = DateTime.parse(raw).toLocal();
      final difference = end.difference(DateTime.now());

      if (difference.isNegative || difference.inSeconds <= 0) {
        return l10n.auctionFinished;
      }

      final hours = difference.inHours;
      final minutes = difference.inMinutes.remainder(60);

      if (hours > 0) {
        return l10n.auctionEndsInHours(hours, minutes);
      }

      return l10n.auctionEndsInMinutes(minutes);
    } catch (_) {
      return '';
    }
  }

  String localizedAuctionDuration(
      AppLocalizations l10n,
      String value,
      ) {
    if (value.trim().isEmpty || value == '-') {
      return '-';
    }

    final normalized = value.toLowerCase().trim();
    final numberMatch = RegExp(r'\d+').firstMatch(normalized);
    final hours = int.tryParse(numberMatch?.group(0) ?? '');

    if (hours == null) {
      return value;
    }

    return l10n.auctionDurationHours(hours);
  }

  String loadingMethodCode(Map item) {
    final value = readString(
      item,
      [
        'nacin_utovara',
        'nacinUtovara',
        'loadingType',
      ],
      fallback: '',
    );

    final normalized = value.toLowerCase().trim();

    if (normalized.contains('vili') ||
        normalized.contains('stroj') ||
        normalized.contains('machine')) {
      return 'machine';
    }

    if (normalized.contains('ruč') ||
        normalized.contains('ruc') ||
        normalized.contains('manual')) {
      return 'manual';
    }

    return '';
  }

  String localizedLoadingMethod(
      AppLocalizations l10n,
      String methodCode,
      ) {
    if (methodCode == 'machine') {
      return l10n.machineLoadingUppercase;
    }

    if (methodCode == 'manual') {
      return l10n.manualLoadingUppercase;
    }

    return '';
  }

  Color loadingMethodColor(String methodCode) {
    if (methodCode == 'machine') {
      return Colors.deepOrange;
    }

    if (methodCode == 'manual') {
      return Colors.blueGrey;
    }

    return Colors.grey;
  }

  Widget smartBadge({
    required String text,
    required Color color,
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(
        right: 4,
        bottom: 4,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 10,
              color: color,
            ),
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
      AppLocalizations l10n,
      Map item,
      int offers,
      int views,
      String loadingDeadline,
      String auctionDuration,
      bool isNew,
      bool auctionFinished,
      bool accepted,
      ) {
    final loadingMethod = loadingMethodCode(item);

    return Wrap(
      spacing: 4,
      runSpacing: 2,
      children: [
        if (isNew)
          smartBadge(
            text: l10n.newUppercase,
            color: Colors.red,
            icon: Icons.fiber_new,
          ),
        smartBadge(
          text: accepted
              ? l10n.acceptedUppercase
              : auctionFinished
              ? l10n.finishedUppercase
              : l10n.activeUppercase,
          color: accepted
              ? Colors.orange
              : auctionFinished
              ? Colors.red
              : Colors.green,
        ),
        if (auctionDuration != '-')
          smartBadge(
            text: l10n.auctionDurationBadge(auctionDuration),
            color: Colors.deepPurple,
            icon: Icons.timer_outlined,
          ),
        if (loadingDeadline != '-')
          smartBadge(
            text: loadingDeadline,
            color: Colors.orange,
          ),
        if (loadingMethod.isNotEmpty)
          smartBadge(
            text: localizedLoadingMethod(
              l10n,
              loadingMethod,
            ),
            color: loadingMethodColor(loadingMethod),
            icon: loadingMethod == 'machine'
                ? Icons.precision_manufacturing_outlined
                : Icons.pan_tool_alt_outlined,
          ),
        smartBadge(
          text: l10n.offersCount(offers),
          color: Colors.teal,
          icon: Icons.gavel,
        ),
        smartBadge(
          text: '👁 $views',
          color: Colors.indigo,
        ),
      ],
    );
  }

  Widget buildShipmentCard(
      AppLocalizations l10n,
      Map item,
      ) {
    final id = readInt(item, ['id']) ?? 0;
    final isNew = isNewShipment(item);

    final status = readString(
      item,
      ['status'],
      fallback: 'aktivan',
    ).toLowerCase().trim();

    final accepted = status == 'prihvaceno' ||
        status == 'prihvaćeno' ||
        status == 'accepted' ||
        status == 'offer_accepted';

    final title = readString(
      item,
      [
        'naziv_tereta',
        'nazivTereta',
        'title',
      ],
      fallback: l10n.cargo,
    );

    final weight = readString(
      item,
      [
        'tezina_cca_kg',
        'tezinaCcaKg',
        'tezina_kg',
        'tezinaKg',
        'tezina',
        'weight_kg',
        'weightKg',
        'weight',
      ],
      fallback: '',
    );

    final createdAtRaw = readString(
      item,
      [
        'createdAt',
        'created_at',
      ],
      fallback: '',
    );

    String publishedDate = '';

    if (createdAtRaw.isNotEmpty) {
      try {
        final createdAt = DateTime.parse(
          createdAtRaw,
        ).toLocal();

        publishedDate =
        '${createdAt.day.toString().padLeft(2, '0')}.'
            '${createdAt.month.toString().padLeft(2, '0')}.'
            '${createdAt.year}.';
      } catch (_) {
        publishedDate = '';
      }
    }

    final offers = readInt(
      item,
      [
        'offersCount',
        'broj_ponuda',
      ],
    ) ??
        0;

    final lowestOffer = readNumber(
      item,
      [
        'lowestOffer',
        'lowest_offer',
      ],
    );

    final views = readInt(
      item,
      [
        'viewsCount',
        'broj_pregleda',
      ],
    ) ??
        0;

    final loadingDeadline = readString(
      item,
      [
        'rok_utovara',
        'rokUtovara',
      ],
      fallback: '-',
    );

    final rawAuctionDuration = readString(
      item,
      [
        'trajanje_licitacije',
        'trajanjeLicitacije',
      ],
      fallback: '-',
    );

    final auctionDuration = localizedAuctionDuration(
      l10n,
      rawAuctionDuration,
    );

    final senderId = readInt(
      item,
      ['senderId'],
    );

    final senderName = readString(
      item,
      ['senderName'],
      fallback: l10n.sender,
    );

    final senderRatingAverage = readString(
      item,
      ['senderRatingAverage'],
      fallback: '',
    );

    final senderRatingsCount = readInt(
      item,
      ['senderRatingsCount'],
    ) ??
        0;

    final timerText = formatAuctionTimer(
      l10n,
      item,
    );

    final auctionFinished = timerText == l10n.auctionFinished;

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
                builder: (_) => ShipmentDetailsScreen(
                  shipmentId: id,
                ),
              ),
            ).then(
                  (_) => fetchShipments(silent: true),
            );
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
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (senderId != null &&
                    senderRatingAverage.isNotEmpty) ...[
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
                        border: Border.all(
                          color: Colors.blue.shade200,
                        ),
                      ),
                      child: Text(
                        '👤 $senderName ⭐ '
                            '$senderRatingAverage '
                            '($senderRatingsCount)',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
                if (weight.isNotEmpty || publishedDate.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    [
                      if (weight.isNotEmpty)
                        l10n.approximateWeight(weight),
                      if (publishedDate.isNotEmpty)
                        l10n.publishedDate(publishedDate),
                    ].join(' • '),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
                if (lowestOffer != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    accepted
                        ? l10n.acceptedOfferPrice(
                      formatMoney(lowestOffer),
                    )
                        : l10n.currentLowestOfferPrice(
                      formatMoney(lowestOffer),
                    ),
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
                      color: auctionFinished
                          ? Colors.red
                          : Colors.deepOrange,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                buildSmartBadges(
                  l10n,
                  item,
                  offers,
                  views,
                  loadingDeadline,
                  auctionDuration,
                  isNew,
                  auctionFinished,
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
                          builder: (_) => ShipmentDetailsScreen(
                            shipmentId: id,
                          ),
                        ),
                      ).then(
                            (_) => fetchShipments(silent: true),
                      );
                    },
                    icon: const Icon(
                      Icons.inventory_2_outlined,
                      size: 18,
                    ),
                    label: Text(l10n.viewDetails),
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.shipmentListTitle),
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
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
          : shipments.isEmpty
          ? RefreshIndicator(
        onRefresh: fetchShipments,
        child: ListView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 120),
            const Icon(
              Icons.local_shipping_outlined,
              size: 70,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                l10n.noShipmentsAvailable,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                ),
                child: Text(
                  l10n.newShipmentsWillAppear,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: fetchShipments,
        child: ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: shipments.length,
          itemBuilder: (context, index) {
            final item = shipments[index];

            if (item is Map) {
              return buildShipmentCard(
                l10n,
                item,
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}