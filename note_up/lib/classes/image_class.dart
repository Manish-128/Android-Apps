class ImageClass {
  int? id;
  String? imageOne;
  String? imageTwo;
  String? imageThree;

  ImageClass({
    this.id,
    this.imageOne,
    this.imageTwo,
    this.imageThree,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    if (imageOne != null) {
      map['imageOne'] = imageOne!;
    }
    if (imageTwo != null) {
      map['imageTwo'] = imageTwo!;
    }
    if (imageThree != null) {
      map['imageThree'] = imageThree!;
    }
    if (id != null) {
      map['id'] = id; // keep it as int
    }

    return map;
  }

  factory ImageClass.fromMap(Map<String, dynamic> map) {
    return ImageClass(
      id: map['id'] as int?,
      imageOne: map['imageOne'] as String?,
      imageTwo: map['imageTwo'] as String?,
      imageThree: map['imageThree'] as String?,
    );
  }
}
