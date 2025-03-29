


abstract class BaseDomain {
  late int id = 0;

  BaseDomain(int id) {
    //implement derive class
    this.id = id;
  }

  bool operator ==(Object other) => other is BaseDomain && other.id == id;

  int get hashCode => id;

  String getObjDBLocation();
  Map<String, dynamic> toJson();



}