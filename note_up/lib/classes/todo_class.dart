import 'package:flutter/material.dart';

class toDOList{
  int? id;
  String title;
  String workList;

  toDOList({this.id ,required this.title, required this.workList});

  Map<String, dynamic> toMap() {
    final map = {
      'title': title,
      'workList': workList,
    };
    if (id != null) {
      map['id'] = id.toString();
    }
    return map;
  }

  factory toDOList.fromMap(Map<String, dynamic> map) {
    return toDOList(
      id: map['id'],
      title: map['title'],
      workList: map['workList'],
    );
  }

}