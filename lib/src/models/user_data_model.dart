class UserDataModel {
  String? nik;
  String? nama;
  String? noTelpon;
  String? jabatan;
  String? alamat;
  String? idDinas;
  String? deviceId;
  String? createdAt;
  String? updatedAt;
  String? dinas;
  String? lat;
  String? lng;
  String? radius;
  String? pangkat;
  String? status;
  String? tanggalLahir;
  String? image;

  UserDataModel({
    this.nik,
    this.nama,
    this.noTelpon,
    this.jabatan,
    this.alamat,
    this.idDinas,
    this.deviceId,
    this.createdAt,
    this.updatedAt,
    this.dinas,
    this.lat,
    this.lng,
    this.radius,
    this.pangkat,
    this.status,
    this.tanggalLahir,
    this.image,
  });

  UserDataModel.fromJson(Map<String, dynamic> json) {
    nik = json['nik'];
    nama = json['nama'];
    noTelpon = json['no_telpon'];
    jabatan = json['jabatan'];
    alamat = json['alamat'];
    idDinas = json['id_dinas'];
    deviceId = json['device_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    dinas = json['dinas'];
    lat = json['lat'];
    lng = json['lng'];
    radius = json['radius'];
    pangkat = json['pangkat'];
    status = json['status'];
    tanggalLahir = json['tanggal_lahir'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['nik'] = nik;
    data['nama'] = nama;
    data['no_telpon'] = noTelpon;
    data['jabatan'] = jabatan;
    data['alamat'] = alamat;
    data['id_dinas'] = idDinas;
    data['device_id'] = deviceId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['dinas'] = dinas;
    data['lat'] = lat;
    data['lng'] = lng;
    data['radius'] = radius;
    data['pangkat'] = pangkat;
    data['status'] = status;
    data['tanggal_lahir'] = tanggalLahir;
    data['image'] = image;
    return data;
  }
}
