class LaporanModel {
  int? countAll;
  int? allPage;
  List<LaporanData>? data;

  LaporanModel({this.countAll, this.allPage, this.data});

  LaporanModel.fromJson(Map<String, dynamic> json) {
    countAll = json['count_all'];
    allPage = json['all_page'];
    if (json['data'] != null) {
      data = <LaporanData>[];
      json['data'].forEach((v) {
        data!.add(LaporanData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['count_all'] = countAll;
    data['all_page'] = allPage;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LaporanData {
  String? noLaporan;
  String? nik;
  String? image;
  String? namaLaporan;
  String? ketLaporan;
  String? createdAt;

  LaporanData(
      {this.noLaporan,
      this.nik,
      this.image,
      this.namaLaporan,
      this.ketLaporan,
      this.createdAt});

  LaporanData.fromJson(Map<String, dynamic> json) {
    noLaporan = json['no_laporan'];
    nik = json['nik'];
    image = json['image'];
    namaLaporan = json['nama_laporan'];
    ketLaporan = json['ket_laporan'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['no_laporan'] = noLaporan;
    data['nik'] = nik;
    data['image'] = image;
    data['nama_laporan'] = namaLaporan;
    data['ket_laporan'] = ketLaporan;
    data['created_at'] = createdAt;
    return data;
  }
}
