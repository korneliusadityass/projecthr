import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:project/src/core/error/failure.dart';
import 'package:project/src/core/services/dio_clients.dart';

import '../../../model/laporan/cuti_khusus/list_laporan_cuti_khusus_model.dart';

class ExportLaporanCutiKhususService {
  DioClients dio;
  ExportLaporanCutiKhususService(this.dio);

  Future<Either<Failure, List<ListLaporanCutiKhususModel>>>
      exportLaporanCutiKhusus(
    int id, {
    String filterStatus = 'All',
    String? filterNama,
    String? tanggalAwal,
    String? tanggalAkhir,
  }) async {
    try {
      final queryParameters = {
        'id_perusahaan': id,
        'filter_status': filterStatus,
        if (filterNama != null) 'filter_nama': filterNama,
        if (tanggalAwal != null) 'filter_tanggal_awal': tanggalAwal,
        if (tanggalAkhir != null) 'filter_tanggal_akhir': tanggalAkhir,
      };

      final response = await dio.dio.get(
        '/laporan/cuti_khusus/export',
        queryParameters: queryParameters,
      );
      List result = response.data;

      return right(
        result
            .map((data) => ListLaporanCutiKhususModel.fromJson(data))
            .toList(),
      );
    } on DioError catch (e) {
      String errorMessage = e.response?.data['detail'] ?? "gagal confirm";
      return Left(ConfirmIzin3JamFailure(errorMessage));
    }
  }
}
