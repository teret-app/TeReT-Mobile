import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../services/token_storage.dart';

class UserProfileScreen extends StatefulWidget {
  final int userId;
  final String userName;

  const UserProfileScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool isLoading = true;
  String errorMessage = '';
  Map<String, dynamic>? ratingData;

  @override
  void initState() {
    super.initState();
    fetchRatings();
  }

  Future<void> fetchRatings() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final token = await TokenStorage.getToken();

      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/users/${widget.userId}/ratings'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          ratingData = data;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = data['message'] ?? 'Greška kod učitavanja ocjena.';
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Greška spajanja na server.';
        isLoading = false;
      });
    }
  }

  Widget buildStars(num rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final filled = index < rating.round();

        return Icon(
          filled ? Icons.star_rounded : Icons.star_border_rounded,
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }
  String formatRatingDate(dynamic value) {
    if (value == null) return '';

    try {
      final date = DateTime.parse(value.toString()).toLocal();

      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();

      return '$day.$month.$year.';
    } catch (_) {
      return '';
    }
  }
  @override
  Widget build(BuildContext context) {
    const mainColor = Color(0xFF0D47A1);

    final ratings = (ratingData?['ratings'] as List?) ?? [];
    final averageRating = ratingData?['averageRating'];
    final ratingsCount = ratingData?['ratingsCount'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil korisnika'),
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
            ? Center(child: Text(errorMessage))
            : RefreshIndicator(
          onRefresh: fetchRatings,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.account_circle_rounded,
                      size: 72,
                      color: mainColor,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.userName.isNotEmpty
                          ? widget.userName
                          : 'Korisnik',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      averageRating == null
                          ? 'Još nema ocjena'
                          : '⭐ $averageRating / 5',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$ratingsCount ocjena',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Komentari korisnika',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              if (ratings.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Još nema komentara.'),
                )
              else
                ...ratings.map((rating) {
                  final value = NumberFormatHelper.toNum(
                    rating['rating'],
                  );
                  final comment =
                  (rating['comment'] ?? '').toString().trim();
                  final ratingDate = formatRatingDate(
                    rating['createdAt'] ??
                        rating['ratedAt'] ??
                        rating['date'],
                  );
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color:
                          Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildStars(value),
                        const SizedBox(height: 8),
                        Text(
                          comment.isNotEmpty
                              ? comment
                              : 'Bez komentara.',
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        if (ratingDate.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            ratingDate,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

class NumberFormatHelper {
  static num toNum(dynamic value) {
    if (value is num) return value;
    return num.tryParse(value.toString()) ?? 0;
  }
}