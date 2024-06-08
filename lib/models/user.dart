class User {
  final String id;
  final String email;
  final String username;
  final String address;
  final String phoneNumber;
  final String idNumber;
  final String region;
  final String gender;

  User({
    required this.id,
    required this.email,
    this.username = '',
    this.address = '',
    this.phoneNumber = '',
    this.idNumber = '',
    this.region = '',
    this.gender = '',
  });

  factory User.fromMap(Map<String, dynamic> data, String id) {
    return User(
      id: id,
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      address: data['address'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      idNumber: data['idNumber'] ?? '',
      region: data['region'] ?? '',
      gender: data['gender'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'address': address,
      'phoneNumber': phoneNumber,
      'idNumber': idNumber,
      'region': region,
      'gender': gender,
    };
  }
}
