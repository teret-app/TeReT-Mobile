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

class TransporterHomeScreen extends StatefulWidget {
  const TransporterHomeScreen({super.key});

  @override
  State<TransporterHomeScreen> createState() => _TransporterHomeScreenState();
}

class _TransporterHomeScreenState extends State<TransporterHomeScreen> {
  int _selectedIndex = 0;
  int unreadCount = 0;

  Timer? notificationTimer;

  final List<Widget> _screens = const [
    ShipmentListScreen(),
    MyOffersScreen(),
    NotificationsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    loadUnreadNotifications();

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
        body: _screens[_selectedIndex],
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