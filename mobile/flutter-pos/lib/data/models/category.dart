class Category {
  final int idKategori;
  final String namaKategori;
  final String? deskripsi;
  final bool status;

  const Category({
    required this.idKategori,
    required this.namaKategori,
    this.deskripsi,
    required this.status,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        idKategori: json['id_kategori'] as int,
        namaKategori: json['nama_kategori'] as String,
        deskripsi: json['deskripsi'] as String?,
        status: json['status'] == 1 || json['status'] == true,
      );

  Map<String, dynamic> toJson() => {
        'id_kategori': idKategori,
        'nama_kategori': namaKategori,
        'deskripsi': deskripsi,
        'status': status ? 1 : 0,
      };
}
