import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../services/token_storage.dart';
import 'login_screen.dart';
import 'shipment_details_screen.dart';
import 'shipment_offers_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> notifications = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

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

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/notifications'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List list = data is List ? data : [];

        list.sort((a, b) {
          final aRead = a['isRead'] == true;
          final bRead = b['isRead'] == true;

          if (aRead != bRead) {
            return aRead ? 1 : -1;
          }

          final aDate = DateTime.tryParse('${a['createdAt']}');
          final bDate = DateTime.tryParse('${b['createdAt']}');

          if (aDate == null || bDate == null) return 0;

          return bDate.compareTo(aDate);
        });

        setState(() {
          notifications = list;
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
        setState(() {
          notifications = [];
          isLoading = false;
          errorMessage = 'Greška pri dohvaćanju obavijesti.';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = 'Greška konekcije sa serverom.';
      });
    }
  }

  Future<void> markAsRead(int id) async {
    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) return;

    try {
      await http.post(
        Uri.parse('${AppConfig.baseUrl}/notifications/$id/read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
    } catch (_) {}
  }

  String _text(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  int? _parseShipmentId(Map<String, dynamic> notification) {
    final directShipmentId = notification['shipmentId'];
    if (directShipmentId is int) return directShipmentId;

    return int.tryParse('$directShipmentId');
  }

  bool _opensOffersScreen(String type) {
    return type == 'offer_created' || type == 'offer_updated';
  }

  bool _opensShipmentDetails(String type) {
    return [
      'new_shipment',
      'offer_accepted',
      'contact_unlocked',
      'delivery_confirmed',
    ].contains(type);
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'new_shipment':
        return Icons.add_box_outlined;
      case 'offer_created':
      case 'offer_updated':
        return Icons.local_offer_outlined;
      case 'offer_outbid':
        return Icons.trending_down;
      case 'offer_accepted':
        return Icons.check_circle_outline;
      case 'offer_rejected':
        return Icons.info_outline;
      case 'contact_unlocked':
        return Icons.lock_open;
      case 'delivery_confirmed':
        return Icons.local_shipping_outlined;
      default:
        return Icons.notifications_none;
    }
  }

  Color _colorForType(String type, bool unread) {
    if (!unread) return Colors.blueGrey;

    switch (type) {
      case 'new_shipment':
        return Colors.green;
      case 'offer_created':
      case 'offer_updated':
        return Colors.deepPurple;
      case 'offer_outbid':
        return Colors.orange;
      case 'offer_accepted':
        return Colors.green;
      case 'offer_rejected':
        return Colors.redAccent;
      case 'contact_unlocked':
        return Colors.blue;
      case 'delivery_confirmed':
        return Colors.teal;
      default:
        return Colors.blueGrey;
    }
  }

  String _titleFromType(Map<String, dynamic> n) {
    switch (n['type']) {
      case 'new_shipment':
        return 'Novi teret';
      case 'offer_created':
        return 'Nova ponuda';
      case 'offer_updated':
        return 'Ažurirana ponuda';
      case 'offer_outbid':
        return 'Ponuda više nije najniža';
      case 'offer_accepted':
        return 'Dobili ste posao';
      case 'offer_rejected':
        return 'Licitacija je završena';
      case 'contact_unlocked':
        return 'Dobili ste posao';
      case 'carrier_contact_unlocked':
        return 'TeReT vas je povezao';
      case 'delivery_confirmed':
        return 'Prijevoz potvrđen';
      default:
        return _text(n['title'], 'Obavijest');
    }
  }

  String _formatDate(dynamic raw) {
    final value = _text(raw);
    if (value.isEmpty) return '';

    try {
      final date = DateTime.parse(value).toLocal();
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 1) return 'Upravo sada';
      if (diff.inMinutes < 60) return 'Prije ${diff.inMinutes} min';
      if (diff.inHours < 24) return 'Prije ${diff.inHours} h';

      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');

      return '$day.$month.$year. $hour:$minute';
    } catch (_) {
      return value;
    }
  }

  Future<void> _handleTap(Map<String, dynamic> n) async {
    final id = n['id'];
    final type = _text(n['type']);
    final shipmentId = _parseShipmentId(n);

    if (id != null) {
      final parsedId = id is int ? id : int.tryParse('$id');
      if (parsedId != null) {
        await markAsRead(parsedId);
      }
    }

    if (!mounted) return;

    if (shipmentId == null) {
      loadNotifications();
      return;
    }

    if (_opensOffersScreen(type)) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ShipmentOffersScreen(shipmentId: shipmentId),
        ),
      );
    } else if (_opensShipmentDetails(type)) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ShipmentDetailsScreen(
            shipmentId: shipmentId,
            isSenderView: false,
          ),
        ),
      );
    }





    if (!mounted) return;
    loadNotifications();
  }

  Widget _card(Map<String, dynamic> n) {
    final unread = n['isRead'] != true;
    final type = _text(n['type']);
    final color = _colorForType(type, unread);
    final message = _text(n['message']);
    final createdAt = _formatDate(n['createdAt']);

    return InkWell(
      onTap: () => _handleTap(n),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: unread ? color.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: unread ? color.withOpacity(0.45) : Colors.grey.shade300,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _iconForType(type),
                    size: 20,
                    color: color,
                  ),
                ),
                if (unread)
                  Positioned(
                    right: 1,
                    top: 1,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _titleFromType(n),
                    style: TextStyle(
                      fontWeight: unread ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  if (message.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      message,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade800,
                        height: 1.3,
                      ),
                    ),
                  ],
                  if (createdAt.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      createdAt,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),

    if (_opensOffersScreen(type) || _opensShipmentDetails(type))
    Icon(
    Icons.chevron_right,
    size: 20,
    color: Colors.grey.shade500,
    ),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return RefreshIndicator(
        onRefresh: loadNotifications,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 120),
            Icon(
              Icons.error_outline,
              size: 54,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 14),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (notifications.isEmpty) {
      return RefreshIndicator(
        onRefresh: loadNotifications,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: const [
            SizedBox(height: 120),
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.blueGrey,
            ),
            SizedBox(height: 14),
            Text(
              'Nema obavijesti',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Nove ponude, prihvati i promjene prikazat će se ovdje.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadNotifications,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: notifications.length,
        itemBuilder: (_, i) {
          final item = notifications[i];

          if (item is Map<String, dynamic>) {
            return _card(item);
          }

          if (item is Map) {
            return _card(Map<String, dynamic>.from(item));
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Obavijesti',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Osvježi',
            onPressed: loadNotifications,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _body(),
    );
  }
}