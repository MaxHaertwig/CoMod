import 'package:flutter/material.dart';

const identifierCharactersRegex = '[0-9a-zA-Z_]';

/// Blend of TUD color (#00305D) and Flutter color (#2196F3)
const appColor = MaterialColor(0xFF1163A8, {
  50: Color.fromRGBO(_appColorR, _appColorG, _appColorB, 0.55),
  100: Color.fromRGBO(_appColorR, _appColorG, _appColorB, 0.6),
  200: Color.fromRGBO(_appColorR, _appColorG, _appColorB, 0.65),
  300: Color.fromRGBO(_appColorR, _appColorG, _appColorB, 0.7),
  400: Color.fromRGBO(_appColorR, _appColorG, _appColorB, 0.75),
  500: Color.fromRGBO(_appColorR, _appColorG, _appColorB, 0.8),
  600: Color.fromRGBO(_appColorR, _appColorG, _appColorB, 0.85),
  700: Color.fromRGBO(_appColorR, _appColorG, _appColorB, 0.9),
  800: Color.fromRGBO(_appColorR, _appColorG, _appColorB, 0.95),
  900: Color.fromRGBO(_appColorR, _appColorG, _appColorB, 1),
});

const _appColorR = 17;
const _appColorG = 99;
const _appColorB = 168;

const menuTextColor = Color(0xFF00305D);
