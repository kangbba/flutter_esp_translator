
import 'package:flutter/cupertino.dart';
import '../utils/menuconfig.dart';
import '../translate/translate_by_googleserver.dart';
import '../utils/utils.dart';

import '../languages/language_control.dart';

enum TranslateTool
{
  googleServer,
}
class TranslateControl with ChangeNotifier
{
  static TranslateControl? _instance;

  static TranslateControl getInstance() {
    _instance ??= TranslateControl._internal();
    return _instance!;
  }

  TranslateControl._internal() {
    // 생성자 내용
  }
  TranslateByGoogleServer translateByGoogleServer = TranslateByGoogleServer();

  void initializeTranslateControl()
  {
    translateByGoogleServer.initializeTranslateByGoogleServer();
  }

  Future<String> translateByAvailablePlatform (String fromStr, LanguageItem fromLanguageItem, LanguageItem toLanguageItem, int timeoutMilliSec) async{
    if(fromStr.length > inputStrMaxLength){
      debugLog("3000자 이상이어서 취소");
      return '';
    }
    List<TranslateTool> translateTools = [TranslateTool.googleServer];
    String? translatedWords;
    TranslateTool? trToolConfirmed;
    List<TranslateTool> trToolsToUse = translateTools;
    for(int i = 0 ; i < trToolsToUse.length ; i++)
    {
      TranslateTool translateTool = trToolsToUse[i];
      String? response = await _translateByPlatform(fromStr, fromLanguageItem, toLanguageItem, translateTool, timeoutMilliSec);
      if(response != null && response.isNotEmpty)
      {
        translatedWords = response;
        trToolConfirmed = translateTool;
        break;
      }
    }
    if(trToolConfirmed != null && translatedWords != null)
    {
      return translatedWords;
    }
    return '';
  }

  Future<String?> _translateByPlatform(String inputStr, LanguageItem fromLanguageItem, LanguageItem toLanguageItem, TranslateTool translateTool, int timeoutMilliSec) async
  {
    debugLog("translateTool $translateTool 를 이용해 번역 시도합니다.");
    String? finalStr;
    switch(translateTool)
    {
      case TranslateTool.googleServer:
        String from =  fromLanguageItem.langCodeGoogleServer;
        String to =  toLanguageItem.langCodeGoogleServer;
        finalStr = await translateByGoogleServer.textTranslate(inputStr, from, to, timeoutMilliSec);
        break;
      default:
        break;
    }

    debugLog("translateTool $translateTool 를 이용한 응답 : $finalStr");
    return (finalStr == null) ? null : finalStr;
  }

}
