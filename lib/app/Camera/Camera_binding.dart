import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'Controllers/CameraUpdateController.dart';

class CameraBindings extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<CameraControllerX>(
          () => CameraControllerX(),
    );
  }

}