// To parse this JSON data, do
//
//     final hrListIzinSakitModel = hrListIzinSakitModelFromJson(jsonString);

import 'dart:convert';

class HrListIzinSakitModel {
  final int id;
  final String judul;
  final String namaKaryawan;
  final DateTime tanggalAwal;
  final DateTime tanggalAkhir;
  final int jumlahHari;
  final String status;

  HrListIzinSakitModel({
    required this.id,
    required this.judul,
    required this.namaKaryawan,
    required this.tanggalAwal,
    required this.tanggalAkhir,
    required this.jumlahHari,
    required this.status,
  });

  factory HrListIzinSakitModel.fromRawJson(String str) =>
      HrListIzinSakitModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory HrListIzinSakitModel.fromJson(Map<String, dynamic> json) =>
      HrListIzinSakitModel(
        id: json["id"],
        judul: json["judul"],
        namaKaryawan: json["nama_karyawan"],
        tanggalAwal: DateTime.parse(json["tanggal_awal"]),
        tanggalAkhir: DateTime.parse(json["tanggal_akhir"]),
        jumlahHari: json["jumlah_hari"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "judul": judul,
        "nama_karyawan": namaKaryawan,
        "tanggal_awal":
            "${tanggalAwal.year.toString().padLeft(4, '0')}-${tanggalAwal.month.toString().padLeft(2, '0')}-${tanggalAwal.day.toString().padLeft(2, '0')}",
        "tanggal_akhir":
            "${tanggalAkhir.year.toString().padLeft(4, '0')}-${tanggalAkhir.month.toString().padLeft(2, '0')}-${tanggalAkhir.day.toString().padLeft(2, '0')}",
        "jumlah_hari": jumlahHari,
        "status": status,
      };
}
