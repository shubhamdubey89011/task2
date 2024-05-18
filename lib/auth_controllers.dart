import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task/home_screen.dart';

class AuthController extends GetxController {
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

  late TextEditingController emailController,
      passwordController,
      nameController;

  var isLoading = false.obs;

  FirebaseAuth auth = FirebaseAuth.instance;

  SharedPreferences? preferences;

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    nameController = TextEditingController();
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    preferences = await SharedPreferences.getInstance();
    checkLogin();
  }

  void checkLogin() {
    final bool isLoggedIn = preferences!.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      // Navigate to HomeScreen if user is logged in
      Get.offAll(() => HomeScreen());
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.onClose();
  }

  String? validateEmail(String? value) {
    if (!GetUtils.isEmail(value ?? "")) {
      return "Provide a valid email";
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.length < 6) {
      return "Password must be of 6 characters";
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "Name cannot be empty";
    }
    return null;
  }

  Future<void> login() async {
    if (loginFormKey.currentState!.validate()) {
      isLoading.value = true;
      try {
        await auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        await preferences!.setBool('isLoggedIn', true);
        Get.offAll(() => HomeScreen()); // Navigate to home screen
        Get.snackbar("Login", "Login successful");
      } catch (e) {
        isLoading.value = false;
        Get.snackbar("Error", e.toString());
        throw e; // rethrow the exception to maintain the Future's error type
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> signup() async {
    if (signupFormKey.currentState!.validate()) {
      isLoading.value = true;
      try {
        UserCredential userCredential =
            await auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
        });
        await preferences!.setBool('isLoggedIn', true);
        Get.offAll(() => HomeScreen()); // Navigate to home screen
        Get.snackbar("Signup", "Signup successful");
      } catch (e) {
        isLoading.value = false;
        Get.snackbar("Error", e.toString());
        throw e; // rethrow the exception to maintain the Future's error type
      } finally {
        isLoading.value = false;
      }
    }
  }
}
