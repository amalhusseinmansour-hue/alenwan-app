class Languages {
  static const List<Map<String, String>> supportedLanguages = [
    {
      'code': 'ar',
      'name': 'العربية',
      'nativeName': 'العربية',
      'flag': '🇸🇦',
    },
    {
      'code': 'en',
      'name': 'English',
      'nativeName': 'English',
      'flag': '🇺🇸',
    },
  ];

  static Map<String, String>? getLanguageByCode(String code) {
    try {
      return supportedLanguages.firstWhere(
        (language) => language['code'] == code,
      );
    } catch (e) {
      return null;
    }
  }

  static bool isRTL(String languageCode) {
    return languageCode == 'ar';
  }
}
