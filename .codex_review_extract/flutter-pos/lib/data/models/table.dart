class TableModel {
  final int idMeja;
  final String nomorMeja;
  final int kapasitas;
  final String status;

  const TableModel({
    required this.idMeja,
    required this.nomorMeja,
    required this.kapasitas,
    required this.status,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) => TableModel(
        idMeja: json['id_meja'] as int,
        nomorMeja: json['nomor_meja'] as String,
        kapasitas: json['kapasitas'] as int,
        status: json['status'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id_meja': idMeja,
        'nomor_meja': nomorMeja,
        'kapasitas': kapasitas,
        'status': status,
      };
}
