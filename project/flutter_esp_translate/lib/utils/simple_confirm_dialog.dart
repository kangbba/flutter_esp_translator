import 'package:flutter/material.dart';

Future<bool?> simpleConfirmDialogA(BuildContext context, String message1, String positiveStr) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentTextStyle: const TextStyle(fontSize: 14, color: Colors.black87),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Text(message1, style: const TextStyle(fontSize: 15), textAlign: TextAlign.center,),
        actions: <Widget>[
          InkWell(
              onTap: (){
                Navigator.of(context).pop(false);
              },
              child: SizedBox(width : 250, height: 30, child: Align(alignment: Alignment.center, child: Text(positiveStr, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))))
          ),
        ],
        actionsPadding: const EdgeInsets.only(bottom: 12),
      );

    },
  );
}
Future<bool?> simpleConfirmDialogB(BuildContext context, String message1, String message2, String positiveStr) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentTextStyle: const TextStyle(fontSize: 14, color: Colors.black87),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: SizedBox(
          width: 100,
          height: 60,
          child: Column(
            children: [
              Container(height: 10,),
              Text(message1, style: const TextStyle(fontSize: 15), textAlign: TextAlign.center,),
              Container(height: 10,),
              Text(message2, style: const TextStyle(fontSize: 11), textAlign: TextAlign.center,),
            ],
          ),
        ),
        actions: <Widget>[
          InkWell(
              onTap: (){
                Navigator.of(context).pop(false);
              },
              child: SizedBox(width : 250, height: 30, child: Align(alignment: Alignment.center, child: Text(positiveStr, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))))
          ),
        ],
        actionsPadding: const EdgeInsets.only(bottom: 12),
      );

    },
  );
}





