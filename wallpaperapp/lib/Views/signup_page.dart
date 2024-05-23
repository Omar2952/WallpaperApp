import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:wallpaperapp/Views/login_page.dart';
import '../Controllers/signup_controller.dart';
import '../Utils/app_colors.dart';
import '../Utils/text_style.dart';
import '../Widgets/custom_container_button.dart';
import '../Widgets/custom_password_field.dart';
import '../Widgets/custom_textfield.dart';

class SignUpPage extends StatelessWidget {
  final SignUpController signUpController = Get.put(SignUpController());
  SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            onPressed: () {
              Get.off(()=>LoginPage());
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: whiteColor,
            ),
            //replace with our own icon data.
          ),
      ),
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Card(
          elevation: 20,
          color: Color(int.parse(color)),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Text("Register Now and Start Exploring",
                      textAlign: TextAlign.center, style: textStyle(size: 24, family: bold, color: whiteColor)),
                ),
                const SizedBox(
                  height: 16,
                ),
                CustomTextField(
                  hint: "Your Name",
                  iconData: Icons.person,
                  controller: signUpController.userNameController,
                ),
                const SizedBox(
                  height: 16,
                ),
                CustomTextField(
                  hint: "Email Address",
                  iconData: Icons.mail,
                  controller: signUpController.emailController,
                ),
                const SizedBox(
                  height: 16,
                ),
                CustomTextField(
                    hint: "Phone number",
                    iconData: Icons.phone,
                    controller: signUpController.phoneNumberController,
                    isNumber: TextInputType.number),
                const SizedBox(
                  height: 16,
                ),
                CustomPasswordField(hint: "Password", iconData: Icons.lock, controller: signUpController.passwordController),
                const SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("By signing up you agree to our ",
                          textAlign: TextAlign.center, style: textStyle(color: Colors.grey, size: 11)),
                      Text(" Terms of Use", style: textStyle(color: whiteColor, size: 11)),
                      Text(" and ", style: textStyle(color: Colors.grey, size: 11)),
                      Text("Privacy Notice", style: textStyle(color: whiteColor, size: 11)),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Obx(
                      () => signUpController.isLoading.value
                      ? const SpinKitFadingCircle(
                    color: Colors.white,
                    size: 40.0,
                  )
                      : ContainerButton(
                    text: "Sign Up Now",
                    onTap: () {
                      signUpController.signUp(
                        name: signUpController.userNameController.text,
                        email: signUpController.emailController.text,
                        phoneNumber: signUpController.phoneNumberController.text,
                        password: signUpController.passwordController.text,
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
