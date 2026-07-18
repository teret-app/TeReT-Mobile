import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../services/token_storage.dart';
import 'login_screen.dart';
import 'shipment_list_screen.dart';
import 'my_offers_screen.dart';
import 'notifications_screen.dart';
import 'legal_settings_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
class TransporterHomeScreen extends StatefulWidget {
  const TransporterHomeScreen({super.key});

  @override
  State<TransporterHomeScreen> createState() => _TransporterHomeScreenState();
}

class _TransporterHomeScreenState extends State<TransporterHomeScreen> {
  int _selectedIndex = 0;
  int unreadCount = 0;

  Timer? notificationTimer;
  bool notificationsEnabled = true;
  final List<Widget> _screens = const [
    ShipmentListScreen(),
    MyOffersScreen(),
    NotificationsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    loadUnreadNotifications();
    checkNotificationPermission();
    notificationTimer = Timer.periodic(
      const Duration(seconds: 10),
          (_) => loadUnreadNotifications(),
    );
  }

  @override
  void dispose() {
    notificationTimer?.cancel();
    super.dispose();
  }

  Future<bool> _confirmExit() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Izlaz iz aplikacije'),
          content: const Text('Jeste li sigurni da želite izaći iz aplikacije?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Odustani'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Izađi'),
            ),
          ],
        );
      },
    );

    return shouldExit == true;
  }
  Future<void> checkNotificationPermission() async {
    if (kIsWeb) return;

    final status = await Permission.notification.status;

    if (!mounted) return;

    setState(() {
      notificationsEnabled = status.isGranted;
    });
  }
  Future<void> loadUnreadNotifications() async {
    try {
      final token = await TokenStorage.getToken();

      if (token == null || token.isEmpty) return;

      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/notifications'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          final unread = data.where((n) => n['isRead'] == false).length;

          if (!mounted) return;
          setState(() {
            unreadCount = unread;
          });
        }
      }
    } catch (_) {}
  }

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    await loadUnreadNotifications();
  }

  Future<void> logout() async {
    notificationTimer?.cancel();

    await TokenStorage.clearAll();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
          (route) => false,
    );
  }

  Widget buildBadgeIcon(IconData icon, int count) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (count > 0)
          Positioned(
            right: -6,
            top: -3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
  Widget buildNotificationsWarning() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.orange,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.notifications_off,
                color: Colors.deepOrange,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Obavijesti su isključene',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Uključite obavijesti kako biste na vrijeme primali nove terete, informacije o ponudi i ostale važne obavijesti o licitacijama.',
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () async {
              await openAppSettings();

              await Future.delayed(
                const Duration(seconds: 1),
              );

              await checkNotificationPermission();
            },
            icon: const Icon(Icons.settings),
            label: const Text('Uključi obavijesti'),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        final shouldExit = await _confirmExit();

        if (shouldExit && mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Prijevoznik'),
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LegalSettingsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.menu),
              label: const Text(
                'Info',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Odjava',
              onPressed: logout,
            ),
          ],
        ),
        body: Column(
          children: [
            if (!notificationsEnabled)
              buildNotificationsWarning(),
            Expanded(
              child: _screens[_selectedIndex],
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping),
              label: 'Lista tereta',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.euro),
              label: 'Moje ponude',
            ),
            BottomNavigationBarItem(
              icon: buildBadgeIcon(Icons.notifications_none, unreadCount),
              label: 'Obavijesti',
            ),
          ],
        ),
      ),
    );
  }
}