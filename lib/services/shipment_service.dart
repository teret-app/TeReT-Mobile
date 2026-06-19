import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config.dart';
import 'token_storage.dart';

class ShipmentService {
  static Future<List<dynamic>> getShipments() async {
    final token = await TokenStorage.getToken();

    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/shipments'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<dynamic>.from(data);
    } else {
      throw Exception(data['message'] ?? 'Greška kod učitavanja tereta');
    }
  }

  static Future<Map<String, dynamic>> createShipment({
    required String title,
    required String fromCity,
    required String toCity,
    required String weight,
    required String pickupDate,
    String fromAddress = '',
    String toAddress = '',
    String dimensions = '',
    String urgency = '',
    String description = '',
    String loadingMethod = '',
    bool driverHelpRequired = false,
    String locationType = '',
    bool hasTruckAccess = false,
    String floor = '',
    bool hasElevator = false,
    String pallets = '',
    List<String> images = const [],
  }) async {
    final token = await TokenStorage.getToken();

    String duzina = '';
    String sirina = '';
    String visina = '';

    if (dimensions.trim().isNotEmpty) {
      final parts = dimensions.split('x');
      if (parts.length == 3) {
        duzina = parts[0].trim();
        sirina = parts[1].trim();
        visina = parts[2].trim();
      }
    }

    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/shipments'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'naziv_tereta': title.trim(),
        'opis_tereta': description.trim(),
        'mjesto_utovara': fromCity.trim(),
        'adresa_utovara': fromAddress.trim(),
        'mjesto_istovara': toCity.trim(),
        'adresa_istovara': toAddress.trim(),
        'datum_utovara': pickupDate.trim(),
        'tezina_kg': double.tryParse(weight.trim().replaceAll(',', '.')) ?? 0,
        'duzina_cm': duzina.isEmpty
            ? null
            : double.tryParse(duzina.replaceAll(',', '.')),
        'sirina_cm': sirina.isEmpty
            ? null
            : double.tryParse(sirina.replaceAll(',', '.')),
        'visina_cm': visina.isEmpty
            ? null
            : double.tryParse(visina.replaceAll(',', '.')),
        'broj_paleta': pallets.trim().isEmpty ? null : int.tryParse(pallets.trim()),
        'nacin_utovara': loadingMethod.trim(),
        'tip_lokacije': locationType.trim(),
        'kat_utovara': floor.trim(),
        'prilaz_za_tegljac': hasTruckAccess,
        'treba_pomoc_vozaca': driverHelpRequired,
        'lift_na_utovaru': hasElevator,
        'rok_utovara': urgency.trim(),
        'images': images,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Map<String, dynamic>.from(data);
    } else {
      throw Exception(data['message'] ?? 'Greška kod objave tereta');
    }
  }

  static Future<List<dynamic>> getMyShipments() async {
    final token = await TokenStorage.getToken();

    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/my-shipments'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<dynamic>.from(data);
    } else {
      throw Exception(data['message'] ?? 'Greška kod učitavanja mojih tereta');
    }
  }

  static Future<Map<String, dynamic>> getShipmentDetails(int id) async {
    final token = await TokenStorage.getToken();

    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/shipments/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data);
    } else {
      throw Exception(data['message'] ?? 'Greška kod učitavanja detalja tereta');
    }
  }

  static Future<Map<String, dynamic>> confirmDelivery(int id) async {
    final token = await TokenStorage.getToken();

    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/shipments/$id/confirm-delivery'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data);
    } else {
      throw Exception(data['message'] ?? 'Greška kod potvrde isporuke');
    }
  }
}