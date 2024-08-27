import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RecordingBtn extends StatefulWidget {

  final VoidCallback onPressed;
  final Color? backgroundColor, btnColor;
  const RecordingBtn({
    required this.onPressed,
    required this.backgroundColor,
    required this.btnColor,
    super.key,
  });

  @override
  State<RecordingBtn> createState() => _RecordingBtnState();
}
class _RecordingBtnState extends State<RecordingBtn> {
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return recordBtn();
  }

  Widget recordBtn() {
    return ElevatedButton(
      style: ButtonStyle(
        minimumSize: WidgetStateProperty.all(const Size(66, 66)),
        shape: WidgetStateProperty.all(const CircleBorder()),
        backgroundColor: WidgetStateProperty.all(widget.backgroundColor)
      ),
      onPressed: () {
        widget.onPressed();
      },
      child: Icon(
        CupertinoIcons.mic_solid,
        color: widget.btnColor,
        size: 38,
      )
    );
  }
}
