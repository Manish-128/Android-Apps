import 'dart:io';

class WatchListClass {
  String title;
  int year;
  String image; // store file path as string
  int? id;

  WatchListClass({
    this.id,
    required this.title,
    required this.year,
    required this.image,
  });

  Map<String, dynamic> toMap() {
    final map = {
      'title': title,
      'year': year,
      'image': image,
    };
    if (id != null) map['id'] = id.toString();  //TODO: Watch Maybe TroubleSome
    return map;
  }

  factory WatchListClass.fromMap(Map<String, dynamic> map) {
    return WatchListClass(
      id: map['id'],
      title: map['title'],
      year: map['year'],
      image: map['image'],
    );
  }
}
