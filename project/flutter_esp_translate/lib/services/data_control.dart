import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../translate/translate_languages.dart';
import '../utils/menuconfig.dart';
import '../languages/language_control.dart';
import '../utils/utils.dart';

class DataControl with ChangeNotifier {
  late SharedPreferences _prefs;

  final int maxRecentLanguagePairs = 3;

  bool isInitialized = false;
  static DataControl? _instance;


  static DataControl getInstance() {
    _instance ??= DataControl._internal();
    return _instance!;
  }

  DataControl._internal() {
    // 생성자 내용
  }
  Future<void> initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    isInitialized = true;
    debugLog("DataControl Initialized Successfully");
  }

  /// 앱 실행시마다 호출되는 local용 key
  Future<void> saveRecentLocalNumber(int number) async {
    if(!isInitialized){
      return;
    }
    await _prefs.setInt('recentLocalNumber', number);
    notifyListeners();
  }
  int loadRecentLocalNumber() {
    if(!isInitialized){
      return 0;
    }
    return _prefs.getInt('recentLocalNumber') ?? 0;
  }

  /// 메뉴에서 눌렀을때 저장하는 최근 언어
  List<String> loadRecentLanguagePairs() {
    if(!isInitialized){
      return [];
    }
    final List<String> languagePairs = _prefs.getStringList('recentLanguagePairs') ?? [];
    return languagePairs;
  }

  Future<void> removeRecentLanguagePairsIfExist(TranslateLanguage myTrLanguage, TranslateLanguage yourTrLanguage) async {
    if(!isInitialized){
      return;
    }
    final List<String> languagePairs = loadRecentLanguagePairs();
    String strToAdd = '${myTrLanguage.toString()}-${yourTrLanguage.toString()}';
    if(languagePairs.contains(strToAdd)){
      // Add the new language pair to the end of the list
      languagePairs.remove(strToAdd);
    }
    await _prefs.setStringList('recentLanguagePairs', languagePairs);
    notifyListeners();
  }

  Future<void> addRecentLanguagePairs(TranslateLanguage myTrLanguage, TranslateLanguage yourTrLanguage) async {
    if(!isInitialized){
      return;
    }
    final List<String> languagePairs = loadRecentLanguagePairs();

    String strToAdd = '${myTrLanguage.toString()}-${yourTrLanguage.toString()}';
    if(languagePairs.contains(strToAdd)){
      // Add the new language pair to the end of the list
      languagePairs.remove(strToAdd);
    }
    languagePairs.add(strToAdd);

    // Remove the oldest language pair if the list size exceeds 5
    if (languagePairs.length > maxRecentLanguagePairs) {
      languagePairs.removeAt(0);
    }

    await _prefs.setStringList('recentLanguagePairs', languagePairs);
    notifyListeners();
  }

  ///Settings

  bool loadSettingAutoTextToSpeech() {
    if(!isInitialized){
      return true;
    }
    String localKeyStr ='settings_autoTextToSpeech';
    return _prefs.getBool(localKeyStr) ?? true;
  }

  Future<void> saveSettingAutoTextToSpeech(bool value) async {
    if(!isInitialized){
      return ;
    }
    String localKeyStr ='settings_autoTextToSpeech';
    await _prefs.setBool(localKeyStr, value);
    notifyListeners();
  }

  bool loadLanguageFavorite(TranslateLanguage translateLanguage) {
    if(!isInitialized){
      return false;
    }
    String localKeyStr ='loadLanguageFavorite_${translateLanguage.toString()}';
    return _prefs.getBool(localKeyStr) ?? false;
  }
  Future<void> saveLanguageFavorite(TranslateLanguage translateLanguage, bool value) async{
    if(!isInitialized){
      return;
    }
    String localKeyStr ='loadLanguageFavorite_${translateLanguage.toString()}';
    await _prefs.setBool(localKeyStr, value);
    notifyListeners();
  }
  int get nowLanguageFavoriteCount{
    if(!isInitialized){
      return 0;
    }
    LanguageControl languageControl = LanguageControl.getInstance();
    int count = 0;
    for(int i = 0 ; i < languageControl.languageDataList.length; i++){
      TranslateLanguage translateLanguage = languageControl.languageDataList[i]!.translateLanguage;
      bool isFavorite = loadLanguageFavorite(translateLanguage);
      if(isFavorite){
        count++;
      }
    }
    return count;
  }

}
