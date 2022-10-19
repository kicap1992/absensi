import 'package:get_storage/get_storage.dart';

class StorageService {
  static final StorageService _singleton = StorageService.internal();

  factory StorageService() {
    return _singleton;
  }

  StorageService.internal();

  late GetStorage _storage;

  init() async {
    await GetStorage.init();
    _storage = GetStorage();
  }

  Future<dynamic> read(String key) async {
    return await _storage.read(key);
  }

  Future<void> write(String key, dynamic val) async {
    return await _storage.write(key, val);
  }

  Future<void> remove(String key) async {
    return await _storage.remove(key);
  }
}
