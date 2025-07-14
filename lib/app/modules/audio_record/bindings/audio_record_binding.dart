import 'package:get/get.dart';

import '../controllers/audio_record_controller.dart';

class AudioRecordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AudioRecordController>(
      () => AudioRecordController(),
    );
  }
}
