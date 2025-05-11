import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final ThemeData knowledgeAITheme = ThemeData(
  useMaterial3: true,

  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF37474F),
    onPrimary: Colors.white,
    secondary: Color(0xFF546E7A),
    onSecondary: Colors.white,
    background: Color(0xFFF5F5F5),
    onBackground: Color(0xFF212121),
    surface: Colors.white,
    onSurface: Color(0xFF212121),
    error: Color(0xFFB00020),
    onError: Colors.white,
  ),

  scaffoldBackgroundColor: const Color(0xFFF5F5F5),

  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF37474F),
    foregroundColor: Colors.white,
    elevation: 0,
    systemOverlayStyle: SystemUiOverlayStyle.dark,
  ),

  textTheme: const TextTheme(
    displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
    headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF546E7A),
      foregroundColor: Colors.white,
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      elevation: 1,
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFF546E7A),
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    ),
  ),

  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(4)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(4)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(4)),
      borderSide: BorderSide(color: Color(0xFF37474F)),
    ),
    labelStyle: TextStyle(color: Color(0xFF546E7A)),
  ),

  cardTheme: const CardTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(4)),
    ),
    elevation: 2,
    margin: EdgeInsets.all(8),
  ),
);
