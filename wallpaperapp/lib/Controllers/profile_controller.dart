import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../Models/user_model.dart';
import '../Utils/app_colors.dart';
import '../Utils/firebase_service.dart';

class ProfileController extends GetxController {
  Rx<UserModel?> userData = Rx<UserModel?>(null);
  var isLoading = false.obs;
  Rx<XFile?> selectedImage = Rx<XFile?>(null);
  FireStoreService fireStoreService = FireStoreService();

  TextEditingController emailController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    getUserData();
  }


  Future<void> getUserData() async {
    try {
      isLoading.value = true;
      UserModel? userDataMapFirebase = await FireStoreService().getUserDataFromFirebase();
      userData.value = userDataMapFirebase;
      update();
      emailController.text = userData.value!.email;
      userNameController.text = userData.value!.name;
      phoneNumberController.text = userData.value!.phoneNumber;

      isLoading.value = false;
      update();
    } catch (e) {
      log('Error getting user data: $e');
    }
  }

  Future<void> updateProfile() async {
    try{
      await fireStoreService.updateProfile(name: userNameController.text, email: emailController.text, phoneNumber: phoneNumberController.text);
      if(selectedImage.value != null){
        await fireStoreService.updateProfileImage(profileImage: selectedImage.value!);
      }
      Get.snackbar('Successfully updated Profile', 'Profile successfully updated', snackPosition: SnackPosition.BOTTOM, colorText: whiteColor);

    }catch(e){
      Get.snackbar('Cannot update profile', 'Cannot update profile', snackPosition: SnackPosition.BOTTOM, colorText: whiteColor, backgroundColor: Colors.redAccent);

    }

  }

  bool isDataChanged() {
    return emailController.text != userData.value!.email ||
        userNameController.text != userData.value!.name ||
        phoneNumberController.text != userData.value!.phoneNumber;
  }


  Future<void> pickImage() async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        selectedImage.value = image;
        update();
      }
    } else {
      log("Permission not granted to access storage");
    }
  }


}