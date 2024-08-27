import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import '../languages/language_control.dart';
import '../services/speech_recognition_control.dart';
import '../utils/simple_separator.dart';
import '../utils/menuconfig.dart';
import '../utils/utils.dart';

class SpeechRecognitionPopUp extends StatefulWidget {
  final String titleText;
  final LanguageItem langItem;
  final double fontSize;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  const SpeechRecognitionPopUp({
    super.key,
    required this.titleText,
    required this.langItem,
    required this.fontSize,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  @override
  State<SpeechRecognitionPopUp> createState() => _SpeechRecognitionPopUpState();
}

class _SpeechRecognitionPopUpState extends State<SpeechRecognitionPopUp> {
  SpeechRecognitionControl speechRecognitionControl = SpeechRecognitionControl();
  TextEditingController textEditingController = TextEditingController();
  bool backBtnAvailable = false;
  Timer? timer;
  Timer? noInputTimer;

  @override
  void initState() {
    super.initState();
    speechRecognitionControl.activateSpeechRecognizer();
    backBtnAvailable = false;
    actingRoutine();
    startTimer();
    startNoInputTimer();
  }

  void startTimer() {
    timer = Timer(const Duration(seconds: 1), () {
      backBtnAvailable = true;
      setState(() {});
    });
  }

  void stopTimer() {
    timer?.cancel();
  }

  void startNoInputTimer() {
    noInputTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        debugLog("start no input timer activated");
     //   exitPopUp();
      }
    });
  }

  void resetNoInputTimer() {
    noInputTimer?.cancel();
    startNoInputTimer();
  }

  @override
  void dispose() {
    stopTimer();
    stopNoInputTimer();
    speechRecognitionControl.stop();
    speechRecognitionControl.dispose();
    textEditingController.dispose();
    super.dispose();
  }

  void stopNoInputTimer() {
    noInputTimer?.cancel();
  }

  actingRoutine() async {
    LanguageItem langItem = widget.langItem;
    speechRecognitionControl.start(langItem.speechLocaleId);
    int count = 0;  // 카운트 변수 초기화

    while (true) {
      String str = speechRecognitionControl.transcription;
      if (str.length > 1000) {
        debugLog("too much length");
        break;
      }
      if (speechRecognitionControl.transcription.isNotEmpty) {
        if (str != textEditingController.text) {
          resetNoInputTimer();  // 입력이 있을 때마다 타이머 리셋
          setState(() {
            textEditingController.text = speechRecognitionControl.transcription;
          });
        }
      }

      count++;

      if (speechRecognitionControl.isCompleted && count >= 10) {
        debugLog(speechRecognitionControl.transcription);
        count = 0;
        break;
      }

      await Future.delayed(const Duration(milliseconds: 50));
    }

    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (mounted) {
        setState(() {
          textEditingController.text = speechRecognitionControl.transcription;
        });
      }
    }

    speechRecognitionControl.stop();
    if (mounted) {
      exitPopUp();
    }
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        debugLog("뒤로가기 막힘");
        if (backBtnAvailable) {
          exitPopUp();
        }
        return false;
      },
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          children: [
            SizedBox(
                height: 30,
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0, left: 0),
                      child: backBtnAvailable
                          ? InkWell(
                          onTap: () {
                            exitPopUp();
                          },
                          child: const Icon(
                            CupertinoIcons.back,
                            color: Colors.black54,
                            size: 32,
                          ))
                          : Container(),
                    ))),
            Text(
              widget.titleText,
              style: const TextStyle(fontSize: 16, height: 1.1, color: yourBackgroundColor),
            ),
            Expanded(
                flex: 1,
                child: Center(
                  child: RippleAnimation(
                    color: yourBackgroundColor,
                    delay: const Duration(milliseconds: 200),
                    repeat: true,
                    minRadius: 30,
                    ripplesCount: 4,
                    duration: const Duration(milliseconds: 1800),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 60, // 원의 지름 설정
                          height: 60, // 원의 지름 설정
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.backgroundColor,
                          ),
                          child: Icon(
                            widget.icon,
                            color: widget.iconColor,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            const SimpleSeparator(color: Colors.grey, height: 1, top: 0, bottom: 0),
            Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
                  child: Container(
                    alignment: Alignment.center,
                    child: Align(
                        alignment: Alignment.center,
                        child: TextField(
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isCollapsed: true, // 높이를 텍스트에 맞게 조절
                          ),
                          readOnly: true,
                          maxLines: 6,
                          controller: textEditingController,
                          style: TextStyle(fontSize: widget.fontSize, height: 1.25),
                        )),
                  ),
                )),
            const SimpleSeparator(color: Colors.grey, height: 1, top: 0, bottom: 20),
          ],
        ),
      ),
    );
  }

  void exitPopUp() {
    stopTimer();
    stopNoInputTimer();
    speechRecognitionControl.stop();
    Navigator.pop(context, textEditingController.text);
  }
}
