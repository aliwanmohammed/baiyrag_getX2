enum UserRole { customer, admin, delivery }

class UserModel {
  final String id;
  final String name;
  final String? phone;
  final String email;
  final UserRole role;
  final String? token;

  const UserModel({
    required this.id,
    required this.name,
    this.phone,
    required this.email,
    required this.role,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id']?.toString() ?? '',
        name: json['name'] ?? '',
        phone: json['phone'],
        email: json['email'] ?? '',
        role: UserRole.values.firstWhere(
          (r) => r.name == (json['role'] ?? 'customer'),
          orElse: () => UserRole.customer,
        ),
        token: json['token'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'role': role.name,
        'token': token,
      };

  bool get isAdmin => role == UserRole.admin;
  bool get isDelivery => role == UserRole.delivery;
  bool get isCustomer => role == UserRole.customer;
}
