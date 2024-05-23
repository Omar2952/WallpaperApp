import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../Controllers/forgot_password_controller.dart';
import '../Utils/app_colors.dart';
import '../Utils/text_style.dart';
import '../Widgets/custom_container_button.dart';
import '../Widgets/custom_textfield.dart';

class ForgotPasswordPage extends StatelessWidget {
  final ForgotPasswordController forgotPasswordController = Get.put(ForgotPasswordController());
  ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: Navigator.canPop(context) ? IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios, color: whiteColor,),
            //replace with our own icon data.
          ) : const Text("")
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 50.0),
            child: Obx(()=>
                Lottie.asset(
                  forgotPasswordController.isButtonDisabled.value ? 'assets/Animations/email_sent.json' : 'assets/Animations/reset_password.json',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
            ),
          ),


          const SizedBox(height: 20,),
          Text("Enter You Email to Reset Your Password ", style: textStyle(size: 18),),
          const SizedBox(height: 10,),
          CustomTextField(hint: "Email Address", iconData: Icons.email, controller: forgotPasswordController.emailController),
          const SizedBox(height: 20,),

          Obx(() {
            if (forgotPasswordController.isLoading.value) {
              return const SpinKitFadingCircle(
                color: Colors.white,
                size: 40.0,
              );
            } else {
              if (forgotPasswordController.isButtonDisabled.value) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Resend Email in ", style: textStyle(),),
                    Obx(() => Text(
                      "${forgotPasswordController.timerDuration.value} seconds",
                      style:  textStyle(family: bold),
                    )),
                  ],
                );
              } else {
                return ContainerButton(
                    text: "Reset Password",
                    onTap: (){
                      if(forgotPasswordController.emailController.text.isNotEmpty){
                        forgotPasswordController.resetPassword();
                      }else{
                        Get.snackbar('Error', "Please Enter Email", snackPosition: SnackPosition.BOTTOM, colorText: whiteColor, backgroundColor: Colors.redAccent);
                      }
                    }
                );
              }
            }
          }),


        ],
      ),
    );
  }
}
