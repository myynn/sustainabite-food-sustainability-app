import 'dart:async';
import 'package:flutter/material.dart';

//this is for the theme colour change in my settings
// this theme service manages and broadcast them colour changes across the application using streamcontroller
class ThemeService {
  StreamController<Color> themeStreamController = StreamController<Color>.broadcast();

  Stream<Color> getThemeStream() { //this returns the theme stream so widgets can subsrcibe and rebuild when the theme colour chagnes
  return themeStreamController.stream;
  }
//this updates the current theme colour, selecttheme is the new colour to apply
  void setTheme (Color selectedTheme, String stringTheme) {
    themeStreamController.add(selectedTheme); //this sends the new colour to all listeners
    debugPrint('Theme: ' + stringTheme);
  }
}