import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_esp_translate/translate/translate_languages.dart';
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
  Future<void> speakWithRouteRequest(String targetDeviceName, String strToSpeech, LanguageItem toLangItem) async {
    // 분할 기준을 설정할 변수들
    int minWordsPerSegment = 10;
    int maxWordsPerSegment = 13;
    int maxCharactersPerSegment = 15;
    bool useCharacterSplit = false; // 글자 수로 나눌지 여부 결정

    // 언어별로 분할 기준을 설정하는 switch 문
    switch (toLangItem.translateLanguage) {
      case TranslateLanguage.english: // 영어
        minWordsPerSegment = 13;
        maxWordsPerSegment = 18;
        useCharacterSplit = false; // 어절 수로 나눔
        break;
      case TranslateLanguage.korean: // 한국어
        minWordsPerSegment = 10;
        maxWordsPerSegment = 13;
        useCharacterSplit = false; // 어절 수로 나눔
        break;
      case TranslateLanguage.chinese: // 중국어
        maxCharactersPerSegment = 14;
        useCharacterSplit = true; // 글자 수로 나눔
        break;
      case TranslateLanguage.japanese: // 일본어
        maxCharactersPerSegment = 15;
        useCharacterSplit = true; // 글자 수로 나눔
        break;
      default: // 기본 설정
        minWordsPerSegment = 10;
        maxWordsPerSegment = 13;
        useCharacterSplit = false; // 어절 수로 나눔
        break;
    }

    // 분할 방식에 따라 함수를 호출
    if (useCharacterSplit) {
      await splitByCharacterCount(targetDeviceName, strToSpeech, maxCharactersPerSegment, toLangItem);
    } else {
      await splitByWordCount(targetDeviceName, strToSpeech, minWordsPerSegment, maxWordsPerSegment, toLangItem);
    }
  }
  Future<void> splitByCharacterCount(String targetDeviceName, String strToSpeech, int maxCharactersPerSegment, LanguageItem toLangItem) async {
    // 띄어쓰기를 기준으로 먼저 분할
    List<String> spaceChunks = strToSpeech.split(' ');

    List<String> rechunkSentences = []; // 최종 분할된 문장을 담을 리스트
    StringBuffer currentChunk = StringBuffer(); // 현재 조합 중인 chunk

    // 띄어쓰기로 나눈 조각들을 최대 글자 수 기준으로 조합
    for (String spaceChunk in spaceChunks) {
      spaceChunk = spaceChunk.trim();

      // 현재 chunk에 단어를 추가해도 최대 글자 수를 넘지 않으면 합침
      if (currentChunk.length + spaceChunk.length <= maxCharactersPerSegment) {
        if (currentChunk.isNotEmpty) {
          currentChunk.write(' '); // 띄어쓰기를 유지하며 추가
        }
        currentChunk.write(spaceChunk);
      } else {
        // 최대 글자 수를 넘으면 현재 chunk를 추가하고 새로운 chunk를 시작
        rechunkSentences.add(currentChunk.toString().trim());
        currentChunk.clear();
        currentChunk.write(spaceChunk);
      }
    }

    // 남아있는 chunk가 있다면 추가
    if (currentChunk.isNotEmpty) {
      rechunkSentences.add(currentChunk.toString().trim());
    }

    // 생성된 chunked list 를 다시 한 번 확인하여 최대 글자 수를 초과하는 경우 다시 분할
    List<String> finalChunks = [];
    for (String chunk in rechunkSentences) {
      if (chunk.length > maxCharactersPerSegment) {
        // 글자 수를 초과하는 경우, 다시 분할하여 추가
        for (int i = 0; i < chunk.length; i += maxCharactersPerSegment) {
          int end = (i + maxCharactersPerSegment < chunk.length) ? i + maxCharactersPerSegment : chunk.length;
          finalChunks.add(chunk.substring(i, end).trim());
        }
      } else {
        // 글자 수를 초과하지 않는 경우 그대로 추가
        finalChunks.add(chunk);
      }
    }

    // 최종 재분할된 문장들 확인 로그
    debugLog('문장이 어떻게 나뉘었는지 확인합니다 (글자 수 기준):');
    for (int i = 0; i < finalChunks.length; i++) {
      debugLog('분할된 문장 $i: "${finalChunks[i]}"');
    }

    // 재분할된 문장들을 순차적으로 처리
    for (String partialSentence in finalChunks) {
      // 오디오 라우트를 설정하고 2.5초 대기
      if(partialSentence.isEmpty){
        continue;
      }
      AudioDeviceService.setAudioRouteESPHFP(targetDeviceName);
      await Future.delayed(const Duration(milliseconds: 2500));
      await speakWithLanguage(partialSentence, toLangItem.speechLocaleId); // TTS로 문장을 읽음
    }

    debugLog('모든 문장이 처리되었습니다 (글자 수 기준).');
  }


  Future<void> splitByWordCount(String targetDeviceName, String strToSpeech, int minWordsPerSegment, int maxWordsPerSegment, LanguageItem toLangItem) async {
    RegExp sentenceRegExp = RegExp(r'[.。?？]'); // 문장 분할을 위한 정규식
    List<String> chunkSentences = strToSpeech.split(sentenceRegExp); // 문장을 마침표와 물음표로 분할

    List<String> rechunkSentences = []; // 재분할된 문장들을 담을 리스트

    // 각 문장을 확인하여 어절 수 기준으로 재분할
    for (String chunkSentence in chunkSentences) {
      chunkSentence = chunkSentence.trim();

      if (chunkSentence.isNotEmpty) {
        // 쉼표로 나누기 (영어 쉼표 포함)
        List<String> commaChunks = chunkSentence.split(',');

        List<String> bufferChunks = []; // 쉼표 덩어리를 모아놓는 리스트
        StringBuffer buffer = StringBuffer();

        for (String commaChunk in commaChunks) {
          commaChunk = commaChunk.trim();
          List<String> words = commaChunk.split(' ');

          if (words.length >= minWordsPerSegment && words.length <= maxWordsPerSegment) {
            if (buffer.isNotEmpty) {
              bufferChunks.add(buffer.toString().trim());
              buffer.clear();
            }
            bufferChunks.add(commaChunk);
          } else {
            for (String word in words) {
              buffer.write(word);
              buffer.write(' ');

              int wordCount = buffer.toString().trim().split(' ').length;

              if (wordCount >= minWordsPerSegment && wordCount <= maxWordsPerSegment) {
                bufferChunks.add(buffer.toString().trim());
                buffer.clear();
              }
            }
          }
        }

        // 버퍼에 남아있는 문장이 있다면 추가
        if (buffer.isNotEmpty) {
          bufferChunks.add(buffer.toString().trim());
        }

        // 쉼표로 분할된 조각을 재조합하여 최종 리스트에 추가
        rechunkSentences.addAll(bufferChunks);
      }
    }

    // 최종 재분할된 문장들 확인 로그
    debugLog('문장이 어떻게 나뉘었는지 확인합니다 (어절 수 기준):');
    for (int i = 0; i < rechunkSentences.length; i++) {
      debugLog('분할된 문장 $i: "${rechunkSentences[i]}"');
    }

    // 재분할된 문장들을 순차적으로 처리
    for (String partialSentence in rechunkSentences) {
      // 오디오 라우트를 설정하고 2.5초 대기
      AudioDeviceService.setAudioRouteESPHFP(targetDeviceName);
      await Future.delayed(const Duration(milliseconds: 2500));
      await speakWithLanguage(partialSentence, toLangItem.speechLocaleId); // TTS로 문장을 읽음
    }

    debugLog('모든 문장이 처리되었습니다 (어절 수 기준).');
  }









// Future<void> speakWithRouteRequest(String targetDeviceName, String strToSpeech, LanguageItem toLangItem) async {
  //   int maxWordsPerSegment = 14; // 단어 수를 관리하는 변수
  //   RegExp regExp = RegExp(r'[.?!:。？！：，；]');
  //   List<String> sentences = strToSpeech.split(regExp);
  //
  //   int sentenceCount = 0;
  //   AudioDeviceService.setAudioRouteESPHFP(targetDeviceName);
  //   for (String sentence in sentences) {
  //     if (sentence.trim().isNotEmpty) {
  //       List<String> words = sentence.trim().split(' ');
  //
  //       AudioDeviceService.setAudioRouteESPHFP(targetDeviceName);
  //       await Future.delayed(Duration(milliseconds: 1000));
  //
  //       // 단어 수가 maxWordsPerSegment 이하일 경우 그대로 출력
  //       if (words.length <= maxWordsPerSegment) {
  //         // 문장 구분될 때마다 AudioDeviceService 호출
  //
  //         debugLog(" 단어 수가 $maxWordsPerSegment 이하일 경우 그대로 출력 : ${words.length}");
  //         sentenceCount++;
  //         debugLog('Processing sentence $sentence');
  //         await speakWithLanguage(sentence.trim(), toLangItem.speechLocaleId);
  //       }
  //       else {
  //         debugLog(" 단어 수가 $maxWordsPerSegment 이상일 경우 로직 적용 : ${words.length}");
  //         // 단어 수가 maxWordsPerSegment 이상일 경우 maxWordsPerSegment 단위로 나눠서 처리
  //         StringBuffer sentenceBuffer = StringBuffer();
  //
  //         for (int i = 0; i < words.length; i++) {
  //           sentenceBuffer.write(words[i]);
  //           sentenceBuffer.write(' '); // 단어 사이에 공백 추가
  //
  //           // maxWordsPerSegment 개의 단어마다 문장 처리
  //           if ((i + 1) % maxWordsPerSegment == 0 || i == words.length - 1 || words[i] == ',') {
  //
  //             String partialSentence = sentenceBuffer.toString().trim();
  //             sentenceCount++;
  //             debugLog('${partialSentence.length}개의 부분 문장 $sentenceCount: $partialSentence');
  //
  //             await speakWithLanguage(partialSentence, toLangItem.speechLocaleId);
  //
  //             AudioDeviceService.setAudioRouteESPHFP(targetDeviceName);
  //             await Future.delayed(const Duration(milliseconds: 1500));
  //
  //             // 버퍼 초기화
  //             sentenceBuffer.clear();
  //           }
  //         }
  //       }
  //     }
  //   }
  // }

}