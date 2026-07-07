class CountryOption {
  final String name;
  final String flag;
  final String region;

  const CountryOption({
    required this.name,
    required this.flag,
    required this.region,
  });
}

const List<CountryOption> countryOptions = [
  CountryOption(name: 'Hrvatska', flag: '🇭🇷', region: 'Evropa'),
  CountryOption(name: 'Slovenija', flag: '🇸🇮', region: 'Evropa'),
  CountryOption(name: 'Austrija', flag: '🇦🇹', region: 'Evropa'),
  CountryOption(name: 'Njemačka', flag: '🇩🇪', region: 'Evropa'),
  CountryOption(name: 'Italija', flag: '🇮🇹', region: 'Evropa'),
  CountryOption(name: 'Mađarska', flag: '🇭🇺', region: 'Evropa'),
  CountryOption(name: 'Češka', flag: '🇨🇿', region: 'Evropa'),
  CountryOption(name: 'Slovačka', flag: '🇸🇰', region: 'Evropa'),
  CountryOption(name: 'Poljska', flag: '🇵🇱', region: 'Evropa'),
  CountryOption(name: 'Francuska', flag: '🇫🇷', region: 'Evropa'),
  CountryOption(name: 'Belgija', flag: '🇧🇪', region: 'Evropa'),
  CountryOption(name: 'Nizozemska', flag: '🇳🇱', region: 'Evropa'),
  CountryOption(name: 'Španjolska', flag: '🇪🇸', region: 'Evropa'),
  CountryOption(name: 'Portugal', flag: '🇵🇹', region: 'Evropa'),
  CountryOption(name: 'Danska', flag: '🇩🇰', region: 'Evropa'),
  CountryOption(name: 'Švedska', flag: '🇸🇪', region: 'Evropa'),
  CountryOption(name: 'Finska', flag: '🇫🇮', region: 'Evropa'),
  CountryOption(name: 'Irska', flag: '🇮🇪', region: 'Evropa'),
  CountryOption(name: 'Rumunjska', flag: '🇷🇴', region: 'Evropa'),
  CountryOption(name: 'Bugarska', flag: '🇧🇬', region: 'Evropa'),
  CountryOption(name: 'Grčka', flag: '🇬🇷', region: 'Evropa'),
  CountryOption(name: 'Litva', flag: '🇱🇹', region: 'Evropa'),
  CountryOption(name: 'Latvija', flag: '🇱🇻', region: 'Evropa'),
  CountryOption(name: 'Estonija', flag: '🇪🇪', region: 'Evropa'),
  CountryOption(name: 'Luksemburg', flag: '🇱🇺', region: 'Evropa'),
  CountryOption(name: 'Malta', flag: '🇲🇹', region: 'Evropa'),
  CountryOption(name: 'Cipar', flag: '🇨🇾', region: 'Evropa'),

  CountryOption(name: 'Srbija', flag: '🇷🇸', region: 'Evropa'),
  CountryOption(name: 'Bosna i Hercegovina', flag: '🇧🇦', region: 'Evropa'),
  CountryOption(name: 'Crna Gora', flag: '🇲🇪', region: 'Evropa'),
  CountryOption(name: 'Sjeverna Makedonija', flag: '🇲🇰', region: 'Evropa'),
  CountryOption(name: 'Albanija', flag: '🇦🇱', region: 'Evropa'),
  CountryOption(name: 'Kosovo', flag: '🇽🇰', region: 'Evropa'),

  CountryOption(name: 'Švicarska', flag: '🇨🇭', region: 'SWITZERLAND'),
  CountryOption(name: 'Ujedinjeno Kraljevstvo', flag: '🇬🇧', region: 'UK'),
  CountryOption(name: 'Norveška', flag: '🇳🇴', region: 'Evropa'),
  CountryOption(name: 'Island', flag: '🇮🇸', region: 'Evropa'),
  CountryOption(name: 'Lihtenštajn', flag: '🇱🇮', region: 'Evropa'),

  CountryOption(name: 'SAD', flag: '🇺🇸', region: 'USA'),
  CountryOption(name: 'Kanada', flag: '🇨🇦', region: 'CANADA'),
  CountryOption(name: 'Australija', flag: '🇦🇺', region: 'AUSTRALIA_NZ'),
];

String countryFlag(String countryName) {
  for (final country in countryOptions) {
    if (country.name == countryName) {
      return country.flag;
    }
  }
  return '🌍';
}

String countryRegion(String countryName) {
  for (final country in countryOptions) {
    if (country.name == countryName) {
      return country.region;
    }
  }
  return 'Evropa';
}