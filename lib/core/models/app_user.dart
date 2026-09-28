class AppUser {
  const AppUser({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.workplaceId,
  });

  final String uid;
  final String fullName;
  final String email;
  final String workplaceId;

  Map<String, dynamic> toMap() {
    return {'fullName': fullName, 'email': email, 'workplace': workplaceId};
  }

  factory AppUser.fromMap(Map<String, dynamic> map, String id) {
    return AppUser(
      uid: id,
      fullName: map['fullName'] as String,
      email: map['email'] as String,
      workplaceId: map['workplaceId'] as String,
    );
  }
}
