import 'dart:async';
import 'dart:io';
import 'package:google_cloud_translation/google_cloud_translation.dart';

import '../secrets/secret_api_keys.dart';


class TranslateByGoogleServer {
  late Translation _translation;

  initializeTranslateByGoogleServer() {
    _translation = Translation(apiKey: Platform.isAndroid ? apiKeyGoogleServerAndroid : apiKeyGoogleServerIOS);
  }

  Future<String?> textTranslate(String inputStr, String from, String to, int timeoutMilliSec) async {
    Completer<TranslationModel> completer = Completer();

    try {
      var translationModel = await Future.any([
        _getTranslationModel(inputStr, from, to),
        Future.delayed(Duration(milliseconds: timeoutMilliSec)).then((_) => throw TimeoutException('Translation request timed out'))
      ]);

      return translationModel.translatedText;
    } on TimeoutException catch (_) {
      completer.completeError(TimeoutException('Translation request timed out'));
      return null;
    }
  }

  Future<TranslationModel> _getTranslationModel(String inputStr, String from, String to) {
    Completer<TranslationModel> completer = Completer();

    _translation.translate(text: inputStr, to: to).then((translationModel) {
      if (!completer.isCompleted) {
        completer.complete(translationModel);
      }
    });

    return completer.future;
  }
}
