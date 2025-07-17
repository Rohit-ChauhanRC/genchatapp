import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class MessageIdStorage {
  static const _fileName = 'shown_ids.json';

  static Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  static Future<List<String>> load() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return [];
      final contents = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(contents);
      return jsonList.map((e) => e.toString()).toList();
    } catch (e) {
      print("❌ [MessageIdStorage] Load failed: $e");
      return [];
    }
  }

  static Future<void> save(List<String> ids) async {
    try {
      final file = await _getFile();
      await file.writeAsString(jsonEncode(ids));
    } catch (e) {
      print("❌ [MessageIdStorage] Save failed: $e");
    }
  }

  static Future<void> add(String id, {int maxItems = 50}) async {
    final ids = await load();
    if (!ids.contains(id)) {
      ids.add(id);
      if (ids.length > maxItems) ids.removeRange(0, ids.length - maxItems);
      await save(ids);
    }
  }

  static Future<void> remove(String id) async {
    final ids = await load();
    ids.remove(id);
    await save(ids);
  }

  static Future<void> clear() async {
    final file = await _getFile();
    if (await file.exists()) await file.delete();
  }
}
