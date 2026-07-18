import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl_phone_field/intl_phone_field.dart';
import '../config.dart';
import 'login_screen.dart';
import 'terms_screen.dart';
import '../utils/country_helper.dart';
class RegisterScreen extends StatefulWidget {
  final String role;

  const RegisterScreen({
    super.key,
    required this.role,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;
  bool acceptedTerms = false;
  String errorMessage = '';
  String verificationUrl = '';
  String selectedCountry = 'Hrvatska';
  String selectedRegion = 'Evropa';
  String get selectedRole => widget.role;

  String get roleTitle {
    if (selectedRole == 'sender') return 'Naručitelj prijevoza';
    return 'Prijevoznik';
  }

  @override
  void dispose() {
    fullNameController.dispose();
    companyNameController.dispose();
    nicknameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    if (!acceptedTerms) {
      setState(() {
        errorMessage = 'Za registraciju morate prihvatiti Uvjete korištenja.';
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = '';
      verificationUrl = '';
    });

    try {
      print('REGISTER URL: ${AppConfig.baseUrl}/register');
      print('PHONE VALUE: ${phoneController.text}');
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fullName': fullNameController.text.trim(),
          'companyName': companyNameController.text.trim(),
          'nickname': nicknameController.text.trim(),
          'phone': phoneController.text.trim(),
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
          'role': selectedRole,
          'country': selectedCountry,
          'region': selectedRegion,
          'acceptedTerms': true,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final verifyLink = (data['verificationUrl'] ?? '').toString();

        if (!mounted) return;
        setState(() {
          verificationUrl = verifyLink;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Registracija uspješna. Potvrdite email adresu prije prijave.',
            ),
          ),
        );
      } else {
        if (!mounted) return;
        setState(() {
          errorMessage = (data['message'] ?? 'Greška pri registraciji.').toString();
        });
      }
    } catch (e) {
      print('REGISTER ERROR: $e');
      if (!mounted) return;
      setState(() {
        errorMessage =
        'Greška konekcije sa serverom. Provjerite je li backend pokrenut i je li IP adresa ispravna.';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  InputDecoration buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
  Widget countryItem(String flag, String country) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          flag,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(width: 10),
        Text(country),
      ],
    );
  }
  Widget buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
          value: acceptedTerms,
          onChanged: isLoading
              ? null
              : (value) {
            setState(() {
              acceptedTerms = value == true;
            });
          },
        ),
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Prihvaćam '),
              GestureDetector(
                onTap: isLoading
                    ? null
                    : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TermsScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Uvjete korištenja',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const Text(' platforme TeReT.'),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registracija'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                children: [


                  Card (
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              'Registracija — $roleTitle',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),

                            TextFormField(
                              controller: fullNameController,
                              textInputAction: TextInputAction.next,
                              decoration: buildInputDecoration('Ime i prezime'),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Unesite ime i prezime';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 14),

                            TextFormField(
                              controller: companyNameController,
                              textInputAction: TextInputAction.next,
                              decoration: buildInputDecoration(
                                'Naziv tvrtke / obrta (nije obavezno)',
                              ),
                            ),

                            const SizedBox(height: 14),

                            if (selectedRole == 'carrier') ...[
                              Card(
                                color: Colors.amber.shade50,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: Colors.amber.shade300,
                                  ),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(14),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: Colors.orange,
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Ako trebate R1 račun, prilikom plaćanja putem Stripe Checkouta unesite točne podatke za račun kako bismo vam mogli izdati i dostaviti R1 račun.',
                                          style: TextStyle(
                                            fontSize: 14,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                            ],

                            TextFormField(
                              controller: nicknameController,
                              textInputAction: TextInputAction.next,
                              decoration: buildInputDecoration(
                                'Grad / sjedište ',
                              ),
                            ),

                            const SizedBox(height: 14),
                            DropdownButtonFormField<String>(
                              value: selectedCountry,
                              decoration: buildInputDecoration('Država'),
                              items: countryOptions.map((country) {
                                return DropdownMenuItem<String>(
                                  value: country.name,
                                  child: countryItem(country.flag, country.name),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value == null) return;

                                setState(() {
                                  selectedCountry = value;

                                  if ([
                                    'Hrvatska',
                                    'Slovenija',
                                    'Austrija',
                                    'Njemačka',
                                    'Italija',
                                    'Mađarska',
                                    'Češka',
                                    'Slovačka',
                                    'Poljska',
                                    'Francuska',
                                    'Belgija',
                                    'Nizozemska',
                                    'Španjolska',
                                    'Portugal',
                                    'Danska',
                                    'Švedska',
                                    'Finska',
                                    'Irska',
                                    'Rumunjska',
                                    'Bugarska',
                                    'Grčka',
                                    'Litva',
                                    'Latvija',
                                    'Estonija',
                                    'Luksemburg',
                                    'Malta',
                                    'Cipar',
                                  ].contains(value)) {
                                    selectedRegion = 'Evropa';
                                  } else if ([
                                    'Srbija',
                                    'Bosna i Hercegovina',
                                    'Crna Gora',
                                    'Sjeverna Makedonija',
                                    'Albanija',
                                    'Kosovo',
                                  ].contains(value)) {
                                    selectedRegion = 'Evropa';
                                  } else if (value == 'Švicarska') {
                                    selectedRegion = 'SWITZERLAND';
                                  } else if (value == 'Ujedinjeno Kraljevstvo') {
                                    selectedRegion = 'UK';
                                  } else if ([
                                    'Norveška',
                                    'Island',
                                    'Lihtenštajn',
                                  ].contains(value)) {
                                    selectedRegion = 'Evropa';
                                  } else if (value == 'SAD') {
                                    selectedRegion = 'USA';
                                  } else if (value == 'Kanada') {
                                    selectedRegion = 'CANADA';
                                  } else if (value == 'Australija') {
                                    selectedRegion = 'AUSTRALIA_NZ';
                                  }
                                });
                              },
                            ),

                            const SizedBox(height: 14),
                            IntlPhoneField(
                              decoration: buildInputDecoration('Broj mobitela'),
                              initialCountryCode: 'HR',
                              disableLengthCheck: true,
                              onChanged: (phone) {
                                phoneController.text = phone.completeNumber;

                                final code = phone.countryCode;

                                if (['381', '387', '382', '389', '383', '355']
                                    .contains(code)) {
                                  selectedRegion = 'Evropa';
                                } else if (code == '44') {
                                  selectedRegion = 'UK';
                                } else if (code == '1') {
                                  selectedRegion = 'USA';
                                } else if (code == '61' || code == '64') {
                                  selectedRegion = 'AUSTRALIA_NZ';
                                } else {
                                  selectedRegion = 'Evropa';
                                }
                              },
                              validator: (phone) {
                                if (phone == null || phone.number.trim().isEmpty) {
                                  return 'Unesite broj mobitela';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 14),

                            TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: buildInputDecoration('Email'),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
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
                              controller: passwordController,
                              obscureText: obscurePassword,
                              textInputAction: TextInputAction.done,
                              decoration: buildInputDecoration('Lozinka').copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      obscurePassword = !obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Unesite lozinku';
                                }
                                if (value.trim().length < 4) {
                                  return 'Lozinka mora imati barem 4 znaka';
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) {
                                if (!isLoading) {
                                  register();
                                }
                              },
                            ),

                            const SizedBox(height: 12),
                            buildTermsCheckbox(),

                            if (errorMessage.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Text(
                                errorMessage,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],

                            if (verificationUrl.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.green),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    const Text(
                                      'Registracija je uspješna.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Za testiranje kopirajte ovaj link i otvorite ga u browseru:',
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    SelectableText(
                                      verificationUrl,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const LoginScreen(
                                              errorMessage:
                                              'Nakon potvrde email adrese možete se prijaviti.',
                                            ),
                                          ),
                                              (route) => false,
                                        );
                                      },
                                      child: const Text('Idi na prijavu'),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 20),

                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : register,
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Colors.white,
                                  ),
                                )
                                    : const Text(
                                  'Registriraj se',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            TextButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                );
                              },
                              child: const Text('Već imaš račun? Prijavi se'),
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