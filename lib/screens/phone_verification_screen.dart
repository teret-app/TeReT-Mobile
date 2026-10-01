import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config.dart';

class PhoneVerificationScreen extends StatefulWidget {
  final String email;

  const PhoneVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState
    extends State<PhoneVerificationScreen> {
  final TextEditingController codeController = TextEditingController();

  bool isLoading = false;
  String errorMessage = '';

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  Future<void> verifyPhone() async {
    final code = codeController.text.trim();

    if (code.isEmpty) {
      setState(() {
        errorMessage = 'Unesite SMS kod.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/verify-phone'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': widget.email,
          'code': code,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data['phoneVerified'] == true) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Broj telefona je uspješno potvrđen.',
            ),
          ),
        );

        Navigator.of(context).pop(true);
      } else {
        if (!mounted) return;

        setState(() {
          errorMessage =
              (data['message'] ?? 'Neispravan SMS kod.').toString();
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage =
        'Greška pri povezivanju sa serverom.';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Potvrda broja telefona'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'SMS kod je poslan na vaš broj telefona.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Unesite kod iz SMS poruke kako biste potvrdili broj telefona.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),

              TextField(
                controller: codeController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'SMS kod',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) {
                  if (!isLoading) {
                    verifyPhone();
                  }
                },
              ),

              if (errorMessage.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  errorMessage,
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: isLoading ? null : verifyPhone,
                child: isLoading
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Text('Potvrdi broj'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}