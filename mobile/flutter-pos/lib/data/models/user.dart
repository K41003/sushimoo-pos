import 'role.dart';

class User {
  final int idUser;
  final int idRole;
  final String nama;
  final String username;
  final bool status;
  final Role? role;

  const User({
    required this.idUser,
    required this.idRole,
    required this.nama,
    required this.username,
    required this.status,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        idUser: json['id_user'] as int,
        idRole: json['id_role'] as int,
        nama: json['nama'] as String,
        username: json['username'] as String,
        status: json['status'] == 1 || json['status'] == true,
        role: json['role'] != null
            ? Role.fromJson(json['role'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id_user': idUser,
        'id_role': idRole,
        'nama': nama,
        'username': username,
        'status': status,
        'role': role?.toJson(),
      };

  String get roleName => role?.namaRole ?? '';
  bool get isAdmin => roleName == 'Admin';
  bool get isKasir => roleName == 'Kasir';
}

extension _RoleX on Role {
  Map<String, dynamic> toJson() =>
      {'id_role': idRole, 'nama_role': namaRole, 'deskripsi': deskripsi};
}
