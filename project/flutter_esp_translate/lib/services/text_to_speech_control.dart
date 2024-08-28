import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import '../languages/language_control.dart';
import '../utils/utils.dart';
import 'audio_device_service.dart';



class TextToSpeechControl extends ChangeNotifier{

  static TextToSpeechControl? _instance;
  final AudioPlayer audioPlayer = AudioPlayer(); // AudioPlayer 인스턴스 생성

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
  Future<void> speakWithFile(String text, String langCode) async {
    // 언어 설정
    await changeLanguage(langCode);

    // 파일 저장 경로 설정
    final directory = await getTemporaryDirectory();
    String filePath = '${directory.path}/output.mp3';

    // 시작 시간 기록
    DateTime startTime = DateTime.now();

    // 텍스트를 파일로 변환
    await flutterTts.synthesizeToFile(text, filePath);
    await flutterTts.awaitSynthCompletion(true);
    // 종료 시간 기록
    DateTime endTime = DateTime.now();

    // 시간 차 계산
    Duration duration = endTime.difference(startTime);

    // 소요 시간 로그 출력
    debugLog('synthesizeToFile 처리 시간: ${duration.inMilliseconds} 밀리초');
    await Future.delayed(const Duration(milliseconds: 500));
    await playAudioFile(filePath);
  }

  Future<void> playAudioFile(String filePath) async {

    // 파일이 존재하는지 확인
    final File audioFile = File(filePath);
    if (await audioFile.exists()) {
      try {
        // 오디오 파일 재생 시도
        await audioPlayer.play(DeviceFileSource(filePath)); // 최신 audioplayers 문법
        debugLog('오디오 파일이 성공적으로 재생되었습니다.');
      } catch (e) {
        debugLog('오디오 파일 재생 실패: $e');
      }
    } else {
      debugLog('오디오 파일이 존재하지 않습니다: $filePath');
    }
  }
  List<String> splitSentence(String sentence, int maxLength) {
    List<String> chunks = [];
    String buffer = "";

    // 문장을 공백 기준으로 나눠 어절 리스트로 만듭니다.
    List<String> words = sentence.split(' ');

    for (String word in words) {
      // 현재 단어를 추가해도 maxLength를 넘지 않으면 buffer에 추가
      if ((buffer + word).length <= maxLength) {
        buffer = buffer.isEmpty ? word : "$buffer $word";
      } else {
        // 최대 길이를 넘으면 buffer를 chunks에 추가하고 buffer를 비웁니다.
        chunks.add(buffer);
        buffer = word;
      }
    }

    // 마지막 buffer를 추가
    if (buffer.isNotEmpty) {
      chunks.add(buffer);
    }

    return chunks;
  }
//
// // 새로운 메서드 추가
//   Future<void> speakWithRouteRequest2(String targetDeviceName, String strToSpeech, LanguageItem toLangItem) async {
//     // 오디오 라우트 설정
//     AudioDeviceService.setAudioRouteESPHFP(targetDeviceName);
//     debugLog('오디오 라우트가 ${targetDeviceName}으로 설정되었습니다.');
//
//     // progressHandler 설정
//     flutterTts.setProgressHandler((String text, int start, int end, String word) async {
//       // 현재 라우팅된 오디오 기기가 ESPHFP인지 확인
//       bool isESPHFP = await AudioDeviceService.isCurrentRouteESPHFP(targetDeviceName);
//       debugLog('현재 라우트가 ESPHFP인지 확인: $isESPHFP');
//       if(!isESPHFP){
//         AudioDeviceService.setAudioRouteESPHFP(targetDeviceName);
//         await speakWithLanguage(strToSpeech.trim(), toLangItem.speechLocaleId);
//       }
//     });
//
//     // 텍스트를 말하기 시작
//     await speakWithLanguage(strToSpeech.trim(), toLangItem.speechLocaleId);
//     debugLog('음성 재생이 시작되었습니다.');
//
//     // 음성이 재생 중인지 확인은 필요하지 않습니다.
//     // flutterTts.progressHandler가 텍스트 재생 중에 지속적으로 호출됩니다.
//   }

  Future<void> speakFileWithTimeRouting(String targetDeviceName, String strToSpeech, LanguageItem toLangItem) async {
    // 오디오 라우트를 설정합니다.
    AudioDeviceService.setAudioRouteESPHFP(targetDeviceName);
    speakWithFile(strToSpeech, toLangItem.speechLocaleId);

    Timer.periodic(Duration(seconds: 1), (timer) async {
      //hfp 연결을 유지하기위한 keep alive data 전송
    });
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
  Future<void> speakWithRouteRequest(BuildContext context, String targetDeviceName, String strToSpeech, LanguageItem toLangItem) async {
    int maxWordsPerSegment = 15; // 단어 수를 관리하는 변수
    RegExp regExp = RegExp(r'[,.?!:。？！：，；]');
    List<String> sentences = strToSpeech.split(regExp);

    int sentenceCount = 0;
    AudioDeviceService.setAudioRouteESPHFP(targetDeviceName);
    for (String sentence in sentences) {
      if (sentence.trim().isNotEmpty) {
        List<String> words = sentence.trim().split(' ');

        // 문장 구분될 때마다 AudioDeviceService 호출
        AudioDeviceService.setAudioRouteESPHFP(targetDeviceName);
        await Future.delayed(Duration(milliseconds: 100));

        // 단어 수가 maxWordsPerSegment 이하일 경우 그대로 출력
        if (words.length <= maxWordsPerSegment) {
          debugLog(" 단어 수가 $maxWordsPerSegment 이하일 경우 그대로 출력 : ${words.length}");
          sentenceCount++;
          debugLog('Processing sentence $sentence');
          await speakWithLanguage(sentence.trim(), toLangItem.speechLocaleId);
        }
        else {
          debugLog(" 단어 수가 $maxWordsPerSegment 이상일 경우 로직 적용 : ${words.length}");
          // 단어 수가 maxWordsPerSegment 이상일 경우 maxWordsPerSegment 단위로 나눠서 처리
          StringBuffer sentenceBuffer = StringBuffer();

          for (int i = 0; i < words.length; i++) {
            sentenceBuffer.write(words[i]);
            sentenceBuffer.write(' '); // 단어 사이에 공백 추가

            // maxWordsPerSegment 개의 단어마다 문장 처리
            if ((i + 1) % maxWordsPerSegment == 0 || i == words.length - 1) {

              String partialSentence = sentenceBuffer.toString().trim();
              sentenceCount++;
              debugLog('${partialSentence.length}개의 부분 문장 $sentenceCount: $partialSentence');
              simpleLoadingDialog(context, "재연결중");
              AudioDeviceService.setAudioRouteESPHFP(targetDeviceName);
              await Future.delayed(Duration(milliseconds: 1500));
              Navigator.pop(context);

              await speakWithLanguage(partialSentence, toLangItem.speechLocaleId);

              // 버퍼 초기화
              sentenceBuffer.clear();
            }
          }
        }
      }
    }
  }

}