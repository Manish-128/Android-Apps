// import 'package:flutter/material.dart';
//
// import '../classes/Code.dart';
// import '../dbs/CodeDbHelper.dart';
//
// class CodeProvider with ChangeNotifier {
//   List<Code> codes = [];
//
//   CodeProvider();
//
//   Future<void> loadCodes() async {
//     codes = await CodeModelHelper.instance.readAllCode();
//     notifyListeners();
//   }
//
//   List<Code> syncCodesFromScreen() {
//     return codes;
//   }
//
//   Future<Code> addCode({required Code code}) async {
//     int dbId = await CodeModelHelper.instance.createCode(code);
//     await loadCodes();
//     notifyListeners();
//     return Code(id: dbId, content: code.content, analysis: code.analysis);
//   }
//
//   Future<void> updateCode({required Code code}) async {
//     await CodeModelHelper.instance.updateCode(code);
//     await loadCodes();
//     notifyListeners();
//   }
//
//   Future<void> deleteCode({required int codeId}) async {
//     await CodeModelHelper.instance.deleteCode(codeId);
//     await loadCodes();
//     notifyListeners();
//   }
// }


import 'package:flutter/material.dart';
import 'package:note_up/dbs/CodeDbHelper.dart';
import 'package:note_up/classes/Code.dart';

class CodeProvider with ChangeNotifier {
  List<Code> codes = [];

  CodeProvider();

  Future<void> loadCodes() async {
    codes = await CodeModelHelper.instance.readAllCode();
    notifyListeners();
  }

  List<Code> syncCodesFromScreen() {
    return codes;
  }

  Future<Code> addCode({required Code code}) async {
    int dbId = await CodeModelHelper.instance.createCode(code);
    await loadCodes();
    notifyListeners();
    return Code(id: dbId, title: code.title, content: code.content, analysis: code.analysis);
  }

  Future<void> updateCode({required Code code}) async {
    await CodeModelHelper.instance.updateCode(code);
    await loadCodes();
    notifyListeners();
  }

  Future<void> deleteCode({required int codeId}) async {
    await CodeModelHelper.instance.deleteCode(codeId);
    await loadCodes();
    notifyListeners();
  }
}