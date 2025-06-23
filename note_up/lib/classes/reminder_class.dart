class Reminder{
  int? id;
  String title;
  String time;
  String date;

  Reminder({required this.title, required this.time, required this.date,this.id});


  Map<String, dynamic> toMap() {
    final map = {
      'title': title,
      'time': time,
      'date':date,
    };
    if (id != null) {
      map['id'] = id.toString();
    }
    return map;
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      title: map['title'],
      time: map['time'],
      date: map['date'],

    );
  }
}