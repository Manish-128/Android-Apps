
import 'package:flutter/cupertino.dart';

class MenuProvider extends ChangeNotifier {
  int selectedIndex = 69;

  MenuProvider({this.selectedIndex = 69});

  void changeIndex({required int inputIndex}) async {
    selectedIndex = inputIndex;
    notifyListeners();
  }
}