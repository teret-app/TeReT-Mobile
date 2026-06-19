import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../services/token_storage.dart';
import 'login_screen.dart';
import 'my_offers_screen.dart';
import 'shipment_details_screen.dart';

class AvailableShipmentsScreen extends StatefulWidget {
  const AvailableShipmentsScreen({super.key});

  @override
  State<AvailableShipmentsScreen> createState() =>
      _AvailableShipmentsScreenState();
}

class _AvailableShipmentsScreenState extends State<AvailableShipmentsScreen> {
  List<dynamic> shipments = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchShipments();
  }

  Future<void> fetchShipments() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final token = await TokenStorage.getToken();

      if (token == null || token.isEmpty) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
          errorMessage = 'Niste prijavljeni. Prijavite se ponovno.';
        });
        return;
      }

      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/shipments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          shipments = data;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = data['message'] ?? 'Greška kod dohvaćanja tereta.';
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Greška veze sa serverom: $e';
        isLoading = false;
      });
    }
  }

  Future<void> logout() async {
    await TokenStorage.clearToken();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    if (text.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey.shade700,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShipmentCard(Map<String, dynamic> shipment) {
    final int shipmentId = shipment['id'] ?? 0;
    final String nazivTereta = (shipment['nazivTereta'] ?? 'Teret').toString();
    final String mjestoUtovara = (shipment['mjestoUtovara'] ?? '').toString();
    final String mjestoIstovara = (shipment['mjestoIstovara'] ?? '').toString();
    final String datumUtovara = (shipment['datumUtovara'] ?? '').toString();
    final String tezina = (shipment['tezina'] ?? '').toString();
    final String brojPaleta = (shipment['brojPaleta'] ?? '').toString();
    final String rokUtovara = (shipment['rokUtovara'] ?? '').toString();
    final String status = (shipment['status'] ?? 'open').toString();

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ShipmentDetailsScreen(
              shipmentId: shipmentId,
            ),
          ),
        ).then((_) => fetchShipments());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.local_shipping_rounded,
                      color: Color(0xFF1E3A8A),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      nazivTereta,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: status == 'open'
                          ? Colors.orange.withOpacity(0.12)
                          : Colors.green.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      status == 'open' ? 'Novo' : 'Zatvoreno',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color:
                            status == 'open' ? Colors.orange : Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.arrow_upward, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            mjestoUtovara,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.arrow_downward, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            mjestoIstovara,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (datumUtovara.isNotEmpty) ...[
                _buildInfoRow(Icons.calendar_today, datumUtovara),
              ],
              if (tezina.isNotEmpty) ...[
                _buildInfoRow(Icons.scale_outlined, 'Težina: $tezina'),
              ],
              if (brojPaleta.isNotEmpty) ...[
                _buildInfoRow(Icons.view_module_outlined, 'Palete: $brojPaleta'),
              ],
              if (rokUtovara.isNotEmpty) ...[
                _buildInfoRow(Icons.schedule, 'Rok utovara: $rokUtovara'),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ShipmentDetailsScreen(
                          shipmentId: shipmentId,
                        ),
                      ),
                    ).then((_) => fetchShipments());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Otvori detalje',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    if (shipments.isEmpty) {
      return RefreshIndicator(
        onRefresh: fetchShipments,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_rounded,
                        size: 68,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Trenutno nema dostupnih tereta.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Kad se objave novi tereti, prikazat će se ovdje.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchShipments,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF1E3A8A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dostupni tereti',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${shipments.length} aktivnih objava',
                  style: const TextStyle(
                    fontSize: 21,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Otvorite teret i pošaljite svoju ponudu.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...shipments.map((shipment) {
            return _buildShipmentCard(
              Map<String, dynamic>.from(shipment),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text(
          'Dostupni tereti',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Moje ponude',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MyOffersScreen(),
                ),
              ).then((_) => fetchShipments());
            },
            icon: const Icon(Icons.description_outlined),
          ),
          IconButton(
            tooltip: 'Odjava',
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MyOffersScreen(),
            ),
          ).then((_) => fetchShipments());
        },
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.request_quote_outlined),
        label: const Text(
          'Moje ponude',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}