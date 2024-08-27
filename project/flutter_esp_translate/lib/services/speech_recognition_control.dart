import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_speech/flutter_speech.dart';

import '../utils/utils.dart';
class SpeechRecognitionControl extends ChangeNotifier {

  void activateSpeechRecognizer() {
    isCompleted = false;
    debugLog('_MyAppState.activateSpeechRecognizer... ');
    _speech = SpeechRecognition();
    _speech.setAvailabilityHandler(onSpeechAvailability);
    _speech.setRecognitionStartedHandler(onRecognitionStarted);
    _speech.setRecognitionResultHandler(onRecognitionResult);
    _speech.setRecognitionCompleteHandler(onRecognitionComplete);
    _speech.setErrorHandler(errorHandler);
  }
  late SpeechRecognition _speech;

  // bool _speechRecognitionAvailable = false;
  bool _isCompleted = false;
  bool get isCompleted {
    return _isCompleted;
  }
  set isCompleted(dynamic value)
  {
    _isCompleted = value;
    notifyListeners();
  }

  String _transcription = '';
  String get transcription{
    return _transcription;
  }
  set transcription(String s)
  {
    _transcription = s;
    notifyListeners();

  }

  String _langCode = '';
  void start(String langCode) {
    isCompleted = false;
    _langCode = langCode;
    _speech.activate(langCode).then((_) {
      return _speech.listen().then((result) {
        debugLog('_MyAppState.start => result $result');
      });
    });
  }

  void cancel() =>
      _speech.cancel().then((_) {

      }
      );

  void stop() => _speech.stop().then((_) {
    _isCompleted = true;
  });

  void onSpeechAvailability(bool result) {
    // _speechRecognitionAvailable = result;
  }


  void onCurrentLocale(String locale) {
    // print('_MyAppState.onCurrentLocale... $locale');
    // selectedLang = languages.firstWhere((l) => l.code == locale;
  }

  void onRecognitionStarted() {
  }

  void onRecognitionComplete(String text) {
    debugLog('_MyAppState.onRecognitionComplete... $text');
    transcription = text;
    isCompleted = transcription.isNotEmpty;
  }

  void onRecognitionResult(String text) {
    debugLog('_MyAppState.onRecognitionResult... $text');
    transcription = text;
  }

  void errorHandler() {
    if(isCompleted){
    }
    else{
      start(_langCode);
    }
  }
}