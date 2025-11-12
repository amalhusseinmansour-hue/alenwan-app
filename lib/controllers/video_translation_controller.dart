import 'package:flutter/foundation.dart';
import '../services/audio_translation_service.dart';

class VideoTranslationController extends ChangeNotifier {
  final AudioTranslationService _translationService = AudioTranslationService();

  bool _isTranslationEnabled = false;
  bool _isInitialized = false;
  bool _showSubtitles = true;
  bool _showTranslationPanel = false;
  String _sourceLanguage = 'ar'; // Default source language (Arabic)
  String _targetLanguage = 'en'; // Default target language (English)
  String _currentTranslation = '';
  TranslationStatus _status = TranslationStatus.stopped;
  final List<TranslationSegment> _translationHistory = [];

  // Getters
  bool get isTranslationEnabled => _isTranslationEnabled;
  bool get isInitialized => _isInitialized;
  bool get showSubtitles => _showSubtitles;
  bool get showTranslationPanel => _showTranslationPanel;
  String get sourceLanguage => _sourceLanguage;
  String get targetLanguage => _targetLanguage;
  String get currentTranslation => _currentTranslation;
  TranslationStatus get status => _status;
  List<TranslationSegment> get translationHistory => _translationHistory;

  Map<String, String> get availableLanguages =>
      AudioTranslationService.supportedLanguages;

  VideoTranslationController() {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      _isInitialized = await _translationService.initialize();

      // Listen to translation stream
      _translationService.translationStream.listen((translation) {
        _currentTranslation = translation;
        _addToHistory(translation);
        notifyListeners();
      });

      // Listen to status stream
      _translationService.statusStream.listen((status) {
        _status = status;
        notifyListeners();
      });

      notifyListeners();
    } catch (e) {
      print('Error initializing video translation controller: $e');
    }
  }

  void _addToHistory(String translation) {
    if (translation.isNotEmpty) {
      _translationHistory.add(
        TranslationSegment(
          text: translation,
          timestamp: DateTime.now(),
          sourceLanguage: _sourceLanguage,
          targetLanguage: _targetLanguage,
        ),
      );

      // Keep only last 50 segments
      if (_translationHistory.length > 50) {
        _translationHistory.removeAt(0);
      }
    }
  }

  Future<void> toggleTranslation() async {
    if (_isTranslationEnabled) {
      await stopTranslation();
    } else {
      await startTranslation();
    }
  }

  Future<void> startTranslation() async {
    if (!_isInitialized) {
      _isInitialized = await _translationService.initialize();
    }

    if (_isInitialized) {
      _isTranslationEnabled = true;
      await _translationService.startListening(
        sourceLanguage: _sourceLanguage,
        targetLanguage: _targetLanguage,
      );
      notifyListeners();
    }
  }

  Future<void> stopTranslation() async {
    _isTranslationEnabled = false;
    await _translationService.stopListening();
    notifyListeners();
  }

  Future<void> pauseTranslation() async {
    if (_isTranslationEnabled) {
      await _translationService.pauseListening();
      notifyListeners();
    }
  }

  Future<void> resumeTranslation() async {
    if (_isTranslationEnabled) {
      await _translationService.resumeListening();
      notifyListeners();
    }
  }

  void setSourceLanguage(String languageCode) {
    if (_sourceLanguage != languageCode) {
      _sourceLanguage = languageCode;
      _translationService.setSourceLanguage(languageCode);

      // Restart translation if active
      if (_isTranslationEnabled) {
        stopTranslation().then((_) => startTranslation());
      }
      notifyListeners();
    }
  }

  void setTargetLanguage(String languageCode) {
    if (_targetLanguage != languageCode) {
      _targetLanguage = languageCode;
      _translationService.setTargetLanguage(languageCode);

      // Restart translation if active
      if (_isTranslationEnabled) {
        stopTranslation().then((_) => startTranslation());
      }
      notifyListeners();
    }
  }

  void toggleSubtitles() {
    _showSubtitles = !_showSubtitles;
    notifyListeners();
  }

  void toggleTranslationPanel() {
    _showTranslationPanel = !_showTranslationPanel;
    notifyListeners();
  }

  void clearHistory() {
    _translationHistory.clear();
    _currentTranslation = '';
    notifyListeners();
  }

  Future<String> translateText(String text) async {
    return await _translationService.translateText(
      text,
      _sourceLanguage,
      _targetLanguage,
    );
  }

  String getLanguageName(String code) {
    return availableLanguages[code] ?? code;
  }

  // Export translation history as text
  String exportTranslationHistory() {
    StringBuffer buffer = StringBuffer();
    buffer.writeln('Translation History');
    buffer.writeln('==================');
    buffer.writeln(
        'Source: ${getLanguageName(_sourceLanguage)} -> Target: ${getLanguageName(_targetLanguage)}');
    buffer.writeln('');

    for (var segment in _translationHistory) {
      buffer.writeln('[${segment.timestamp.toLocal()}]');
      buffer.writeln(segment.text);
      buffer.writeln('');
    }

    return buffer.toString();
  }

  @override
  void dispose() {
    _translationService.dispose();
    super.dispose();
  }
}

class TranslationSegment {
  final String text;
  final DateTime timestamp;
  final String sourceLanguage;
  final String targetLanguage;

  TranslationSegment({
    required this.text,
    required this.timestamp,
    required this.sourceLanguage,
    required this.targetLanguage,
  });
}
