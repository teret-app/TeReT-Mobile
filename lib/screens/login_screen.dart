import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../l10n/app_localizations.dart';
import '../services/language_service.dart';
import '../services/token_storage.dart';
import 'odabir_uloge_screen.dart';
import 'sender_home_screen.dart';
import 'transporter_home_screen.dart';

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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  String serverMessage = '';
  bool showResendVerificationButton = false;

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
    final String role = (value ?? '').toString().trim().toLowerCase();

    if (role == 'sender') {
      return 'sender';
    }

    if (role == 'carrier' || role == 'transporter') {
      return 'transporter';
    }

    return '';
  }

  Future<void> login() async {
    final AppLocalizations t = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    if (!mounted) {
      return;
    }

    setState(() {
      isLoading = true;
      serverMessage = '';
      showResendVerificationButton = false;
    });

    try {
      final http.Response response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept-Language':
          LanguageService.currentLanguage.value,
        },
        body: jsonEncode({
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
        }),
      );

      Map<String, dynamic> data = {};

      try {
        final dynamic decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          data = decoded;
        }
      } catch (_) {
        data = {};
      }

      if (response.statusCode == 200) {
        final String token = (data['token'] ?? '').toString();

        if (token.isEmpty) {
          if (!mounted) {
            return;
          }

          setState(() {
            serverMessage = t.loginError;
          });

          return;
        }

        await TokenStorage.saveToken(token);

        final dynamic user = data['user'] ?? {};
        final String role = _normalizeRole(
          user is Map ? user['role'] : null,
        );

        if (role.isEmpty) {
          await TokenStorage.clearAll();

          if (!mounted) {
            return;
          }

          setState(() {
            serverMessage = t.invalidUserRole;
          });

          return;
        }

        await TokenStorage.saveRole(role);

        try {
          final String? fcmToken =
          await FirebaseMessaging.instance.getToken();

          if (fcmToken != null && fcmToken.isNotEmpty) {
            await http.post(
              Uri.parse('${AppConfig.baseUrl}/fcm-token'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: jsonEncode({
                'fcmToken': fcmToken,
                'language': LanguageService.currentLanguage.value,
              }),
            );
          }
        } catch (e) {
          debugPrint('FCM TOKEN ERROR: $e');
        }

        if (!mounted) {
          return;
        }

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

        if (!mounted) {
          return;
        }

        setState(() {
          serverMessage = t.accountNotVerified;
          showResendVerificationButton = true;
        });
      } else if (response.statusCode == 400) {
        if (!mounted) {
          return;
        }

        setState(() {
          serverMessage = t.emailAndPasswordRequired;
        });
      } else if (response.statusCode == 401) {
        if (!mounted) {
          return;
        }

        setState(() {
          serverMessage = t.invalidEmailOrPassword;
        });
      } else if (response.statusCode >= 500) {
        if (!mounted) {
          return;
        }

        setState(() {
          serverMessage = t.serverError;
        });
      } else {
        if (!mounted) {
          return;
        }

        setState(() {
          serverMessage = t.loginError;
        });
      }
    } catch (e) {
      debugPrint('LOGIN ERROR: $e');

      if (!mounted) {
        return;
      }

      setState(() {
        serverMessage = t.serverConnectionError;
      });
    } finally {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> resendVerificationEmail() async {
    final AppLocalizations t = AppLocalizations.of(context)!;
    final String email = emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.enterValidEmailFirst),
        ),
      );

      return;
    }

    try {
      final http.Response response = await http.post(
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

      if (!mounted) {
        return;
      }

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.verificationEmailResent),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.verificationEmailSendError),
          ),
        );
      }
    } catch (e) {
      debugPrint('RESEND VERIFICATION ERROR: $e');

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.verificationEmailSendError),
        ),
      );
    }
  }

  Future<void> showForgotPasswordDialog() async {
    final AppLocalizations t = AppLocalizations.of(context)!;

    final TextEditingController forgotEmailController =
    TextEditingController(
      text: emailController.text.trim(),
    );

    bool isSending = false;
    String dialogMessage = '';
    bool requestSuccessful = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (
              BuildContext dialogBuilderContext,
              void Function(void Function()) setDialogState,
              ) {
            Future<void> sendResetRequest() async {
              final String email =
              forgotEmailController.text.trim();

              if (email.isEmpty || !email.contains('@')) {
                setDialogState(() {
                  dialogMessage = t.enterValidEmail;
                  requestSuccessful = false;
                });
                return;
              }

              FocusManager.instance.primaryFocus?.unfocus();

              setDialogState(() {
                isSending = true;
                dialogMessage = '';
                requestSuccessful = false;
              });

              try {
                final http.Response response = await http.post(
                  Uri.parse(
                    '${AppConfig.baseUrl}/forgot-password',
                  ),
                  headers: {
                    'Content-Type': 'application/json',
                    'Accept-Language':
                    LanguageService.currentLanguage.value,
                  },
                  body: jsonEncode({
                    'email': email,
                  }),
                );

                if (!dialogBuilderContext.mounted) {
                  return;
                }

                if (response.statusCode >= 200 &&
                    response.statusCode < 300) {
                  setDialogState(() {
                    isSending = false;
                    requestSuccessful = true;
                    dialogMessage = t.passwordResetLinkSent;
                  });
                } else {
                  setDialogState(() {
                    isSending = false;
                    requestSuccessful = false;
                    dialogMessage =
                        t.passwordResetLinkSendError;
                  });
                }
              } catch (e) {
                debugPrint('FORGOT PASSWORD ERROR: $e');

                if (!dialogBuilderContext.mounted) {
                  return;
                }

                setDialogState(() {
                  isSending = false;
                  requestSuccessful = false;
                  dialogMessage = t.serverConnectionError;
                });
              }
            }

            return PopScope(
              canPop: !isSending,
              child: AlertDialog(
                title: Text(t.forgotPasswordTitle),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                    children: [
                      Text(t.forgotPasswordDescription),
                      const SizedBox(height: 16),
                      TextField(
                        controller: forgotEmailController,
                        enabled: !isSending,
                        keyboardType:
                        TextInputType.emailAddress,
                        textInputAction:
                        TextInputAction.done,
                        autofocus: true,
                        decoration:
                        buildInputDecoration(t.email),
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
                        : () {
                      FocusManager
                          .instance.primaryFocus
                          ?.unfocus();
                      Navigator.of(
                        dialogBuilderContext,
                      ).pop();
                    },
                    child: Text(
                      requestSuccessful
                          ? t.close
                          : t.cancel,
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
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                          : Text(t.sendResetLink),
                    ),
                ],
              ),
            );
          },
        );
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      forgotEmailController.dispose();
    });
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
    final AppLocalizations t = AppLocalizations.of(context)!;

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
                  Align(
                    alignment: Alignment.centerRight,
                    child: DropdownButton<String>(
                      value: LanguageService.language,
                      underline: const SizedBox.shrink(),
                      items: const [
                        DropdownMenuItem(
                          value: 'hr',
                          child: Text('🇭🇷 Hrvatski'),
                        ),
                        DropdownMenuItem(
                          value: 'en',
                          child: Text('🇬🇧 English'),
                        ),
                      ],
                      onChanged: isLoading
                          ? null
                          : (String? value) async {
                        if (value == null) {
                          return;
                        }

                        await LanguageService.setLanguage(
                          value,
                        );
                      },
                    ),
                  ),
                  Image.asset(
                    'assets/logo_login3.png',
                    height: 180,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    t.welcomeToTeret,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    t.loginPlatformDescription,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
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
                            Text(
                              t.login,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: emailController,
                              enabled: !isLoading,
                              keyboardType:
                              TextInputType.emailAddress,
                              textInputAction:
                              TextInputAction.next,
                              autofillHints: const [
                                AutofillHints.email,
                              ],
                              decoration: buildInputDecoration(
                                t.email,
                              ),
                              validator: (String? value) {
                                if (value == null ||
                                    value.trim().isEmpty) {
                                  return t.enterEmail;
                                }

                                if (!value.trim().contains('@')) {
                                  return t.enterValidEmail;
                                }

                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: passwordController,
                              enabled: !isLoading,
                              obscureText: obscurePassword,
                              textInputAction:
                              TextInputAction.done,
                              autofillHints: const [
                                AutofillHints.password,
                              ],
                              decoration: buildInputDecoration(
                                t.password,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  tooltip: obscurePassword
                                      ? t.showPassword
                                      : t.hidePassword,
                                  icon: Icon(
                                    obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      obscurePassword =
                                      !obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (String? value) {
                                if (value == null ||
                                    value.trim().isEmpty) {
                                  return t.enterPassword;
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
                                child: Text(
                                  t.forgotPasswordQuestion,
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
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (showResendVerificationButton) ...[
                                const SizedBox(height: 8),
                                TextButton.icon(
                                  onPressed: isLoading
                                      ? null
                                      : resendVerificationEmail,
                                  icon: const Icon(
                                    Icons.mark_email_read_outlined,
                                  ),
                                  label: Text(
                                    t.resendVerificationEmail,
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
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(12),
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
                                    : Text(
                                  t.signIn,
                                  style: const TextStyle(
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
                              child: Text(
                                t.noAccountRegister,
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