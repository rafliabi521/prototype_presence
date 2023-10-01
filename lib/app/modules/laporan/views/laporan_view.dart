import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:prototype_presence/app/data/models/absensi_model.dart';


import '../controllers/laporan_controller.dart';

class LaporanView extends GetView<LaporanController> {
  const LaporanView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Absensi'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: controller.streamKaryawan(),
        builder: (context, snapKaryawan) {
          if (snapKaryawan.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapKaryawan.data!.docs.isEmpty) {
            return const Center(
              child: Text("Tidak dapat menampilkan data karyawan"),
            );
          }

          List<AbsensiModel> daftarAbsensi = [];

          for (var element in snapKaryawan.data!.docs) {
            daftarAbsensi.add(AbsensiModel.fromJson(element.data()));
          }

          return ListView.builder(
            itemCount: daftarAbsensi.length,
            padding: const EdgeInsets.all(20),
            itemBuilder: (context, index) {
              AbsensiModel karyawan = daftarAbsensi[index];
              AbsensiModel absensi = daftarAbsensi[index];
              return Card(
                elevation: 10,
                margin: const EdgeInsets.only(bottom: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(9),
                  child: Container(
                    height: 100,
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                karyawan.nik,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Column(
                                children: [
                                  Text(karyawan.name),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Column(
                                children: [
                                  Text(karyawan.job),
                                ],
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            controller.cetakLaporan(absensi);
                          },
                          child: const Text("Cetak"),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
