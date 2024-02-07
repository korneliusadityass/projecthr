import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/src/core/colors/color.dart';
import 'package:project/src/core/model/hr_pengajuan_pembatalan/cuti_khusus/hr_list_karyawan_model.dart';
import 'package:project/src/core/model/hr_pengajuan_pembatalan/izin_3_jam/list_hr_izin_3_jam_model.dart';
import 'package:project/src/core/routes/routes.dart';
import 'package:project/src/core/services/pengajuan_hr_services/izin_3_jam_services/hr_input_izin_3_jam_service.dart';
import 'package:project/src/core/services/pengajuan_hr_services/izin_3_jam_services/hr_izin_3_jam_list_service.dart';
import 'package:project/src/core/services/pengajuan_hr_services/izin_3_jam_services/hr_list_karyawan_service.dart';

import '../../../../core/services/pengajuan_hr_services/izin_3_jam_services/hr_cancelled_izin_3_jam_service.dart';

class ListIzin3JamHrController extends GetxController
    with StateMixin<List<ListHrIzin3JamModel>> {
  Izin3JamListHrService service;
  ListIzin3JamHrController(this.service);

  RxBool isFetchData = false.obs;
  RxInt pageSize = 10.obs;
  RxInt pageNum = 1.obs;
  RxString filterStatus2 = 'All'.obs;

  RxList<ListHrIzin3JamModel> dataIzin3Jam = <ListHrIzin3JamModel>[].obs;

  Future<List<ListHrIzin3JamModel>> execute({
    int page = 1,
    int size = 10,
    String filterStatus = 'All',
    String? tanggalAwal,
    String? tanggalAkhir,
  }) async {
    isFetchData.value = true;
    final result = await service.fetchIzin3Jam(
      filterStatus: filterStatus2.value,
      page: pageNum.value,
      size: pageSize.value,
      tanggalAkhir: tanggalAkhir,
      tanggalAwal: tanggalAwal,
    );
    dataIzin3Jam.value = result;
    isFetchData.value = false;
    return result;
  }

  @override
  void onInit() {
    super.onInit();
    execute();
  }

  // @override
  // void onInit() {
  //   super.onInit();
  //   execute().then((value) {
  //     change(dataIzin3Jam.value = value, status: RxStatus.success());
  //   }).catchError((e) {
  //     change(null, status: RxStatus.error(e.toString()));
  //   }).whenComplete(() => isFetchData.value = false);
  // }
}

class HrPengajuanIzin3JamController extends GetxController
    with StateMixin<int> {
  HrPengajuanIzin3JamService service;
  HrPengajuanIzin3JamController(this.service);

  RxInt id = 0.obs;

  Future pengajuan(
    int id,
    String judul,
    String tanggalIjin,
    String waktuAwal,
    String waktuAkhir,
  ) async {
    try {
      final result = await service.pengajuanIzin3Jam(
        id,
        judul,
        tanggalIjin,
        waktuAwal,
        waktuAkhir,
      );
      result.fold((failure) {
        Get.dialog(Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            width: 278,
            height: 270,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), color: Colors.white),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 31,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                    color: kRedColor,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                const Icon(
                  Icons.warning_amber,
                  color: kRedColor,
                  size: 80,
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  'Hari yang diinput\ntelah diisi',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: kBlackColor,
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: kRedColor,
                    fixedSize: const Size(120, 45),
                  ),
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text(
                    'Oke',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                      color: kWhiteColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
      }, (success) async {
        await Get.toNamed(Routes.pageHrDetailIzin3Jam, arguments: success);
      });
    } catch (e) {
      Get.snackbar('Terjadi kesalahan', e.toString());
    }
  }
}

class HrListKaryawanController extends GetxController
    with StateMixin<List<HrListKaryawanModel>> {
  HrListKaryawanService service;
  HrListKaryawanController(this.service);

  RxBool isFetchData = true.obs;

  RxList<HrListKaryawanModel> dataKaryawan = <HrListKaryawanModel>[].obs;

  Future<List<HrListKaryawanModel>> execute({
    String? filterNama,
  }) async {
    return await service.listKaryawan(
      filterNama: filterNama,
    );
  }

  @override
  void onInit() {
    super.onInit();
    execute().then((value) {
      change(dataKaryawan.value = value, status: RxStatus.success());
    }).catchError((e) {
      change(null, status: RxStatus.error(e.toString()));
    }).whenComplete(() => isFetchData.value = false);
  }
}

class HrCancelPengajuanIzin3JamController extends GetxController {
  HrCancelledIzin3JamService service;
  HrCancelPengajuanIzin3JamController(this.service);

  Future cancelIzin3Jam(int id) async {
    try {
      final result = await service.cancelledIzin3Jam(id);
      result.fold((failure) {
        Get.dialog(Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            width: 278,
            height: 270,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), color: Colors.white),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 31,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                    color: kRedColor,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                const Icon(
                  Icons.warning_amber,
                  color: kRedColor,
                  size: 80,
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  'Gagal cancel pengajuan\nharap coba lagi',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: kBlackColor,
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: kRedColor,
                    fixedSize: const Size(120, 45),
                  ),
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text(
                    'Oke',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                      color: kWhiteColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
      }, (success) {
        Get.find<ListIzin3JamHrController>().execute();
        Get.dialog(Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            width: 278,
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 31,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                    color: kDarkGreenColor,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                const Icon(
                  Icons.check_circle,
                  color: kGreenColor,
                  size: 80,
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  'Sukses cancel pengajuan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: kBlackColor,
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: kDarkGreenColor,
                    fixedSize: const Size(120, 45),
                  ),
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text(
                    'Oke',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                      color: kWhiteColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
      });
    } catch (e) {
      Get.snackbar('Terjadi kesalahan', e.toString());
    }
  }
}
