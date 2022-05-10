import 'package:flutter/material.dart';

ThemeData buildMyTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: const Color(0xFF9146FF)
    ),
  );
}