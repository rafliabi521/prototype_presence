import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../data/models/absensi_model.dart';

class LaporanController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> streamKaryawan() async* {
    yield* firestore.collection("karyawan").snapshots();
  }

  RxList<AbsensiModel> karyawanAbsensi = List<AbsensiModel>.empty().obs;

  void cetakLaporan(AbsensiModel absensi) async {
    final pdf = pw.Document();
    String uid = absensi.uid;

    // Mendapatkan detail absensi karyawan yang berhasil melakukan absensi di dalam area
    var getDataAbsensi = await firestore
        .collection("karyawan")
        .doc(uid)
        .collection("presence")
        .where("status", isEqualTo: "Di Luar Area")
        .get();

    // Reset data absensiKaryawan -> untuk mengatasi duplikat
    karyawanAbsensi([]);

    // Isi data absensi Karyawan dari database
    for (var element in getDataAbsensi.docs) {
      karyawanAbsensi.add(AbsensiModel.fromJson(element.data()));
    }

    pdf.addPage(
      pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            List<pw.TableRow> allData =
                List.generate(karyawanAbsensi.length, (index) {
              AbsensiModel absensi = karyawanAbsensi[index];
              return pw.TableRow(children: [
                // No
                pw.Padding(
                  padding: const pw.EdgeInsets.all(10),
                  child: pw.Text(
                    "${index + 1}",
                    textAlign: pw.TextAlign.center,
                    style: const pw.TextStyle(
                      fontSize: 10,
                    ),
                  ),
                ),
                // Tanggal
                pw.Padding(
                  padding: const pw.EdgeInsets.all(10),
                  child: pw.Text(
                    DateFormat.yMMMMEEEEd('id')
                        .format(DateTime.parse(absensi.date)),
                    textAlign: pw.TextAlign.center,
                    style: const pw.TextStyle(
                      fontSize: 10,
                    ),
                  ),
                ),
                // Jam Absensi Datang
                pw.Padding(
                  padding: const pw.EdgeInsets.all(10),
                  child: pw.Text(
                    "Jam : ${absensi.masuk.substring(18, 26)}",
                    textAlign: pw.TextAlign.center,
                    style: const pw.TextStyle(
                      fontSize: 10,
                    ),
                  ),
                ),
                // Jam Absensi Keluar
                pw.Padding(
                  padding: const pw.EdgeInsets.all(10),
                  child: pw.Text(
                    "Jam : ${absensi.keluar.substring(18, 26)}",
                    textAlign: pw.TextAlign.center,
                    style: const pw.TextStyle(
                      fontSize: 10,
                    ),
                  ),
                ),
              ]);
            });

            return [
              pw.Center(
                child: pw.Text(
                  "LAPORAN ABSENSI JNE BSD TANGERANG",
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontSize: 25),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text(
                  absensi.name,
                  textAlign: pw.TextAlign.left,
                  style: const pw.TextStyle(fontSize: 15),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  absensi.nik,
                  textAlign: pw.TextAlign.left,
                  style: const pw.TextStyle(fontSize: 15),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  absensi.job,
                  textAlign: pw.TextAlign.left,
                  style: const pw.TextStyle(fontSize: 15),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Table(
                  border: pw.TableBorder.all(
                    color: PdfColor.fromHex("#000000"),
                    width: 1,
                  ),
                  children: [
                    pw.TableRow(children: [
                      // No
                      pw.Padding(
                        padding: const pw.EdgeInsets.fromLTRB(1, 10, 1, 5),
                        child: pw.Text(
                          "NO",
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      // Tanggal
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(10),
                        child: pw.Text(
                          "Tanggal Absensi",
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      // Jam Absensi Datang
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(10),
                        child: pw.Text(
                          "Absensi Masuk",
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      // Jam Absensi Keluar
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(10),
                        child: pw.Text(
                          "Absensi Keluar",
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ]),
                    ...allData,
                  ])
            ];
          }),
    );
    // Simpan
    Uint8List bytes = await pdf.save();

    // Buat file kosong di direktori
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/AbsensiKaryawan.pdf');

    // Memasukan file bytes ke file kosong
    await file.writeAsBytes(bytes);

    // Buka PDF
    await OpenFile.open(file.path);
  }
}
