// void addNote() async {
//   final note = Note(title: 'My Note', content: 'This is a note');
//   await NoteDatabase.instance.createNote(note);
// }
//
// void fetchNotes() async {
//   final notes = await NoteDatabase.instance.readAllNotes();
//   notes.forEach((note) {
//     print('${note.id}: ${note.title} - ${note.content}');
//   });
// }
//
// void updateNote() async {
//   final note = Note(id: 1, title: 'Updated', content: 'Updated content');
//   await NoteDatabase.instance.updateNote(note);
// }
//
// void deleteNote() async {
//   await NoteDatabase.instance.deleteNote(1);
// }