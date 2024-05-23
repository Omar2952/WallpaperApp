import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:wallpaperapp/Views/signup_page.dart';
import '../Controllers/login_controller.dart';
import '../Utils/app_colors.dart';
import '../Utils/text_style.dart';
import '../Widgets/custom_container_button.dart';
import '../Widgets/custom_password_field.dart';
import '../Widgets/custom_textfield.dart';
import 'forgot_password_page.dart';


class LoginPage extends StatelessWidget {
  final LoginController loginController = Get.put(LoginController());
  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            onPressed: () {
              Get.offAll(()=> SignUpPage());
            },
            icon: const Icon(Icons.arrow_back_ios, color: whiteColor,),
          )
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
                Text(
                    "Glad to meet you again!",
                    textAlign: TextAlign.center,
                    style: textStyle(family: bold, size: 24)
                ),
                const SizedBox(
                  height: 16,
                ),
                CustomTextField(hint: "Email Address", iconData: Icons.email, controller: loginController.emailController,),

                const SizedBox(
                  height: 16,
                ),
                CustomPasswordField(hint: "Password", iconData: Icons.lock, controller: loginController.passwordController),

                const SizedBox(
                  height: 16,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            child: Text(
                                "Forgot Password",
                                textAlign: TextAlign.end,
                                style: textStyle(color: whiteColor,)
                            ),
                            onTap: () {
                              Get.to(()=> ForgotPasswordPage(), transition: Transition.fade,duration: const Duration(milliseconds: 500));
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),

                Obx(() => loginController.isLoading.value ?  const SpinKitFadingCircle(
                  color: Colors.white,
                  size: 40.0,
                )  : ContainerButton(text: "Login Now", onTap: loginController.login,),),

                const SizedBox(
                  height: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


