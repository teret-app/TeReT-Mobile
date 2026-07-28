import 'dart:ui';

class CountryOption {
  final String name;
  final String englishName;
  final String flag;
  final String region;
  final String isoCode;

  const CountryOption({
    required this.name,
    required this.englishName,
    required this.flag,
    required this.region,
    required this.isoCode,
  });

  String localizedName(String languageCode) {
    return languageCode == 'en' ? englishName : name;
  }
}

const List<CountryOption> countryOptions = [
  CountryOption(
    name: 'Hrvatska',
    englishName: 'Croatia',
    flag: '🇭🇷',
    region: 'Evropa',
    isoCode: 'HR',
  ),
  CountryOption(
    name: 'Slovenija',
    englishName: 'Slovenia',
    flag: '🇸🇮',
    region: 'Evropa',
    isoCode: 'SI',
  ),
  CountryOption(
    name: 'Austrija',
    englishName: 'Austria',
    flag: '🇦🇹',
    region: 'Evropa',
    isoCode: 'AT',
  ),
  CountryOption(
    name: 'Njemačka',
    englishName: 'Germany',
    flag: '🇩🇪',
    region: 'Evropa',
    isoCode: 'DE',
  ),
  CountryOption(
    name: 'Italija',
    englishName: 'Italy',
    flag: '🇮🇹',
    region: 'Evropa',
    isoCode: 'IT',
  ),
  CountryOption(
    name: 'Mađarska',
    englishName: 'Hungary',
    flag: '🇭🇺',
    region: 'Evropa',
    isoCode: 'HU',
  ),
  CountryOption(
    name: 'Češka',
    englishName: 'Czech Republic',
    flag: '🇨🇿',
    region: 'Evropa',
    isoCode: 'CZ',
  ),
  CountryOption(
    name: 'Slovačka',
    englishName: 'Slovakia',
    flag: '🇸🇰',
    region: 'Evropa',
    isoCode: 'SK',
  ),
  CountryOption(
    name: 'Poljska',
    englishName: 'Poland',
    flag: '🇵🇱',
    region: 'Evropa',
    isoCode: 'PL',
  ),
  CountryOption(
    name: 'Francuska',
    englishName: 'France',
    flag: '🇫🇷',
    region: 'Evropa',
    isoCode: 'FR',
  ),
  CountryOption(
    name: 'Belgija',
    englishName: 'Belgium',
    flag: '🇧🇪',
    region: 'Evropa',
    isoCode: 'BE',
  ),
  CountryOption(
    name: 'Nizozemska',
    englishName: 'Netherlands',
    flag: '🇳🇱',
    region: 'Evropa',
    isoCode: 'NL',
  ),
  CountryOption(
    name: 'Španjolska',
    englishName: 'Spain',
    flag: '🇪🇸',
    region: 'Evropa',
    isoCode: 'ES',
  ),
  CountryOption(
    name: 'Portugal',
    englishName: 'Portugal',
    flag: '🇵🇹',
    region: 'Evropa',
    isoCode: 'PT',
  ),
  CountryOption(
    name: 'Danska',
    englishName: 'Denmark',
    flag: '🇩🇰',
    region: 'Evropa',
    isoCode: 'DK',
  ),
  CountryOption(
    name: 'Švedska',
    englishName: 'Sweden',
    flag: '🇸🇪',
    region: 'Evropa',
    isoCode: 'SE',
  ),
  CountryOption(
    name: 'Finska',
    englishName: 'Finland',
    flag: '🇫🇮',
    region: 'Evropa',
    isoCode: 'FI',
  ),
  CountryOption(
    name: 'Irska',
    englishName: 'Ireland',
    flag: '🇮🇪',
    region: 'Evropa',
    isoCode: 'IE',
  ),
  CountryOption(
    name: 'Rumunjska',
    englishName: 'Romania',
    flag: '🇷🇴',
    region: 'Evropa',
    isoCode: 'RO',
  ),
  CountryOption(
    name: 'Bugarska',
    englishName: 'Bulgaria',
    flag: '🇧🇬',
    region: 'Evropa',
    isoCode: 'BG',
  ),
  CountryOption(
    name: 'Grčka',
    englishName: 'Greece',
    flag: '🇬🇷',
    region: 'Evropa',
    isoCode: 'GR',
  ),
  CountryOption(
    name: 'Litva',
    englishName: 'Lithuania',
    flag: '🇱🇹',
    region: 'Evropa',
    isoCode: 'LT',
  ),
  CountryOption(
    name: 'Latvija',
    englishName: 'Latvia',
    flag: '🇱🇻',
    region: 'Evropa',
    isoCode: 'LV',
  ),
  CountryOption(
    name: 'Estonija',
    englishName: 'Estonia',
    flag: '🇪🇪',
    region: 'Evropa',
    isoCode: 'EE',
  ),
  CountryOption(
    name: 'Luksemburg',
    englishName: 'Luxembourg',
    flag: '🇱🇺',
    region: 'Evropa',
    isoCode: 'LU',
  ),
  CountryOption(
    name: 'Malta',
    englishName: 'Malta',
    flag: '🇲🇹',
    region: 'Evropa',
    isoCode: 'MT',
  ),
  CountryOption(
    name: 'Cipar',
    englishName: 'Cyprus',
    flag: '🇨🇾',
    region: 'Evropa',
    isoCode: 'CY',
  ),
  CountryOption(
    name: 'Srbija',
    englishName: 'Serbia',
    flag: '🇷🇸',
    region: 'Evropa',
    isoCode: 'RS',
  ),
  CountryOption(
    name: 'Bosna i Hercegovina',
    englishName: 'Bosnia and Herzegovina',
    flag: '🇧🇦',
    region: 'Evropa',
    isoCode: 'BA',
  ),
  CountryOption(
    name: 'Crna Gora',
    englishName: 'Montenegro',
    flag: '🇲🇪',
    region: 'Evropa',
    isoCode: 'ME',
  ),
  CountryOption(
    name: 'Sjeverna Makedonija',
    englishName: 'North Macedonia',
    flag: '🇲🇰',
    region: 'Evropa',
    isoCode: 'MK',
  ),
  CountryOption(
    name: 'Albanija',
    englishName: 'Albania',
    flag: '🇦🇱',
    region: 'Evropa',
    isoCode: 'AL',
  ),
  CountryOption(
    name: 'Kosovo',
    englishName: 'Kosovo',
    flag: '🇽🇰',
    region: 'Evropa',
    isoCode: 'XK',
  ),
  CountryOption(
    name: 'Švicarska',
    englishName: 'Switzerland',
    flag: '🇨🇭',
    region: 'SWITZERLAND',
    isoCode: 'CH',
  ),
  CountryOption(
    name: 'Ujedinjeno Kraljevstvo',
    englishName: 'United Kingdom',
    flag: '🇬🇧',
    region: 'UK',
    isoCode: 'GB',
  ),
  CountryOption(
    name: 'Norveška',
    englishName: 'Norway',
    flag: '🇳🇴',
    region: 'Evropa',
    isoCode: 'NO',
  ),
  CountryOption(
    name: 'Island',
    englishName: 'Iceland',
    flag: '🇮🇸',
    region: 'Evropa',
    isoCode: 'IS',
  ),
  CountryOption(
    name: 'Lihtenštajn',
    englishName: 'Liechtenstein',
    flag: '🇱🇮',
    region: 'Evropa',
    isoCode: 'LI',
  ),
  CountryOption(
    name: 'SAD',
    englishName: 'United States',
    flag: '🇺🇸',
    region: 'USA',
    isoCode: 'US',
  ),
  CountryOption(
    name: 'Kanada',
    englishName: 'Canada',
    flag: '🇨🇦',
    region: 'CANADA',
    isoCode: 'CA',
  ),
  CountryOption(
    name: 'Australija',
    englishName: 'Australia',
    flag: '🇦🇺',
    region: 'AUSTRALIA_NZ',
    isoCode: 'AU',
  ),
];

/// Vraća ISO oznaku države postavljene na uređaju.
///
/// Primjeri:
/// Hrvatska -> HR
/// Njemačka -> DE
/// Kanada -> CA
String? deviceCountryCode() {
  final countryCode =
  PlatformDispatcher.instance.locale.countryCode?.toUpperCase();

  if (countryCode == null || countryCode.isEmpty) {
    return null;
  }

  return countryCode;
}

/// Vraća listu država tako da je država uređaja prva.
///
/// Ostale države ostaju istim redoslijedom kao u originalnoj listi.
List<CountryOption> countryOptionsForDevice() {
  final deviceCode = deviceCountryCode();

  if (deviceCode == null) {
    return List<CountryOption>.from(countryOptions);
  }

  final deviceCountryIndex = countryOptions.indexWhere(
        (country) => country.isoCode == deviceCode,
  );

  if (deviceCountryIndex == -1) {
    return List<CountryOption>.from(countryOptions);
  }

  final result = List<CountryOption>.from(countryOptions);
  final deviceCountry = result.removeAt(deviceCountryIndex);

  result.insert(0, deviceCountry);

  return result;
}

/// Pronalazi državu prema ISO oznaci.
CountryOption? countryFromIsoCode(String? isoCode) {
  final normalizedCode = isoCode?.trim().toUpperCase();

  if (normalizedCode == null || normalizedCode.isEmpty) {
    return null;
  }

  for (final country in countryOptions) {
    if (country.isoCode == normalizedCode) {
      return country;
    }
  }

  return null;
}

String countryFlag(String countryName) {
  for (final country in countryOptions) {
    if (country.name == countryName ||
        country.englishName == countryName) {
      return country.flag;
    }
  }

  return '🌍';
}

String countryRegion(String countryName) {
  for (final country in countryOptions) {
    if (country.name == countryName ||
        country.englishName == countryName) {
      return country.region;
    }
  }

  return 'Evropa';
}