import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../services/token_storage.dart';

class RatingScreen extends StatefulWidget {
  final int shipmentId;
  final String ratedUserLabel;

  const RatingScreen({
    super.key,
    required this.shipmentId,
    this.ratedUserLabel = 'korisnika',
  });

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  final TextEditingController commentController = TextEditingController();

  int selectedRating = 0;
  bool isSubmitting = false;
  String errorMessage = '';

  Future<void> submitRating() async {
    if (selectedRating < 1 || selectedRating > 5) {
      setState(() {
        errorMessage = 'Molimo odaberite ocjenu od 1 do 5.';
      });
      return;
    }

    setState(() {
      isSubmitting = true;
      errorMessage = '';
    });

    try {
      final token = await TokenStorage.getToken();

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/ratings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'shipmentId': widget.shipmentId,
          'rating': selectedRating,
          'comment': commentController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ocjena je uspješno poslana.'),
          ),
        );

        Navigator.pop(context, true);
      } else {
        setState(() {
          errorMessage =
              data['message'] ?? 'Došlo je do greške kod slanja ocjene.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Greška spajanja na server.';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        isSubmitting = false;
      });
    }
  }

  Widget buildStar(int starNumber) {
    final isSelected = selectedRating >= starNumber;

    return IconButton(
      onPressed: isSubmitting
          ? null
          : () {
        setState(() {
          selectedRating = starNumber;
          errorMessage = '';
        });
      },
      iconSize: 42,
      splashRadius: 26,
      icon: Icon(
        isSelected ? Icons.star_rounded : Icons.star_border_rounded,
        color: isSelected ? Colors.amber : Colors.grey.shade500,
      ),
    );
  }

  String getRatingText() {
    switch (selectedRating) {
      case 1:
        return 'Vrlo loše';
      case 2:
        return 'Loše';
      case 3:
        return 'Dobro';
      case 4:
        return 'Vrlo dobro';
      case 5:
        return 'Odlično';
      default:
        return 'Odaberite ocjenu';
    }
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const mainColor = Color(0xFF0D47A1);
    const accentColor = Color(0xFFFF9800);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ocijeni prijevoz'),
        centerTitle: true,
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        color: mainColor.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.rate_review_rounded,
                        size: 38,
                        color: mainColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ocijenite ${widget.ratedUserLabel}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vaša povratna informacija pomaže drugim korisnicima.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        buildStar(1),
                        buildStar(2),
                        buildStar(3),
                        buildStar(4),
                        buildStar(5),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      getRatingText(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: selectedRating == 0
                            ? Colors.grey.shade600
                            : accentColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: commentController,
                      maxLines: 5,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        labelText: 'Komentar (opcionalno)',
                        alignLabelWithHint: true,
                        hintText: 'Npr. sve uredno i na vrijeme...',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: mainColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    if (errorMessage.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          errorMessage,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : submitRating,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.orange.shade200,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.6,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                            : const Text(
                          'Pošalji ocjenu',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
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
    );
  }
}