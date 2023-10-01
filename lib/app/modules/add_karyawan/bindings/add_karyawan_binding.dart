import 'package:get/get.dart';

import '../controllers/add_karyawan_controller.dart';

class AddKaryawanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddKaryawanController>(
      () => AddKaryawanController(),
    );
  }
}
