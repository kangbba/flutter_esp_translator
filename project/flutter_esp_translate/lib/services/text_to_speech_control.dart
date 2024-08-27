import 'package:flutter/cupertino.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../utils/utils.dart';


class TextToSpeechControl extends ChangeNotifier{

  static TextToSpeechControl? _instance;

  static TextToSpeechControl getInstance() {
    _instance ??= TextToSpeechControl._internal();
    return _instance!;
  }

  TextToSpeechControl._internal() {
    // 생성자 내용
  }

  FlutterTts flutterTts = FlutterTts();
  initTextToSpeech()
  {
    flutterTts.setPitch(1.0);
    flutterTts.setSpeechRate(0.5);
  }
  Future<void> changeLanguage(String langCode) async
  {
    List<String> separated = langCode.split('_');
    debugLog(separated.length);
    String manipulatedLangCode = "${separated[0]}-${separated[1]}";
    await flutterTts.setLanguage(manipulatedLangCode);
  }
  Future<void> speakWithLanguage(String str, String langCode) async {
    int? maxLength = await flutterTts.getMaxSpeechInputLength;
    debugLog("speakWithLanguage :: ${maxLength ?? ''}");
    await changeLanguage(langCode);
    await flutterTts.speak(str);
    await flutterTts.awaitSpeakCompletion(true);
    debugLog("말하기 끝");
  }
  Future<void> pause() async {
    await flutterTts.pause();
  }
  Future<void> stop() async {
    await flutterTts.stop();
  }
}