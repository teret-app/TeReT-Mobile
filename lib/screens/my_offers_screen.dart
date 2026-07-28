import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../l10n/app_localizations.dart';
import '../services/token_storage.dart';
import 'login_screen.dart';
import 'send_offer_screen.dart';
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
        final l10n = AppLocalizations.of(context)!;
        _goToLogin(l10n.myOffersNotLoggedIn);
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

      final l10n = AppLocalizations.of(context)!;

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        setState(() {
          offers = decoded is List ? decoded : [];
          isLoading = false;
        });
        return;
      }

      if (response.statusCode == 401) {
        _goToLogin(l10n.myOffersSessionExpired);
        return;
      }

      setState(() {
        errorMessage = l10n.myOffersFetchError;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      final l10n = AppLocalizations.of(context)!;

      setState(() {
        errorMessage = l10n.myOffersConnectionError;
        isLoading = false;
      });
    }
  }

  Future<void> _hideOfferFromHistory(int offerId) async {
    final l10n = AppLocalizations.of(context)!;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.myOffersRemoveFromHistoryTitle),
        content: Text(l10n.myOffersRemoveFromHistoryMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.myOffersCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.myOffersRemove),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      _goToLogin(l10n.myOffersNotLoggedIn);
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

      final currentL10n = AppLocalizations.of(context)!;

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
          SnackBar(
            content: Text(currentL10n.myOffersRemovedFromHistory),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(currentL10n.myOffersRemoveFailed),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;

      final currentL10n = AppLocalizations.of(context)!;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(currentL10n.myOffersConnectionError),
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

    if (number == null) {
      return '${value.toString()} €';
    }

    final formattedValue =
    number.toStringAsFixed(2).replaceAll('.', ',');

    return '$formattedValue €';
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

  bool _isMyOfferLowest(
      dynamic myOfferValue,
      dynamic lowestOfferValue,
      ) {
    final myOffer = _number(myOfferValue);
    final lowestOffer = _number(lowestOfferValue);

    if (myOffer == null || lowestOffer == null) {
      return false;
    }

    return myOffer <= lowestOffer;
  }

  bool _isAcceptedOffer(String status) {
    final normalizedStatus = status.toLowerCase().trim();

    return normalizedStatus == 'accepted' ||
        normalizedStatus == 'prihvacena' ||
        normalizedStatus == 'prihvaćena' ||
        normalizedStatus == 'prihvaceno' ||
        normalizedStatus == 'prihvaćeno';
  }

  bool _isRejectedOffer(String status) {
    final normalizedStatus = status.toLowerCase().trim();

    return normalizedStatus == 'rejected' ||
        normalizedStatus == 'odbijena' ||
        normalizedStatus == 'odbijeno' ||
        normalizedStatus == 'nadmaseno' ||
        normalizedStatus == 'nadmašeno';
  }

  bool _isCompletedShipment(String status) {
    final normalizedStatus = status.toLowerCase().trim();

    return normalizedStatus == 'completed' ||
        normalizedStatus == 'zavrseno' ||
        normalizedStatus == 'završeno';
  }

  bool _isAcceptedShipment(String status) {
    final normalizedStatus = status.toLowerCase().trim();

    return normalizedStatus == 'accepted' ||
        normalizedStatus == 'prihvaceno' ||
        normalizedStatus == 'prihvaćeno' ||
        normalizedStatus == 'offer_accepted';
  }

  bool _isExpiredShipment(String status) {
    final normalizedStatus = status.toLowerCase().trim();

    return normalizedStatus == 'licitacija_zavrsena' ||
        normalizedStatus == 'licitacija završena' ||
        normalizedStatus == 'expired' ||
        normalizedStatus == 'isteklo';
  }

  bool _isActiveShipment(String status) {
    final normalizedStatus = status.toLowerCase().trim();

    return normalizedStatus == 'active' ||
        normalizedStatus == 'aktivan' ||
        normalizedStatus == 'open';
  }

  bool _canHideOffer({
    required String offerStatus,
    required String shipmentStatus,
  }) {
    if (_isRejectedOffer(offerStatus)) return true;
    if (_isExpiredShipment(shipmentStatus)) return true;
    if (_isCompletedShipment(shipmentStatus)) return true;

    if (_isAcceptedShipment(shipmentStatus) &&
        !_isAcceptedOffer(offerStatus)) {
      return true;
    }

    return false;
  }

  String _offerDisplayStatus({
    required String offerStatus,
    required String shipmentStatus,
    required bool isLowest,
  }) {
    final l10n = AppLocalizations.of(context)!;

    if (_isAcceptedShipment(shipmentStatus) ||
        _isCompletedShipment(shipmentStatus) ||
        _isExpiredShipment(shipmentStatus)) {
      return l10n.myOffersStatusFinished;
    }

    if (_isAcceptedOffer(offerStatus)) {
      return l10n.myOffersStatusAccepted;
    }

    if (isLowest) {
      return l10n.myOffersStatusLowest;
    }

    return l10n.myOffersStatusOutbid;
  }

  Color _offerDisplayColor({
    required String offerStatus,
    required String shipmentStatus,
    required bool isLowest,
  }) {
    if (_isAcceptedShipment(shipmentStatus) ||
        _isCompletedShipment(shipmentStatus)) {
      return Colors.grey;
    }

    if (_isExpiredShipment(shipmentStatus)) {
      return Colors.red;
    }

    if (_isAcceptedOffer(offerStatus) || isLowest) {
      return Colors.green;
    }

    return Colors.orange;
  }

  String _shipmentStatusText(String status) {
    final l10n = AppLocalizations.of(context)!;

    if (_isActiveShipment(status)) {
      return l10n.myOffersShipmentActive;
    }

    if (_isAcceptedShipment(status)) {
      return l10n.myOffersShipmentOfferAccepted;
    }

    if (_isCompletedShipment(status)) {
      return l10n.myOffersShipmentUsersConnected;
    }

    if (_isExpiredShipment(status)) {
      return l10n.myOffersShipmentAuctionEnded;
    }

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
          Icon(
            icon,
            size: 18,
            color: Colors.blueGrey.shade700,
          ),
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
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
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

  Widget _buildStatusChip(
      String label,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: 0.28),
        ),
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
    final l10n = AppLocalizations.of(context)!;

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

    final offerStatus = _text(
      offer['status'],
      'active',
    );

    final shipmentStatus = _text(
      shipment['status'],
      '—',
    );

    final loadingPlace = _text(
      shipment['mjesto_utovara'] ??
          shipment['mjestoUtovara'] ??
          shipment['pickupCity'],
    );

    final unloadingPlace = _text(
      shipment['mjesto_istovara'] ??
          shipment['mjestoIstovara'] ??
          shipment['deliveryCity'],
    );

    final shipmentName = _text(
      shipment['naziv_tereta'] ??
          shipment['nazivTereta'] ??
          shipment['title'],
      l10n.myOffersDefaultShipmentName,
    );

    final myOffer = _priceText(offer['amount']);
    final offersCount = shipment['offersCount'] ?? 0;
    final lowestOfferValue = _lowestOfferValue(offer, shipment);
    final message = _text(offer['message'], '');

    final weightValue = shipment['tezina_cca_kg'] ??
        shipment['tezina_kg'] ??
        shipment['weight'];

    final weight =
    weightValue != null &&
        weightValue.toString().trim().isNotEmpty
        ? '${weightValue.toString().trim()} kg'
        : '—';

    final isLowest = _isMyOfferLowest(
      offer['amount'],
      lowestOfferValue,
    );

    final displayStatus = _offerDisplayStatus(
      offerStatus: offerStatus,
      shipmentStatus: shipmentStatus,
      isLowest: isLowest,
    );

    final displayColor = _offerDisplayColor(
      offerStatus: offerStatus,
      shipmentStatus: shipmentStatus,
      isLowest: isLowest,
    );

    final isAccepted = _isAcceptedOffer(offerStatus);
    final isRejected = _isRejectedOffer(offerStatus);
    final isShipmentActive = _isActiveShipment(shipmentStatus);

    final canSendNewOffer = isShipmentActive && !isLowest;

    final canHideOffer = offerId > 0 &&
        _canHideOffer(
          offerStatus: offerStatus,
          shipmentStatus: shipmentStatus,
        );

    final isCommissionPaid =
        offer['commissionPaid'] == true ||
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
                _buildStatusChip(
                  displayStatus,
                  displayColor,
                ),
                _buildStatusChip(
                  '${l10n.myOffersShipmentPrefix}: '
                      '${_shipmentStatusText(shipmentStatus)}',
                  _shipmentStatusColor(shipmentStatus),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '$loadingPlace → $unloadingPlace',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              shipmentName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.blueGrey.shade800,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.euro,
              label: l10n.myOffersMyOffer,
              value: myOffer,
              valueColor: displayColor,
              valueWeight: FontWeight.w800,
            ),
            _buildInfoRow(
              icon: Icons.trending_down,
              label: l10n.myOffersOffersCount,
              value: offersCount.toString(),
              valueColor:
              isLowest ? Colors.green : Colors.orange,
              valueWeight: FontWeight.w800,
            ),
            _buildInfoRow(
              icon: Icons.calendar_today_outlined,
              label: l10n.myOffersLoading,
              value: l10n.myOffersByAgreement,
            ),
            _buildInfoRow(
              icon: Icons.scale_outlined,
              label: l10n.myOffersWeight,
              value: weight,
            ),
            if (message.isNotEmpty && message != '—')
              _buildInfoRow(
                icon: Icons.message_outlined,
                label: l10n.myOffersMyMessage,
                value: message,
              ),
            if (isAccepted &&
                !isRejected &&
                !isCommissionPaid)
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: shipmentId == null
                    ? null
                    : () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ShipmentDetailsScreen(
                            shipmentId: shipmentId,
                          ),
                    ),
                  );

                  if (!mounted) return;
                  fetchMyOffers();
                },
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(
                    top: 10,
                    bottom: 10,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(
                      alpha: 0.08,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.withValues(
                        alpha: 0.35,
                      ),
                    ),
                  ),
                  child: Text(
                    l10n.myOffersAcceptedUnlockContact,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
            if (isAccepted &&
                !isRejected &&
                isCommissionPaid)
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: shipmentId == null
                    ? null
                    : () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ShipmentDetailsScreen(
                            shipmentId: shipmentId,
                          ),
                    ),
                  );

                  if (!mounted) return;
                  fetchMyOffers();
                },
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(
                    top: 10,
                    bottom: 10,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(
                      alpha: 0.10,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    l10n.myOffersContactUnlocked,
                    style: const TextStyle(
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
                  label: Text(
                    l10n.myOffersSendNewOffer,
                  ),
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red.shade200,
                  ),
                ),
                child: Text(
                  l10n.myOffersOtherCarrierSelected,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            if (canHideOffer) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _hideOfferFromHistory(offerId),
                  icon: const Icon(Icons.delete_outline),
                  label: Text(
                    l10n.myOffersRemoveFromHistory,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    final l10n = AppLocalizations.of(context)!;

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
                child: Text(
                  l10n.myOffersTryAgain,
                ),
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
          physics:
          const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 80,
          ),
          children: [
            const Icon(
              Icons.local_shipping_outlined,
              size: 70,
              color: Colors.blueGrey,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.myOffersEmptyTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.myOffersEmptyDescription,
              textAlign: TextAlign.center,
              style: const TextStyle(
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
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          24,
        ),
        itemCount: offers.length,
        separatorBuilder: (_, __) =>
        const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _buildOfferCard(offers[index]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text(
          l10n.myOffersTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: l10n.myOffersRefresh,
            onPressed: fetchMyOffers,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
}
