import 'package:flutter/cupertino.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../languages/language_control.dart';
import '../utils/utils.dart';
import 'audio_device_service.dart';


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
// 새로운 메서드 추가
  Future<void> speakWithRouteRequest2(String targetDeviceName, String strToSpeech, LanguageItem toLangItem) async {
    // 오디오 라우트 설정
    AudioDeviceService.setAudioRouteESPHFP(targetDeviceName);
    debugLog('오디오 라우트가 ${targetDeviceName}으로 설정되었습니다.');

    // progressHandler 설정
    flutterTts.setProgressHandler((String text, int start, int end, String word) async {
      // 현재 라우팅된 오디오 기기가 ESPHFP인지 확인
      bool isESPHFP = await AudioDeviceService.isCurrentRouteESPHFP(targetDeviceName);
      debugLog('현재 라우트가 ESPHFP인지 확인: $isESPHFP');
    });

    // 텍스트를 말하기 시작
    await speakWithLanguage(strToSpeech.trim(), toLangItem.speechLocaleId);
    debugLog('음성 재생이 시작되었습니다.');

    // 음성이 재생 중인지 확인은 필요하지 않습니다.
    // flutterTts.progressHandler가 텍스트 재생 중에 지속적으로 호출됩니다.
  }
  Future<void> speakWithRouteRequest(String targetDeviceName, String strToSpeech, LanguageItem toLangItem) async{
    // 정규식을 이용하여 '.', ',', '?', '!' 기준으로 텍스트 분리
    int maxWordsPerSegment = 15; // 단어 수를 관리하는 변수
    double delayBetweenWords = 10.0; // 단어 수 사이의 딜레이
    double delayBetweenSentences = 100.0; // 문장 간 딜레이

    // 정규식을 이용하여 '.', ',', '?', '!', ':' 기준으로 텍스트 분리
    RegExp regExp = RegExp(r'[.?!:。？！：，；]');
    List<String> sentences = strToSpeech.split(regExp);

    int sentenceCount = 0;

    for (String sentence in sentences) {
      if (sentence.trim().isNotEmpty) {
        // 문장을 공백을 기준으로 단어 리스트로 분리
        List<String> words = sentence.trim().split(' ');

        // 단어 수가 maxWordsPerSegment 이하일 경우 그대로 출력
        if (words.length <= maxWordsPerSegment) {
          sentenceCount++;
          AudioDeviceService.setAudioRouteESPHFP(targetDeviceName);
          await Future.delayed(Duration(milliseconds: delayBetweenSentences.toInt()));
          await speakWithLanguage(sentence.trim(), toLangItem.speechLocaleId);
        } else {
          // 단어 수가 maxWordsPerSegment 이상일 경우 maxWordsPerSegment 단위로 나눠서 처리
          StringBuffer sentenceBuffer = StringBuffer();

          for (int i = 0; i < words.length; i++) {
            sentenceBuffer.write(words[i]);
            sentenceBuffer.write(' '); // 단어 사이에 공백 추가

            // maxWordsPerSegment 개의 단어마다 문장 처리
            if ((i + 1) % maxWordsPerSegment == 0 || i == words.length - 1) {
              String partialSentence = sentenceBuffer.toString().trim();
              if (partialSentence.isNotEmpty) {
                sentenceCount++;
                debugLog("현재 문장 길이 : ${partialSentence.length}");
                debugLog('Processing sentence $sentenceCount: $partialSentence');

                AudioDeviceService.setAudioRouteESPHFP(targetDeviceName);
                await Future.delayed(Duration(milliseconds: delayBetweenWords.toInt()));

                await speakWithLanguage(partialSentence, toLangItem.speechLocaleId);

                // 버퍼 초기화
                sentenceBuffer.clear();
              }
            }
          }
        }
        await Future.delayed(Duration(milliseconds: delayBetweenSentences.toInt()));
      }
    }
  }
}