class AbsensiKaryawanModel {
  String? no;
  String? nik;
  String? idDinas;
  String? tanggal;
  String? jamMasuk;
  String? jamIstirehat;
  String? jamMasukKembali;
  String? jamPulang;

  AbsensiKaryawanModel(
      {this.no,
      this.nik,
      this.idDinas,
      this.tanggal,
      this.jamMasuk,
      this.jamIstirehat,
      this.jamMasukKembali,
      this.jamPulang});

  AbsensiKaryawanModel.fromJson(Map<String, dynamic> json) {
    no = json['no'];
    nik = json['nik'];
    idDinas = json['id_dinas'];
    tanggal = json['tanggal'];
    jamMasuk = json['jam_masuk'];
    jamIstirehat = json['jam_istirehat'];
    jamMasukKembali = json['jam_masuk_kembali'];
    jamPulang = json['jam_pulang'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['no'] = no;
    data['nik'] = nik;
    data['id_dinas'] = idDinas;
    data['tanggal'] = tanggal;
    data['jam_masuk'] = jamMasuk;
    data['jam_istirehat'] = jamIstirehat;
    data['jam_masuk_kembali'] = jamMasukKembali;
    data['jam_pulang'] = jamPulang;
    return data;
  }
}
