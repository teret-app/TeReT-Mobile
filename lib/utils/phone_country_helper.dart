class PhoneCountryOption {
  final String hrName;
  final String enName;
  final String flag;
  final String dialCode;
  final String region;

  const PhoneCountryOption({
    required this.hrName,
    required this.enName,
    required this.flag,
    required this.dialCode,
    this.region = 'Evropa',
  });

  String localizedName(String languageCode) {
    return languageCode == 'en' ? enName : hrName;
  }
}

const List<PhoneCountryOption> phoneCountryOptions = [
  PhoneCountryOption(
    hrName: 'Hrvatska',
    enName: 'Croatia',
    flag: '🇭🇷',
    dialCode: '+385',
  ),
  PhoneCountryOption(
    hrName: 'Slovenija',
    enName: 'Slovenia',
    flag: '🇸🇮',
    dialCode: '+386',
  ),
  PhoneCountryOption(
    hrName: 'Bosna i Hercegovina',
    enName: 'Bosnia and Herzegovina',
    flag: '🇧🇦',
    dialCode: '+387',
  ),
  PhoneCountryOption(
    hrName: 'Srbija',
    enName: 'Serbia',
    flag: '🇷🇸',
    dialCode: '+381',
  ),
  PhoneCountryOption(
    hrName: 'Crna Gora',
    enName: 'Montenegro',
    flag: '🇲🇪',
    dialCode: '+382',
  ),
  PhoneCountryOption(
    hrName: 'Sjeverna Makedonija',
    enName: 'North Macedonia',
    flag: '🇲🇰',
    dialCode: '+389',
  ),
  PhoneCountryOption(
    hrName: 'Albanija',
    enName: 'Albania',
    flag: '🇦🇱',
    dialCode: '+355',
  ),
  PhoneCountryOption(
    hrName: 'Kosovo',
    enName: 'Kosovo',
    flag: '🇽🇰',
    dialCode: '+383',
  ),
  PhoneCountryOption(
    hrName: 'Austrija',
    enName: 'Austria',
    flag: '🇦🇹',
    dialCode: '+43',
  ),
  PhoneCountryOption(
    hrName: 'Njemačka',
    enName: 'Germany',
    flag: '🇩🇪',
    dialCode: '+49',
  ),
  PhoneCountryOption(
    hrName: 'Italija',
    enName: 'Italy',
    flag: '🇮🇹',
    dialCode: '+39',
  ),
  PhoneCountryOption(
    hrName: 'Mađarska',
    enName: 'Hungary',
    flag: '🇭🇺',
    dialCode: '+36',
  ),
  PhoneCountryOption(
    hrName: 'Češka',
    enName: 'Czechia',
    flag: '🇨🇿',
    dialCode: '+420',
  ),
  PhoneCountryOption(
    hrName: 'Slovačka',
    enName: 'Slovakia',
    flag: '🇸🇰',
    dialCode: '+421',
  ),
  PhoneCountryOption(
    hrName: 'Poljska',
    enName: 'Poland',
    flag: '🇵🇱',
    dialCode: '+48',
  ),
  PhoneCountryOption(
    hrName: 'Francuska',
    enName: 'France',
    flag: '🇫🇷',
    dialCode: '+33',
  ),
  PhoneCountryOption(
    hrName: 'Belgija',
    enName: 'Belgium',
    flag: '🇧🇪',
    dialCode: '+32',
  ),
  PhoneCountryOption(
    hrName: 'Nizozemska',
    enName: 'Netherlands',
    flag: '🇳🇱',
    dialCode: '+31',
  ),
  PhoneCountryOption(
    hrName: 'Luksemburg',
    enName: 'Luxembourg',
    flag: '🇱🇺',
    dialCode: '+352',
  ),
  PhoneCountryOption(
    hrName: 'Švicarska',
    enName: 'Switzerland',
    flag: '🇨🇭',
    dialCode: '+41',
    region: 'SWITZERLAND',
  ),
  PhoneCountryOption(
    hrName: 'Lihtenštajn',
    enName: 'Liechtenstein',
    flag: '🇱🇮',
    dialCode: '+423',
  ),
  PhoneCountryOption(
    hrName: 'Španjolska',
    enName: 'Spain',
    flag: '🇪🇸',
    dialCode: '+34',
  ),
  PhoneCountryOption(
    hrName: 'Portugal',
    enName: 'Portugal',
    flag: '🇵🇹',
    dialCode: '+351',
  ),
  PhoneCountryOption(
    hrName: 'Ujedinjeno Kraljevstvo',
    enName: 'United Kingdom',
    flag: '🇬🇧',
    dialCode: '+44',
    region: 'UK',
  ),
  PhoneCountryOption(
    hrName: 'Irska',
    enName: 'Ireland',
    flag: '🇮🇪',
    dialCode: '+353',
  ),
  PhoneCountryOption(
    hrName: 'Danska',
    enName: 'Denmark',
    flag: '🇩🇰',
    dialCode: '+45',
  ),
  PhoneCountryOption(
    hrName: 'Švedska',
    enName: 'Sweden',
    flag: '🇸🇪',
    dialCode: '+46',
  ),
  PhoneCountryOption(
    hrName: 'Norveška',
    enName: 'Norway',
    flag: '🇳🇴',
    dialCode: '+47',
  ),
  PhoneCountryOption(
    hrName: 'Finska',
    enName: 'Finland',
    flag: '🇫🇮',
    dialCode: '+358',
  ),
  PhoneCountryOption(
    hrName: 'Island',
    enName: 'Iceland',
    flag: '🇮🇸',
    dialCode: '+354',
  ),
  PhoneCountryOption(
    hrName: 'Estonija',
    enName: 'Estonia',
    flag: '🇪🇪',
    dialCode: '+372',
  ),
  PhoneCountryOption(
    hrName: 'Latvija',
    enName: 'Latvia',
    flag: '🇱🇻',
    dialCode: '+371',
  ),
  PhoneCountryOption(
    hrName: 'Litva',
    enName: 'Lithuania',
    flag: '🇱🇹',
    dialCode: '+370',
  ),
  PhoneCountryOption(
    hrName: 'Rumunjska',
    enName: 'Romania',
    flag: '🇷🇴',
    dialCode: '+40',
  ),
  PhoneCountryOption(
    hrName: 'Bugarska',
    enName: 'Bulgaria',
    flag: '🇧🇬',
    dialCode: '+359',
  ),
  PhoneCountryOption(
    hrName: 'Grčka',
    enName: 'Greece',
    flag: '🇬🇷',
    dialCode: '+30',
  ),
  PhoneCountryOption(
    hrName: 'Cipar',
    enName: 'Cyprus',
    flag: '🇨🇾',
    dialCode: '+357',
  ),
  PhoneCountryOption(
    hrName: 'Malta',
    enName: 'Malta',
    flag: '🇲🇹',
    dialCode: '+356',
  ),
  PhoneCountryOption(
    hrName: 'Moldavija',
    enName: 'Moldova',
    flag: '🇲🇩',
    dialCode: '+373',
  ),
  PhoneCountryOption(
    hrName: 'Ukrajina',
    enName: 'Ukraine',
    flag: '🇺🇦',
    dialCode: '+380',
  ),
  PhoneCountryOption(
    hrName: 'Turska',
    enName: 'Türkiye',
    flag: '🇹🇷',
    dialCode: '+90',
  ),
  PhoneCountryOption(
    hrName: 'Sjedinjene Američke Države',
    enName: 'United States',
    flag: '🇺🇸',
    dialCode: '+1',
    region: 'USA',
  ),
  PhoneCountryOption(
    hrName: 'Kanada',
    enName: 'Canada',
    flag: '🇨🇦',
    dialCode: '+1',
    region: 'CANADA',
  ),
  PhoneCountryOption(
    hrName: 'Australija',
    enName: 'Australia',
    flag: '🇦🇺',
    dialCode: '+61',
    region: 'AUSTRALIA_NZ',
  ),
  PhoneCountryOption(
    hrName: 'Novi Zeland',
    enName: 'New Zealand',
    flag: '🇳🇿',
    dialCode: '+64',
    region: 'AUSTRALIA_NZ',
  ),
];