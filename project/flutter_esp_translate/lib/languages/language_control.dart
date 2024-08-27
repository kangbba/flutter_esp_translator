import 'package:flutter/material.dart';
import '../screens/select_languages_pair_screen.dart';
import '../services/data_control.dart';
import '../services/translate_control.dart';
import '../translate/translate_languages.dart';
import '../utils/utils.dart';

enum LanguageName{

  /// Afrikaans
  afrikaans,

  /// Albanian
  albanian,

  /// Arabic
  arabic,

  /// Belarusian
  belarusian,

  /// Bengali
  bengali,

  /// Bulgarian
  bulgarian,

  /// Catalan
  catalan,

  /// Chinese
  chinese,

  /// Croatian
  croatian,

  /// Czech
  czech,

  /// Danish
  danish,

  /// Dutch
  dutch,

  /// English
  english,

  /// Esperanto
  esperanto,

  /// Estonian
  estonian,

  /// Finnish
  finnish,

  /// French
  french,

  /// Galician
  galician,

  /// Georgian
  georgian,

  /// German
  german,

  /// Greek
  greek,

  /// Gujarati
  gujarati,

  /// Haitian
  haitian,

  /// Hebrew
  hebrew,

  /// Hindi
  hindi,

  /// Hungarian
  hungarian,

  /// Icelandic
  icelandic,

  /// Indonesian
  indonesian,

  /// Irish
  irish,

  /// Italian
  italian,

  /// Japanese
  japanese,

  /// Kannada
  kannada,

  /// Korean
  korean,

  /// Latvian
  latvian,

  /// Lithuanian
  lithuanian,

  /// Macedonian
  macedonian,

  /// Malay
  malay,

  /// Maltese
  maltese,

  /// Marathi
  marathi,

  /// Norwegian
  norwegian,

  /// Persian
  persian,

  /// Polish
  polish,

  /// Portuguese
  portuguese,

  /// Romanian
  romanian,

  /// Russian
  russian,

  /// Slovak
  slovak,

  /// Slovenian
  slovenian,

  /// Spanish
  spanish,

  /// Swahili
  swahili,

  /// Swedish
  swedish,

  /// Tagalog
  tagalog,

  /// Tamil
  tamil,

  /// Telugu
  telugu,

  /// Thai
  thai,

  /// Turkish
  turkish,

  /// Ukrainian
  ukrainian,

  /// Urdu
  urdu,

  /// Vietnamese
  vietnamese,

  /// Welsh
  welsh,
}

get translateControl => TranslateControl.getInstance();
get dataControl => DataControl.getInstance();
class LanguageItem {
  final TranslateLanguage translateLanguage;
  final String originalMenuDisplayStr;
  final String speechLocaleId;
  final String langCodeGoogleServer;
  final String langCodePapagoServer;
  final int uniqueId;

  List<String> frqtlyUsedSentences = [];

  LanguageItem({
    required this.translateLanguage,
    required this.originalMenuDisplayStr,
    required this.speechLocaleId,
    required this.langCodeGoogleServer,
    required this.langCodePapagoServer,
    required this.uniqueId,
    List<String>? menuStrKeywordListToRemove, // 선택적 위치 매개변수
  }); // 초기화

}
class LanguageControl with ChangeNotifier{

  static LanguageControl? _instance;



  static LanguageControl getInstance() {
    _instance ??= LanguageControl._internal();
    return _instance!;
  }

  LanguageControl._internal() {
    // 생성자 내용
  }
  String myStr = "";
  String yourStr = "";

  LanguageItem findEnglishLanguageItem(){
    return findLanguageItemByTranslateLanguage(TranslateLanguage.english)!;
  }

  late LanguageItem nowMyLanguageItem;
  late LanguageItem nowYourLanguageItem;

  initLanguageControl(String systemLangCode) {

    LanguageItem englishLangItem = findEnglishLanguageItem();
    List<String> recentLanguagePairs = dataControl.loadRecentLanguagePairs(); /// [ korean-english , english-korean, thai-japanese ... ]

    LanguageItem properMyLangItem;
    LanguageItem properYourLangItem ;
    if(recentLanguagePairs.isEmpty){ /// 첫실행
      properMyLangItem = findLanguageItemByGoogleLangCode(systemLangCode) ?? englishLangItem;
      properYourLangItem = findLanguageItemByTranslateLanguage((properMyLangItem.translateLanguage != TranslateLanguage.english) ? TranslateLanguage.english : TranslateLanguage.korean)
          ?? englishLangItem;

      dataControl.addRecentLanguagePairs(properMyLangItem.translateLanguage, properYourLangItem.translateLanguage);
      dataControl.saveLanguageFavorite(properMyLangItem.translateLanguage, true);
    }
    else{ /// 이후 실행
      String mostRecentLanguagePairStr = recentLanguagePairs.last;
      String myMostRecentLanguageStr = mostRecentLanguagePairStr.split('-')[0];
      String yourMostRecentLanguageStr = mostRecentLanguagePairStr.split('-')[1];
      properMyLangItem = findLanguageItemByTranslateLanguageStr(myMostRecentLanguageStr) ?? englishLangItem;
      properYourLangItem = findLanguageItemByTranslateLanguageStr(yourMostRecentLanguageStr) ?? englishLangItem;
    }

    nowMyLanguageItem = properMyLangItem ;
    nowYourLanguageItem = properYourLangItem ;


    sortLanguageDataListByFavorite();

    notifyListeners();
  }

// TODO: LanguageItem 관리
  LanguageItem? findLanguageItemByTranslateLanguage(TranslateLanguage translateLanguage) {
    return languageDataList.firstWhere((item) => item?.translateLanguage == translateLanguage, orElse: () => null);
  }
  LanguageItem? findLanguageItemBySystemLocaleId(String speechLocaleId) {
    return languageDataList.firstWhere((item) => item?.speechLocaleId == speechLocaleId, orElse: () => null);
  }
  LanguageItem? findLanguageItemByGoogleLangCode(String langCodeGoogleServer) {
    return languageDataList.firstWhere((item) => item?.langCodeGoogleServer == langCodeGoogleServer, orElse: () => null);
  }
  LanguageItem? findLanguageItemByTranslateLanguageStr(String translateLanguageStr) {
    return languageDataList.firstWhere((item) => item?.translateLanguage.toString() == translateLanguageStr, orElse: () => null);

  }

  sortLanguageDataListByFavorite(){
    languageDataList.sort((a, b) {
      bool isFavoriteA = dataControl.loadLanguageFavorite(a!.translateLanguage);
      bool isFavoriteB = dataControl.loadLanguageFavorite(b!.translateLanguage);

      // 좋아요가 있는 아이템을 먼저 나열하고, 그 다음에는 없는 아이템을 나열
      if (isFavoriteA && !isFavoriteB) {
        return -1; // a가 b보다 앞에 정렬됨
      } else if (!isFavoriteA && isFavoriteB) {
        return 1; // b가 a보다 앞에 정렬됨
      } else {
        return 0; // 순서 변경 없음
      }
    });
    notifyListeners();
  }

  Future<bool> waitGoogleServerActivated() async{
    LanguageItem engLangItem = findEnglishLanguageItem();
    for(int i = 0 ; i < 10; i++){
      String? resp = await translateControl.translateByGoogleServer.textTranslate('car', engLangItem.langCodeGoogleServer, nowYourLanguageItem.langCodeGoogleServer, 500);
      if(resp != null && resp.isNotEmpty){
        return true;
      }
    }
    return false;
  }


  void switchStrEachOther() {
    var tmp = myStr ;
    myStr = yourStr;
    yourStr = tmp;
    notifyListeners();
  }


  List<LanguageItem?> languageDataList = [
    LanguageItem(translateLanguage: TranslateLanguage.english, originalMenuDisplayStr: "English", speechLocaleId: "en_US", langCodeGoogleServer: "en", langCodePapagoServer: "en", uniqueId: 1),
    LanguageItem(translateLanguage: TranslateLanguage.spanish, originalMenuDisplayStr: "Spanish", speechLocaleId: "es_ES", langCodeGoogleServer: "es", langCodePapagoServer: "es", uniqueId: 2),
    LanguageItem(translateLanguage: TranslateLanguage.french, originalMenuDisplayStr: "French", speechLocaleId: "fr_FR", langCodeGoogleServer: "fr", langCodePapagoServer: "fr", uniqueId: 3),
    LanguageItem(translateLanguage: TranslateLanguage.german, originalMenuDisplayStr: "German", speechLocaleId: "de_DE", langCodeGoogleServer: "de", langCodePapagoServer: "de", uniqueId: 4),
    LanguageItem(translateLanguage: TranslateLanguage.chinese, originalMenuDisplayStr: "Chinese", speechLocaleId: "zh_CN", langCodeGoogleServer: "zh", langCodePapagoServer: "zh-CN", uniqueId: 5),
    LanguageItem(translateLanguage: TranslateLanguage.arabic, originalMenuDisplayStr: "Arabic", speechLocaleId: "ar_AR", langCodeGoogleServer: "ar", langCodePapagoServer: "", uniqueId: 6),
    LanguageItem(translateLanguage: TranslateLanguage.russian, originalMenuDisplayStr: "Russian", speechLocaleId: "ru_RU", langCodeGoogleServer: "ru", langCodePapagoServer: "", uniqueId: 7),
    LanguageItem(translateLanguage: TranslateLanguage.portuguese, originalMenuDisplayStr: "Portuguese", speechLocaleId: "pt_PT", langCodeGoogleServer: "pt", langCodePapagoServer: "", uniqueId: 8,),
    LanguageItem(translateLanguage: TranslateLanguage.italian, originalMenuDisplayStr: "Italian", speechLocaleId: "it_IT", langCodeGoogleServer: "it", langCodePapagoServer: "", uniqueId: 9),
    LanguageItem(translateLanguage: TranslateLanguage.japanese, originalMenuDisplayStr: "Japanese", speechLocaleId: "ja_JP", langCodeGoogleServer: "ja", langCodePapagoServer: "ja", uniqueId: 10),
    LanguageItem(translateLanguage: TranslateLanguage.dutch, originalMenuDisplayStr: "Dutch", speechLocaleId: "nl_NL", langCodeGoogleServer: "nl", langCodePapagoServer: "", uniqueId: 11),
    LanguageItem(translateLanguage: TranslateLanguage.korean, originalMenuDisplayStr: "Korean", speechLocaleId: "ko_KR", langCodeGoogleServer: "ko", langCodePapagoServer: "", uniqueId: 12),
    LanguageItem(translateLanguage: TranslateLanguage.swedish, originalMenuDisplayStr: "Swedish", speechLocaleId: "sv_SE", langCodeGoogleServer: "sv", langCodePapagoServer: "", uniqueId: 13),
    LanguageItem(translateLanguage: TranslateLanguage.turkish, originalMenuDisplayStr: "Turkish", speechLocaleId: "tr_TR", langCodeGoogleServer: "tr", langCodePapagoServer: "", uniqueId: 14),
    LanguageItem(translateLanguage: TranslateLanguage.polish, originalMenuDisplayStr: "Polish", speechLocaleId: "pl_PL", langCodeGoogleServer: "pl", langCodePapagoServer: "", uniqueId: 15),
    LanguageItem(translateLanguage: TranslateLanguage.danish, originalMenuDisplayStr: "Danish", speechLocaleId: "da_DK", langCodeGoogleServer: "da", langCodePapagoServer: "", uniqueId: 16),
    LanguageItem(translateLanguage: TranslateLanguage.norwegian, originalMenuDisplayStr: "Norwegian", speechLocaleId: "nb_NO", langCodeGoogleServer: "no", langCodePapagoServer: "", uniqueId: 17),
    LanguageItem(translateLanguage: TranslateLanguage.finnish, originalMenuDisplayStr: "Finnish", speechLocaleId: "fi_FI", langCodeGoogleServer: "fi", langCodePapagoServer: "", uniqueId: 18),
    LanguageItem(translateLanguage: TranslateLanguage.czech, originalMenuDisplayStr: "Czech", speechLocaleId: "cs_CZ", langCodeGoogleServer: "cs", langCodePapagoServer: "", uniqueId: 19),
    LanguageItem(translateLanguage: TranslateLanguage.thai, originalMenuDisplayStr: "Thai", speechLocaleId: "th_TH", langCodeGoogleServer: "th", langCodePapagoServer: "th", uniqueId: 20),
    LanguageItem(translateLanguage: TranslateLanguage.greek, originalMenuDisplayStr: "Greek", speechLocaleId: "el_GR", langCodeGoogleServer: "el", langCodePapagoServer: "", uniqueId: 21),
    LanguageItem(translateLanguage: TranslateLanguage.hungarian, originalMenuDisplayStr: "Hungarian", speechLocaleId: "hu_HU", langCodeGoogleServer: "hu", langCodePapagoServer: "hu", uniqueId: 22),
    LanguageItem(translateLanguage: TranslateLanguage.hebrew, originalMenuDisplayStr: "Hebrew", speechLocaleId: "he_IL", langCodeGoogleServer: "he", langCodePapagoServer: "he", uniqueId: 23),
    LanguageItem(translateLanguage: TranslateLanguage.romanian, originalMenuDisplayStr: "Romanian", speechLocaleId: "ro_RO", langCodeGoogleServer: "ro", langCodePapagoServer: "ro", uniqueId: 24),
    LanguageItem(translateLanguage: TranslateLanguage.ukrainian, originalMenuDisplayStr: "Ukrainian", speechLocaleId: "uk_UA", langCodeGoogleServer: "uk", langCodePapagoServer: "uk", uniqueId: 25),
    LanguageItem(translateLanguage: TranslateLanguage.vietnamese, originalMenuDisplayStr: "Vietnamese", speechLocaleId: "vi_VN", langCodeGoogleServer: "vi", langCodePapagoServer: "vi", uniqueId: 26),
    LanguageItem(translateLanguage: TranslateLanguage.icelandic, originalMenuDisplayStr: "Icelandic", speechLocaleId: "is_IS", langCodeGoogleServer: "is", langCodePapagoServer: "", uniqueId: 27),
    LanguageItem(translateLanguage: TranslateLanguage.bulgarian, originalMenuDisplayStr: "Bulgarian", speechLocaleId: "bg_BG", langCodeGoogleServer: "bg", langCodePapagoServer: "bg", uniqueId: 28),
    LanguageItem(translateLanguage: TranslateLanguage.lithuanian, originalMenuDisplayStr: "Lithuanian", speechLocaleId: "lt_LT", langCodeGoogleServer: "lt", langCodePapagoServer: "lt", uniqueId: 29),
    LanguageItem(translateLanguage: TranslateLanguage.latvian, originalMenuDisplayStr: "Latvian", speechLocaleId: "lv_LV", langCodeGoogleServer: "lv", langCodePapagoServer: "lv", uniqueId: 30),
    LanguageItem(translateLanguage: TranslateLanguage.slovenian, originalMenuDisplayStr: "Slovenian", speechLocaleId: "sl_SI", langCodeGoogleServer: "sl", langCodePapagoServer: "sl", uniqueId: 31),
    LanguageItem(translateLanguage: TranslateLanguage.croatian, originalMenuDisplayStr: "Croatian", speechLocaleId: "hr_HR", langCodeGoogleServer: "hr", langCodePapagoServer: "hr", uniqueId: 32),
    LanguageItem(translateLanguage: TranslateLanguage.estonian, originalMenuDisplayStr: "Estonian", speechLocaleId: "et_EE", langCodeGoogleServer: "et", langCodePapagoServer: "", uniqueId: 33),
    // LanguageItem(translateLanguage: TranslateLanguage. , menuDisplayStr: "Serbian", speechLocaleId: "sr_RS", langCodeGoogleServer: "sr", langCodePapagoServer: "", uniqueId: 34),
    LanguageItem(translateLanguage: TranslateLanguage.slovak, originalMenuDisplayStr: "Slovak", speechLocaleId: "sk_SK", langCodeGoogleServer: "sk", langCodePapagoServer: "", uniqueId: 35),
    LanguageItem(translateLanguage: TranslateLanguage.georgian, originalMenuDisplayStr: "Georgian", speechLocaleId: "ka_GE", langCodeGoogleServer: "ka", langCodePapagoServer: "", uniqueId: 36),
    LanguageItem(translateLanguage: TranslateLanguage.catalan, originalMenuDisplayStr: "Catalan", speechLocaleId: "ca_ES", langCodeGoogleServer: "ca", langCodePapagoServer: "", uniqueId: 37),
    LanguageItem(translateLanguage: TranslateLanguage.bengali, originalMenuDisplayStr: "Bengali", speechLocaleId: "bn_IN", langCodeGoogleServer: "bn", langCodePapagoServer: "", uniqueId: 38),
    LanguageItem(translateLanguage: TranslateLanguage.persian, originalMenuDisplayStr: "Persian", speechLocaleId: "fa_IR", langCodeGoogleServer: "fa", langCodePapagoServer: "", uniqueId: 39),
    LanguageItem(translateLanguage: TranslateLanguage.marathi, originalMenuDisplayStr: "Marathi", speechLocaleId: "mr_IN", langCodeGoogleServer: "mr", langCodePapagoServer: "", uniqueId: 40),
    LanguageItem(translateLanguage: TranslateLanguage.indonesian, originalMenuDisplayStr: "Indonesian", speechLocaleId: "id_ID", langCodeGoogleServer: "id", langCodePapagoServer: "id", uniqueId: 41),
    LanguageItem(translateLanguage: TranslateLanguage.irish, originalMenuDisplayStr: "Irish", speechLocaleId: "ga_IE", langCodeGoogleServer: "ga", langCodePapagoServer: "ga", uniqueId: 41),
  ];

  showLanguagesPairSelectScreen(BuildContext context, bool isMyLanguage) async{
    List<LanguageItem>? respLangItems = await showModalBottomSheet<List<LanguageItem>>(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.8,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: const SelectLanguagesPairScreen(),
          ),
        );
      },
    );
    if(respLangItems == null){
      return;
    }
    if(respLangItems.length == 2){
      if(respLangItems[0].translateLanguage == nowMyLanguageItem.translateLanguage && respLangItems[1].translateLanguage == nowYourLanguageItem.translateLanguage){
        debugLog("같은 국가 선택됨");
        return;
      }
      dataControl.addRecentLanguagePairs(respLangItems[0].translateLanguage, respLangItems[1].translateLanguage);
      nowMyLanguageItem = respLangItems[0];
      nowYourLanguageItem =respLangItems[1];
    }
    else if(respLangItems.length == 1){
      LanguageItem respLangItem = respLangItems[0];
      if(isMyLanguage){ // 내 언어를 바꾸기위한 화면이었으므로, 반환은 내 언어
        if(respLangItem.translateLanguage == nowMyLanguageItem.translateLanguage){
          debugLog("같은 국가 선택됨");
          return;
        }
        dataControl.addRecentLanguagePairs(respLangItems[0].translateLanguage, nowYourLanguageItem.translateLanguage);
        nowMyLanguageItem = respLangItems[0];
      }
      else{
        if(respLangItem.translateLanguage == nowYourLanguageItem.translateLanguage){
          debugLog("같은 국가 선택됨");
          return;
        }
        dataControl.addRecentLanguagePairs(nowMyLanguageItem.translateLanguage, respLangItems[0].translateLanguage);
        nowYourLanguageItem = respLangItems[0];
      }
    }
    else{
      debugLog("respLangItems error $respLangItems");
    }
    notifyListeners();
  }
  switchLanguagesEachOther(){
    var tmp = nowMyLanguageItem;
    nowMyLanguageItem = nowYourLanguageItem;
    nowYourLanguageItem = tmp;

    dataControl.addRecentLanguagePairs(nowMyLanguageItem.translateLanguage, nowYourLanguageItem.translateLanguage);
    notifyListeners();
  }
}