import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Generira se automatski iz ARB datoteka.
import 'l10n/app_localizations.dart';

import 'services/language_service.dart';

import 'screens/login_screen.dart';
import 'screens/sender_home_screen.dart';
import 'screens/transporter_home_screen.dart';
import 'screens/odabir_uloge_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/shipment_details_screen.dart';
import 'screens/my_offers_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final FlutterLocalNotificationsPlugin localNotifications =
FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel androidChannel = AndroidNotificationChannel(
  'teret_channel',
  'TeReT obavijesti',
  description: 'Obavijesti aplikacije TeReT',
  importance: Importance.high,
);

Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
    ) async {
  await Firebase.initializeApp();

  debugPrint('📩 Background poruka: ${message.messageId}');
}

void _openShipmentFromNotification(Map<String, dynamic> data) {
  final type = data['type']?.toString();

  if (type == 'offer_outbid') {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => const MyOffersScreen(),
      ),
    );
    return;
  }

  final shipmentIdRaw = data['shipmentId'];

  if (shipmentIdRaw == null) {
    return;
  }

  final shipmentId = int.tryParse(shipmentIdRaw.toString());

  if (shipmentId == null) {
    return;
  }

  navigatorKey.currentState?.push(
    MaterialPageRoute(
      builder: (_) => ShipmentDetailsScreen(
        shipmentId: shipmentId,
        isSenderView: false,
      ),
    ),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await LanguageService.loadLanguage();
  debugPrint(
    'JEZIK = ${LanguageService.currentLanguage.value}',
  );

  await localNotifications
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(androidChannel);

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  await localNotifications.initialize(
    const InitializationSettings(
      android: initializationSettingsAndroid,
    ),
    onDidReceiveNotificationResponse: (
        NotificationResponse response,
        ) {
      final payload = response.payload;

      if (payload == null || payload.isEmpty) {
        return;
      }

      try {
        final decodedPayload = jsonDecode(payload);

        if (decodedPayload is Map<String, dynamic>) {
          _openShipmentFromNotification(decodedPayload);
        }
      } catch (error) {
        debugPrint(
          'Greška pri čitanju notification payloada: $error',
        );
      }
    },
  );

  FirebaseMessaging.onBackgroundMessage(
    _firebaseMessagingBackgroundHandler,
  );

  final token = await FirebaseMessaging.instance.getToken();

  debugPrint('🔥 FCM TOKEN: $token');

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notification = message.notification;

    if (notification == null) {
      return;
    }

    localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          androidChannel.id,
          androidChannel.name,
          channelDescription: androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: jsonEncode(message.data),
    );

    debugPrint(
      '📩 Foreground poruka: ${notification.title}',
    );
    debugPrint(
      '📩 Foreground body: ${notification.body}',
    );
    debugPrint('📩 Data: ${message.data}');
  });

  FirebaseMessaging.onMessageOpenedApp.listen(
        (RemoteMessage message) {
      _openShipmentFromNotification(message.data);
    },
  );

  runApp(const MyApp());

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _openShipmentFromNotification(initialMessage.data);
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageService.currentLanguage,
      builder: (context, language, _) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'TeReT',
          debugShowCheckedModeBanner: false,

          locale: Locale(language),

          localizationsDelegates:
          AppLocalizations.localizationsDelegates,

          supportedLocales:
          AppLocalizations.supportedLocales,

          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),

          initialRoute: '/splash',

          routes: {
            '/splash': (context) => const SplashScreen(),

            '/login': (context) => const LoginScreen(),

            '/register': (context) =>
            const OdabirUlogeScreen(),

            '/user_profile': (context) {
              final route = ModalRoute.of(context);

              final arguments = route?.settings.arguments;

              final args =
              arguments is Map<String, dynamic>
                  ? arguments
                  : <String, dynamic>{};

              return UserProfileScreen(
                userId: args['userId'],
                userName:
                args['userName']?.toString() ??
                    'Prijevoznik',
              );
            },

            '/sender_home': (context) =>
            const SenderHomeScreen(),

            '/transporter_home': (context) =>
            const TransporterHomeScreen(),
          },
        );
      },
    );
  }
}