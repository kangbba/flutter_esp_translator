import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/text_to_speech_control.dart';
import '../languages/language_control.dart';

class TextToSpeechBtn extends StatelessWidget {
  final bool isMine;
  final Color color;
  late final LanguageControl languageControl;
  late final TextToSpeechControl textToSpeechControl;

  TextToSpeechBtn({
    super.key,
    required this.isMine,
    required this.color,
  }) {
    languageControl = LanguageControl.getInstance();
    textToSpeechControl = TextToSpeechControl.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    String inputStr = isMine ? languageControl.myStr : languageControl.yourStr;
    return inputStr.isEmpty ? Container() :
    InkWell(
      onTap: () {
        String? speechLocaleId = isMine
            ? languageControl.nowMyLanguageItem.speechLocaleId
            : languageControl.nowYourLanguageItem.speechLocaleId;

        textToSpeechControl.speakWithLanguage(inputStr, speechLocaleId);
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 4.0, bottom: 4),
        child: Icon(
          size : 28,
          CupertinoIcons.speaker_2,
          color: color,
        ),
      ),
    );
  }

}
