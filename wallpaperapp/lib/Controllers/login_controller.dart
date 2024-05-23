import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallpaperapp/Views/home_page.dart';

import '../Utils/app_colors.dart';
import '../Utils/firebase_service.dart';


class LoginController extends GetxController {

  var isLoading = false.obs;
  var isRememberMe = false.obs;

  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  final FireStoreService _fireStoreService = FireStoreService();


  Future<void> login() async {
    try {
      isLoading.value = true;
      await _fireStoreService.loginUser(
         email: emailController.text, password: passwordController.text,
      );
      Get.offAll(() => const HomePage(), transition: Transition.fade, duration: const Duration(milliseconds: 500));

    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      if (e.code == 'invalid-email') {
        Get.snackbar('Login Error', 'The email address is badly formatted.', snackPosition: SnackPosition.BOTTOM, colorText: whiteColor, backgroundColor: Colors.redAccent);
      } else {
        Get.snackbar('Login Error', e.message ?? 'An error occurred',snackPosition: SnackPosition.BOTTOM, colorText: whiteColor, backgroundColor: Colors.redAccent);
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Login Error', e.toString(), snackPosition: SnackPosition.BOTTOM, colorText: whiteColor, backgroundColor: Colors.redAccent);
    }
  }
}