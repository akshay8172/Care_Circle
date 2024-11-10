import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfile extends StatefulWidget {
  final String name;
  final String place;
  final String pin;
  final String post;
  final String phone;
  final String email;
  final String establishedYear;

  const EditProfile({
    Key? key,
    required this.name,
    required this.place,
    required this.pin,
    required this.post,
    required this.phone,
    required this.email,
    required this.establishedYear,
  }) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late TextEditingController nameController;
  late TextEditingController placeController;
  late TextEditingController pinController;
  late TextEditingController postController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController establishedYearController;

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
    placeController = TextEditingController(text: widget.place);
    pinController = TextEditingController(text: widget.pin);
    postController = TextEditingController(text: widget.post);
    phoneController = TextEditingController(text: widget.phone);
    emailController = TextEditingController(text: widget.email);
    establishedYearController = TextEditingController(text: widget.establishedYear);
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
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => isLoading = true);
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url') ?? '';
      String url = '$urls/OrgEditProfile';
      String lid = sh.getString("lid") ?? '';

      try {
        var request = http.MultipartRequest('POST', Uri.parse(url));
        request.fields['id'] = lid;
        request.fields['name'] = nameController.text;
        request.fields['place'] = placeController.text;
        request.fields['pin'] = pinController.text;
        request.fields['post'] = postController.text;
        request.fields['email'] = emailController.text;
        request.fields['phone'] = phoneController.text;
        request.fields['established_year'] = establishedYearController.text;

        if (_selectedImage != null) {
          var imageStream = http.ByteStream(_selectedImage!.openRead());
          var length = await _selectedImage!.length();
          request.files.add(http.MultipartFile('image', imageStream, length,
              filename: _selectedImage!.path.split('/').last));
        }

        var response = await request.send();
        if (response.statusCode == 200) {
          final responseData = await response.stream.bytesToString();
          final data = jsonDecode(responseData);

          if (data['status'] == 'ok') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar (
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.green[700],
      ),
      body: Container(
        color: Colors.green[50],
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a name';
                  if (value.length < 3) return 'Name should be at least 3 characters';
                  if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) return 'Only letters and spaces are allowed';
                  return null;
                },

              ),
              SizedBox(height: 10),
              TextFormField(
                controller: placeController,
                decoration: InputDecoration(
                  labelText: 'Place',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a place';
                  if (value.length < 3) return 'Place should be at least 3 characters';
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: pinController,
                decoration: InputDecoration(
                  labelText: 'Pin Code',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a pin code';
                  if (value.length != 6 || !RegExp(r'^\d{6}$').hasMatch(value)) return 'Pin code must be 6 digits';
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: postController,
                decoration: InputDecoration(
                  labelText: 'Post',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a post';
                  if (value.length < 3) return 'Post should be at least 3 characters';
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a phone number';
                  if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) return 'Phone number must be 10 digits starting with 6-9';
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter an email';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value))
                    return 'Enter a valid email';
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: establishedYearController,
                decoration: InputDecoration(
                  labelText: 'Established Year',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final currentYear = DateTime.now().year;
                  if (value == null || value.isEmpty) {
                    return 'Please enter the established year';
                  }
                  if (!RegExp(r'^\d{4}$').hasMatch(value)) {
                    return 'Enter a valid year (e.g., 1990)';
                  }
                  final enteredYear = int.parse(value);
                  if (enteredYear > currentYear) {
                    return 'The year cannot be in the future';
                  }
                  return null;
                },
              ),

              SizedBox(height: 10),
              _selectedImage == null
                  ? TextButton(
                onPressed: _chooseImage,
                child: Text('Choose Image', style: TextStyle(color: Colors.green[700])),
              )
                  : Image.file(_selectedImage!, height: 100),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveProfile,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
