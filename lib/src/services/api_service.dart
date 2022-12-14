import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/base_response.dart';
import '../models/user_data_model.dart';
import 'storage_service.dart';

class ApiServices {
  static final dev = Logger();
  static final storage = StorageService();
  static final url = dotenv.env['SERVER_URL'];

  static final Future<SharedPreferences> _prefs =
      SharedPreferences.getInstance();

  static final options = BaseOptions(
    baseUrl: url!,
    connectTimeout: 5000,
    receiveTimeout: 5000,
  );

  static Dio dio = Dio(options);

  static Future<BaseResponse?> login(String nik, String password) async {
    try {
      String endpoint = 'login';
      String deviceId = await storage.read("device_id");

      Map<String, String> data = {
        "nik": nik,
        "password": password,
        "device_id": deviceId,
      };
      var response = await dio.post(endpoint, data: data);
      var responseReturn = response.data;
      // dev.i(responseReturn);
      return BaseResponse.fromJson(responseReturn);
    } on DioError catch (e) {
      dev.e(e);
      return BaseResponse(
        status: false,
        message: e.response != null ? e.response!.data['message'] : e.message,
      );
    } catch (e) {
      dev.e(e);
      return null;
    }
  }

  static Future<BaseResponse?> cekUserPhoneID(
      Map<String, dynamic> datanya) async {
    try {
      String endpoint = 'cek_datanya';
      String deviceId = await storage.read("device_id");

      Map<String, String> data = {
        "nik": datanya['nik'],
        "device_id": deviceId,
      };
      var response = await dio.post(endpoint, data: data);
      var responseReturn = response.data;
      // dev.i(responseReturn);
      return BaseResponse.fromJson(responseReturn);
    } on DioError catch (e) {
      dev.e(e);

      await storage.remove('userData');
      return BaseResponse(
        status: false,
        message: e.response != null ? e.response!.data['message'] : e.message,
      );
    } catch (e) {
      await storage.remove('userData');
      dev.e(e);
      return null;
    }
    // return null;
  }

  static Future<BaseResponse?> gantiPassword(
      String passwordLama, String passwordBaru) async {
    try {
      String endpoint = 'ganti_password';
      Map<String, dynamic> userData = await storage.read('userData');

      Map<String, String> data = {
        "nik": userData['nik'],
        "password_lama": passwordLama,
        "password_baru": passwordBaru,
        "id_dinas": userData['id_dinas'],
      };

      var response = await dio.post(endpoint, data: data);
      var responseReturn = response.data;

      return BaseResponse.fromJson(responseReturn);
    } on DioError catch (e) {
      dev.e(e);
      return BaseResponse(
        status: false,
        message: e.response != null ? e.response!.data['message'] : e.message,
      );
    } catch (e) {
      dev.e(e);
      return null;
    }
  }

  static Future<BaseResponse?> uploadLaporan(
      String? imgPath, String namaLaporan, String ketLaporan) async {
    try {
      String endpoint = 'laporan';
      String deviceId = await storage.read("device_id");
      Map<String, dynamic> userData = await storage.read("userData");
      UserDataModel userDataModel = UserDataModel.fromJson(userData);

      var formData = FormData.fromMap({
        'ada_foto': imgPath != null ? true : false,
        'image': imgPath != null ? await MultipartFile.fromFile(imgPath) : null,
        'nik': userDataModel.nik,
        'device_id': deviceId,
        'id_dinas': userDataModel.idDinas,
        'nama_laporan': namaLaporan,
        'ket_laporan': ketLaporan,
      });
      var response = await dio.post(endpoint, data: formData);
      var data = response.data;
      dev.i(data);

      return BaseResponse.fromJson(data);
    } on DioError catch (e) {
      dev.e(e);
      return BaseResponse(
        status: false,
        message: e.response != null ? e.response!.data['message'] : e.message,
      );
    } catch (e) {
      dev.e(e);
      return null;
    }
  }

  static Future<BaseResponse?> getLaporan(int page, String search) async {
    dev.i(page);
    try {
      Map<String, dynamic> userData = await storage.read("userData");
      UserDataModel userDataModel = UserDataModel.fromJson(userData);
      String deviceId = await storage.read("device_id");
      String endpoint =
          'laporan?nik=${userDataModel.nik}&device_id=$deviceId&page=$page&where=$search';
      // dev.i(endpoint);
      var response = await dio.get(endpoint);
      var responseReturn = response.data;
      // dev.i(responseReturn['data']['data']);
      // return null;
      return BaseResponse.fromJson(responseReturn);
    } on DioError catch (e) {
      dev.e(e);
      return BaseResponse(
        status: false,
        message: e.response != null ? e.response!.data['message'] : e.message,
      );
    } catch (e) {
      dev.e(e);
      return null;
    }
  }

  static Future<BaseResponse?> getJadwalDinas() async {
    try {
      Map<String, dynamic> userData = await storage.read("userData");
      UserDataModel userDataModel = UserDataModel.fromJson(userData);

      var response = await dio
          .post("jadwal_dinas", data: {"id_dinas": userDataModel.idDinas});

      var responseReturn = response.data;
      // dev.i(responseReturn['data']);
      // return null;
      if (response.statusCode == 200) {
        storage.write('jadwalKerja', responseReturn['data']);
        final SharedPreferences prefs = await _prefs;
        prefs.setString('jadwalKerja', jsonEncode(responseReturn['data']));
      }

      return null;
    } on DioError catch (e) {
      dev.e(e);
      return null;
    } catch (e) {
      dev.e(e);
      return null;
    }
  }

  static Future<BaseResponse?> getUserData() async {
    try {
      Map<String, dynamic> userData = await storage.read("userData");
      UserDataModel userDataModel = UserDataModel.fromJson(userData);

      var response = await dio.get("user_data?nik=${userDataModel.nik}");
      var responseReturn = response.data;
      // dev.i(responseReturn['data']);
      if (response.statusCode == 200) {
        await storage.write('userData', responseReturn['data']);
      }

      // return null;
      return null;
    } on DioError catch (e) {
      dev.e(e);
      return null;
    } catch (e) {
      dev.e(e);
      return null;
    }
  }

  static Future<BaseResponse?> getUserTodayAbsensi(String date) async {
    try {
      Map<String, dynamic> userData = await storage.read("userData");
      UserDataModel userDataModel = UserDataModel.fromJson(userData);

      var response =
          await dio.get("today_absensi?nik=${userDataModel.nik}&date=$date");
      var responseReturn = response.data;
      // dev.i(responseReturn);

      // return null;
      return BaseResponse.fromJson(responseReturn);
    } on DioError catch (e) {
      // dev.e(e.response);
      // return null;

      if (e.response == null) return null;
      return BaseResponse(
        status: false,
        message: e.response != null ? e.response!.data['message'] : e.message,
      );
    } catch (e) {
      dev.e(e);
      return null;
    }
  }

  static Future<BaseResponse?> getTodayLiburAndPerjalanDinas(
      String date) async {
    try {
      Map<String, dynamic> userData = await storage.read("userData");
      UserDataModel userDataModel = UserDataModel.fromJson(userData);

      var response = await dio.get(
          "get_perjalanan_dinas_libur?nik=${userDataModel.nik}&date=$date");
      var responseReturn = response.data;
      BaseResponse baseResponse = BaseResponse.fromJson(responseReturn);
      if (baseResponse.data == null) {
        await storage.write('ada_perjalanan_dinas_libur', 'tiada');
      } else {
        await storage.write('ada_perjalanan_dinas_libur', baseResponse.data);
        // dev.i(baseResponse.data);
      }
      return null;
      // return BaseResponse.fromJson(responseReturn);
    } on DioError catch (e) {
      dev.e(e.response);
      // return null;
      await storage.write('ada_perjalanan_dinas_libur', null);
      if (e.response == null) return null;
      return BaseResponse(
        status: false,
        message: e.response != null ? e.response!.data['message'] : e.message,
      );
    } catch (e) {
      await storage.write('ada_perjalanan_dinas_libur', null);
      dev.e(e);
      return null;
    }
  }

  static Future<BaseResponse?> postUserTodayAbsensi(
      String date, String stat) async {
    try {
      Map<String, dynamic> userData = await storage.read("userData");
      UserDataModel userDataModel = UserDataModel.fromJson(userData);

      var response = await dio.post("today_absensi",
          data: {'nik': userDataModel.nik, "date": date, "stat": stat});
      var responseReturn = response.data;
      dev.i(responseReturn);

      return null;
      // return BaseResponse.fromJson(responseReturn);
    } on DioError catch (e) {
      // dev.e(e.response);
      // return null;

      if (e.response == null) return null;
      return BaseResponse(
        status: false,
        message: e.response != null ? e.response!.data['message'] : e.message,
      );
    } catch (e) {
      dev.e(e);
      return null;
    }
  }

  static Future<void> sendMyLocation(String lat, String lng) async {
    try {
      Map<String, dynamic> userData = await storage.read("userData");
      UserDataModel userDataModel = UserDataModel.fromJson(userData);

      dev.i(lat);
      dev.i(lng);

      var response = await dio.post("my_location",
          data: {'nik': userDataModel.nik, "lat": lat, "lng": lng});
      var responseReturn = response.data;
      dev.i(responseReturn);
    } on DioError catch (e) {
      dev.e(e);
    } catch (e) {
      dev.e(e);
    }
  }
}
