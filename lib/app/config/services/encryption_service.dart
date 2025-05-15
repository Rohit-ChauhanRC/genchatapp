import 'package:get/get.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;


class EncryptionService extends GetxService {
  // 32-byte key for AES-256
  static final _keyString = dotenv.dotenv.get("KEYSTRING"); // 32 chars
  static final _ivString = dotenv.dotenv.get("IVSTRING"); // 16 chars for AES

  final _key = encrypt.Key.fromUtf8(_keyString);
  final _iv = encrypt.IV.fromUtf8(_ivString);

  late final encrypt.Encrypter _encrypter;

  @override
  void onInit() {
    super.onInit();
    _encrypter =
        encrypt.Encrypter(encrypt.AES(_key, mode: encrypt.AESMode.cbc));
  }

  String encryptText(String plainText) {
    final encrypted = _encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  String decryptText(String base64CipherText) {
    // if(base64CipherText != "This message was deleted"){}
    final decrypted = base64CipherText != "This message was deleted" ?_encrypter.decrypt64(base64CipherText, iv: _iv): base64CipherText;
    return decrypted;
  }
}
