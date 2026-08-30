class LanguageService {
  LanguageService._();

  static final LanguageService instance = LanguageService._();

  String _language = 'ar';

  String get language => _language;

  void changeLanguage(String language) {
    _language = language;
  }
}
