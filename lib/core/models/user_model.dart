class UserModel {
  final String uid;
  final String email;
  final String name;
  final double heightCm;
  final double weightKg;
  final int bottleSizeMl; 
  final String? currentIllness;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.heightCm = 0,
    this.weightKg = 0.0,
    this.bottleSizeMl = 500,
    this.currentIllness,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'bottleSizeMl': bottleSizeMl,
      'currentIllness': currentIllness,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? 'Student',
      heightCm: map['heightCm'] ?? 0,
      weightKg: (map['weightKg'] ?? 0),
      bottleSizeMl: map['bottleSizeMl'] ?? 500,
      currentIllness: map['currentIllness'],
    );
  }
}