import 'package:flutter/material.dart';
import 'language_control.dart';

class LanguageMenuSelector extends StatelessWidget {
  final bool isMyLanguage;
  final Color? textColor;
  final Color? iconColor;
  final VoidCallback onTap;
  final double width;
  final double height;

  const LanguageMenuSelector({super.key,
    required this.isMyLanguage,
    required this.textColor,
    required this.iconColor,
    required this.width,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    LanguageControl languageControl = LanguageControl.getInstance();

    String myTranslatedMenuDisplay = languageControl.nowMyLanguageItem.originalMenuDisplayStr;
    String myMenuDisplayForUser = myTranslatedMenuDisplay;

    String yourTranslatedMenuDisplay = languageControl.nowYourLanguageItem.originalMenuDisplayStr;
    String yourMenuDisplayForUser = yourTranslatedMenuDisplay;

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 12,),
            Text(
              isMyLanguage
                  ? myMenuDisplayForUser
                  : yourMenuDisplayForUser,
            style: TextStyle(
                fontSize: 16,
                color: textColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top : 1.0),
              child: SizedBox(child:  Icon(
                Icons.arrow_drop_down,
                color: iconColor,
              ),),
            ),

          ],
        ),
      ),
    );
  }
}
