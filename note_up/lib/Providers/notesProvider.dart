import 'package:flutter/material.dart';
import 'package:note_up/dbs/note_db_helper.dart';

import '../classes/note_class.dart';

class NotesProvider with ChangeNotifier {
  List<Note> notes = [];

  void loadNotes() async{
    notes = await NoteDbHelper.instance.readAllNotes();
    notifyListeners();
  }// Call this once and just add in it? how's the plan?

  NotesProvider();

  List<Note> syncNotesFromScreen(){
    return notes;
  }

  // Currently we are seperating the database addition and the provider's addition
  Future<Note> addNote({required Note note}) async{
    int DbId = await NoteDbHelper.instance.createNote(note);
    loadNotes();
    notifyListeners();
    return Note(title: note.title, content: note.content, id: DbId);
  }

  void updateNote({required Note note}) async{
    await NoteDbHelper.instance.updateNote(note);
    loadNotes();
    notifyListeners();
  }

  void deleteNote({required int noteId}) async{
    await NoteDbHelper.instance.deleteNote(noteId);
    loadNotes();
    notifyListeners();
  }

//   Ill make a List in Provider
// Ill then update the list with whatever there is in the database
// Ill then use this list as the main list in the Note Screen
// Whatever that comes into or goes out of the Note Screen to the database should go with Provider
// Similarly for the New Note Creation and its updation should also happen through Provider


}
