// lib/pages/auth/sign_in_form.dart
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/config.dart';
import '../../componets/bottom_nav_bar.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _initSharedPref();
  }

  Future<void> _initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  // ---------- LOGIN ----------
  void loginUser() async{
    if(_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty){

      var reqBody = {
        "email":_emailController.text,
        "password":_passwordController.text
      };

      var response = await http.post(Uri.parse(login),
          headers: {"Content-Type":"application/json"},
          body: jsonEncode(reqBody)
      );

      var jsonResponse = jsonDecode(response.body);
      if(jsonResponse['status']){
        var myToken = jsonResponse['token'];
        prefs.setString('token', myToken);
        Navigator.push(context, MaterialPageRoute(builder: (context)=>BottomNavBar()));
      }else{
        print('Something went wrong');
      }

    }
  }

  // ---------- SNACKBAR ----------
  void _showSnackBar(String msg, {bool error = false, bool success = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? Colors.green : (error ? Colors.red : null),
        duration: Duration(seconds: success ? 2 : 4),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Email', style: TextStyle(color: Colors.black54)),
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              child: TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  prefixIcon: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.email),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                ),
              ),
            ),

            const Text('Password', style: TextStyle(color: Colors.black54)),
            Padding(
              padding: const EdgeInsets.only(top: 3, bottom: 15),
              child: TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  prefixIcon: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.password),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 3, bottom: 10),
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : loginUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF07536C),
                  minimumSize: const Size(double.infinity, 56),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                      bottomLeft: Radius.circular(25),
                    ),
                  ),
                ),
                icon: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(CupertinoIcons.arrow_right, color: Color(0xFF031330)),
                label: Text(
                  _isLoading ? 'Signing In...' : 'Sign In',
                  style: const TextStyle(color: Color(0xFF031330)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}