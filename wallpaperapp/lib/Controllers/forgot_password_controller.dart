import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../Utils/firebase_service.dart';

class ForgotPasswordController extends GetxController {

  var isLoading = false.obs;
  var isButtonDisabled = false.obs;
  var timerDuration = 120.obs;
  late Timer _timer;
  TextEditingController emailController = TextEditingController();


  Future<void> resetPassword() async {
    try {
      isLoading.value = true;
      isButtonDisabled.value = true;
      FireStoreService fireStoreService = FireStoreService();
      await fireStoreService.resetPassword(emailController.text.trim());
      startTimer();
      isLoading.value = false;
      Future.delayed(const Duration(minutes: 2), () {
        isButtonDisabled.value = false;
      });
    }  catch (e) {
      isLoading.value = false;
      isButtonDisabled.value = false;
    }
  }

  void startTimer() {
    isButtonDisabled.value = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      timerDuration.value--;
      if (timerDuration.value <= 0) {
        timer.cancel();
        isButtonDisabled.value = false;
        timerDuration.value = 120;
      }
    });
  }

}