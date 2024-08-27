import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';


loadingDialog(BuildContext context, String message) async {
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

