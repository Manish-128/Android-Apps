class Note {
  int? id; // <--- make nullable
  String title;
  String content;
  int? imgKey;

  Note({this.id, required this.title, required this.content, this.imgKey});

  Map<String, dynamic> toMap() {
    final map = {
      'title': title,
      'content': content,
    };
    if (id != null) {
      map['id'] = id.toString();
    }
    if (imgKey != null) {
      map['imgKey'] = imgKey.toString();
    }
    return map;
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      imgKey: map['imgKey'],
    );
  }
}
