// import 'dart:developer';

// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:prototype_presence/app/routes/app_pages.dart';

class PageIndexController extends GetxController {
  RxInt pageIndex = 0.obs;

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void changePage(int i) async {
    switch (i) {
      case 1:
        Map<String, dynamic> dataResponse = await determinePosition();
        if (dataResponse["error"] != true) {
          Position position = dataResponse["position"];
          List<Placemark> placemarks = await placemarkFromCoordinates(
              position.latitude, position.longitude);
          String address =
              "${placemarks[0].street}, ${placemarks[0].subAdministrativeArea}, ${placemarks[0].administrativeArea}";
          await updatePosition(position, address);

          // cek posisi antara 2 kordinat
          double distance = Geolocator.distanceBetween(
              37.4153114, -122.0796995, position.latitude, position.longitude);

          // presensi
          await presensi(position, address, distance);
        } else {
          Get.snackbar("Terjadi Kesalahan", dataResponse["message"]);
        }
        break;
      case 2:
        pageIndex.value = i;
        Get.offAllNamed(Routes.PROFILE);
        break;
      default:
        pageIndex.value = i;
        Get.offAllNamed(Routes.HOME);
    }
  }

  Future<void> presensi(
      Position position, String address, double distance) async {
    String uid = await auth.currentUser!.uid;

    CollectionReference<Map<String, dynamic>> colPresence =
        await firestore.collection("karyawan").doc(uid).collection("presence");
    QuerySnapshot<Map<String, dynamic>> snapPresence = await colPresence.get();
    DateTime now = DateTime.now();
    String todayDocID = DateFormat.yMd().format(now).replaceAll("/", "-");
    String status = "Di Luar Area";
    if (distance <= 200) {
      status = "Di Dalam Area";
    }
    if (snapPresence.docs.isEmpty) {
      // belum pernah absen dan set masuk absen pertama
      await Get.defaultDialog(
        title: "Validasi Presensi",
        middleText:
            "Apakah kamu yakin akan mengisi daftar hadir (MASUK) sekarang?",
        actions: [
          OutlinedButton(
            onPressed: () => Get.back(),
            child: const Text("CANCEL"),
          ),
          ElevatedButton(
            onPressed: () async {
              await colPresence.doc(todayDocID).set({
                "date": now.toIso8601String(),
                "masuk": {
                  "date": now.toIso8601String(),
                  "lat": position.latitude,
                  "long": position.longitude,
                  "address": address,
                  "status": status,
                  "distance": distance,
                },
              });
              Get.back();
              Get.snackbar("Berhasil", "Kamu Telah Mengisi Daftar Hadir");
            },
            child: const Text("YES"),
          ),
        ],
      );
    } else {
      DocumentSnapshot<Map<String, dynamic>> todayDoc =
          await colPresence.doc(todayDocID).get();
      if (todayDoc.exists == true) {
        // sisa absen keluar atau sudah absen masuk dan keluar
        Map<String, dynamic>? dataPresenceToday = todayDoc.data();
        if (dataPresenceToday?["keluar"] != null) {
          Get.snackbar("Informasi Penting", "Kamu telah absen masuk & keluar. Tidak dapat mengubah data kembali");
        } else {
          await Get.defaultDialog(
            title: "Validasi Presensi",
            middleText:
                "Apakah kamu yakin akan mengisi daftar hadir (KELUAR) sekarang?",
            actions: [
              OutlinedButton(
                onPressed: () => Get.back(),
                child: Text("CANCEL"),
              ),
              ElevatedButton(
                onPressed: () async {
                  await colPresence.doc(todayDocID).update({
                    "keluar": {
                      "date": now.toIso8601String(),
                      "lat": position.latitude,
                      "long": position.longitude,
                      "address": address,
                      "status": status,
                      "distance": distance,
                    },
                  });
                  Get.back();
                  Get.snackbar("Berhasil", "Kamu Telah Mengisi Daftar Hadir");
                },
                child: Text("YES"),
              ),
            ],
          );
        }
      } else {
        // absen masuk
        await Get.defaultDialog(
          title: "Validasi Presensi",
          middleText:
              "Apakah kamu yakin akan mengisi daftar hadir (MASUK) sekarang?",
          actions: [
            OutlinedButton(
              onPressed: () => Get.back(),
              child: Text("CANCEL"),
            ),
            ElevatedButton(
              onPressed: () async {
                await colPresence.doc(todayDocID).set({
                  "date": now.toIso8601String(),
                  "masuk": {
                    "date": now.toIso8601String(),
                    "lat": position.latitude,
                    "long": position.longitude,
                    "address": address,
                    "status": status,
                    "distance": distance,
                  },
                });
                Get.back();
                Get.snackbar("Berhasil", "Kamu Telah Mengisi Daftar Hadir");
              },
              child: Text("YES"),
            ),
          ],
        );
      }
    }
  }

  Future<void> updatePosition(Position position, String address) async {
    String uid = await auth.currentUser!.uid;

    await firestore.collection("karyawan").doc(uid).update(
      {
        "position": {"lat": position.latitude, "long": position.longitude},
        "address": address,
      },
    );
  }

  Future<Map<String, dynamic>> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return {
        "message": "Layanan lokasi dinonaktifkan.",
        "error": true,
      };
      // return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return {
          "message": "Izin menggunakan GPS ditolak.",
          "error": true,
        };
        // return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return {
        "message":
            "Settingan hp kamu tidak memperbolehkan untuk mengakses GPS. Ubah pada settingan GPS kamu.",
        "error": true,
      };
      // return Future.error(
      //     'Location permissions are permanently denied, we cannot request permissions.');
    }
    Position position = await Geolocator.getCurrentPosition();
    return {
      "position": position,
      "message": "Berhasil mendapatkan posisi device.",
      "error": false,
    };
  }
}
