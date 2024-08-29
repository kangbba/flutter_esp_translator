import 'package:flutter/material.dart';
import 'package:flutter_esp_translate/languages/language_control.dart';
import 'package:flutter_esp_translate/services/text_to_speech_control.dart';

import '../devices/audio_device_info.dart';
import '../secrets/secret_device_keys.dart';
import '../services/audio_device_service.dart';
import '../translate/translate_languages.dart';

class AudioTest{
  TranslateLanguage curTranslateLanguage = TranslateLanguage.korean;
  String get curLangCode => curTranslateLanguage == TranslateLanguage.korean ? 'ko_KR' : 'en_US';
// sentenceToTest getter
  String get sentenceToTest => curTranslateLanguage == TranslateLanguage.korean
      ? "계속해서 앞으로 나아가기 위해서는, 자신이 걸어가고 있는 길의 의미를 끊임없이 되새기고 좌절의 순간에도 포기하지 않는 마음이 중요합니다. 때로는 예상치 못한 난관이 우리의 길을 가로막을지라도, 그 순간이 우리를 더 강하게 만들어 줄 기회라는 것을 잊지 말아야 합니다."
      : "To keep moving forward, it is important to constantly reflect on the meaning of the path you are on and maintain the resolve not to give up, even in moments of despair. Even when unexpected obstacles block our way, we must remember that these moments are opportunities that can make us stronger.";


  Widget buildAudioControlRow(BuildContext context, TextToSpeechControl textToSpeechControl, LanguageControl languageControl) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () async {
            try {
              List<AudioDevice> allConnectedAudioDevices = await AudioDeviceService.getConnectedAudioDevicesByPrefixAndType(PRODUCT_PREFIX, 7);
              String targetDeviceName = allConnectedAudioDevices.isEmpty ? "" : allConnectedAudioDevices[0].name;
              AudioDeviceService.setAudioRouteESPHFP(targetDeviceName);
              print('Audio route set to ESP HFP for device: $targetDeviceName');
            } catch (e) {
              print('Error setting audio route to ESP HFP: $e');
            }
          },
          child: Text('단말기 라우팅'),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              AudioDeviceService.setAudioRouteMobile();
            } catch (e) {
              print('Error setting audio route to Mobile: $e');
            }
          },
          child: Text('모바일 라우팅'),
        ),
        ElevatedButton(
          onPressed: () async {
            //   textToSpeechControl.speakWithLanguage("Hello, this is a test speech.", "en_US");
            textToSpeechControl.speakWithLanguage(
                sentenceToTest,
                curLangCode);
          },
          child: Text("그냥 말하기"),
        ),
        ElevatedButton(
          onPressed: () async{
            List<AudioDevice> allConnectedAudioDevices = await AudioDeviceService.getConnectedAudioDevicesByPrefixAndType(PRODUCT_PREFIX, 7);
            String targetDeviceName = allConnectedAudioDevices.isEmpty ? "" : allConnectedAudioDevices[0].name;
            // 여기에 기능 추가 예정
            textToSpeechControl.speakWithRouteRequest(
                targetDeviceName,
                sentenceToTest,
                languageControl.findLanguageItemByTranslateLanguage(curTranslateLanguage)!
            );
          },
          child: Text("라우팅 요청하며 말하기"),
        ),
        ElevatedButton(
          onPressed: () async{
            if(curTranslateLanguage == TranslateLanguage.korean){
              curTranslateLanguage = TranslateLanguage.english;
            }
            else{
              curTranslateLanguage = TranslateLanguage.korean;
            }
          },
          child: Text("언어 토글"),
        ),

      ],
    );
  }
}