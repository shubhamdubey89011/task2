import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task/auth_controllers.dart';

class SignupScreen extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());

  SignupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Signup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: authController.signupFormKey,
          child: Column(
            children: [
              TextFormField(
                controller: authController.nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  return authController.validateName(value);
                },
              ),
              TextFormField(
                controller: authController.emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  return authController.validateEmail(value);
                },
              ),
              TextFormField(
                controller: authController.passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  return authController.validatePassword(value);
                },
              ),
              const SizedBox(height: 20),
              Obx(() => authController.isLoading.value
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: authController.signup,
                      child: const Text('Signup'),
                    )),
            ],
          ),
        ),
      ),
    );
  }
}
