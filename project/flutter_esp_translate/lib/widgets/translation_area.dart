import 'package:flutter/material.dart';
import '../widgets/text_to_speech_btn.dart';

class TranslationArea extends StatelessWidget {
  final Color? textColor;
  final Color? backgroundColor;
  final String str;
  final bool isMine;

  const TranslationArea({
    super.key,
    required this.textColor,
    required this.backgroundColor,
    required this.str,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    return Container(
      color: backgroundColor,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 16),
              child: TextToSpeechBtn(
                isMine: isMine,
                color: Colors.black45,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Scrollbar(
                controller: scrollController,
                thumbVisibility: true,
                scrollbarOrientation: ScrollbarOrientation.right,
                radius: const Radius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.only(left: 22.0, right: 22),
                  child: SingleChildScrollView(
                    controller: scrollController, // <---- Same as the Scrollbar controller
                    child: Text(
                      str,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 24,
                        height: 1.2,
                      ),
                      overflow: TextOverflow.clip, // Keep the content within bounds
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
