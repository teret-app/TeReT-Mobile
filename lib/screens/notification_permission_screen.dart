import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationPermissionScreen extends StatefulWidget {
  final Widget nextScreen;

  const NotificationPermissionScreen({
    super.key,
    required this.nextScreen,
  });

  @override
  State<NotificationPermissionScreen> createState() =>
      _NotificationPermissionScreenState();
}

class _NotificationPermissionScreenState
    extends State<NotificationPermissionScreen>
    with WidgetsBindingObserver {
  bool isChecking = true;
  bool isOpeningSettings = false;
  bool hasContinued = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkNotificationPermission();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Kada se korisnik vrati iz postavki mobitela,
    // ponovno provjeravamo jesu li obavijesti uključene.
    if (state == AppLifecycleState.resumed) {
      _checkNotificationPermission();
    }
  }

  Future<void> _checkNotificationPermission() async {
    if (hasContinued) return;

    if (kIsWeb) {
      _continueToApp();
      return;
    }

    if (mounted) {
      setState(() {
        isChecking = true;
        errorMessage = null;
      });
    }

    final status = await Permission.notification.status;

    if (!mounted || hasContinued) return;

    if (status.isGranted || status.isLimited) {
      _continueToApp();
      return;
    }

    setState(() {
      isChecking = false;
      isOpeningSettings = false;
    });
  }

  Future<void> _enableNotifications() async {
    if (isChecking || isOpeningSettings || hasContinued) return;

    setState(() {
      isChecking = true;
      errorMessage = null;
    });

    final currentStatus = await Permission.notification.status;

    if (!mounted) return;

    if (currentStatus.isGranted || currentStatus.isLimited) {
      _continueToApp();
      return;
    }

    // Ako Android još dopušta prikaz službenog dijaloga,
    // zatražit ćemo dozvolu izravno.
    if (!currentStatus.isPermanentlyDenied &&
        !currentStatus.isRestricted) {
      final requestedStatus = await Permission.notification.request();

      if (!mounted) return;

      if (requestedStatus.isGranted || requestedStatus.isLimited) {
        _continueToApp();
        return;
      }

      if (!requestedStatus.isPermanentlyDenied &&
          !requestedStatus.isRestricted) {
        setState(() {
          isChecking = false;
          errorMessage =
          'Obavijesti još nisu omogućene. Pritisnite gumb ponovno kako biste otvorili postavke.';
        });
        return;
      }
    }

    await _openNotificationSettings();
  }

  Future<void> _openNotificationSettings() async {
    if (!mounted) return;

    setState(() {
      isChecking = false;
      isOpeningSettings = true;
      errorMessage = null;
    });

    final opened = await openAppSettings();

    if (!mounted) return;

    if (!opened) {
      setState(() {
        isOpeningSettings = false;
        errorMessage =
        'Postavke nije bilo moguće otvoriti. Otvorite postavke mobitela i omogućite obavijesti za TeReT.';
      });
    }
  }

  void _continueToApp() {
    if (!mounted || hasContinued) return;

    hasContinued = true;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => widget.nextScreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF030712),
        body: SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.15,
                colors: [
                  Color(0xFF123352),
                  Color(0xFF061226),
                  Color(0xFF02040A),
                ],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 440),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFF1FCBFF)
                          .withValues(alpha: 0.35),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1FCBFF)
                            .withValues(alpha: 0.18),
                        blurRadius: 35,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1FCBFF)
                              .withValues(alpha: 0.14),
                          border: Border.all(
                            color: const Color(0xFF1FCBFF)
                                .withValues(alpha: 0.55),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.notifications_active_outlined,
                          size: 48,
                          color: Color(0xFF8FEAFF),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Omogućite obavijesti',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        '🔔 Kako bi TeReT ispravno funkcionirao, '
                            'obavezno omogućite obavijesti u postavkama '
                            'svog mobitela.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFD8F5FF),
                          fontSize: 16,
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tako ćete na vrijeme primati nove ponude, '
                            'obavijesti o licitacijama i druge važne informacije.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.72),
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                      if (errorMessage != null) ...[
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.13),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.redAccent
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                          child: Text(
                            errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              height: 1.4,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 26),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed:
                          isChecking || isOpeningSettings
                              ? null
                              : _enableNotifications,
                          icon: isChecking
                              ? const SizedBox(
                            width: 21,
                            height: 21,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                              : const Icon(
                            Icons.settings_outlined,
                          ),
                          label: Text(
                            isOpeningSettings
                                ? 'Uključite obavijesti u postavkama'
                                : isChecking
                                ? 'Provjera obavijesti...'
                                : 'Omogući obavijesti',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1595D3),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                            const Color(0xFF1595D3)
                                .withValues(alpha: 0.65),
                            disabledForegroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      if (isOpeningSettings) ...[
                        const SizedBox(height: 14),
                        const Text(
                          'Nakon uključivanja obavijesti vratite se u TeReT. '
                              'Aplikacija će automatski nastaviti.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF8FEAFF),
                            fontSize: 13,
                            height: 1.4,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}