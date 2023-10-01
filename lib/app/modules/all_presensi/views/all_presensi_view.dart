import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:prototype_presence/app/routes/app_pages.dart';

import '../controllers/all_presensi_controller.dart';

class AllPresensiView extends GetView<AllPresensiController> {
  const AllPresensiView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Presensi'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: controller.streamAllPresence(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snap.data?.docs.length == 0 || snap.data == null) {
            return SizedBox(
              height: 130,
              child: Center(
                child: Text("Belum Terdapat Catatan Kehadiran"),
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(20),
            itemCount: snap.data!.docs.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> data = snap.data!.docs[index].data();
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Material(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.grey[200],
                  child: InkWell(
                    onTap: () => Get.toNamed(
                      Routes.DETAIL_PRESENSI,
                      arguments: data,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Masuk",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${DateFormat.yMMMEd().format(DateTime.parse(data['date']))}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(data['masuk']?['date'] == null
                              ? "-"
                              : "${DateFormat.jms().format(DateTime.parse(data['masuk']!['date']))}"),
                          SizedBox(height: 10),
                          Text(
                            "Keluar",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(data['keluar']?['date'] == null
                              ? "-"
                              : "${DateFormat.jms().format(DateTime.parse(data['keluar']!['date']))}"),
                        ],
                      ),
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
