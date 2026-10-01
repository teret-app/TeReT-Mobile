import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'admin_shipment_details.screen.dart';
import '../config.dart';
import '../services/token_storage.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _loading = true;
  String? _error;

  int totalUsers = 0;
  int carriers = 0;
  int senders = 0;
  int totalShipments = 0;
  int activeShipments = 0;
  int acceptedShipments = 0;
  int finishedShipments = 0;
  int totalOffers = 0;
  int unpaidCommissions = 0;

  List<dynamic> adminShipments = [];
  List<dynamic> adminUsers = [];
  String selectedFilter = 'all';
  String selectedSection = 'overview';
  String selectedUserRole = 'carrier';
  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Niste prijavljeni.');
    }

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<void> _loadAll() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final headers = await _headers();

      final responses = await Future.wait([
        http.get(
          Uri.parse('${AppConfig.baseUrl}/admin/stats'),
          headers: headers,
        ),

        http.get(
          Uri.parse('${AppConfig.baseUrl}/admin/shipments'),
          headers: headers,
        ),
        http.get(
          Uri.parse('${AppConfig.baseUrl}/admin/users'),
          headers: headers,
        ),
      ]);

      final statsResponse = responses[0];
      final shipmentsResponse = responses[1];
      final usersResponse = responses[2];
      if (statsResponse.statusCode == 403 ||
          shipmentsResponse.statusCode == 403 ||
          usersResponse.statusCode == 403) {
        throw Exception('Nemate administratorska prava.');
      }

      if (statsResponse.statusCode != 200) {
        throw Exception(
          'Greška statistike (${statsResponse.statusCode}).',
        );
      }

      if (shipmentsResponse.statusCode != 200) {
        throw Exception(
          'Greška aktivnih tereta (${shipmentsResponse.statusCode}).',
        );
      }

      final stats = jsonDecode(statsResponse.body);
      final shipments = jsonDecode(shipmentsResponse.body);
      final users = jsonDecode(usersResponse.body);
      if (!mounted) return;

      setState(() {
        totalUsers = stats['totalUsers'] ?? 0;
        carriers = stats['carriers'] ?? 0;
        senders = stats['senders'] ?? 0;
        totalShipments = stats['totalShipments'] ?? 0;
        activeShipments = stats['activeShipments'] ?? 0;
        acceptedShipments = stats['acceptedShipments'] ?? 0;
        finishedShipments = stats['finishedShipments'] ?? 0;
        totalOffers = stats['totalOffers'] ?? 0;
        unpaidCommissions = stats['unpaidCommissions'] ?? 0;

        adminShipments = shipments is List ? shipments : [];
        adminUsers = users is List ? users : [];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _deleteShipment(dynamic shipment) async {
    final id = shipment['id'];

    if (id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Obrisati objavu?'),
          content: Text(
            'Želite li kao administrator trajno obrisati objavu '
                '"${shipment['naziv_tereta'] ?? 'Teret'}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Odustani'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              icon: const Icon(Icons.delete_forever),
              label: const Text('Obriši'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      final headers = await _headers();

      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/admin/shipments/$id'),
        headers: headers,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Objava je uspješno obrisana.'),
          ),
        );

        await _loadAll();
        return;
      }

      String message = 'Brisanje nije uspjelo.';

      try {
        final data = jsonDecode(response.body);
        message = data['message'] ?? message;
      } catch (_) {}

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }
  Future<void> _toggleUserBlock(dynamic user) async {
    final id = user['id'];
    if (id == null) return;

    final bool isBlocked = user['isBlocked'] == true;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            isBlocked ? 'Odblokirati korisnika?' : 'Blokirati korisnika?',
          ),
          content: Text(
            isBlocked
                ? 'Želite li ponovno omogućiti pristup ovom korisniku?'
                : 'Želite li ovom korisniku onemogućiti pristup aplikaciji?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Odustani'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: Text(
                isBlocked ? 'Odblokiraj' : 'Blokiraj',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      final headers = await _headers();

      final action = isBlocked ? 'unblock' : 'block';

      final response = await http.put(
        Uri.parse(
          '${AppConfig.baseUrl}/admin/users/$id/$action',
        ),
        headers: headers,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isBlocked
                  ? 'Korisnik je odblokiran.'
                  : 'Korisnik je blokiran.',
            ),
          ),
        );

        await _loadAll();
        return;
      }

      String message = 'Promjena statusa nije uspjela.';

      try {
        final data = jsonDecode(response.body);
        message = data['message'] ?? message;
      } catch (_) {}

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }
  Widget _statCard({
    required String title,
    required int value,
    required IconData icon,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                size: 28,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value.toString(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  List<dynamic> get filteredShipments {
    if (selectedFilter == 'all') {
      return adminShipments;
    }

    return adminShipments.where((shipment) {
      final status =
          shipment['status']?.toString().toLowerCase() ?? '';

      if (selectedFilter == 'active') {
        return status == 'active' ||
            status == 'aktivan';
      }

      if (selectedFilter == 'accepted') {
        return status == 'accepted' ||
            status == 'prihvaceno' ||
            status == 'prihvaćeno';
      }

      if (selectedFilter == 'finished') {
        return status == 'finished' ||
            status == 'completed' ||
            status == 'zavrsen' ||
            status == 'završen' ||
            status == 'zavrseno' ||
            status == 'završeno' ||
            status == 'licitacija_zavrsena' ||
            status == 'licitacija završena' ||
            status == 'expired';
      }

      return true;
    }).toList();
  }
  List<dynamic> get filteredUsers {
    return adminUsers.where((user) {
      final role =
          user['role']?.toString().toLowerCase() ?? '';

      if (selectedUserRole == 'carrier') {
        return role == 'carrier';
      }

      if (selectedUserRole == 'sender') {
        return role == 'sender';
      }

      return true;
    }).toList();
  }

  Widget _shipmentCard(dynamic shipment) {
    final pickup =
    '${shipment['drzava_utovara'] ?? ''} '
        '${shipment['mjesto_utovara'] ?? ''}'
        .trim();

    final delivery =
    '${shipment['drzava_istovara'] ?? ''} '
        '${shipment['mjesto_istovara'] ?? ''}'
        .trim();
    final acceptedCarrierName =
        shipment['acceptedCarrierName']?.toString() ?? '';

    final acceptedCarrierEmail =
        shipment['acceptedCarrierEmail']?.toString() ?? '';

    final acceptedCarrierPhone =
        shipment['acceptedCarrierPhone']?.toString() ?? '';

    final commissionPaid =
        shipment['commissionPaid'] == true;
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AdminShipmentDetailsScreen(
                  shipment: Map<String, dynamic>.from(shipment),
                ),
              ),
            );
          },
          child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    shipment['naziv_tereta']?.toString().isNotEmpty == true
                        ? shipment['naziv_tereta'].toString()
                        : 'Teret #${shipment['id']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '#${shipment['id']}',
                  style: const TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.route,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$pickup → $delivery',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Naručitelj: '
                        '${shipment['senderName'] ?? 'Nepoznat korisnik'}',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(
                  Icons.gavel,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Ponude: ${shipment['offersCount'] ?? 0}',
                ),
              ],
            ),
            if ((shipment['acceptedCarrierName'] ?? '').toString().isNotEmpty) ...[
              const SizedBox(height: 10),

              Row(
                children: [
                  const Icon(Icons.local_shipping, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Prihvaćeni prijevoznik: ${shipment['acceptedCarrierName']}',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              Row(
                children: [
                  Icon(
                    shipment['commissionPaid'] == true
                        ? Icons.check_circle
                        : Icons.warning_amber_rounded,
                    size: 20,
                    color: shipment['commissionPaid'] == true
                        ? Colors.green
                        : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    shipment['commissionPaid'] == true
                        ? 'Provizija plaćena — ${(double.tryParse(shipment['commissionAmount']?.toString() ?? '') ?? 0).toStringAsFixed(2)} €'
                        : 'PROVIZIJA NIJE PLAĆENA — ${(double.tryParse(shipment['commissionAmount']?.toString() ?? '') ?? 0).toStringAsFixed(2)} €',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: shipment['commissionPaid'] == true
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _deleteShipment(shipment),
                icon: const Icon(Icons.delete_forever),
                label: const Text('Obriši objavu'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),

        ),    
    );
  }
  Widget _userCard(dynamic user) {
    final bool isBlocked = user['isBlocked'] == true;

    final String name =
    (user['name'] ?? 'Nepoznat korisnik').toString();

    final String role =
    (user['role'] ?? '').toString();

    final String email =
    (user['email'] ?? '').toString();

    final String phone =
    (user['phone'] ?? '').toString();

    final int shipmentsCount =
        user['shipmentsCount'] ?? 0;

    final int offersCount =
        user['offersCount'] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text('Uloga: $role'),
            Text('Email: $email'),
            Text('Telefon: $phone'),

            const SizedBox(height: 8),

            Text('Objave tereta: $shipmentsCount'),
            Text('Poslane ponude: $offersCount'),

            const SizedBox(height: 8),

            Text(
              isBlocked
                  ? 'Status: BLOKIRAN'
                  : 'Status: AKTIVAN',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isBlocked
                    ? Colors.red
                    : Colors.green,
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _toggleUserBlock(user),
                icon: Icon(
                  isBlocked ? Icons.lock_open : Icons.block,
                ),
                label: Text(
                  isBlocked
                      ? 'ODBLOKIRAJ KORISNIKA'
                      : 'BLOKIRAJ KORISNIKA',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  isBlocked ? Colors.green : Colors.red,
                  foregroundColor: Colors.white,
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
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Admin pregled',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Osvježi',
            onPressed: _loading ? null : _loadAll,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAll,
        child: _loading
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : _error != null
            ? ListView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),

              children: [

            const SizedBox(height: 100),
            const Icon(
              Icons.error_outline,
              size: 70,
              color: Colors.red,
            ),
            const SizedBox(height: 20),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadAll,
              icon: const Icon(Icons.refresh),
              label: const Text('Pokušaj ponovno'),
            ),
          ],
        )
            : ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            // GORNJI IZBORNIK
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedSection = 'overview';
                      });
                    },
                    child: const Text('Pregled'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedSection = 'shipments';
                      });
                    },
                    child: const Text('Tereti'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedSection = 'users';
                      });
                    },
                    child: const Text('Korisnici'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // PREGLED
            if (selectedSection == 'overview') ...[
              _statCard(
                title: 'Ukupno korisnika',
                value: totalUsers,
                icon: Icons.people,
              ),
              _statCard(
                title: 'Prijevoznici',
                value: carriers,
                icon: Icons.local_shipping,
              ),
              _statCard(
                title: 'Naručitelji',
                value: senders,
                icon: Icons.person,
              ),
              _statCard(
                title: 'Ukupno objava tereta',
                value: totalShipments,
                icon: Icons.inventory_2,
              ),
              _statCard(
                title: 'Aktivni tereti',
                value: activeShipments,
                icon: Icons.timer,
              ),
              _statCard(
                title: 'Prihvaćeni prijevozi',
                value: acceptedShipments,
                icon: Icons.handshake,
              ),
              _statCard(
                title: 'Završeni prijevozi',
                value: finishedShipments,
                icon: Icons.check_circle,
              ),
              _statCard(
                title: 'Ukupno ponuda',
                value: totalOffers,
                icon: Icons.euro,
              ),
              _statCard(
                title: 'Neplaćene provizije',
                value: unpaidCommissions,
                icon: Icons.warning_amber_rounded,
              ),
            ],

            // TERETI
            if (selectedSection == 'shipments') ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Sve'),
                    selected: selectedFilter == 'all',
                    onSelected: (_) {
                      setState(() {
                        selectedFilter = 'all';
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Aktivni'),
                    selected: selectedFilter == 'active',
                    onSelected: (_) {
                      setState(() {
                        selectedFilter = 'active';
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Prihvaćeni'),
                    selected: selectedFilter == 'accepted',
                    onSelected: (_) {
                      setState(() {
                        selectedFilter = 'accepted';
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Završeni'),
                    selected: selectedFilter == 'finished',
                    onSelected: (_) {
                      setState(() {
                        selectedFilter = 'finished';
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 14),

              if (filteredShipments.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text('Trenutno nema tereta.'),
                    ),
                  ),
                )
              else
                ...filteredShipments.map(_shipmentCard),
            ],

            // KORISNICI
            if (selectedSection == 'users') ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Korisnici',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedUserRole = 'carrier';
                        });
                      },
                      child: const Text('Prijevoznici'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedUserRole = 'sender';
                        });
                      },
                      child: const Text('Naručitelji'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),
              if (filteredUsers.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text('Nema korisnika.'),
                    ),
                  ),
                )
              else
                ...filteredUsers.map(_userCard),
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}