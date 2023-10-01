import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddKaryawanController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isLoadingAddKaryawan = false.obs;
  TextEditingController nameC = TextEditingController();
  TextEditingController nikC = TextEditingController();
  TextEditingController emailC = TextEditingController();
  TextEditingController jobC = TextEditingController();
  TextEditingController passAdminC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> prosesAddKaryawan() async {
    if (passAdminC.text.isNotEmpty) {
      isLoadingAddKaryawan.value = true;
      try {
        String emailAdmin = auth.currentUser!.email!;

        UserCredential userCredentialAdmin =
            await auth.signInWithEmailAndPassword(
          email: emailAdmin,
          password: passAdminC.text,
        );

        UserCredential karyawanCredential =
            await auth.createUserWithEmailAndPassword(
          email: emailC.text,
          password: "password",
        );

        if (karyawanCredential.user != null) {
          String uid = karyawanCredential.user!.uid;

          await firestore.collection("karyawan").doc(uid).set({
            "nik": nikC.text,
            "name": nameC.text,
            "email": emailC.text,
            "job": jobC.text,
            "uid": uid,
            "role": "karyawan",
            "created_at": DateTime.now().toIso8601String(),
          });

          await karyawanCredential.user!.sendEmailVerification();

          await auth.signOut();

          UserCredential userCredentialAdmin =
              await auth.signInWithEmailAndPassword(
            email: emailAdmin,
            password: passAdminC.text,
          );
          Get.back(); // tutup dialog
          Get.back(); // back to home
          Get.snackbar("Berhasil", "Berhasil menambahkan karyawan");
        }
        isLoadingAddKaryawan.value = false;
      } on FirebaseAuthException catch (e) {
        isLoadingAddKaryawan.value = false;
        if (e.code == 'weak-password') {
          Get.snackbar(
              "Terjadi Kesalahan", "Password yang digunakan terlalu singkat");
        } else if (e.code == 'email-already-in-use') {
          Get.snackbar("Terjadi Kesalahan", "Email sudah digunakan");
        } else if (e.code == 'wrong-password') {
          Get.snackbar(
              "Terjadi Kesalahan", "Admin tidak dapat login. Password salah!");
        } else {
          Get.snackbar("Terjadi Kesalahan", "${e.code}");
        }
      } catch (e) {
        isLoadingAddKaryawan.value = false;
        Get.snackbar("Terjadi Kesalahan", "Tidak dapat menambahkan karyawan");
      }
    } else {
      isLoading.value = false;
      Get.snackbar(
          "Terjadi Kesalahan", "Password wajib diisi untuk validasi admin");
    }
  }

  Future<void> addKaryawan() async {
    if (nameC.text.isNotEmpty &&
        nikC.text.isNotEmpty &&
        emailC.text.isNotEmpty &&
        jobC.text.isNotEmpty) {
      isLoading.value = true;
      Get.defaultDialog(
        title: "Validasi Admin",
        content: Column(
          children: [
            Text("Masukan password untuk validasi admin!"),
            SizedBox(
              height: 10,
            ),
            TextField(
              controller: passAdminC,
              autocorrect: false,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () {
              isLoading.value = false;
              Get.back();
            },
            child: Text("Cancel"),
          ),
          Obx(
            () => ElevatedButton(
              onPressed: () async {
                if (isLoadingAddKaryawan.isFalse) {
                  await prosesAddKaryawan();
                }
                isLoading.value = false;
              },
              child:
                  Text(isLoadingAddKaryawan.isFalse ? "Confirm" : "Loading..."),
            ),
          )
        ],
      );
    } else {
      Get.snackbar("Terjadi Kesalahan", "NIK, Nama, Email dan Job harus diisi");
    }
  }
}
