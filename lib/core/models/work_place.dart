class Workplace {
  const Workplace({
    required this.name,
    required this.description,
    required this.uid,
  });

  final String uid;
  final String name;
  final String description;

  Map<String, dynamic> toMap() {
    return {'uid': uid, 'name': name, 'description': description};
  }

  factory Workplace.fromMap(Map<String, dynamic> map, String id) => Workplace(
    uid: id,
    name: map['name'] as String,
    description: map['description'] as String,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Workplace && other.uid == uid);

  @override
  int get hashCode => uid.hashCode;
}
