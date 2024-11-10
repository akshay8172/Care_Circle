import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:care_circle_new/admin/admin_home.dart';
import 'package:care_circle_new/organization/organization_home.dart';
import 'package:care_circle_new/user/user_home.dart';
import 'package:care_circle_new/main_files/registration.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Set light grey background color
      appBar: AppBar(
        title: Text(
          'Login to Care Circle',
          style: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.teal, // Set AppBar color
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: passwordController,
                    obscureText: !passwordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            passwordVisible = !passwordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: isLoading ? null : loginFunction,
                    child: isLoading
                        ? CircularProgressIndicator(
                      color: Colors.white,
                    )
                        : Text(
                      'Login',
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Text(
                      //   'Don\'t have an account?',
                      //   style: GoogleFonts.nunito(),
                      // ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddOrganizationPage()),
                          );
                        },
                        child: Text(
                          'Create Account',
                          style: GoogleFonts.nunito(
                            color: Colors.teal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void loginFunction() async {
    setState(() {
      isLoading = true;
    });

    String username = usernameController.text;
    String password = passwordController.text;

    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url') ?? '';  // Ensure URL is not null
    if (url.isEmpty) {
      Fluttertoast.showToast(msg: 'Server URL not found');
      setState(() {
        isLoading = false;
      });
      return;
    }

    final urls = Uri.parse('$url/login');  // Using string interpolation
    try {
      final response = await http.post(urls, body: {
        'user_name': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = jsonDecode(response.body);

        String status = responseBody['status'];
        if (status == 'ok') {
          Fluttertoast.showToast(msg: 'Login Success !!');

          String type = responseBody['type'];
          String lid = responseBody['lid'].toString();

          sh.setString('lid', lid);

          if (type == 'user') {
            Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) => UserHome(),
            ));
          } else if (type == 'admin') {
            Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) => admin_home_full(),
            ));
          } else if (type == 'organization') {
            Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) => OrganizationHome(),
            ));
          } else {
            Fluttertoast.showToast(msg: 'Invalid user type');
          }
        } else {
          Fluttertoast.showToast(msg: 'User Not Found');
        }
      } else {
        Fluttertoast.showToast(msg: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: ${e.toString()}');
    }

    setState(() {
      isLoading = false;
    });
  }
}
