import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../languages/language_control.dart';
import '../services/data_control.dart';
import '../utils/simple_separator.dart';
import '../utils/menuconfig.dart';

class SelectLanguagesPairScreen extends StatefulWidget {
  const SelectLanguagesPairScreen({super.key});

  @override
  State<SelectLanguagesPairScreen> createState() => _SelectLanguagesPairScreenState();
}

class _SelectLanguagesPairScreenState extends State<SelectLanguagesPairScreen> {

  final int maxFavoriteLanguageCount = 5;
  DataControl dataControl = DataControl.getInstance();
  LanguageControl languageControl = LanguageControl.getInstance();
  final ScrollController _scrollController = ScrollController();

  void scrollToPosition() {
    _scrollController.animateTo(
      30,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        child: Consumer<LanguageControl>(
          builder: (context, languageControl, _) {
            return Container(
              color: Colors.white,
              child: Column(
                children: [
                  const SimpleSeparator(color: Colors.black54, height: 0, top: 4, bottom: 4),
                  const Text('Please select your language', style: TextStyle(fontSize: 18)),
                  const SimpleSeparator(color: Colors.black54, height: 0.5, top: 16, bottom: 16),
                  Expanded(
                    child: CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text('Recent languages', style: TextStyle(fontSize: 16)),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: dataControl.loadRecentLanguagePairs().length,
                                itemBuilder: (context, index) {
                                  List<String> recentLanguagePairs = dataControl.loadRecentLanguagePairs();
                                  int itemCount = recentLanguagePairs.length;

                                  String recentLanguagesPairStr = recentLanguagePairs[itemCount - 1 - index];
                                  String myRecentLangStr = recentLanguagesPairStr.split('-')[0];
                                  String yourRecentLangStr = recentLanguagesPairStr.split('-')[1];
                                  LanguageItem? myRecentLangItem = languageControl.findLanguageItemByTranslateLanguageStr(myRecentLangStr);
                                  LanguageItem? yourRecentLangItem = languageControl.findLanguageItemByTranslateLanguageStr(yourRecentLangStr);
                                  bool isSelected =  (recentLanguagesPairStr == recentLanguagePairs.last);

                                  return (myRecentLangItem != null && yourRecentLangItem != null) ? twoLanguageListTile(myRecentLangItem, yourRecentLangItem, isSelected) : Container();
                                },
                              ),
                              const SimpleSeparator(color: Colors.black54, height: 0, top: 16, bottom: 16),
                              Container(
                                padding: const EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16), // 내부 여백 설정
                                decoration: BoxDecoration(
                                  color: Colors.white, // 회색 배경색
                                  borderRadius: BorderRadius.circular(20), // 모서리를 둥글게 설정
                                ),

                                child: const Text('Entire languages', style: TextStyle(fontSize: 14)),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: languageControl.languageDataList.length,
                                itemBuilder: (context, index) {
                                  LanguageItem languageItem = languageControl.languageDataList[index]!;
                                  dataControl.loadLanguageFavorite(languageItem.translateLanguage);
                                  return oneLanguageListTile(languageItem, Colors.black87);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
  Widget oneLanguageListTile(LanguageItem langItem, Color textColor)
  {
    bool isFavoriteLangItem = dataControl.loadLanguageFavorite(langItem.translateLanguage);
    return Column(
      children: [
        ListTile(
          title: InkWell(
              onTap: (){
                Navigator.pop(context, [langItem]);
              },
              child: SizedBox(
                  height: 50,
                  child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(langItem.originalMenuDisplayStr,
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 16, color: textColor),
                  )
              )
            )
          ),
          trailing: InkWell(
            onTap: (){
              bool wantFavorite = !isFavoriteLangItem;
              if(wantFavorite){
                if(dataControl.nowLanguageFavoriteCount >= maxFavoriteLanguageCount){
                  Fluttertoast.showToast(
                      msg: 'Max favorites',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.black54,
                      textColor: Colors.white,
                      fontSize: 16.0
                  );
                }
                else{
                  dataControl.saveLanguageFavorite(langItem.translateLanguage, true);
                  languageControl.sortLanguageDataListByFavorite();
                  scrollToPosition();
                  setState(() {

                  });
                }
              }
              else{
                dataControl.saveLanguageFavorite(langItem.translateLanguage, false);
                languageControl.sortLanguageDataListByFavorite();
                scrollToPosition();
                setState(() {

                });
              }

            },
            child: isFavoriteLangItem ?
            SizedBox(height: 50, child: Icon(CupertinoIcons.star_fill, color: Colors.yellow[600],)) : const Icon(CupertinoIcons.star, color: Colors.grey,),
          ),
        ),
        const SimpleSeparator(color: Colors.black12, height: 1.2, top: 0, bottom: 0),
      ],
    );
  }
  Widget twoLanguageListTile(LanguageItem myTrLangItem, LanguageItem yourTrLangItem, bool isSelected)
  {
    return Column(
      children: [
        ListTile(
          title: InkWell(
            onTap: (){
              if(isSelected){
                Navigator.pop(context);
              }
              else{
                Navigator.pop(context, [myTrLangItem, yourTrLangItem]);
              }
            },
            child: SizedBox(
              height: 45,
              child: Row(
                children: [
                  Text(myTrLangItem.originalMenuDisplayStr,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: isSelected ? Colors.green : Colors.black87),
                  ),
                  const SizedBox(width: 16,),
                  const SizedBox(width: 36, height: 18,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children : [
                        Icon(Icons.arrow_back, size: 12,),
                        Icon(Icons.arrow_forward, size: 12,) ],
                    ),
                  ),
                  const SizedBox(width: 16,),
                  Text(yourTrLangItem.originalMenuDisplayStr,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: isSelected ? Colors.green : Colors.black87),
                  ),
                ],
              ),
            ),
          ),
          trailing: isSelected ? null :
          InkWell(
              onTap: (){
                dataControl.removeRecentLanguagePairsIfExist(myTrLangItem.translateLanguage, yourTrLangItem.translateLanguage);
                setState(() {

                });
              },
              child: const Padding(
                padding: EdgeInsets.only(top: 20, bottom: 20, left: 4, right: 4),
                child: Icon(CupertinoIcons.xmark, size: 15,),
              )),
        ),
        const SimpleSeparator(color: Colors.black12, height: 1.2, top: 0, bottom: 0),
      ],
    );
  }
}
