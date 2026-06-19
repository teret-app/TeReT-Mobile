import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../services/token_storage.dart';
import 'login_screen.dart';

class ShipmentOffersScreen extends StatefulWidget {
  final int shipmentId;

  const ShipmentOffersScreen({
    super.key,
    required this.shipmentId,
  });

  @override
  State<ShipmentOffersScreen> createState() => _ShipmentOffersScreenState();
}

class _ShipmentOffersScreenState extends State<ShipmentOffersScreen> {
  bool isLoading = true;
  bool isAccepting = false;
  String errorMessage = '';
  String shipmentStatus = '';
  int? acceptedOfferId;
  List<dynamic> offers = [];

  @override
  void initState() {
    super.initState();
    fetchOffers();
  }

  Future<void> logoutAndGoToLogin() async {
    await TokenStorage.clearToken();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  Future<String?> getTokenOrLogout() async {
    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      await logoutAndGoToLogin();
      return null;
    }

    return token;
  }

  Future<void> handleUnauthorized() async {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sesija je istekla. Prijavite se ponovno.'),
      ),
    );

    await logoutAndGoToLogin();
  }

  Future<void> fetchOffers() async {
    final token = await getTokenOrLogout();
    if (token == null) return;

    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/shipments/${widget.shipmentId}/offers'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 401) {
        await handleUnauthorized();
        return;
      }

      if (response.statusCode != 200) {
        String message = 'Greška kod učitavanja ponuda.';

        try {
          final body = jsonDecode(response.body);
          if (body is Map && body['message'] != null) {
            message = body['message'].toString();
          }
        } catch (_) {}

        if (!mounted) return;
        setState(() {
          errorMessage = message;
          isLoading = false;
        });
        return;
      }

      final data = jsonDecode(response.body);

      List<dynamic> loadedOffers = [];
      int? foundAcceptedOfferId;

      if (data is List) {
        loadedOffers = data;
      } else if (data is Map && data['offers'] is List) {
        loadedOffers = data['offers'];
      }

      for (final offer in loadedOffers) {
        if (offer is! Map) continue;

        final status = (offer['status'] ?? '').toString().toLowerCase();

        if (status == 'accepted' ||
            status == 'prihvaceno' ||
            status == 'prihvaćeno') {
          foundAcceptedOfferId =
          offer['id'] is int ? offer['id'] : int.tryParse('${offer['id']}');
          shipmentStatus = 'prihvaceno';
          break;
        }
      }

      if (!mounted) return;
      setState(() {
        offers = loadedOffers;
        acceptedOfferId = foundAcceptedOfferId;
        if (foundAcceptedOfferId == null) {
          shipmentStatus = '';
        }
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Greška konekcije sa serverom.';
        isLoading = false;
      });
    }
  }

  Future<void> confirmAcceptOffer(dynamic offer) async {
    if (!mounted) return;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Jesi li siguran?'),
          content: const Text(
            'Prihvatom ove ponude zaključuješ dogovor i odabireš ovog prijevoznika.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Odustani'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Prihvati ponudu'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await acceptOffer(offer);
    }
  }

  Future<void> acceptOffer(dynamic offer) async {
    final offerId =
    offer['id'] is int ? offer['id'] : int.tryParse('${offer['id']}');

    if (offerId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Neispravan ID ponude.')),
      );
      return;
    }

    final token = await getTokenOrLogout();
    if (token == null) return;

    if (!mounted) return;
    setState(() {
      isAccepting = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/offers/$offerId/accept'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 401) {
        await handleUnauthorized();
        return;
      }

      if (response.statusCode == 200) {
        if (!mounted) return;

        String message = 'Ponuda je uspješno prihvaćena.';

        try {
          final body = jsonDecode(response.body);
          if (body is Map && body['message'] != null) {
            message = body['message'].toString();
          }
        } catch (_) {}

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );

        await fetchOffers();
      } else {
        String message = 'Prihvat ponude nije uspio.';

        try {
          final body = jsonDecode(response.body);
          if (body is Map && body['message'] != null) {
            message = body['message'].toString();
          }
        } catch (_) {}

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Greška konekcije sa serverom.')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        isAccepting = false;
      });
    }
  }

  String formatPrice(dynamic value) {
    if (value == null) return '-';

    if (value is int) return '$value €';
    if (value is double) {
      if (value == value.roundToDouble()) {
        return '${value.toInt()} €';
      }
      return '${value.toStringAsFixed(2)} €';
    }

    return '$value €';
  }

  String formatOfferStatus(dynamic statusRaw) {
    final status = (statusRaw ?? '').toString().toLowerCase();

    if (status == 'accepted' ||
        status == 'prihvaceno' ||
        status == 'prihvaćeno') {
      return 'Prihvaćena';
    }

    if (status == 'nadmaseno' || status == 'nadmašeno') {
      return 'Nadmašena';
    }

    if (status == 'rejected' || status == 'odbijeno') {
      return 'Odbijena';
    }

    if (status == 'pending' ||
        status == 'na_cekanju' ||
        status == 'na čekanju') {
      return 'Na čekanju';
    }

    return 'Aktivna';
  }

  Color statusColor(dynamic statusRaw) {
    final status = (statusRaw ?? '').toString().toLowerCase();

    if (status == 'accepted' ||
        status == 'prihvaceno' ||
        status == 'prihvaćeno') {
      return Colors.green;
    }

    if (status == 'nadmaseno' || status == 'nadmašeno') {
      return Colors.orange;
    }

    if (status == 'rejected' || status == 'odbijeno') {
      return Colors.red;
    }

    if (status == 'pending' ||
        status == 'na_cekanju' ||
        status == 'na čekanju') {
      return Colors.orange;
    }

    return Colors.blueGrey;
  }

  bool shipmentAlreadyAccepted() {
    final status = shipmentStatus.toLowerCase();

    return status == 'accepted' ||
        status == 'prihvaceno' ||
        status == 'prihvaćeno' ||
        status == 'offer_accepted' ||
        acceptedOfferId != null;
  }

  String getCarrierDisplayName(dynamic offer) {
    if (offer is! Map) return 'Prijevoznik';

    final carrier = offer['carrier'];

    if (carrier is Map) {
      final nickname = (carrier['nickname'] ?? '').toString().trim();
      final companyName = (carrier['companyName'] ?? '').toString().trim();
      final fullName = (carrier['fullName'] ?? '').toString().trim();

      if (nickname.isNotEmpty) return nickname;
      if (companyName.isNotEmpty) return companyName;

      if (fullName.isNotEmpty) {
        final parts = fullName.split(RegExp(r'\s+'));
        if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
          return '${parts[0][0]}. ${parts.sublist(1).join(' ')}';
        }
        return fullName;
      }
    }

    final fallbackName = (offer['transporterName'] ??
        offer['carrierName'] ??
        offer['prijevoznik_ime'] ??
        offer['full_name'] ??
        offer['name'] ??
        '')
        .toString()
        .trim();

    return fallbackName.isNotEmpty ? fallbackName : 'Prijevoznik';
  }

  String getCarrierRatingText(dynamic offer) {
    if (offer is! Map) return '';

    final carrier = offer['carrier'];

    dynamic averageRating;
    dynamic ratingsCount;

    if (carrier is Map) {
      averageRating = carrier['averageRating'];
      ratingsCount = carrier['ratingsCount'];
    }

    averageRating ??= offer['averageRating'];
    ratingsCount ??= offer['ratingsCount'];

    if (averageRating == null || averageRating.toString().trim().isEmpty) {
      return '';
    }

    return '⭐ $averageRating (${ratingsCount ?? 0} ocjena)';
  }

  int? getCarrierId(dynamic offer) {
    if (offer is! Map) return null;

    final carrier = offer['carrier'];

    if (carrier is Map && carrier['id'] != null) {
      return carrier['id'] is int
          ? carrier['id']
          : int.tryParse('${carrier['id']}');
    }

    return null;
  }

  void openCarrierProfile(dynamic offer) {
    final carrierId = getCarrierId(offer);
    final carrierName = getCarrierDisplayName(offer);

    if (carrierId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nije pronađen ID prijevoznika za ovu ponudu.'),
        ),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/user_profile',
      arguments: {
        'userId': carrierId,
        'userName': carrierName,
      },
    );
  }

  Widget buildOfferCard(dynamic offer) {
    final offerId = offer['id'];
    final transporterName = getCarrierDisplayName(offer);
    final carrierRatingText = getCarrierRatingText(offer);

    final price = offer['amount'] ?? offer['price'] ?? offer['cijena'];
    final message =
    (offer['message'] ?? offer['note'] ?? offer['poruka'] ?? '').toString();

    final isAcceptedThisOne =
        acceptedOfferId != null && offerId.toString() == acceptedOfferId.toString();

    final alreadyAccepted = shipmentAlreadyAccepted();

    final displayStatus = alreadyAccepted
        ? (isAcceptedThisOne ? 'prihvaceno' : 'nadmaseno')
        : offer['status'];

    return Material(
      color: Colors.white,
      elevation: 0.7,
      borderRadius: BorderRadius.circular(10),

      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => openCarrierProfile(offer),
              child: Text(
                transporterName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            if (carrierRatingText.isNotEmpty) ...[
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => openCarrierProfile(offer),
                child: Text(
                  carrierRatingText,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              'Ponuda: ${formatPrice(price)}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor(displayStatus).withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                formatOfferStatus(displayStatus),
                style: TextStyle(
                  color: statusColor(displayStatus),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (message.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ],
            const SizedBox(height: 14),
            if (isAcceptedThisOne)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Ova ponuda je prihvaćena',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
            else if (!alreadyAccepted)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isAccepting ? null : () => confirmAcceptOffer(offer),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isAccepting
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text(
                    'Prihvati ponudu',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Ova ponuda je nadmašena',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ponude za teret'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Osvježi',
            onPressed: fetchOffers,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Odjava',
            onPressed: logoutAndGoToLogin,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchOffers,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
            ? ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(10),
          children: [
            const SizedBox(height: 100),
            Center(
              child: Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        )
            : offers.isEmpty
            ? ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: const [
            SizedBox(height: 100),
            Center(
              child: Text(
                'Za ovaj teret još nema ponuda.',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        )
            : ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (shipmentAlreadyAccepted())
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Jedna ponuda je već prihvaćena i teret je zaključen.',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ...offers.map(buildOfferCard),
          ],
        ),
      ),
    );
  }
}