class ServiceLocation {
  const ServiceLocation({
    this.id,
    required this.name,
    required this.description,
    required this.coordinator,
  });

  final int? id;
  final String name;
  final String description;
  final String coordinator;

  String get displayText => '$name - $coordinator';

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'coordinator': coordinator,
    };
  }

  factory ServiceLocation.fromMap(Map<String, Object?> map) {
    return ServiceLocation(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      coordinator: map['coordinator'] as String? ?? '',
    );
  }

  factory ServiceLocation.fromJoinedMap(Map<String, Object?> map) {
    return ServiceLocation(
      id: (map['service_location_id'] as int?) ??
          (map['user_service_location_id'] as int?),
      name: (map['service_location_name'] as String?) ??
          (map['work_location'] as String?) ??
          '',
      description: (map['service_location_description'] as String?) ?? '',
      coordinator: (map['service_location_coordinator'] as String?) ?? '',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ServiceLocation &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.coordinator == coordinator;
  }

  @override
  int get hashCode => Object.hash(id, name, description, coordinator);
}