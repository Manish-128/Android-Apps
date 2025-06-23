class Code {
  int? id;
  String? title; // New field for the code snippet title
  String content;
  String? analysis;

  Code({this.id, this.title, required this.content, this.analysis});

  Map<String, dynamic> toMap() {
    final map = {
      'title': title,
      'content': content,
    };
    if (id != null) {
      map['id'] = id.toString();
    }
    if (analysis != null) {
      map['analysis'] = analysis;
    }
    return map;
  }

  factory Code.fromMap(Map<String, dynamic> map) {
    return Code(
      id: map['id'] != null ? int.parse(map['id'].toString()) : null,
      title: map['title'],
      content: map['content'] ?? '',
      analysis: map['analysis'],
    );
  }
}