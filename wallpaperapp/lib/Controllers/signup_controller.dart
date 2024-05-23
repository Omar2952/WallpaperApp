import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallpaperapp/Views/home_page.dart';
import '../Utils/app_colors.dart';
import '../Utils/firebase_service.dart';

class SignUpController extends GetxController {

  var isLoading = false.obs;
  final FireStoreService _fireStoreService = FireStoreService();

  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController categoryController = TextEditingController();

  Future<void> signUp({required String name,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    isLoading.value = true;
    try {
      await _fireStoreService.signUpUser(
          name: name,
          email: email,
          phoneNumber: phoneNumber,
          password: password
      );
      Get.off(() => const HomePage(), transition: Transition.fade, duration: const Duration(milliseconds: 500));
    } catch (e) {
      log('Error signing up user: $e');
      String errorMessage = 'An error occurred';
      if (e is FirebaseAuthException) {
        errorMessage = e.message ?? 'An error occurred';
      }
      Get.snackbar('Error', errorMessage, snackPosition: SnackPosition.BOTTOM, colorText: whiteColor, backgroundColor: Colors.redAccent);
    } finally {
      isLoading.value = false;
    }
  }
}