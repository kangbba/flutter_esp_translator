
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'menuconfig.dart';

void debugLog(Object? message) {
  if (kDebugMode) {
    print('[커스텀 디버그] $message');
  }
}
String capitalizeFirstLetter(String text) {
  if (text.isEmpty) {
    return text;
  }
  if (text.length < 2) {
    return text.toUpperCase();
  }
  return text[0].toUpperCase() + text.substring(1);
}
Future<bool?> simpleConfirmDialog(BuildContext context, String message1, String positiveStr) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentTextStyle: const TextStyle(fontSize: 13, color: Colors.black87),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Text(message1, style: const TextStyle(fontSize: 14), textAlign: TextAlign.center,),
        actions: <Widget>[
          InkWell(
              onTap: (){
                Navigator.of(context).pop(false);
              },
              child: SizedBox(width : 250, height: 40, child: Align(alignment: Alignment.center, child: Text(positiveStr, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))))
          ),
        ],
        actionsPadding: const EdgeInsets.only(bottom: 12),
      );

    },
  );
}
Future<bool?> askDialogColumn(BuildContext context, Widget contentWidget, String positiveStr, String negativeStr, double height) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentTextStyle: const TextStyle(fontSize: 14, color: Colors.black),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: SizedBox(
          width: 600, // 원하는 너비로 설정
          height: height,
          child: Center(
            child: contentWidget,
          ),
        ),
        actions: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).pop(true);
                },
                child: Container(
                  width: 250,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20), // 원하는 라운드값 설정
                    color: yourBackgroundColor, // 배경색 설정
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      positiveStr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.normal),
                    ),
                  ),
                )
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).pop(false);
                },
                child: SizedBox(
                  width: 100,
                  height: 40, // 높이 조절
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(negativeStr, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15)),
                  ),
                ),
              ),
              Container(height: 8,)
            ],
          )
        ],
      );
    },
  );
}
Future<bool?> askDialogRow(BuildContext context, Widget contentWidget, String positiveStr, String negativeStr, double height) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentTextStyle: const TextStyle(fontSize: 14, color: Colors.black),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        alignment: Alignment.center,
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        content: SizedBox(
          height: height,
          width: 500,
          child: Center(child: contentWidget),
        ),
        actions: <Widget>[
          SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).pop(false);
                },
                child: SizedBox(
                  width: 100,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      negativeStr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15, color: Colors.black87),
                    ),
                  ),
                ),
              ),
              Container(width: 1, height : 20, color: Colors.grey,),
              InkWell(
                  onTap: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Container(
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20), // 원하는 라운드값 설정
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        positiveStr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 15, color: Colors.black87, ),
                      ),
                    ),
                  )
              ),
            ],),
          )
        ],
      );
    },
  );
}

simpleLoadingDialog(BuildContext context, String message) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        insetPadding: const EdgeInsets.symmetric(vertical: 100),
        contentTextStyle: const TextStyle(fontSize: 14, color: Colors.black87),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.normal),
            ),
            const SizedBox(height: 20),
            LoadingAnimationWidget.inkDrop(
              size: 30,
              color: Colors.indigo,
            ),
          ],
        ),
      );
    },
  );
}








