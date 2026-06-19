import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../services/token_storage.dart';

class EditShipmentScreen extends StatefulWidget {
  final Map<String, dynamic> shipment;

  const EditShipmentScreen({
    super.key,
    required this.shipment,
  });

  @override
  State<EditShipmentScreen> createState() => _EditShipmentScreenState();
}

class _EditShipmentScreenState extends State<EditShipmentScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nazivController;
  late TextEditingController opisController;
  late TextEditingController mjestoUtovaraController;
  late TextEditingController mjestoIstovaraController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    nazivController = TextEditingController(
      text: widget.shipment['naziv_tereta'] ?? '',
    );

    opisController = TextEditingController(
      text: widget.shipment['opis_tereta'] ?? '',
    );

    mjestoUtovaraController = TextEditingController(
      text: widget.shipment['mjesto_utovara'] ?? '',
    );

    mjestoIstovaraController = TextEditingController(
      text: widget.shipment['mjesto_istovara'] ?? '',
    );
  }

  @override
  void dispose() {
    nazivController.dispose();
    opisController.dispose();
    mjestoUtovaraController.dispose();
    mjestoIstovaraController.dispose();
    super.dispose();
  }

  InputDecoration dekoracija(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  Future<void> spremiPromjene() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final token = await TokenStorage.getToken();

      final response = await http.put(
        Uri.parse(
          '${AppConfig.baseUrl}/shipments/${widget.shipment['id']}',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'naziv_tereta': nazivController.text.trim(),
          'opis_tereta': opisController.text.trim(),
          'mjesto_utovara': mjestoUtovaraController.text.trim(),
          'mjesto_istovara': mjestoIstovaraController.text.trim(),
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Objava uspješno ažurirana.'),
          ),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Greška pri ažuriranju objave.'),
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
    } finally {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uredi objavu'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: nazivController,
              decoration: dekoracija('Naziv tereta'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Unesite naziv tereta.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: opisController,
              maxLines: 4,
              decoration: dekoracija('Opis tereta'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Unesite opis tereta.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: mjestoUtovaraController,
              decoration: dekoracija('Mjesto utovara'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: mjestoIstovaraController,
              decoration: dekoracija('Mjesto istovara'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : spremiPromjene,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Spremi promjene'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}