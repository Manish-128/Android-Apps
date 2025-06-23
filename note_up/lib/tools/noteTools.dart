import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NoteTools {
  void copyFunction(BuildContext context, {required TextEditingController controller}) {
    final text = controller.text;
    final selection = controller.selection;

    String selectedText;

    if (selection.isValid && !selection.isCollapsed) {
      selectedText = text.substring(selection.start, selection.end);
    } else {
      selectedText = text;
    }

    Clipboard.setData(ClipboardData(text: selectedText));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Copied!')));
  }

  Future<void> pasteFunction(BuildContext context, {required TextEditingController controller}) async {
    final clipboardData = await Clipboard.getData('text/plain');
    if (clipboardData == null || clipboardData.text == null) return;

    final pasteText = clipboardData.text!;
    final text = controller.text;
    final selection = controller.selection;

    final newText = text.replaceRange(
      selection.start,
      selection.end,
      pasteText,
    );

    final cursorPosition = selection.start + pasteText.length;

    controller.value = controller.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pasted!')));
  }
}
