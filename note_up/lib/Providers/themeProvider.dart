// import 'package:flutter/material.dart';
//
// class ThemeProvider extends ChangeNotifier {
//   Color textCol = Colors.black;
//   Color? backg = Colors.white;
//   Color buttonCol = Colors.black;
//   Color inputTextCol = Colors.black;
//
//   ThemeProvider({
//     this.textCol = Colors.black,
//     this.backg = Colors.white,
//     this.buttonCol = Colors.black,
//     this.inputTextCol = Colors.black,
//   });
//
//   void changeTextCol({required Color inputCol}) async {
//     textCol = inputCol;
//     notifyListeners();
//   }
//
//   void changeBg({required Color? inputCol}) async {
//     backg = inputCol;
//     notifyListeners();
//   }
//
//   void changeButtCol({required Color inputCol}) async {
//     buttonCol = inputCol;
//     notifyListeners();
//   }
//
//   void changeInputTextCol({required Color inputCol}) async {
//     inputTextCol = inputCol;
//     notifyListeners();
//   }
// }


import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  // Theme Colors
  Color textCol = Colors.black;
  Color? backg = Colors.white;
  Color buttonCol = Colors.teal.shade800;
  Color inputTextCol = Colors.black;

  bool _isDark = false;
  bool get isDarkMode => _isDark;

  ThemeProvider({bool isDark = false}) {
    toggleTheme(isDark);
  }

  void toggleTheme(bool isDark) {
    _isDark = isDark;

    if (isDark) {
      // 🌙 Dark Mode Colors
      textCol = Colors.white;
      backg = const Color(0xFF121212); // deep grey
      buttonCol = Colors.tealAccent.shade200;
      inputTextCol = Colors.white70;
    } else {
      // ☀️ Light Mode Colors
      textCol = Colors.black87;
      backg = Colors.white;
      buttonCol = Colors.teal.shade800;
      inputTextCol = Colors.black54;
    }

    notifyListeners();
  }

  // Optional if you want separate setters:
  void changeTextCol({required Color inputCol}) {
    textCol = inputCol;
    notifyListeners();
  }

  void changeBg({required Color? inputCol}) {
    backg = inputCol;
    notifyListeners();
  }

  void changeButtCol({required Color inputCol}) {
    buttonCol = inputCol;
    notifyListeners();
  }

  void changeInputTextCol({required Color inputCol}) {
    inputTextCol = inputCol;
    notifyListeners();
  }
}
