class UserModel {
  final String uid;
  final String email;
  final String name;
  final int heightCm;
  final double weightKg;
  final int bottleSizeMl; 
  final String? currentIllness;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.heightCm = 170,
    this.weightKg = 60.0,
    this.bottleSizeMl = 1000,
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
      heightCm: map['heightCm'] ?? 170,
      weightKg: (map['weightKg'] ?? 60.0).toDouble(),
      bottleSizeMl: map['bottleSizeMl'] ?? 1000,
      currentIllness: map['currentIllness'],
    );
  }
}