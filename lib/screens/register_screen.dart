import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../l10n/app_localizations.dart';
import 'login_screen.dart';
import 'terms_screen.dart';
import '../utils/country_helper.dart';

class PhoneCountryOption {
  final String name;
  final String flag;
  final String dialCode;
  final String region;

  const PhoneCountryOption({
    required this.name,
    required this.flag,
    required this.dialCode,
    this.region = 'Evropa',
  });
}

const List<PhoneCountryOption> phoneCountryOptions = [
  PhoneCountryOption(name: 'Hrvatska', flag: '🇭🇷', dialCode: '+385'),
  PhoneCountryOption(name: 'Slovenija', flag: '🇸🇮', dialCode: '+386'),
  PhoneCountryOption(name: 'Bosna i Hercegovina', flag: '🇧🇦', dialCode: '+387'),
  PhoneCountryOption(name: 'Srbija', flag: '🇷🇸', dialCode: '+381'),
  PhoneCountryOption(name: 'Crna Gora', flag: '🇲🇪', dialCode: '+382'),
  PhoneCountryOption(name: 'Sjeverna Makedonija', flag: '🇲🇰', dialCode: '+389'),
  PhoneCountryOption(name: 'Albanija', flag: '🇦🇱', dialCode: '+355'),
  PhoneCountryOption(name: 'Kosovo', flag: '🇽🇰', dialCode: '+383'),
  PhoneCountryOption(name: 'Austrija', flag: '🇦🇹', dialCode: '+43'),
  PhoneCountryOption(name: 'Njemačka', flag: '🇩🇪', dialCode: '+49'),
  PhoneCountryOption(name: 'Italija', flag: '🇮🇹', dialCode: '+39'),
  PhoneCountryOption(name: 'Mađarska', flag: '🇭🇺', dialCode: '+36'),
  PhoneCountryOption(name: 'Češka', flag: '🇨🇿', dialCode: '+420'),
  PhoneCountryOption(name: 'Slovačka', flag: '🇸🇰', dialCode: '+421'),
  PhoneCountryOption(name: 'Poljska', flag: '🇵🇱', dialCode: '+48'),
  PhoneCountryOption(name: 'Francuska', flag: '🇫🇷', dialCode: '+33'),
  PhoneCountryOption(name: 'Belgija', flag: '🇧🇪', dialCode: '+32'),
  PhoneCountryOption(name: 'Nizozemska', flag: '🇳🇱', dialCode: '+31'),
  PhoneCountryOption(name: 'Luksemburg', flag: '🇱🇺', dialCode: '+352'),
  PhoneCountryOption(name: 'Švicarska', flag: '🇨🇭', dialCode: '+41', region: 'SWITZERLAND'),
  PhoneCountryOption(name: 'Lihtenštajn', flag: '🇱🇮', dialCode: '+423'),
  PhoneCountryOption(name: 'Španjolska', flag: '🇪🇸', dialCode: '+34'),
  PhoneCountryOption(name: 'Portugal', flag: '🇵🇹', dialCode: '+351'),
  PhoneCountryOption(name: 'Ujedinjeno Kraljevstvo', flag: '🇬🇧', dialCode: '+44', region: 'UK'),
  PhoneCountryOption(name: 'Irska', flag: '🇮🇪', dialCode: '+353'),
  PhoneCountryOption(name: 'Danska', flag: '🇩🇰', dialCode: '+45'),
  PhoneCountryOption(name: 'Švedska', flag: '🇸🇪', dialCode: '+46'),
  PhoneCountryOption(name: 'Norveška', flag: '🇳🇴', dialCode: '+47'),
  PhoneCountryOption(name: 'Finska', flag: '🇫🇮', dialCode: '+358'),
  PhoneCountryOption(name: 'Island', flag: '🇮🇸', dialCode: '+354'),
  PhoneCountryOption(name: 'Estonija', flag: '🇪🇪', dialCode: '+372'),
  PhoneCountryOption(name: 'Latvija', flag: '🇱🇻', dialCode: '+371'),
  PhoneCountryOption(name: 'Litva', flag: '🇱🇹', dialCode: '+370'),
  PhoneCountryOption(name: 'Rumunjska', flag: '🇷🇴', dialCode: '+40'),
  PhoneCountryOption(name: 'Bugarska', flag: '🇧🇬', dialCode: '+359'),
  PhoneCountryOption(name: 'Grčka', flag: '🇬🇷', dialCode: '+30'),
  PhoneCountryOption(name: 'Cipar', flag: '🇨🇾', dialCode: '+357'),
  PhoneCountryOption(name: 'Malta', flag: '🇲🇹', dialCode: '+356'),
  PhoneCountryOption(name: 'Moldavija', flag: '🇲🇩', dialCode: '+373'),
  PhoneCountryOption(name: 'Ukrajina', flag: '🇺🇦', dialCode: '+380'),
  PhoneCountryOption(name: 'Turska', flag: '🇹🇷', dialCode: '+90'),
  PhoneCountryOption(name: 'Sjedinjene Američke Države', flag: '🇺🇸', dialCode: '+1', region: 'USA'),
  PhoneCountryOption(name: 'Kanada', flag: '🇨🇦', dialCode: '+1', region: 'CANADA'),
  PhoneCountryOption(name: 'Australija', flag: '🇦🇺', dialCode: '+61', region: 'AUSTRALIA_NZ'),
  PhoneCountryOption(name: 'Novi Zeland', flag: '🇳🇿', dialCode: '+64', region: 'AUSTRALIA_NZ'),
];

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
  late String selectedCountry;
  String selectedRegion = 'Evropa';
  late PhoneCountryOption selectedPhoneCountry;
  @override
  void initState() {
    super.initState();

    final countries = countryOptionsForDevice();
    final deviceCountry = countries.first;

    selectedCountry = deviceCountry.name;
    selectedRegion = deviceCountry.region;

    selectedPhoneCountry = phoneCountryOptions.firstWhere(
          (country) => country.flag == deviceCountry.flag,
      orElse: () => phoneCountryOptions.first,
    );
  }
  String get completePhoneNumber {
    var localNumber = phoneController.text.trim().replaceAll(RegExp(r'\s+'), '');

    while (localNumber.startsWith('0')) {
      localNumber = localNumber.substring(1);
    }

    return '${selectedPhoneCountry.dialCode}$localNumber';
  }
  String get selectedRole => widget.role;

  String roleTitle(AppLocalizations t) {
    if (selectedRole == 'sender') {
      return t.transportCustomer;
    }

    return t.carrier;
  }


  void capitalizeWords(
      String value,
      TextEditingController controller,
      ) {
    if (value.isEmpty) return;

    final newText = value.replaceAllMapped(
      RegExp(r'(^|\s)(\S)'),
          (match) => '${match.group(1)}${match.group(2)!.toUpperCase()}',
    );

    if (newText != value) {
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: newText.length,
        ),
      );
    }
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
    final AppLocalizations t = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;

    if (!acceptedTerms) {
      setState(() {
        errorMessage = t.termsAcceptanceRequired;
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
      print('PHONE VALUE: $completePhoneNumber');
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fullName': fullNameController.text.trim(),
          'companyName': companyNameController.text.trim(),
          'nickname': nicknameController.text.trim(),
          'phone': completePhoneNumber,
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
          SnackBar(
            content: Text(t.registrationSuccessfulVerifyEmail),
          ),
        );
      } else {
        if (!mounted) return;
        setState(() {
          final String backendMessage =
          (data['message'] ?? '').toString().trim();

          errorMessage = backendMessage.isNotEmpty
              ? backendMessage
              : t.registrationError;
        });
      }
    } catch (e) {
      print('REGISTER ERROR: $e');
      if (!mounted) return;
      setState(() {
        errorMessage = t.registrationConnectionError;
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
  List<PhoneCountryOption> phoneCountryOptionsForDevice() {
    final deviceCountry = countryFromIsoCode(deviceCountryCode());

    if (deviceCountry == null) {
      return List<PhoneCountryOption>.from(phoneCountryOptions);
    }

    final result = List<PhoneCountryOption>.from(phoneCountryOptions);

    final deviceCountryIndex = result.indexWhere(
          (country) => country.flag == deviceCountry.flag,
    );

    if (deviceCountryIndex == -1) {
      return result;
    }

    final firstCountry = result.removeAt(deviceCountryIndex);
    result.insert(0, firstCountry);

    return result;
  }
  Future<void> selectPhoneCountry() async {
    final AppLocalizations t = AppLocalizations.of(context)!;

    final result = await showDialog<PhoneCountryOption>(
      context: context,
      builder: (dialogContext) {
        String searchText = '';

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filteredCountries =
            phoneCountryOptionsForDevice().where((country) {
              final query = searchText.trim().toLowerCase();

              return query.isEmpty ||
                  country.name.toLowerCase().contains(query) ||
                  country.dialCode.contains(query);
            }).toList();

            return AlertDialog(
              titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              title: Text(t.selectCountry),
              content: SizedBox(
                width: double.maxFinite,
                height: 500,
                child: Column(
                  children: [
                    TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: t.searchCountryOrDialCode,
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          searchText = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: filteredCountries.isEmpty
                          ? Center(
                        child: Text(t.noCountriesFound),
                      )
                          : ListView.separated(
                        itemCount: filteredCountries.length,
                        separatorBuilder: (_, __) =>
                        const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final country = filteredCountries[index];

                          return ListTile(
                            leading: Text(
                              country.flag,
                              style: const TextStyle(fontSize: 24),
                            ),
                            title: Text(country.name),
                            trailing: Text(
                              country.dialCode,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(dialogContext, country);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result == null || !mounted) return;

    setState(() {
      selectedPhoneCountry = result;
      selectedRegion = result.region;
    });
  }

  Widget buildTermsCheckbox() {
    final AppLocalizations t = AppLocalizations.of(context)!;

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
              Text(t.iAccept),
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
                child: Text(
                  t.termsOfUse,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Text(t.teretPlatformSuffix),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.register),
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
                              '${t.register} — ${roleTitle(t)}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),

                            TextFormField(
                              controller: fullNameController,
                              onChanged: (value) =>
                                  capitalizeWords(value, fullNameController),
                              textInputAction: TextInputAction.next,
                              decoration: buildInputDecoration(t.fullName),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return t.enterFullName;
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 14),

                            TextFormField(
                              controller: companyNameController,
                              onChanged: (value) =>
                                  capitalizeWords(value, companyNameController),
                              textInputAction: TextInputAction.next,
                              decoration: buildInputDecoration(
                                t.companyNameOptional,
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
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.info_outline,
                                        color: Colors.orange,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          t.r1InvoiceNotice,
                                          style: const TextStyle(
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
                              onChanged: (value) =>
                                  capitalizeWords(value, nicknameController),
                              textInputAction: TextInputAction.next,
                              decoration: buildInputDecoration(
                                t.cityOrHeadquarters,
                              ),
                            ),

                            const SizedBox(height: 14),
                            DropdownButtonFormField<String>(
                              value: selectedCountry,
                              decoration: buildInputDecoration(t.country),
                              items: countryOptionsForDevice().map((country) {
                                return DropdownMenuItem<String>(
                                  value: country.name,
                                  child: countryItem(
                                    country.flag,
                                    country.localizedName(
                                      Localizations.localeOf(context).languageCode,
                                    ),
                                  ),
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
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: isLoading ? null : selectPhoneCountry,
                                  child: Container(
                                    height: 56,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade600,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          selectedPhoneCountry.flag,
                                          style: const TextStyle(fontSize: 22),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          selectedPhoneCountry.dialCode,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.arrow_drop_down,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextFormField(
                                    controller: phoneController,
                                    keyboardType: TextInputType.phone,
                                    textInputAction: TextInputAction.next,
                                    decoration: buildInputDecoration(
                                      t.mobilePhoneNumber,
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return t.enterPhoneNumber;
                                      }

                                      final digits = value.replaceAll(
                                        RegExp(r'\D'),
                                        '',
                                      );

                                      if (digits.length < 6) {
                                        return t.enterValidPhoneNumber;
                                      }

                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: buildInputDecoration(t.email),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return t.enterEmail;
                                }
                                if (!value.contains('@')) {
                                  return t.enterValidEmail;
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 14),

                            TextFormField(
                              controller: passwordController,
                              obscureText: obscurePassword,
                              textInputAction: TextInputAction.done,
                              decoration: buildInputDecoration(t.password).copyWith(
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
                                      obscurePassword = !obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return t.enterPassword;
                                }
                                if (value.trim().length < 4) {
                                  return t.passwordMinimumFourCharacters;
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
                                    Text(
                                      t.registrationSuccessful,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      t.copyVerificationLinkForTesting,
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
                                            builder: (_) => LoginScreen(
                                              errorMessage:
                                              t.afterEmailVerificationLogin,
                                            ),
                                          ),
                                              (route) => false,
                                        );
                                      },
                                      child: Text(t.goToLogin),
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
                                    : Text(
                                  t.registerButton,
                                  style: const TextStyle(
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
                              child: Text(t.alreadyHaveAccountLogin),
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