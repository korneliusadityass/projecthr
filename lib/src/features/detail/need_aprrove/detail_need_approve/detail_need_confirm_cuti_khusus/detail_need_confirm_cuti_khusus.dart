import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../../../util/navhr.dart';
import '../../../../../core/colors/color.dart';
import '../../../../../core/model/approval/cuti_khusus/cuti_khusus_attachment_need_confirm_model.dart';
import '../../../../../core/model/approval/cuti_khusus/cuti_khusus_detail_need_confirm_model.dart';
import '../../../../../core/model/pengajuan_pembatalan/cuti_khusus/cuti_khusus_attachment_model.dart';
import '../../../../appbar/custom_appbar_widget.dart';
import '../../../../pengajuan_hr/cuti_khusus/widget/hr_cuti_khusus_controller.dart';
import '../../need_confirm_cuti_khusus/widgets/need_confirm_cuti_khusus_controller.dart';
import 'widgets/detail_need_confirm_cuti_khusus_controller.dart';

class DetailNeedConfirmCutiKhusus extends StatefulWidget {
  const DetailNeedConfirmCutiKhusus({super.key});

  @override
  State<DetailNeedConfirmCutiKhusus> createState() => _DetailNeedConfirmCutiKhususState();
}

class _DetailNeedConfirmCutiKhususState extends State<DetailNeedConfirmCutiKhusus> {
  final args = Get.arguments;
  final TextEditingController judulcutiController = TextEditingController();
  final TextEditingController tanggalAwalController = TextEditingController();
  final TextEditingController tanggalAkhirController = TextEditingController();
  final TextEditingController jumlahHariController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final disabledUpload = {'Refused', 'Cancelled'};

  final detailNeedConfirmCutiKhususcontroller = Get.find<DetailNeedConfirmCutiKhususController>();
  final getAttachmentEditCutiKhususController = Get.find<GetattachmentApprovalCutiKhususController>();
  final approveRefuseCutiKhususController = Get.find<NeedConfirmCutiKhususController>();
  final hrDownloadAttachmentCutiKhususController = Get.find<HrCutiKhususController>();

  FilePickerResult? result;
  bool isLoading = false;
  List<File>? files;
  int maxFiles = 5;
  int maxFileSize = 10485760;

  String? errorMessage;

  Map<String, dynamic> dataLogCutiKhusus = {};
  Future<Map<String, dynamic>>? _futureData;
  List<Map<String, dynamic>> filesData = [];
  List<Map<String, dynamic>> combinedList = [];

  late Future<DetailNeedCutiKhususModel> _fetchDataCutiKhusus;
  late List<AttachmentNeedConfirmCutiKhususModel> resultAttachment;

  Future getAttachment(int id) async {
    resultAttachment = await getAttachmentEditCutiKhususController.attach(args);
  }

  Future downAttach(int idFile, String fileName, BuildContext context) async {
    await hrDownloadAttachmentCutiKhususController.downloadAttachment(
        idFile, fileName, context);
  }

  Future<Map<String, dynamic>> getData() async {
    final value1 = await _fetchDataCutiKhusus;
    final value2 = await getAttachment(args);
    return {
      'value1': value1,
      'value2': value2,
    };
  }

  @override
  void initState() {
    super.initState();
    _fetchDataCutiKhusus = detailNeedConfirmCutiKhususcontroller.execute(args);
    getAttachment(args);
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Scaffold(
          appBar: CustomAppBarWidget(),
          drawer: const NavHr(),
          body: FutureBuilder(
            future: getData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return const Text('Error fetching data');
              } else {
                final hasil = snapshot.data!;
                DetailNeedCutiKhususModel? data = hasil['value1'];
                CutiKhususAttachmentModel? data2 = hasil['value2'];
                judulcutiController.text = data!.judul;
                jumlahHariController.text = data.jumlahHari.toString();

                final dynamic inputDateAwalString = data.tanggalAwal.toString();
                final inputDateAwalFormat = DateFormat('yyyy-MM-dd');
                final outputDateAwalFormat = DateFormat('d/M/y');
                final inputDateAwal = inputDateAwalFormat.parse(inputDateAwalString);
                final outputDateAwalString = outputDateAwalFormat.format(inputDateAwal);
                tanggalAwalController.text = outputDateAwalString;

                final dynamic inputDateAkhirString = data.tanggalAkhir.toString();
                final inputDateAkhirFormat = DateFormat('yyyy-MM-dd');
                final outputDateAkhirFormat = DateFormat('d/M/y');
                final inputDateAkhir = inputDateAkhirFormat.parse(inputDateAkhirString);
                final outputDateAkhirString = outputDateAkhirFormat.format(inputDateAkhir);
                tanggalAkhirController.text = outputDateAkhirString;

                // Attachment
                final filesData = resultAttachment.map((data2) {
                  return {
                    'id': data2.id,
                    'path': data2.namaAttachment,
                  };
                }).toList();
                combinedList = [
                  ...filesData,
                  ...?files?.map((file) => {'path': file.path}),
                ];
                return Form(
                  key: formKey,
                  child: ListView(
                    padding: const EdgeInsets.only(
                      top: 20,
                      right: 20,
                      left: 20,
                      bottom: 50,
                    ),
                    children: [
                      const Text(
                        'Detail Need Confirm Cuti Khusus',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'Judul Cuti Khusus',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: kBlackColor,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: 270,
                        height: 35,
                        child: TextFormField(
                          enabled: false,
                          keyboardType: TextInputType.none,
                          controller: judulcutiController,
                          decoration: InputDecoration(
                            disabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                              color: kBlackColor,
                              width: 1,
                            )),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            contentPadding: const EdgeInsets.fromLTRB(10, 10, 0, 5),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(
                                width: 1,
                                color: kBlackColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tanggal Awal',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(
                                  height: 1,
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: TextFormField(
                                    enabled: false,
                                    textAlign: TextAlign.center,
                                    textAlignVertical: TextAlignVertical.center,
                                    controller: tanggalAwalController,
                                    keyboardType: TextInputType.none,
                                    decoration: InputDecoration(
                                      disabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: kBlackColor,
                                          width: 1,
                                        ),
                                      ),
                                      fillColor: Colors.white24,
                                      filled: true,
                                      contentPadding: const EdgeInsets.all(0),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: const BorderSide(
                                          width: 1,
                                          color: kBlackColor,
                                        ),
                                      ),
                                    ),
                                    onTap: () {},
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 19,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tanggal Akhir',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(
                                  height: 1,
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: TextFormField(
                                    enabled: false,
                                    textAlign: TextAlign.center,
                                    textAlignVertical: TextAlignVertical.center,
                                    controller: tanggalAkhirController,
                                    keyboardType: TextInputType.none,
                                    decoration: InputDecoration(
                                      disabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: kBlackColor,
                                          width: 1,
                                        ),
                                      ),
                                      fillColor: Colors.white24,
                                      filled: true,
                                      contentPadding: const EdgeInsets.all(0),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: const BorderSide(
                                          width: 1,
                                          color: kBlackColor,
                                        ),
                                      ),
                                    ),
                                    onTap: () {},
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 19,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Hari',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(
                                  height: 1,
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: TextFormField(
                                    enabled: false,
                                    textAlign: TextAlign.center,
                                    textAlignVertical: TextAlignVertical.center,
                                    keyboardType: TextInputType.none,
                                    controller: jumlahHariController,
                                    decoration: InputDecoration(
                                      disabledBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                        color: kBlackColor,
                                        width: 1,
                                      )),
                                      fillColor: Colors.white24,
                                      filled: true,
                                      contentPadding: const EdgeInsets.all(0),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: const BorderSide(
                                          width: 1,
                                          color: kBlackColor,
                                        ),
                                      ),
                                      hintStyle: const TextStyle(
                                        color: kBlackColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('File Lampiran Opsional'),
                          const SizedBox(
                            height: 5,
                          ),
                          Center(
                            child: isLoading
                                ? const CircularProgressIndicator()
                                : ListView(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    children: combinedList
                                        .asMap()
                                        .map(
                                          (index, file) => MapEntry(
                                            index,
                                            Container(
                                              // padding: const EdgeInsets.all(15),
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  bottom: BorderSide(
                                                    color: Colors.grey.shade400,
                                                    width: 1,
                                                  ),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text('${index + 1}. ${file['path'].split('/').last}'),
                                                  ),
                                                  IconButton(
                                                  onPressed: () async {
                                                    if (!Platform.isAndroid) {
                                                      return;
                                                    }

                                                    var status =
                                                        await Permission.storage
                                                            .request();

                                                    if (status
                                                        .isPermanentlyDenied) {
                                                      var newStatus =
                                                          await Permission
                                                              .manageExternalStorage
                                                              .request();
                                                      if (!newStatus
                                                          .isRestricted) {
                                                        status = newStatus;
                                                      }
                                                    }

                                                    if (status.isGranted) {
                                                      if (context.mounted) {
                                                        downAttach(
                                                          file['id'],
                                                          file['path'],
                                                          context,
                                                        );
                                                      }
                                                    }

                                                    if (status
                                                        .isPermanentlyDenied) {
                                                      if (context.mounted) {
                                                        showDialog(
                                                            context: context,
                                                            builder: (context) {
                                                              return Dialog(
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                ),
                                                                child:
                                                                    Container(
                                                                  width: 278,
                                                                  height: 270,
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                      color: Colors
                                                                          .white),
                                                                  child: Column(
                                                                    children: [
                                                                      Container(
                                                                        width: double
                                                                            .infinity,
                                                                        height:
                                                                            31,
                                                                        decoration:
                                                                            const BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.vertical(
                                                                            top:
                                                                                Radius.circular(8),
                                                                          ),
                                                                          color:
                                                                              kRedColor,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            15,
                                                                      ),
                                                                      const Icon(
                                                                        Icons
                                                                            .warning_amber,
                                                                        color:
                                                                            kRedColor,
                                                                        size:
                                                                            80,
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            15,
                                                                      ),
                                                                      const Text(
                                                                        'Tidak mendapatkan akses\nuntuk menulis file',
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style:
                                                                            TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.w400,
                                                                          fontSize:
                                                                              16,
                                                                          color:
                                                                              kBlackColor,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            24,
                                                                      ),
                                                                      ElevatedButton(
                                                                        style: ElevatedButton
                                                                            .styleFrom(
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(8),
                                                                          ),
                                                                          backgroundColor:
                                                                              kRedColor,
                                                                          fixedSize: const Size(
                                                                              120,
                                                                              45),
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          openAppSettings();
                                                                        },
                                                                        child:
                                                                            const Text(
                                                                          'Buka Setting',
                                                                          style:
                                                                              TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            fontSize:
                                                                                20,
                                                                            color:
                                                                                kWhiteColor,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            });
                                                      }
                                                    }
                                                  },
                                                  icon: const Icon(
                                                      Icons.download),
                                                ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                        .values
                                        .toList(),
                                  ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: double.infinity,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: kLightOrangeColor,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              data.status,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: kNormalOrangeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              fixedSize: const Size(108, 22),
                              backgroundColor: kLightRedColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                            onPressed: () async {
                              Navigator.pop(context);
                              await approveRefuseCutiKhususController.cutiKhususRefuse(data.id);
                            },
                            child: const Text(
                              'Refuse',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kBlackColor),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              fixedSize: const Size(108, 22),
                              backgroundColor: kLightGreenColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                            onPressed: () async {
                              Navigator.pop(context);
                              await approveRefuseCutiKhususController.cutiKhususApproved(data.id);
                            },
                            child: const Text(
                              'Approve',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kBlackColor),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}
