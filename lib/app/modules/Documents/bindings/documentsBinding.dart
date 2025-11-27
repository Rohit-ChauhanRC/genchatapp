import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';

import '../Controllers/DocumentsController.dart';
class DocumentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DocumentPickerController>(() => DocumentPickerController());
  }
}