import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../l10n/app_localizations.dart';
import '../services/token_storage.dart';
import 'login_screen.dart';

class SendOfferScreen extends StatefulWidget {
  final int shipmentId;

  const SendOfferScreen({
    super.key,
    required this.shipmentId,
  });

  @override
  State<SendOfferScreen> createState() => _SendOfferScreenState();
}

class _SendOfferScreenState extends State<SendOfferScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController amountController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  bool isLoading = false;
  bool isLoadingLowestOffer = true;

  double? lowestOffer;
  double? myOffer;

  String selectedCurrency = '€';

  bool get isMyOfferLowest {
    if (lowestOffer == null || myOffer == null) return false;
    return myOffer! <= lowestOffer!;
  }

  @override
  void initState() {
    super.initState();
    fetchLowestOffer();
  }

  @override
  void dispose() {
    amountController.dispose();
    messageController.dispose();
    super.dispose();
  }

  double? _parseAmount() {
    final raw = amountController.text.trim().replaceAll(',', '.');
    return double.tryParse(raw);
  }

  String formatPrice(dynamic value) {
    if (value == null) return '-';

    final number = double.tryParse(value.toString());

    if (number == null) {
      return value.toString();
    }

    if (number == number.roundToDouble()) {
      return '${number.toInt()} $selectedCurrency';
    }

    return '${number.toStringAsFixed(2)} $selectedCurrency';
  }

  void setQuickOffer(double value) {
    if (value <= 0) return;

    setState(() {
      if (value == value.roundToDouble()) {
        amountController.text = value.toInt().toString();
      } else {
        amountController.text = value.toStringAsFixed(2);
      }
    });
  }

  void lowerOfferBy(double amount) {
    final l10n = AppLocalizations.of(context)!;
    final base = lowestOffer ?? myOffer;

    if (base == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.noCurrentOfferForAutomaticReduction),
        ),
      );
      return;
    }

    final newAmount = base - amount;

    if (newAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.offerAmountMustBeGreaterThanZero),
        ),
      );
      return;
    }

    setQuickOffer(newAmount);
  }

  void setAsLowestOffer() {
    final l10n = AppLocalizations.of(context)!;

    if (lowestOffer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.noLowestOfferForShipment),
        ),
      );
      return;
    }

    final newAmount = lowestOffer! - 5;

    if (newAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.offerAmountMustBeGreaterThanZero),
        ),
      );
      return;
    }

    setQuickOffer(newAmount);
  }

  Future<void> fetchLowestOffer() async {
    try {
      final token = await TokenStorage.getToken();

      if (token == null || token.isEmpty) {
        if (!mounted) return;

        setState(() {
          isLoadingLowestOffer = false;
        });

        return;
      }

      final shipmentsResponse = await http.get(
        Uri.parse('${AppConfig.baseUrl}/shipments'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );

      if (shipmentsResponse.statusCode == 200) {
        final data = jsonDecode(shipmentsResponse.body);

        if (data is List) {
          final shipment = data.firstWhere(
                (item) {
              if (item is! Map) return false;

              return int.tryParse('${item['id']}') == widget.shipmentId;
            },
            orElse: () => null,
          );

          if (shipment is Map && shipment['lowestOffer'] != null) {
            lowestOffer = double.tryParse(
              '${shipment['lowestOffer']}',
            );
          }
        }
      }

      final myOffersResponse = await http.get(
        Uri.parse('${AppConfig.baseUrl}/my-offers'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );

      if (myOffersResponse.statusCode == 200) {
        final data = jsonDecode(myOffersResponse.body);

        if (data is List) {
          final offer = data.firstWhere(
                (item) {
              if (item is! Map) return false;

              final offerShipmentId = int.tryParse(
                '${item['shipmentId'] ??
                    item['shipment_id'] ??
                    item['shipment_id_fk']}',
              );

              return offerShipmentId == widget.shipmentId;
            },
            orElse: () => null,
          );

          if (offer is Map) {
            myOffer = double.tryParse(
              '${offer['amount'] ??
                  offer['price'] ??
                  offer['cijena']}',
            );
          }
        }
      }
    } catch (_) {
      // Ekran se nastavlja prikazivati i ako dohvat ne uspije.
    } finally {
      if (!mounted) return;

      setState(() {
        isLoadingLowestOffer = false;
      });
    }
  }

  Future<void> sendOffer() async {
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() {
      isLoading = true;
    });

    try {
      final token = await TokenStorage.getToken();

      if (token == null || token.isEmpty) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.notLoggedInLoginAgain),
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
              (route) => false,
        );

        return;
      }

      final amount = _parseAmount();

      if (amount == null || amount <= 0) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.enterValidOfferAmount),
          ),
        );

        return;
      }

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/offers'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
        body: jsonEncode({
          'shipmentId': widget.shipmentId,
          'amount': amount,
          'currency': selectedCurrency,
          'message': messageController.text.trim(),
        }),
      );

      Map<String, dynamic> data = {};

      try {
        final decoded = response.body.isNotEmpty
            ? jsonDecode(response.body)
            : {};

        if (decoded is Map<String, dynamic>) {
          data = decoded;
        } else if (decoded is Map) {
          data = Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        data = {};
      }

      if (!mounted) return;

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['message']?.toString() ??
                  l10n.offerSuccessfullySent,
            ),
          ),
        );

        Navigator.pop(context, true);
        return;
      }

      if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.sessionExpiredLoginAgain),
          ),
        );

        await TokenStorage.clearToken();

        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
              (route) => false,
        );

        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            data['message']?.toString() ??
                l10n.errorSendingOffer,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.serverConnectionError),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  InputDecoration buildInputDecoration({
    required String label,
    String? hint,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon) : null,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.blue,
          width: 1.4,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
    );
  }

  Widget buildQuickButton({
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon ?? Icons.remove,
          size: 18,
        ),
        label: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.blueGrey.shade900,
          side: BorderSide(
            color: Colors.blueGrey.shade200,
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget buildOfferInfoBox() {
    final l10n = AppLocalizations.of(context)!;

    if (isLoadingLowestOffer) {
      return Text(
        l10n.loadingCurrentLowestOffer,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      );
    }

    if (lowestOffer == null && myOffer == null) {
      return Text(
        l10n.noOffersForShipmentYet,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lowestOffer == null
              ? l10n.currentLowestOfferUnavailable
              : l10n.currentLowestOffer(
            formatPrice(lowestOffer),
          ),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          myOffer == null
              ? l10n.yourOfferNotSubmitted
              : l10n.yourOffer(
            formatPrice(myOffer),
          ),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        if (isMyOfferLowest) ...[
          const SizedBox(height: 8),
          Text(
            l10n.yourOfferIsCurrentlyLowest,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.green,
            ),
          ),
        ],
        if (!isMyOfferLowest && lowestOffer != null) ...[
          const SizedBox(height: 8),
          Text(
            l10n.newOfferMinimumLower(
              selectedCurrency,
            ),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sendOffer),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.newOffer,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.enterRequestedTransportPrice,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMyOfferLowest
                              ? Colors.green.shade50
                              : Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isMyOfferLowest
                                ? Colors.green.shade300
                                : Colors.teal.shade200,
                          ),
                        ),
                        child: buildOfferInfoBox(),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.shade200,
                          ),
                        ),
                        child: Text(
                          l10n.offerBindingNotice,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: selectedCurrency,
                        decoration: buildInputDecoration(
                          label: l10n.currency,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: '€',
                            child: Text(l10n.euroCurrency),
                          ),
                          DropdownMenuItem(
                            value: '\$',
                            child: Text(l10n.usDollarCurrency),
                          ),
                          DropdownMenuItem(
                            value: '£',
                            child: Text(l10n.britishPoundCurrency),
                          ),
                          DropdownMenuItem(
                            value: 'C\$',
                            child: Text(l10n.canadianDollarCurrency),
                          ),
                          DropdownMenuItem(
                            value: 'A\$',
                            child: Text(l10n.australianDollarCurrency),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;

                          setState(() {
                            selectedCurrency = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: amountController,
                        keyboardType:
                        const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: buildInputDecoration(
                          label: l10n.offerAmount(
                            selectedCurrency,
                          ),
                          hint: l10n.enterAmount,
                        ),
                        validator: (value) {
                          final text = value?.trim() ?? '';

                          if (text.isEmpty) {
                            return l10n.enterOfferAmount;
                          }

                          final parsed = double.tryParse(
                            text.replaceAll(',', '.'),
                          );

                          if (parsed == null) {
                            return l10n.enterValidNumber;
                          }

                          if (parsed <= 0) {
                            return l10n.amountMustBeGreaterThanZero;
                          }

                          if (lowestOffer != null &&
                              parsed > lowestOffer!) {
                            return l10n
                                .offerMustBeLowerThanCurrentLowest;
                          }

                          if (lowestOffer != null &&
                              lowestOffer! - parsed < 5) {
                            return l10n.minimumOfferReduction(
                              selectedCurrency,
                            );
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          buildQuickButton(
                            label: '-5 $selectedCurrency',
                            onPressed: () => lowerOfferBy(5),
                          ),
                          const SizedBox(width: 8),
                          buildQuickButton(
                            label: '-10 $selectedCurrency',
                            onPressed: () => lowerOfferBy(10),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: setAsLowestOffer,
                          icon: const Icon(
                            Icons.trending_down,
                          ),
                          label: Text(
                            l10n.setAsLowestOffer,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.green.shade800,
                            side: BorderSide(
                              color: Colors.green.shade300,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 13,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: messageController,
                        maxLines: 4,
                        decoration: buildInputDecoration(
                          label: l10n.messageToCustomerOptional,
                          hint: l10n.enterShortMessage,
                          icon: Icons.message_outlined,
                        ),
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) {
                          if (!isLoading) {
                            sendOffer();
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(
                          bottom: 16,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          border: Border.all(
                            color: Colors.orange.shade300,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '⚡',
                              style: TextStyle(
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                l10n.nearLoadingLocationNotice,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed:
                          isLoading ? null : sendOffer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: Colors.white,
                            ),
                          )
                              : Text(
                            l10n.sendOffer,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}