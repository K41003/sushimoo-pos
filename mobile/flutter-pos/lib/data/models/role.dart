class Role {
  final int idRole;
  final String namaRole;
  final String? deskripsi;

  const Role({required this.idRole, required this.namaRole, this.deskripsi});

  factory Role.fromJson(Map<String, dynamic> json) => Role(
        idRole: json['id_role'] as int,
        namaRole: json['nama_role'] as String,
        deskripsi: json['deskripsi'] as String?,
      );
}
