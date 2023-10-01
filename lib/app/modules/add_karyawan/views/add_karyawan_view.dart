import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/add_karyawan_controller.dart';

class AddKaryawanView extends GetView<AddKaryawanController> {
  const AddKaryawanView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Karyawan'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          TextField(
            autocorrect: false,
            controller: controller.nikC,
            decoration: InputDecoration(
              labelText: "NIK",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          TextField(
            autocorrect: false,
            controller: controller.nameC,
            decoration: InputDecoration(
              labelText: "Nama",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          TextField(
            autocorrect: false,
            controller: controller.emailC,
            decoration: InputDecoration(
              labelText: "Email",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          TextField(
            autocorrect: false,
            controller: controller.jobC,
            decoration: InputDecoration(
              labelText: "Job",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 30),
          Obx(
            () => ElevatedButton(
              onPressed: () async {
                if (controller.isLoading.isFalse) {
                  await controller.addKaryawan();
                }
              },
              child: Text(
                  controller.isLoading.isFalse ? "Add Karyawan" : "Loading..."),
            ),
          ),
        ],
      ),
    );
  }
}
