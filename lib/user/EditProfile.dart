import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfile extends StatefulWidget {
  final String name;
  final String phone;
  final String place;
  final String pin;
  final String post;
  final String email;
  final String image;

  const EditProfile({
    Key? key,
    required this.name,
    required this.phone,
    required this.place,
    required this.pin,
    required this.post,
    required this.email,
    required this.image,
  }) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController phoneController;
  late TextEditingController placeController;
  late TextEditingController pinController;
  late TextEditingController postController;
  late TextEditingController emailController;

  bool isLoading = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    phoneController = TextEditingController(text: widget.phone);
    placeController = TextEditingController(text: widget.place);
    pinController = TextEditingController(text: widget.pin);
    postController = TextEditingController(text: widget.post);
    emailController = TextEditingController(text: widget.email);
  }

  Future<void> _chooseImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> saveProfile() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() => isLoading = true);
    SharedPreferences sh = await SharedPreferences.getInstance();
    String urls = sh.getString('url').toString();
    String url = '$urls/edit_profile';
    String lid = sh.getString("lid").toString();

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields['id'] = lid;
      request.fields['phone'] = phoneController.text;
      request.fields['place'] = placeController.text;
      request.fields['pin'] = pinController.text;
      request.fields['post'] = postController.text;
      request.fields['email'] = emailController.text;

      if (_selectedImage != null) {
        var imageStream = http.ByteStream(_selectedImage!.openRead());
        var length = await _selectedImage!.length();
        request.files.add(http.MultipartFile('photo', imageStream, length,
            filename: _selectedImage!.path.split('/').last));
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final data = jsonDecode(responseData);

        if (data['status'] == 'ok') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          throw Exception('Failed to update profile: ${data['message']}');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _chooseImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : widget.image.isNotEmpty
                        ? NetworkImage(widget.image)
                        : null,
                    child: _selectedImage == null && widget.image.isEmpty
                        ? const Center(
                      child: Text(
                        'Select Image',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                buildTextField('Phone', phoneController, (value) {
                  if (value == null || value.length != 10 || !RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
                    return 'Enter a valid 10-digit phone number starting with 6-9';
                  }
                  return null;
                }),
                buildTextField('Place', placeController, (value) {
                  if (value == null || value.length < 5) {
                    return 'Place must be at least 5 characters long';
                  }
                  return null;
                }),
                buildTextField('Pin', pinController, (value) {
                  if (value == null || value.length != 6 || !RegExp(r'^\d{6}$').hasMatch(value)) {
                    return 'Pin must be a 6-digit number';
                  }
                  return null;
                }),
                buildTextField('Post', postController, (value) {
                  if (value == null || value.length < 5) {
                    return 'Post must be at least 5 characters long';
                  }
                  return null;
                }),
                buildTextField('Email', emailController, (value) {
                  if (value == null || !RegExp(r'^[\w\.-]+@[a-zA-Z\d\.-]+\.[a-zA-Z]{2,4}$').hasMatch(value)) {
                    return 'Enter a valid email';
                  }
                  return null;
                }),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: saveProfile,
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
      String label, TextEditingController controller, String? Function(String?)? validator) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: validator,
      ),
    );
  }
}
