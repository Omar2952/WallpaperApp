import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:wallpaperapp/Utils/firebase_service.dart';
import '../../Widgets/custom_textfield.dart';
import '../Controllers/profile_controller.dart';
import '../Utils/app_colors.dart';
import '../Utils/text_style.dart';
import '../Widgets/custom_container_button.dart';
import 'forgot_password_page.dart';

class ProfilePage extends StatelessWidget {
  final ProfileController profileController = Get.put(ProfileController());
  ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: textStyle(size: 24),
        ),
        leading: IconButton(
          icon: const Icon(
            CupertinoIcons.back,
            color: whiteColor,
            size: 28,
          ),
          onPressed: () {
              Get.back(result: true);
          },
        ),
        actions: [
          IconButton(onPressed: (){
            FireStoreService().signOut();
          }, icon: const Icon(Icons.logout))
        ],
      ),
      body: Obx(
            () => profileController.isLoading.value
            ? const SpinKitFadingCircle(
          color: Colors.white,
          size: 40.0,
        )
            : SingleChildScrollView(

          child: SizedBox(
            height: MediaQuery.of(context).size.height/1.15,
            child: Column(
              children: [
                const SizedBox(height: 10,),
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                            border: Border.all(
                              width: 0,
                              color: Colors.transparent,
                            ),
                            boxShadow: [
                              BoxShadow(
                                spreadRadius: 2,
                                blurRadius: 10,
                                color: Colors.black.withOpacity(0.1),
                              ),
                            ],
                            shape: BoxShape.circle,
                            image: profileController.selectedImage.value != null
                                ? DecorationImage(
                              fit: BoxFit.cover,
                              image:
                              FileImage(File(profileController.selectedImage.value!.path)),
                            )
                                : DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(profileController.userData.value!.profileImageUrl,),
                            )
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () async {
                            await profileController.pickImage();
                          },
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                width: 0,
                                color: Colors.transparent,
                              ),
                              color: sliderColor,
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20,),
                CustomTextField(hint: "Email Address", iconData: Icons.email, controller: profileController.emailController,enabled: false,),
                const SizedBox(height: 10,),
                CustomTextField(hint: "User Name", iconData: Icons.person, controller: profileController.userNameController,),
                const SizedBox(height: 10,),
                CustomTextField(hint: "Phone Number", iconData: Icons.phone, controller: profileController.phoneNumberController,),
                const SizedBox(height: 10,),
                ContainerButton(text: "Change Password",buttonColor: Colors.grey, onTap: ()async {
                  Get.to(()=> ForgotPasswordPage());
                },),
                const Spacer(),
                profileController.isLoading.value ?  const CircularProgressIndicator(color: sliderColor,) : ContainerButton(text: "Update Profile", onTap: ()async {
                  await profileController.updateProfile();
                },),
                const SizedBox(height: 20,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
