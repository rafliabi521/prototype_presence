class AbsensiModel {
  AbsensiModel({
    required this.uid,
    required this.name,
    required this.nik,
    required this.job,
    required this.date,
    required this.masuk,
    required this.keluar,
  });

  final String uid;
  final String name;
  final String nik;
  final String job;
  final String date;
  final String masuk;
  final String keluar;

  factory AbsensiModel.fromJson(Map<String, dynamic> json) => AbsensiModel(
        uid: json["uid"] ?? "",
        name: json["name"] ?? "",
        nik: json["nik"] ?? "",
        job: json["job"] ?? "",
        date: json["date"] ?? "",
        masuk: json["masuk"].toString(),
        keluar: json["keluar"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "name": name,
        "nik": nik,
        "job": job,
        "date": "date",
        "masuk": masuk,
        "keluar": keluar,
      };
}