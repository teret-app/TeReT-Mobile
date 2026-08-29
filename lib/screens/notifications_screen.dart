import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../l10n/app_localizations.dart';
import '../services/token_storage.dart';
import 'login_screen.dart';
import 'shipment_details_screen.dart';
import 'my_offers_screen.dart';
import 'shipment_offers_screen.dart';
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> notifications = [];
  bool isLoading = true;
  String errorCode = '';

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<String?> _getTokenOrLogout() async {
    final token = await TokenStorage.getToken();

    if (token == null || token.isEmpty) {
      if (!mounted) return null;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );

      return null;
    }

    return token;
  }

  Future<void> loadNotifications() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorCode = '';
    });

    final token = await _getTokenOrLogout();
    if (token == null) return;

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
        final List list = data is List ? data : [];

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
        return;
      }

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

      setState(() {
        notifications = [];
        isLoading = false;
        errorCode = 'fetch';
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorCode = 'connection';
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

  Future<bool> deleteNotification(int id) async {
    final token = await _getTokenOrLogout();
    if (token == null) return false;

    try {
      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/notifications/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<void> deleteReadNotifications() async {
    final l10n = AppLocalizations.of(context)!;

    final confirm = await _confirmDialog(
      title: l10n.deleteReadNotificationsTitle,
      message: l10n.deleteReadNotificationsMessage,
    );

    if (confirm != true) return;

    final token = await _getTokenOrLogout();
    if (token == null) return;

    try {
      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/notifications/read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        await loadNotifications();
        _showSnack(l10n.readNotificationsDeleted);
      } else {
        _showSnack(l10n.deletionFailed);
      }
    } catch (_) {
      if (!mounted) return;
      _showSnack(l10n.serverConnectionError);
    }
  }

  Future<void> deleteAllNotifications() async {
    final l10n = AppLocalizations.of(context)!;

    final confirm = await _confirmDialog(
      title: l10n.deleteAllNotificationsTitle,
      message: l10n.deleteAllNotificationsMessage,
    );

    if (confirm != true) return;

    final token = await _getTokenOrLogout();
    if (token == null) return;

    try {
      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/notifications'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        await loadNotifications();
        _showSnack(l10n.allNotificationsDeleted);
      } else {
        _showSnack(l10n.deletionFailed);
      }
    } catch (_) {
      if (!mounted) return;
      _showSnack(l10n.serverConnectionError);
    }
  }

  Future<bool?> _confirmDialog({
    required String title,
    required String message,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
  }

  void _showSnack(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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

  bool _opensMyOffersScreen(String type) {
    return type == 'offer_outbid';
  }

  bool _opensShipmentOffersScreen(String type) {
    return type == 'offer_created' ||
        type == 'offer_updated' ||
        type == 'auction_ended';
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
      case 'auction_ended':
        return Icons.gavel_outlined;
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
      case 'auction_ended':
        return Colors.deepOrange;
      default:
        return Colors.blueGrey;
    }
  }

  String _titleFromType(AppLocalizations l10n, Map<String, dynamic> n) {
    switch (n['type']) {
      case 'new_shipment':
        return l10n.notificationNewShipment;
      case 'offer_created':
        return l10n.notificationNewOffer;
      case 'offer_updated':
        return l10n.notificationUpdatedOffer;
      case 'offer_outbid':
        return l10n.notificationOfferOutbid;
      case 'offer_accepted':
        return l10n.notificationJobWon;
      case 'offer_rejected':
        return l10n.notificationAuctionFinished;
      case 'contact_unlocked':
        return l10n.notificationJobWonCelebration;
      case 'carrier_contact_unlocked':
        return l10n.notificationConnected;
      case 'delivery_confirmed':
        return l10n.notificationDeliveryConfirmed;
      case 'auction_ended':
        return l10n.notificationAuctionFinished;
      default:
        return _text(n['title'], l10n.notification);
    }
  }

  String _localizedMessage(
      AppLocalizations l10n,
      Map<String, dynamic> notification,
      ) {
    final type = _text(notification['type']);
    final originalMessage = _text(notification['message']);

    switch (type) {
      case 'new_shipment':
        var route = '';

        final colonIndex = originalMessage.indexOf(':');
        if (colonIndex >= 0 && colonIndex < originalMessage.length - 1) {
          route = originalMessage.substring(colonIndex + 1).trim();
        }

        return route.isNotEmpty
            ? l10n.notificationNewShipmentMessage(route)
            : l10n.notificationNewShipmentMessageWithoutRoute;

      case 'offer_created':
        return l10n.notificationNewOfferMessage;

      case 'offer_updated':
        return l10n.notificationUpdatedOfferMessage;

      case 'offer_outbid':
        return l10n.notificationOfferOutbidMessage;

      case 'offer_accepted':
        return l10n.notificationOfferAcceptedMessage;

      case 'offer_rejected':
        return l10n.notificationOfferRejectedMessage;

      case 'contact_unlocked':
        return l10n.notificationContactUnlockedMessage;

      case 'carrier_contact_unlocked':
        return l10n.notificationCarrierConnectedMessage;

      case 'delivery_confirmed':
        return l10n.notificationDeliveryConfirmedMessage;

      default:
        return originalMessage;
    }
  }

  String _formatDate(AppLocalizations l10n, dynamic raw) {
    final value = _text(raw);
    if (value.isEmpty) return '';

    try {
      final date = DateTime.parse(value).toLocal();
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 1) return l10n.justNow;
      if (diff.inMinutes < 60) return l10n.minutesAgo(diff.inMinutes);
      if (diff.inHours < 24) return l10n.hoursAgo(diff.inHours);

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

    if (_opensMyOffersScreen(type)) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const MyOffersScreen(),
        ),
      );
    } else if (_opensShipmentOffersScreen(type)) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ShipmentOffersScreen(
            shipmentId: shipmentId,
          ),
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

  Widget _card(AppLocalizations l10n, Map<String, dynamic> n) {
    final unread = n['isRead'] != true;
    final type = _text(n['type']);
    final color = _colorForType(type, unread);
    final message = _localizedMessage(l10n, n);
    final createdAt = _formatDate(l10n, n['createdAt']);

    return InkWell(
      onTap: () => _handleTap(n),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: unread ? color.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: unread ? color.withValues(alpha: 0.45) : Colors.grey.shade300,
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
                    color: color.withValues(alpha: 0.12),
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
                    _titleFromType(l10n, n),
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
            if (_opensMyOffersScreen(type) ||
                _opensShipmentOffersScreen(type) ||
                _opensShipmentDetails(type))
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

  Widget _dismissibleCard(AppLocalizations l10n, Map<String, dynamic> n) {
    final idRaw = n['id'];
    final id = idRaw is int ? idRaw : int.tryParse('$idRaw');

    if (id == null) {
      return _card(l10n, n);
    }

    return Dismissible(
      key: ValueKey('notification_$id'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (_) async {
        final success = await deleteNotification(id);

        if (!success) {
          _showSnack(l10n.notificationDeletionFailed);
          return false;
        }

        return true;
      },
      onDismissed: (_) {
        setState(() {
          notifications.removeWhere((item) {
            if (item is Map) {
              return '${item['id']}' == '$id';
            }
            return false;
          });
        });

        _showSnack(l10n.notificationDeleted);
      },
      child: _card(l10n, n),
    );
  }

  Widget _body(AppLocalizations l10n) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorCode.isNotEmpty) {
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
              errorCode == 'fetch'
                  ? l10n.notificationsFetchError
                  : l10n.serverConnectionError,
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
          children: [
            const SizedBox(height: 120),
            const Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.blueGrey,
            ),
            const SizedBox(height: 14),
            Text(
              l10n.noNotifications,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.notificationsEmptyDescription,
              textAlign: TextAlign.center,
              style: const TextStyle(
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
            return _dismissibleCard(l10n, item);
          }

          if (item is Map) {
            return _dismissibleCard(l10n, Map<String, dynamic>.from(item));
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _openNotificationMenu(AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.mark_email_read_outlined),
              title: Text(l10n.deleteReadNotifications),
              onTap: () {
                Navigator.pop(context);
                deleteReadNotifications();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_sweep_outlined),
              title: Text(l10n.deleteAllNotifications),
              onTap: () {
                Navigator.pop(context);
                deleteAllNotifications();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasNotifications = notifications.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text(
          l10n.notificationsTitle,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: l10n.refresh,
            onPressed: loadNotifications,
            icon: const Icon(Icons.refresh),
          ),
          if (hasNotifications)
            IconButton(
              tooltip: l10n.manageNotifications,
              onPressed: () => _openNotificationMenu(l10n),
              icon: const Icon(Icons.more_vert),
            ),
        ],
      ),
      body: _body(l10n),
    );
  }
}