import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../services/token_storage.dart';
import 'sender_home_screen.dart';
import 'transporter_home_screen.dart';
import 'odabir_uloge_screen.dart';

class LoginScreen extends StatefulWidget {
  final String? errorMessage;

  const LoginScreen({
    super.key,
    this.errorMessage,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;
  String serverMessage = '';

  @override
  void initState() {
    super.initState();
    serverMessage = widget.errorMessage ?? '';
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String _normalizeRole(dynamic value) {
    final role = (value ?? '').toString().trim().toLowerCase();

    if (role == 'sender') return 'sender';

    if (role == 'carrier' || role == 'transporter') {
      return 'transporter';
    }

    return '';
  }

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    if (!mounted) return;

    setState(() {
      isLoading = true;
      serverMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = (data['token'] ?? '').toString();

        if (token.isNotEmpty) {
          await TokenStorage.saveToken(token);
        }

        final user = data['user'] ?? {};
        final role = _normalizeRole(user['role']);

        await TokenStorage.saveRole(role);

        final fcmToken = await FirebaseMessaging.instance.getToken();

        if (fcmToken != null && fcmToken.isNotEmpty) {
          await http.post(
            Uri.parse('${AppConfig.baseUrl}/fcm-token'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'fcmToken': fcmToken,
            }),
          );
        }

        if (!mounted) return;

        if (role == 'sender') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const SenderHomeScreen(),
            ),
                (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const TransporterHomeScreen(),
            ),
                (route) => false,
          );
        }
      } else if (response.statusCode == 403) {
        await TokenStorage.clearAll();

        if (!mounted) return;

        setState(() {
          serverMessage = (
              data['message'] ??
                  'Račun nije potvrđen. Molimo potvrdite email adresu prije prijave.'
          ).toString();
        });
      } else {
        if (!mounted) return;

        setState(() {
          serverMessage =
              (data['message'] ?? 'Greška pri prijavi.').toString();
        });
      }
    } catch (e) {
      debugPrint('LOGIN ERROR: $e');

      if (!mounted) return;

      setState(() {
        serverMessage = 'Greška konekcije sa serverom.';
      });
    } finally {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> resendVerificationEmail() async {
    final email = emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Prvo unesite ispravnu email adresu.',
          ),
        ),
      );

      return;
    }

    try {
      final response = await http.post(
        Uri.parse(
          '${AppConfig.baseUrl}/resend-verification-email',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            (
                data['message'] ??
                    'Email za potvrdu je ponovno poslan.'
            ).toString(),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Greška prilikom slanja emaila za potvrdu.',
          ),
        ),
      );
    }
  }

  Future<void> showForgotPasswordDialog() async {
    final forgotEmailController = TextEditingController(
      text: emailController.text.trim(),
    );

    bool isSending = false;
    String dialogMessage = '';
    bool requestSuccessful = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: !isSending,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> sendResetRequest() async {
              final email = forgotEmailController.text.trim();

              if (email.isEmpty || !email.contains('@')) {
                setDialogState(() {
                  dialogMessage =
                  'Unesite ispravnu email adresu.';
                  requestSuccessful = false;
                });

                return;
              }

              setDialogState(() {
                isSending = true;
                dialogMessage = '';
                requestSuccessful = false;
              });

              try {
                final response = await http.post(
                  Uri.parse(
                    '${AppConfig.baseUrl}/forgot-password',
                  ),
                  headers: {
                    'Content-Type': 'application/json',
                  },
                  body: jsonEncode({
                    'email': email,
                  }),
                );

                Map<String, dynamic> data = {};

                try {
                  final decoded = jsonDecode(response.body);

                  if (decoded is Map<String, dynamic>) {
                    data = decoded;
                  }
                } catch (_) {
                  data = {};
                }

                if (!dialogContext.mounted) return;

                if (response.statusCode >= 200 &&
                    response.statusCode < 300) {
                  setDialogState(() {
                    isSending = false;
                    requestSuccessful = true;
                    dialogMessage = (
                        data['message'] ??
                            'Ako račun s tim emailom postoji, poslana je poveznica za promjenu lozinke.'
                    ).toString();
                  });
                } else {
                  setDialogState(() {
                    isSending = false;
                    requestSuccessful = false;
                    dialogMessage = (
                        data['message'] ??
                            'Slanje poveznice nije uspjelo.'
                    ).toString();
                  });
                }
              } catch (e) {
                if (!dialogContext.mounted) return;

                setDialogState(() {
                  isSending = false;
                  requestSuccessful = false;
                  dialogMessage =
                  'Greška konekcije sa serverom.';
                });
              }
            }

            return AlertDialog(
              title: const Text(
                'Zaboravljena lozinka',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Unesite email adresu povezanu s vašim računom. Poslat ćemo vam poveznicu za postavljanje nove lozinke.',
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: forgotEmailController,
                      enabled: !isSending,
                      keyboardType:
                      TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      autofocus: true,
                      decoration: buildInputDecoration(
                        'Email',
                      ),
                      onSubmitted: (_) {
                        if (!isSending) {
                          sendResetRequest();
                        }
                      },
                    ),
                    if (dialogMessage.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text(
                        dialogMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: requestSuccessful
                              ? Colors.green.shade700
                              : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSending
                      ? null
                      : () async {
                    FocusScope.of(dialogContext).unfocus();

                    await Future.delayed(
                      const Duration(milliseconds: 150),
                    );

                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: Text(
                    requestSuccessful
                        ? 'Zatvori'
                        : 'Odustani',
                  ),
                ),
                if (!requestSuccessful)
                  ElevatedButton(
                    onPressed:
                    isSending ? null : sendResetRequest,
                    child: isSending
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      'Pošalji poveznicu',
                    ),
                  ),
              ],
            );
          },
        );
      },
    );


  }

  InputDecoration buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showResendVerificationButton =
        serverMessage == 'Račun nije potvrđen.' ||
            serverMessage.contains('Račun nije potvrđen');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 500,
              ),
              child: Column(
                children: [
                  Image.asset(
                    'assets/logo_login3.png',
                    height: 180,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Dobro došli u TeReT',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Platforma za jednostavno povezivanje naručitelja i prijevoznika.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 8),
                            const Text(
                              'Prijava',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: emailController,
                              keyboardType:
                              TextInputType.emailAddress,
                              textInputAction:
                              TextInputAction.next,
                              decoration:
                              buildInputDecoration(
                                'Email',
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty) {
                                  return 'Unesite email';
                                }

                                if (!value.contains('@')) {
                                  return 'Unesite ispravan email';
                                }

                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller:
                              passwordController,
                              obscureText:
                              obscurePassword,
                              textInputAction:
                              TextInputAction.done,
                              decoration:
                              buildInputDecoration(
                                'Lozinka',
                              ).copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscurePassword
                                        ? Icons.visibility
                                        : Icons
                                        .visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      obscurePassword =
                                      !obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty) {
                                  return 'Unesite lozinku';
                                }

                                return null;
                              },
                              onFieldSubmitted: (_) {
                                if (!isLoading) {
                                  login();
                                }
                              },
                            ),
                            Center(
                              child: TextButton(
                                onPressed: isLoading
                                    ? null
                                    : showForgotPasswordDialog,
                                child: const Text(
                                  'Zaboravili ste lozinku?',
                                ),
                              ),
                            ),
                            if (serverMessage.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                serverMessage,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight:
                                  FontWeight.w600,
                                ),
                              ),
                              if (showResendVerificationButton) ...[
                                const SizedBox(height: 8),
                                TextButton.icon(
                                  onPressed:
                                  resendVerificationEmail,
                                  icon: const Icon(
                                    Icons
                                        .mark_email_read_outlined,
                                  ),
                                  label: const Text(
                                    'Pošalji ponovno email za potvrdu',
                                  ),
                                ),
                              ],
                            ],
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed:
                                isLoading ? null : login,
                                style:
                                ElevatedButton.styleFrom(
                                  shape:
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(
                                      12,
                                    ),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child:
                                  CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Colors.white,
                                  ),
                                )
                                    : const Text(
                                  'Prijavi se',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                    FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                    const OdabirUlogeScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Nemaš račun? Registriraj se',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}