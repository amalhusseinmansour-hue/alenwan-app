import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';

class AudioTranslationService {
  static final AudioTranslationService _instance = AudioTranslationService._internal();
  factory AudioTranslationService() => _instance;
  AudioTranslationService._internal();

  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  final GoogleTranslator _translator = GoogleTranslator();

  bool _isListening = false;
  bool _isInitialized = false;
  String _currentLanguageCode = 'en';
  String _targetLanguageCode = 'ar';

  StreamController<String>? _translationController;
  StreamController<TranslationStatus>? _statusController;
  Timer? _silenceTimer;

  Stream<String> get translationStream => _translationController?.stream ?? const Stream.empty();
  Stream<TranslationStatus> get statusStream => _statusController?.stream ?? const Stream.empty();
  bool get isListening => _isListening;
  bool get isInitialized => _isInitialized;

  // Supported languages for translation
  static const Map<String, String> supportedLanguages = {
    'ar': 'العربية',
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'de': 'Deutsch',
    'it': 'Italiano',
    'pt': 'Português',
    'ru': 'Русский',
    'zh': '中文',
    'ja': '日本語',
    'ko': '한국어',
    'hi': 'हिंदी',
    'tr': 'Türkçe',
    'id': 'Bahasa Indonesia',
    'ur': 'اردو',
  };

  Future<bool> initialize() async {
    try {
      _translationController = StreamController<String>.broadcast();
      _statusController = StreamController<TranslationStatus>.broadcast();

      // Initialize speech to text
      _isInitialized = await _speechToText.initialize(
        onStatus: (status) => _handleSpeechStatus(status),
        onError: (error) => _handleSpeechError(error),
      );

      if (_isInitialized) {
        // Initialize text to speech
        await _flutterTts.setLanguage(_targetLanguageCode);
        await _flutterTts.setPitch(1.0);
        await _flutterTts.setSpeechRate(0.5);
        await _flutterTts.setVolume(1.0);

        if (kIsWeb) {
          await _flutterTts.setSharedInstance(true);
        }

        _statusController?.add(TranslationStatus.ready);
      }

      return _isInitialized;
    } catch (e) {
      print('Error initializing audio translation service: $e');
      _statusController?.add(TranslationStatus.error);
      return false;
    }
  }

  Future<void> startListening({
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_isListening) return;

    _currentLanguageCode = sourceLanguage;
    _targetLanguageCode = targetLanguage;

    await _flutterTts.setLanguage(_targetLanguageCode);

    _statusController?.add(TranslationStatus.listening);
    _isListening = true;

    await _speechToText.listen(
      onResult: (result) => _handleSpeechResult(result),
      localeId: _getLocaleId(sourceLanguage),
      listenOptions: stt.SpeechListenOptions(
        cancelOnError: false,
        partialResults: true,
        listenMode: stt.ListenMode.dictation,
      ),
    );
  }

  void _handleSpeechResult(result) async {
    if (result.recognizedWords.isNotEmpty) {
      _resetSilenceTimer();

      try {
        // Translate the recognized text
        final translation = await _translator.translate(
          result.recognizedWords,
          from: _currentLanguageCode,
          to: _targetLanguageCode,
        );

        final translatedText = translation.text;

        // Send translated text to stream
        _translationController?.add(translatedText);

        // If final result, speak the translation
        if (result.finalResult && translatedText.isNotEmpty) {
          await speakTranslation(translatedText);
        }

        _statusController?.add(TranslationStatus.translating);
      } catch (e) {
        print('Translation error: $e');
        _statusController?.add(TranslationStatus.error);
      }
    }
  }

  void _resetSilenceTimer() {
    _silenceTimer?.cancel();
    _silenceTimer = Timer(const Duration(seconds: 2), () {
      if (_isListening) {
        restartListening();
      }
    });
  }

  Future<void> restartListening() async {
    await _speechToText.stop();
    await Future.delayed(const Duration(milliseconds: 100));

    if (_isListening) {
      await _speechToText.listen(
        onResult: (result) => _handleSpeechResult(result),
        localeId: _getLocaleId(_currentLanguageCode),
        listenOptions: stt.SpeechListenOptions(
          cancelOnError: false,
          partialResults: true,
          listenMode: stt.ListenMode.dictation,
        ),
      );
    }
  }

  Future<void> speakTranslation(String text) async {
    try {
      await _flutterTts.speak(text);
      _statusController?.add(TranslationStatus.speaking);
    } catch (e) {
      print('TTS error: $e');
    }
  }

  Future<void> stopListening() async {
    _isListening = false;
    _silenceTimer?.cancel();
    await _speechToText.stop();
    await _flutterTts.stop();
    _statusController?.add(TranslationStatus.stopped);
  }

  Future<void> pauseListening() async {
    if (_isListening) {
      await _speechToText.stop();
      _statusController?.add(TranslationStatus.paused);
    }
  }

  Future<void> resumeListening() async {
    if (_isListening) {
      await startListening(
        sourceLanguage: _currentLanguageCode,
        targetLanguage: _targetLanguageCode,
      );
    }
  }

  void setTargetLanguage(String languageCode) {
    _targetLanguageCode = languageCode;
    _flutterTts.setLanguage(languageCode);
  }

  void setSourceLanguage(String languageCode) {
    _currentLanguageCode = languageCode;
  }

  String _getLocaleId(String languageCode) {
    // Map language codes to locale IDs for speech recognition
    final localeMap = {
      'ar': 'ar-SA',
      'en': 'en-US',
      'es': 'es-ES',
      'fr': 'fr-FR',
      'de': 'de-DE',
      'it': 'it-IT',
      'pt': 'pt-BR',
      'ru': 'ru-RU',
      'zh': 'zh-CN',
      'ja': 'ja-JP',
      'ko': 'ko-KR',
      'hi': 'hi-IN',
      'tr': 'tr-TR',
      'id': 'id-ID',
      'ur': 'ur-PK',
    };
    return localeMap[languageCode] ?? 'en-US';
  }

  void _handleSpeechStatus(String status) {
    print('Speech status: $status');
    if (status == 'done' && _isListening) {
      // Restart listening after a brief pause
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_isListening) {
          restartListening();
        }
      });
    }
  }

  void _handleSpeechError(dynamic error) {
    print('Speech error: $error');
    _statusController?.add(TranslationStatus.error);
  }

  Future<String> translateText(String text, String from, String to) async {
    try {
      final translation = await _translator.translate(
        text,
        from: from,
        to: to,
      );
      return translation.text;
    } catch (e) {
      print('Translation error: $e');
      return text;
    }
  }

  void dispose() {
    _isListening = false;
    _silenceTimer?.cancel();
    _speechToText.stop();
    _flutterTts.stop();
    _translationController?.close();
    _statusController?.close();
  }
}

enum TranslationStatus {
  ready,
  listening,
  translating,
  speaking,
  paused,
  stopped,
  error,
}