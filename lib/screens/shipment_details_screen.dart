import 'user_profile_screen.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../config.dart';
import '../services/token_storage.dart';
import 'login_screen.dart';
import 'send_offer_screen.dart';
import 'bid_history_screen.dart';
import 'rating_screen.dart';

class ShipmentDetailsScreen extends StatefulWidget {
  final int shipmentId;
  final bool isSenderView;

  const ShipmentDetailsScreen({
    super.key,
    required this.shipmentId,
    this.isSenderView = false,
  });

  @override
  State<ShipmentDetailsScreen> createState() => _ShipmentDetailsScreenState();
}

class _ShipmentDetailsScreenState extends State<ShipmentDetailsScreen> {
  bool isLoading = true;
  bool isPayingCommission = false;
  bool isConfirmingDelivery = false;
  String errorMessage = '';
  Map<String, dynamic>? shipment;

  @override
  void initState() {
    super.initState();
    fetchShipmentDetails();
  }

  Future<void> fetchShipmentDetails() async {
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

      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/shipments/${widget.shipmentId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (!mounted) return;
        setState(() {
          shipment = Map<String, dynamic>.from(decoded);
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        await TokenStorage.clearToken();

        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
        );
      } else {
        String message = 'Greška pri dohvaćanju detalja tereta.';

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
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Greška konekcije sa serverom.';
        isLoading = false;
      });
    }
  }

  Future<void> payCommission() async {
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

    if (!mounted) return;

    setState(() {
      isPayingCommission = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/shipments/${widget.shipmentId}/pay-commission'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 401) {
        await TokenStorage.clearToken();

        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
        );
        return;
      }

      String message = 'Provizija je evidentirana.';

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

      if (response.statusCode == 200) {
        await fetchShipmentDetails();
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Greška konekcije sa serverom.')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        isPayingCommission = false;
      });
    }
  }

  Future<void> confirmDelivery() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Jesi li siguran?'),
          content: const Text('Potvrdom označavaš da je prijevoz obavljen.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Odustani'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Prijevoz obavljen'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

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

    if (!mounted) return;
    setState(() {
      isConfirmingDelivery = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/shipments/${widget.shipmentId}/confirm-delivery'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      String message = 'Prijevoz je označen kao obavljen.';

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

      if (response.statusCode == 200) {
        await fetchShipmentDetails();

        if (!mounted) return;

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RatingScreen(
              shipmentId: widget.shipmentId,
              ratedUserLabel: 'prijevoznika',
            ),
          ),
        );

        await fetchShipmentDetails();
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Greška konekcije sa serverom.')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        isConfirmingDelivery = false;
      });
    }
  }
  Future<void> _callPhoneNumber(String phoneNumber) async {
    final cleanPhone = phoneNumber
        .replaceAll(' ', '')
        .replaceAll('-', '')
        .replaceAll('/', '');

    final uri = Uri(scheme: 'tel', path: cleanPhone);

    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nije moguće otvoriti aplikaciju za poziv.'),
        ),
      );
    }
  }
  String _textValue(List<String> keys, [String fallback = '-']) {
    if (shipment == null) return fallback;

    for (final key in keys) {
      final value = shipment![key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return fallback;
  }

  bool _boolValue(List<String> keys) {
    if (shipment == null) return false;

    for (final key in keys) {
      final value = shipment![key];

      if (value == null) continue;
      if (value is bool) return value;

      final text = value.toString().toLowerCase().trim();

      if (text == 'true' || text == 'da' || text == '1') return true;
      if (text == 'false' || text == 'ne' || text == '0') return false;
    }

    return false;
  }

  num? _numValue(List<String> keys) {
    if (shipment == null) return null;

    for (final key in keys) {
      final value = shipment![key];

      if (value == null) continue;
      if (value is num) return value;

      final parsed = num.tryParse(value.toString().replaceAll(',', '.'));
      if (parsed != null) return parsed;
    }

    return null;
  }

  List<String> _extractImages() {
    if (shipment == null) return [];

    final rawImages = shipment!['slike'] ??
        shipment!['images'] ??
        shipment!['imageUrls'] ??
        shipment!['photos'];

    if (rawImages == null) return [];

    if (rawImages is List) {
      return rawImages
          .map((e) => e.toString())
          .where((e) => e.trim().isNotEmpty)
          .toList();
    }

    if (rawImages is String) {
      final value = rawImages.trim();

      if (value.isEmpty) return [];

      try {
        final decoded = jsonDecode(value);

        if (decoded is List) {
          return decoded
              .map((e) => e.toString())
              .where((e) => e.trim().isNotEmpty)
              .toList();
        }
      } catch (_) {
        return [value];
      }
    }

    return [];
  }

  String? _buildImageUrl(String value) {
    final clean = value.trim();



    if (clean.isEmpty) return null;

    if (clean.startsWith('http://') || clean.startsWith('https://')) {
      return clean;
    }

    if (clean.startsWith('/uploads/')) {
      final url = '${AppConfig.baseUrl}$clean';

      return url;
    }

    if (clean.startsWith('uploads/')) {
      final url = '${AppConfig.baseUrl}/$clean';

      return url;
    }

    return null;
  }

  Uint8List? _tryDecodeBase64Image(String value) {
    try {
      String clean = value.trim();

      if (clean.startsWith('data:image')) {
        final commaIndex = clean.indexOf(',');

        if (commaIndex != -1) {
          clean = clean.substring(commaIndex + 1);
        }
      }

      return base64Decode(clean);
    } catch (_) {
      return null;
    }
  }

  String _maskAddressForTransporter(String address) {
    final value = address.trim();

    if (value.isEmpty) return '-';

    return value
        .replaceAll(RegExp(r'\b\d+[a-zA-Z\-\/]*\b'), '')
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .replaceAll(RegExp(r'\s+,'), ',')
        .trim();
  }

  String _formatMoney(num? value) {
    if (value == null) return '-';

    if (value == value.roundToDouble()) {
      return '${value.toInt()} €';
    }

    return '${value.toStringAsFixed(2)} €';
  }

  String _formatStatus(String raw) {
    final status = raw.toLowerCase();

    if (status == 'aktivan' || status == 'active' || status == 'open') {
      return 'Aktivan';
    }

    if (status == 'prihvaceno' ||
        status == 'prihvaćeno' ||
        status == 'accepted' ||
        status == 'offer_accepted') {
      return 'Prihvaćena ponuda';
    }

    if (status == 'zavrseno' || status == 'završeno' || status == 'completed') {
      return 'Završeno';
    }

    return raw.isEmpty ? '-' : raw;
  }

  Color _statusColor(String raw) {
    final status = raw.toLowerCase();

    if (status == 'aktivan' || status == 'active' || status == 'open') {
      return Colors.green;
    }

    if (status == 'prihvaceno' ||
        status == 'prihvaćeno' ||
        status == 'accepted' ||
        status == 'offer_accepted') {
      return Colors.orange;
    }

    if (status == 'zavrseno' || status == 'završeno' || status == 'completed') {
      return Colors.blue;
    }

    return Colors.grey;
  }

  bool _isActiveStatus(String raw) {
    final status = raw.toLowerCase().trim();

    return status == 'aktivan' || status == 'active' || status == 'open';
  }

  bool _isAcceptedStatus(String raw) {
    final status = raw.toLowerCase().trim();

    return status == 'prihvaceno' ||
        status == 'prihvaćeno' ||
        status == 'accepted' ||
        status == 'offer_accepted';
  }

  bool _isCompletedStatus(String raw) {
    final status = raw.toLowerCase().trim();

    return status == 'zavrseno' ||
        status == 'završeno' ||
        status == 'completed';
  }

  Widget _buildInfoRow(String label, String value) {
    final displayValue =
    (label.toLowerCase().contains('način utovara') &&
        value.toLowerCase().contains('vili'))
        ? 'Strojno'
        : value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 145,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              displayValue.isEmpty ? '-' : displayValue,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildSenderRatingCard({
    required dynamic senderId,
    required String senderName,
    required String senderRatingAverage,
    required dynamic senderRatingsCount,
  }) {
    if (widget.isSenderView || senderId == null) {
      return const SizedBox.shrink();
    }

    final hasRating = senderRatingAverage.trim().isNotEmpty;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UserProfileScreen(
              userId: int.tryParse(senderId.toString()) ?? 0,
              userName: senderName,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(top: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.green.shade200,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: const Icon(
                Icons.person,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    senderName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasRating
                        ? '⭐ $senderRatingAverage ($senderRatingsCount ocjena)'
                        : 'Nema ocjena',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildImagesSection() {
    final images = _extractImages();

    if (images.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        const Text(
          'Slike tereta',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final imageValue = images[index];
              final base64Bytes = _tryDecodeBase64Image(imageValue);
              final imageUrl = _buildImageUrl(imageValue);

              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return Dialog(
                        insetPadding: const EdgeInsets.all(12),
                        child: Container(
                          color: Colors.black,
                          padding: const EdgeInsets.all(8),
                          child: base64Bytes != null
                              ? InteractiveViewer(
                            child: Image.memory(
                              base64Bytes,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) =>
                              const SizedBox(
                                height: 250,
                                child: Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.white,
                                    size: 48,
                                  ),
                                ),
                              ),
                            ),
                          )
                              : imageUrl != null
                              ? InteractiveViewer(
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) =>
                              const SizedBox(
                                height: 250,
                                child: Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.white,
                                    size: 48,
                                  ),
                                ),
                              ),
                            ),
                          )
                              : const SizedBox(
                            height: 250,
                            child: Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 130,
                    height: 110,
                    color: Colors.grey.shade200,
                    child: base64Bytes != null
                        ? Image.memory(
                      base64Bytes,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image),
                    )
                        : imageUrl != null
                        ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image),
                    )
                        : const Icon(Icons.broken_image),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBidHistoryButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BidHistoryScreen(
                shipmentId: widget.shipmentId,
              ),
            ),
          );
        },
        icon: const Icon(Icons.show_chart),
        label: const Text('Tijek licitacije'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildRatingButton({
    required bool canRate,
    required bool hasRated,
    required String ratingTargetLabel,
  }) {
    if (hasRated) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Text(
          'Već ste ocijenili $ratingTargetLabel.',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.green,
          ),
        ),
      );
    }

    if (!canRate) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RatingScreen(
                shipmentId: widget.shipmentId,
                ratedUserLabel: ratingTargetLabel,
              ),
            ),
          );

          await fetchShipmentDetails();
        },
        icon: const Icon(Icons.star_rate_rounded),
        label: Text('Ocijeni $ratingTargetLabel'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmDeliveryButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isConfirmingDelivery ? null : confirmDelivery,
        icon: isConfirmingDelivery
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : const Icon(Icons.task_alt),
        label: Text(
          isConfirmingDelivery ? 'Potvrđujem...' : 'Prijevoz obavljen',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade700,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBlock({
    required String status,
    required bool kontaktOtkljucan,
    required bool commissionPaid,
    required bool acceptedTransporterMustPay,
    required bool isAcceptedCarrier,
    required num? provizijaIznos,
    required num? acceptedPrice,
  }) {
    if (widget.isSenderView) {
      if (_isAcceptedStatus(status)) {
        return Container(
          margin: const EdgeInsets.only(top: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: commissionPaid ? Colors.green.shade50 : Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: commissionPaid ? Colors.green.shade200 : Colors.orange.shade200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                commissionPaid
                    ? 'Odabrali ste prijevoznika.'
                    : 'Ponuda je prihvaćena.',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: commissionPaid ? Colors.green.shade800 : Colors.orange.shade900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                commissionPaid
                    ? ' Prijevoznik će vas uskoro kontaktirati.'
                    : 'Čeka se potvrda prijevoznika.',
              ),
            ],
          ),
        );
      }

      return const SizedBox.shrink();
    }

    if (acceptedTransporterMustPay) {
      return Container(
        margin: const EdgeInsets.only(top: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ponuda prihvaćena.',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ponuda je prihvaćena. Za otključavanje kontakt podataka potrebno je '
                  'povezati Stripe račun i platiti naknadu platforme '
                  'u iznosu od 5% dogovorene cijene prijevoza.',
            ),
            if (acceptedPrice != null) ...[
              const SizedBox(height: 8),
              Text('Dogovorena cijena prijevoza: ${_formatMoney(acceptedPrice)}'),
            ],
            if (provizijaIznos != null) ...[
              const SizedBox(height: 6),
              Text(
                'Iznos naknade (5%): ${_formatMoney(provizijaIznos)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isPayingCommission ? null : payCommission,
                child: isPayingCommission
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Plati naknadu i otključaj kontakt'),
              ),
            ),
          ],
        ),
      );
    }

    if ((widget.isSenderView || isAcceptedCarrier) &&
        kontaktOtkljucan &&
        commissionPaid) {
      return Container(
        margin: const EdgeInsets.only(top: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: const Text(
          'Sad možete kontaktirati naručitelja.',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.green,
          ),
        ),
      );
    }

    if (!kontaktOtkljucan &&
        !widget.isSenderView &&
        !commissionPaid &&
        !acceptedTransporterMustPay &&
        _isAcceptedStatus(status)) {
      return Container(
        margin: const EdgeInsets.only(top: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Text(
          'Nažalost drugi prijevoznik je dobio ovaj posao. Hvala na sudjelovanju u licitaciji.',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    if (shipment == null) {
      return const Center(child: Text('Teret nije pronađen.'));
    }

    final nazivTereta = _textValue([
      'naziv_tereta',
      'nazivTereta',
      'title',
      'naziv',
    ]);

    final opisTereta = _textValue([
      'opis_tereta',
      'opisTereta',
      'description',
      'opis',
    ]);

    final mjestoUtovara = _textValue([
      'mjesto_utovara',
      'mjestoUtovara',
      'grad_utovara',
      'cityFrom',
    ]);

    String adresaUtovara = _textValue([
      'adresa_utovara',
      'adresaUtovara',
      'addressFrom',
    ]);

    final mjestoIstovara = _textValue([
      'mjesto_istovara',
      'mjestoIstovara',
      'grad_istovara',
      'cityTo',
    ]);

    String adresaIstovara = _textValue([
      'adresa_istovara',
      'adresaIstovara',
      'addressTo',
    ]);

    final datumUtovara = _textValue([
      'datum_utovara',
      'datumUtovara',
      'loadingDate',
    ]);

    final rokUtovara = _textValue([
      'rok_utovara',
      'rokUtovara',
      'hitnost',
    ]);

    final nacinUtovara = _textValue([
      'nacin_utovara',
      'nacinUtovara',
      'loadingType',
    ]);

    final tipLokacijeUtovara = _textValue([
      'tip_lokacije_utovara',
      'tipLokacijeUtovara',
      'tip_lokacije',
      'tipLokacije',
    ]);

    final tipLokacijeIstovara = _textValue([
      'tip_lokacije_istovara',
      'tipLokacijeIstovara',
    ]);

    final katUtovara = _textValue(['kat_utovara', 'katUtovara']);
    final katIstovara = _textValue(['kat_istovara', 'katIstovara']);

    final kontaktTelefon = _textValue([
      'kontakt_telefon',
      'kontaktTelefon',
      'telefon',
      'phone',
      'broj_mobitela',
    ], '');

    final tezina = _numValue(['tezina_kg/lb', 'tezinaKg/lb', 'weight']);
    final duzina = _numValue(['duzina_cm/in', 'duzinaCm/in', 'length']);
    final sirina = _numValue(['sirina_cm/in', 'sirinaCm/in', 'width']);
    final visina = _numValue(['visina_cm/in', 'visinaCm/in', 'height']);
    final brojPaleta = _numValue(['broj_paleta', 'brojPaleta', 'pallets']);

    final offerCount =
        _numValue(['offerCount', 'offersCount', 'ponudeCount']) ?? 0;

    final views =
        _numValue(['viewsCount', 'views', 'viewCount', 'broj_pregleda']) ?? 0;

    final senderRatingAverage =
        shipment!['senderRatingAverage']?.toString() ?? '';

    final senderRatingsCount = shipment!['senderRatingsCount'] ?? 0;

    final senderName = shipment!['senderName']?.toString() ?? 'Naručitelj';
    print('IS SENDER VIEW = ${widget.isSenderView}');
    final senderId = shipment!['senderId'];
    final acceptedPrice = _numValue(['acceptedPrice']);
    final provizijaIznos = _numValue(['provizija_iznos']);

    final liftUtovar = _boolValue(['lift_na_utovaru', 'liftNaUtovaru']);
    final liftIstovar = _boolValue(['lift_na_istovaru', 'liftNaIstovaru']);

    final trebaPomocVozaca = _boolValue([
      'treba_pomoc_vozaca',
      'trebaPomocVozaca',
    ]);

    final prilazZaTegljac = _boolValue([
      'prilaz_za_tegljac',
      'prilazZaTegljac',
      'prilaz_za_sleper',
    ]);

    final status = _textValue(['status'], '');
    print('STATUS TERETA = $status');

    final trajanjeLicitacije = _textValue(['trajanje_licitacije'], '');
    final licitacijaZavrsavaAt = _textValue(['licitacija_zavrsava_at'], '');

    final canRate = shipment!['canRate'] == true;
    final hasRated = shipment!['hasRated'] == true;

    final ratingTargetLabel =
    shipment!['ratingTargetLabel']?.toString().trim().isNotEmpty == true
        ? shipment!['ratingTargetLabel'].toString()
        : widget.isSenderView
        ? 'prijevoznika'
        : 'naručitelja';

    String timerText = '';
    bool licitacijaZavrsena = false;

    if (licitacijaZavrsavaAt.isNotEmpty && licitacijaZavrsavaAt != '-') {
      try {
        final end = DateTime.parse(licitacijaZavrsavaAt).toLocal();
        final diff = end.difference(DateTime.now());

        if (diff.isNegative || diff.inSeconds <= 0) {
          licitacijaZavrsena = true;
          timerText = 'Licitacija završena';
        } else {
          final hours = diff.inHours;
          final minutes = diff.inMinutes.remainder(60);

          timerText = 'Još ${hours}h ${minutes}min';
        }
      } catch (_) {}
    }

    final statusIsActive = _isActiveStatus(status);
    final statusIsAccepted = _isAcceptedStatus(status);
    final statusIsCompleted = _isCompletedStatus(status);

    final bool canSendOffer = !licitacijaZavrsena && statusIsActive;

    final kontaktOtkljucan = shipment!['kontakt_otkljucan'] == true;
    final commissionPaid = shipment!['commissionPaid'] == true;

    final acceptedTransporterMustPay =
        shipment!['acceptedTransporterMustPay'] == true;

    final isAcceptedCarrier = shipment!['isAcceptedCarrier'] == true;
    print('SHIPMENT DATA = $shipment');
    print('IS ACCEPTED CARRIER = ${shipment!['isAcceptedCarrier']}');
    print('ACCEPTED TRANSPORTER MUST PAY = ${shipment!['acceptedTransporterMustPay']}');
    final isLosingCarrier =
        !widget.isSenderView &&
            statusIsAccepted &&
            !isAcceptedCarrier;
    print('IS ACCEPTED CARRIER = $isAcceptedCarrier');
    print('CAN RATE = $canRate');
    print('HAS RATED = $hasRated');
    print('STATUS COMPLETED = $statusIsCompleted');
    if (!widget.isSenderView && !kontaktOtkljucan) {
      adresaUtovara = _maskAddressForTransporter(adresaUtovara);
      adresaIstovara = _maskAddressForTransporter(adresaIstovara);
    }

    final showConfirmDeliveryButton = widget.isSenderView &&
        statusIsAccepted &&
        commissionPaid &&
        !statusIsCompleted;
    if (isLosingCarrier) {
      return RefreshIndicator(
        onRefresh: fetchShipmentDetails,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Text(
                'Status: Odabran drugi prijevoznik',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.orange,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Text(
                'Nažalost, drugi prijevoznik je odabran za ovaj prijevoz. Hvala na sudjelovanju u licitaciji.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
            _buildBidHistoryButton(),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: fetchShipmentDetails,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            elevation: 0.7,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nazivTereta,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (opisTereta != '-') ...[
                    Text(
                      opisTereta,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: (licitacijaZavrsena
                          ? Colors.red
                          : _statusColor(status))
                          .withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      licitacijaZavrsena
                          ? 'Status: Licitacija završena'
                          : (!widget.isSenderView && statusIsAccepted && !isAcceptedCarrier)
                          ? 'Status: Odabran drugi prijevoznik'
                          : (widget.isSenderView && statusIsAccepted)
                          ? 'Status: Prihvatili ste ponudu'
                          : 'Status: ${_formatStatus(status)}',
                      style: TextStyle(
                        color: licitacijaZavrsena
                            ? Colors.red
                            : _statusColor(status),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _buildStatusBlock(
                    status: status,
                    kontaktOtkljucan: kontaktOtkljucan,
                    commissionPaid: commissionPaid,
                    acceptedTransporterMustPay: acceptedTransporterMustPay,
                    isAcceptedCarrier: isAcceptedCarrier,
                    provizijaIznos: provizijaIznos,
                    acceptedPrice: acceptedPrice,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Mjesto utovara', mjestoUtovara),
                  _buildInfoRow('Adresa utovara', adresaUtovara),
                  _buildInfoRow('Mjesto istovara', mjestoIstovara),
                  _buildInfoRow('Adresa istovara', adresaIstovara),
                  _buildInfoRow('Datum utovara', datumUtovara),
                  _buildInfoRow('Rok utovara', rokUtovara),
                  if (statusIsActive &&
                      !statusIsAccepted &&
                      !kontaktOtkljucan &&
                      trajanjeLicitacije != '-')
                    _buildInfoRow('Trajanje licitacije', trajanjeLicitacije),
                  if (statusIsActive &&
                      !statusIsAccepted &&
                      !kontaktOtkljucan &&
                      timerText.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        timerText,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: licitacijaZavrsena
                              ? Colors.red
                              : Colors.deepOrange,
                        ),
                      ),
                    ),
                  if (tezina != null) _buildInfoRow('Težina', '$tezina kg'),
                  if (duzina != null) _buildInfoRow('Dužina', '$duzina cm'),
                  if (sirina != null) _buildInfoRow('Širina', '$sirina cm'),
                  if (visina != null) _buildInfoRow('Visina', '$visina cm'),
                  if (brojPaleta != null)
                    _buildInfoRow('Broj paleta', '$brojPaleta'),
                  _buildInfoRow('Način utovara', nacinUtovara),
                  _buildInfoRow('Tip lokacije utovara', tipLokacijeUtovara),
                  _buildInfoRow('Tip lokacije istovara', tipLokacijeIstovara),
                  _buildInfoRow('Kat utovara', katUtovara),
                  _buildInfoRow('Kat istovara', katIstovara),
                  _buildInfoRow('Lift na utovaru', liftUtovar ? 'Da' : 'Ne'),
                  _buildInfoRow('Lift na istovaru', liftIstovar ? 'Da' : 'Ne'),
                  _buildInfoRow(
                    'Treba pomoć vozača',
                    trebaPomocVozaca ? 'Da' : 'Ne',
                  ),
                  _buildInfoRow(
                    'Prilaz za tegljač',
                    prilazZaTegljac ? 'Da' : 'Ne',
                  ),
                  if (acceptedPrice != null)
                    _buildInfoRow(
                      'Prihvaćena cijena',
                      _formatMoney(acceptedPrice),
                    ),
                  if (provizijaIznos != null &&
                      (acceptedTransporterMustPay ||
                          commissionPaid ||
                          widget.isSenderView))
                    _buildInfoRow('Provizija', _formatMoney(provizijaIznos)),
                  if ((widget.isSenderView || kontaktOtkljucan) &&
                      kontaktTelefon.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: 145,
                            child: Text(
                              'Kontakt telefon:',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () => _callPhoneNumber(kontaktTelefon),
                              child: Text(
                                kontaktTelefon,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (!widget.isSenderView &&
                      kontaktOtkljucan &&
                      kontaktTelefon.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, bottom: 12),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _callPhoneNumber(kontaktTelefon),
                          icon: const Icon(Icons.phone),
                          label: const Text('Nazovi naručitelja'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ),
                  _buildInfoRow('Broj ponuda', '$offerCount'),
                  _buildInfoRow('Pregledi objave', '$views'),
                  _buildSenderRatingCard(
                    senderId: senderId,
                    senderName: senderName,
                    senderRatingAverage: senderRatingAverage,
                    senderRatingsCount: senderRatingsCount,
                  ),
                  _buildImagesSection(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          if (!widget.isSenderView && canSendOffer) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SendOfferScreen(
                        shipmentId: widget.shipmentId,
                      ),
                    ),
                  );

                  fetchShipmentDetails();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Pošalji ponudu',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          _buildBidHistoryButton(),

          if (showConfirmDeliveryButton) ...[
            const SizedBox(height: 12),
            _buildConfirmDeliveryButton(),
          ],
          if (statusIsCompleted &&
              (widget.isSenderView || isAcceptedCarrier)) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.shade200,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/logo_login3.png',
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TeReT isporučen',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.green.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Prijevoz je uspješno završen.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.isSenderView
                              ? 'Sada možete ocijeniti prijevoznika.'
                              : 'Sada možete ocijeniti naručitelja.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (statusIsCompleted &&
              !hasRated &&
              (widget.isSenderView || isAcceptedCarrier)) ...[
            const SizedBox(height: 12),
            _buildRatingButton(
              canRate: widget.isSenderView || isAcceptedCarrier,
              hasRated: hasRated,
              ratingTargetLabel: ratingTargetLabel,
            ),
          ],
          const SizedBox(height: 12),
          if (!widget.isSenderView &&
              !canSendOffer &&
              !acceptedTransporterMustPay &&
              !statusIsActive &&
              !isAcceptedCarrier)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                border: Border.all(color: Colors.orange.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                (!statusIsActive &&
                    statusIsAccepted &&
                    !acceptedTransporterMustPay &&
                    !kontaktOtkljucan)
                    ? 'Odabran je drugi prijevoznik za ovaj teret.'
                    : 'Na ovaj teret više nije moguće slati ponude.',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
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
        title: const Text('Detalji tereta'),
        actions: [
          IconButton(
            onPressed: fetchShipmentDetails,
            icon: const Icon(Icons.refresh),
            tooltip: 'Osvježi',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
}
