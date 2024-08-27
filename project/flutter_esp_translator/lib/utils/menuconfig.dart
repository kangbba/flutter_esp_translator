import 'package:flutter/material.dart';

const Color yourBackgroundColor = Color(0xFF4D5B65);
const Color myBackgroundColor = Color(0xFF20816F);
Color? middleColor = Color.lerp(myBackgroundColor, yourBackgroundColor, 0.5);
const int inputStrMaxLength = 3000;
const int maxRecentLanguagePairs = 3;
const int maxFavoriteLanguageCount = 5;