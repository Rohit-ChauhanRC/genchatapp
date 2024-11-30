import 'package:get_storage/get_storage.dart';

final _box = GetStorage();

void saveLocal({required String key, required dynamic data}) {
  _box.write(key, data);
}

readData({required String key}) {
  return _box.read(key);
}

void deleteStorage() {
  _box.erase();
}
