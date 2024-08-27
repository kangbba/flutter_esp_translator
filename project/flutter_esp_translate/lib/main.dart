import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/translation_page_voice_mode.dart';

import 'services/data_control.dart';
import 'languages/language_control.dart';

void main() async {
  // 플러그인 초기화
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LanguageControl>(
          create: (_) => LanguageControl.getInstance(),
        ),
        ChangeNotifierProvider<DataControl>(
          create: (_) => DataControl.getInstance(),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
          fontFamily: 'NotoSans',
          // 나머지 테마 설정들...
        ),
        debugShowCheckedModeBanner: false,
        home: const TranslatePageVoiceMode(),
      ),
    );
  }
}
