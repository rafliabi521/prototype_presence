import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  RxBool isLoading = false.obs;
  TextEditingController emailC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  void sendEmail() async {
    if (emailC.text.isNotEmpty) {
      isLoading.value = true;
      try {
        await auth.sendPasswordResetEmail(email: emailC.text);
        Get.back();
        Get.snackbar(
            "Berhasil", "Pengiriman email reset password telah berhasil");
      } catch (e) {
        Get.snackbar("Terjadi Kesalahan",
            "Tidak dapat mengirim link email reset password");
      } finally {
        isLoading.value = false;
      }
    }
  }
}
