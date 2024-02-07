import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../helper/auth_pref_helper.dart';

class KaryawanDeleteService {
  final url = 'http://192.168.2.155:8000/user/hr/delete_karyawan';
  Dio dio = Dio();
  final pref = Get.find<AuthStorageHelper>();

  // KaryawanDeleteService(KaryawanDelete);

  Future KaryawanDelete(int idKaryawan) async {
    try {
      final tokenResponse = '';
      final tokenJson = jsonDecode(tokenResponse);
      final token = tokenJson['access_token'];
      final headers = {
        "Authorization": 'Bearer $token',
      };
      final response = await dio.delete(url,
          options: Options(
            headers: headers,
          ),
          queryParameters: {
            'id_karyawan': idKaryawan
          },
          data: {
            'id_karyawan': idKaryawan,
          });
      print(response.statusCode);
      if (response.statusCode == 200) {
        print('berhasil di hapus');
      } else {
        print('gagal dihapus');
      }
    } on DioError catch (e) {
      print(e.error);
      print(e.message);
      print(e.response);
    }
  }
}
