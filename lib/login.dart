import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task/auth_controllers.dart';
import 'package:task/signup.dart';

class LoginScreen extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: authController.loginFormKey,
          child: Column(
            children: [
              TextFormField(
                controller: authController.emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  return authController.validateEmail(value!);
                },
              ),
              TextFormField(
                controller: authController.passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  return authController.validatePassword(value!);
                },
              ),
              const SizedBox(height: 20),
              Obx(() => authController.isLoading.value
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: authController.login,
                      child: const Text('Login'),
                    )),
              TextButton(
                onPressed: () {
                  Get.to(() => SignupScreen());
                },
                child: const Text("Don't have an account? Sign up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
