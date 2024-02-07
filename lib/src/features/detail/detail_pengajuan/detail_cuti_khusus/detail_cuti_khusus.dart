import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../util/drawerBuilder.dart';
import '../../../../core/colors/color.dart';
import '../../../../core/model/pengajuan_pembatalan/cuti_khusus/cuti_khusus_detail_model.dart';
import '../../../appbar/appbar_controller.dart';
import '../../../appbar/custom_appbar_widget.dart';
import 'widgets/detail_cuti_khusus_controller.dart';

class DetailCutiKhusus extends StatefulWidget {
  const DetailCutiKhusus({super.key});

  @override
  State<DetailCutiKhusus> createState() => _DetailCutiKhususState();
}

class _DetailCutiKhususState extends State<DetailCutiKhusus> {
  final args = Get.arguments;

  final cutiKhususDetailController = Get.find<DetailCutiKhususController>();

  final TextEditingController judulcutiController = TextEditingController();
  final TextEditingController tanggalAwalController = TextEditingController();
  final TextEditingController tanggalAkhirController = TextEditingController();
  final TextEditingController jumlahHariController = TextEditingController();
  final appbarController = Get.find<AppBarController>();

  String tanggalAPIAwal = '';
  String tanggalAPIAkhir = '';

  FilePickerResult? result;
  bool isLoading = false;
  List<File>? files;
  int maxFiles = 5;
  int maxFileSize = 10485760;
  String? errorMessage;

  void pickFile() async {
    try {
      isLoading = true;

      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'pdf', 'jpg'],
        allowMultiple: true,
      );
      if (result != null) {
        List<PlatformFile>? platformFiles = result!.files;
        List<File> newFiles = [];
        bool hasInvalidFile = false;
        for (PlatformFile platformFile in platformFiles) {
          if (platformFile.size <= maxFileSize) {
            File newFile = File(platformFile.path!);
            newFiles.add(newFile);
          } else {
            debugPrint('File yang diperbolehkan hanya 10mb');
            hasInvalidFile = true;
          }
        }
        if (hasInvalidFile) {
          errorMessage = 'File yang diperbolehkan hanya 10mb';
        } else if ((files?.length ?? 0) + newFiles.length <= maxFiles) {
          files ??= [];
          files!.addAll(newFiles);
          debugPrint('Selected files: $files');

          errorMessage = null;
        } else {
          debugPrint('File telah mencapai batas');

          errorMessage = 'File telah mencapai batas';

          // Add only the first 5 files if more than 5 files are selected
          int maxNewFiles = maxFiles - (files?.length ?? 0);
          if (maxNewFiles > 0) {
            files ??= [];
            files!.addAll(newFiles.take(maxNewFiles));
          }
        }
      }
      isLoading = false;
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading = false;
      setState(() {});
    }
  }

  late Future<DetailCutiKhususModel> _fetchDetailCutiKhusus;

  @override
  void initState() {
    super.initState();
    _fetchDetailCutiKhusus = cutiKhususDetailController.execute(args);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _fetchDetailCutiKhusus,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.data == null) {
            return const Center(
              child: SpinKitFadingFour(
                size: 20,
                color: kDarkBlueColor,
              ),
            );
          } else if (snapshot.hasError) {
            return const Text('Error Fetching Data');
          } else {
            DetailCutiKhususModel? data = snapshot.data;
            judulcutiController.text = data!.judul;
            jumlahHariController.text = data.jumlahHari.toString();

            final dynamic inputDateAwalString = data.tanggalAwal.toString();
            final inputDateAwalFormat = DateFormat('yyyy-MM-dd');
            final outputDateAwalFormat = DateFormat('d/M/y');
            final inputDateAwal =
                inputDateAwalFormat.parse(inputDateAwalString);
            final outputDateAwalString =
                outputDateAwalFormat.format(inputDateAwal);
            tanggalAwalController.text = outputDateAwalString;
            tanggalAPIAwal = data.tanggalAwal.toString().substring(0, 10);

            final dynamic inputDateAkhirString = data.tanggalAkhir.toString();
            final inputDateAkhirFormat = DateFormat('yyyy-MM-dd');
            final outputDateAkhirFormat = DateFormat('d/M/y');
            final inputDateAkhir =
                inputDateAkhirFormat.parse(inputDateAkhirString);
            final outputDateAkhirString =
                outputDateAkhirFormat.format(inputDateAkhir);
            tanggalAkhirController.text = outputDateAkhirString;
            tanggalAPIAkhir = data.tanggalAkhir.toString().substring(0, 10);
            return Scaffold(
              appBar: CustomAppBarWidget(),
              drawer: DrawerBuilder(
                userMe: appbarController.fetchUserMe(),
              ),
              body: ListView(
                padding: const EdgeInsets.only(
                  top: 20,
                  left: 20,
                  right: 20,
                ),
                children: [
                  const Text(
                    'Detail Cuti Khusus',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Judul Cuti Khusus',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: kBlackColor,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
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
                            contentPadding:
                                const EdgeInsets.fromLTRB(10, 10, 0, 5),
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
                    ],
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
                        width: 12,
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
                        width: 14,
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
                            : TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: kBlueColor,
                                ),
                                onPressed: () {
                                  pickFile();
                                },
                                child: const Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.cloud_upload_rounded,
                                      color: kWhiteColor,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'Pilih File',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: kWhiteColor,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      if (files != null)
                        ListView(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          children: files!
                              .asMap()
                              .map(
                                (index, file) => MapEntry(
                                  index,
                                  Container(
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
                                            child: Text(
                                                '${index + 1}. ${file.path.split('/').last}')),
                                        IconButton(
                                          onPressed: () {
                                            files!.removeAt(index);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content:
                                                    Text('File telah dihapus'),
                                              ),
                                            );
                                            setState(() {});
                                          },
                                          icon: const Icon(Icons.delete),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                              .values
                              .toList(),
                        ),
                      const SizedBox(
                        height: 5,
                      ),
                      if (errorMessage != null)
                        Text(
                          errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Container(
                    width: double.infinity,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: kLightOrangeColor,
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Draft',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: kNormalOrangeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kRedColor,
                          fixedSize: const Size(
                            101,
                            29,
                          ),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Container(
                                  width: 278,
                                  height: 250,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: kWhiteColor,
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
                                          color: kYellowColor,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 12,
                                      ),
                                      Image.asset(
                                        'assets/warning logo.png',
                                        width: 80,
                                        height: 80,
                                      ),
                                      const SizedBox(
                                        height: 7,
                                      ),
                                      const Text(
                                        'Apakah yakin ingin\nmenghapus data ini ?',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 24,
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              backgroundColor: kLightGrayColor,
                                              fixedSize: const Size(100, 35.81),
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text(
                                              'Cancel',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 20,
                                                color: kWhiteColor,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 34,
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              backgroundColor: kYellowColor,
                                              fixedSize: const Size(100, 35.81),
                                            ),
                                            onPressed: () async {
                                              // CutiKhususDeleteService()
                                              //     .cutiKhususDelete(
                                              //   idCutiKhusus,
                                              //   context,
                                              // );
                                              await cutiKhususDetailController
                                                  .cutiKhususdelete(args);
                                              // Navigator.pop(context);
                                              // showDialog(
                                              //   context: context,
                                              //   builder: (context) {
                                              //     return Dialog(
                                              //       shape: RoundedRectangleBorder(
                                              //         borderRadius:
                                              //             BorderRadius.circular(
                                              //                 8),
                                              //       ),
                                              //       child: Container(
                                              //         width: 278,
                                              //         height: 250,
                                              //         decoration: BoxDecoration(
                                              //           borderRadius:
                                              //               BorderRadius.circular(
                                              //                   8),
                                              //           color: kWhiteColor,
                                              //         ),
                                              //         child: Column(
                                              //           children: [
                                              //             Container(
                                              //               width:
                                              //                   double.infinity,
                                              //               height: 31,
                                              //               decoration:
                                              //                   const BoxDecoration(
                                              //                 borderRadius:
                                              //                     BorderRadius
                                              //                         .vertical(
                                              //                   top: Radius
                                              //                       .circular(8),
                                              //                 ),
                                              //                 color:
                                              //                     kDarkGreenColor,
                                              //               ),
                                              //             ),
                                              //             const SizedBox(
                                              //               height: 15,
                                              //             ),
                                              //             const Icon(
                                              //               Icons.check_circle,
                                              //               color: kGreenColor,
                                              //               size: 80,
                                              //             ),
                                              //             const SizedBox(
                                              //               height: 15,
                                              //             ),
                                              //             const Text(
                                              //               'Data Berhasil di Hapus',
                                              //               style: TextStyle(
                                              //                 fontWeight:
                                              //                     FontWeight.w400,
                                              //                 fontSize: 20,
                                              //                 color: kBlackColor,
                                              //               ),
                                              //             ),
                                              //             const SizedBox(
                                              //               height: 24,
                                              //             ),
                                              //             ElevatedButton(
                                              //               style: ElevatedButton
                                              //                   .styleFrom(
                                              //                 shape:
                                              //                     RoundedRectangleBorder(
                                              //                   borderRadius:
                                              //                       BorderRadius
                                              //                           .circular(
                                              //                               8),
                                              //                 ),
                                              //                 backgroundColor:
                                              //                     kDarkGreenColor,
                                              //                 fixedSize:
                                              //                     const Size(
                                              //                         120, 45),
                                              //               ),
                                              //               onPressed: () {
                                              //                 Navigator.pop(
                                              //                     context);
                                              //               },
                                              //               child: const Text(
                                              //                 'Oke',
                                              //                 style: TextStyle(
                                              //                   fontWeight:
                                              //                       FontWeight
                                              //                           .w500,
                                              //                   fontSize: 20,
                                              //                   color:
                                              //                       kWhiteColor,
                                              //                 ),
                                              //               ),
                                              //             ),
                                              //           ],
                                              //         ),
                                              //       ),
                                              //     );
                                              //   },
                                              // );
                                            },
                                            child: const Text(
                                              'Ya',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 20,
                                                color: kWhiteColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: const Icon(Icons.delete),
                      ),
                      const SizedBox(
                        width: 24,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kGreenColor,
                          fixedSize: const Size(
                            101,
                            29,
                          ),
                        ),
                        onPressed: () async {
                          // if (files?.isEmpty ?? true) {
                          //   debugPrint('File kosong');
                          //   CutiKhususConfirmService().cutiKhususConfirm(
                          //     idCutiKhusus,
                          //     context,
                          //   );
                          // } else {
                          //   debugPrint('File Masuk');
                          //   CutiKhususInputAttachmentService()
                          //       .cutiKhususInputAttachment(
                          //     idCutiKhusus,
                          //     files!,
                          //   );
                          //   CutiKhususConfirmService().cutiKhususConfirm(
                          //     idCutiKhusus,
                          //     context,
                          //   );
                          // }
                          if (files?.isEmpty ?? true) {
                            print('kosongan bang');
                            await cutiKhususDetailController
                                .cutiKhususConfirm(args);
                          } else {
                            print('ada isinya bang');
                            await cutiKhususDetailController
                                .cutiKhususInputAttachment(args, files!);
                            await cutiKhususDetailController
                                .cutiKhususConfirm(args);
                          }
                        },
                        child: const Icon(Icons.send),
                      ),
                    ],
                  )
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
