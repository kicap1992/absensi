class JadwalDinasModel {
  String? no;
  String? idDinas;
  String? hari;
  String? jamMasuk;
  String? jamIstirehat;
  String? jamMasukKembali;
  String? jamPulang;

  JadwalDinasModel(
      {this.no,
      this.idDinas,
      this.hari,
      this.jamMasuk,
      this.jamIstirehat,
      this.jamMasukKembali,
      this.jamPulang});

  JadwalDinasModel.fromJson(Map<String, dynamic> json) {
    no = json['no'];
    idDinas = json['id_dinas'];
    hari = json['hari'];
    jamMasuk = json['jam_masuk'];
    jamIstirehat = json['jam_istirehat'];
    jamMasukKembali = json['jam_masuk_kembali'];
    jamPulang = json['jam_pulang'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['no'] = no;
    data['id_dinas'] = idDinas;
    data['hari'] = hari;
    data['jam_masuk'] = jamMasuk;
    data['jam_istirehat'] = jamIstirehat;
    data['jam_masuk_kembali'] = jamMasukKembali;
    data['jam_pulang'] = jamPulang;
    return data;
  }
}
