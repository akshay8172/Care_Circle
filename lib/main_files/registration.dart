import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:care_circle_new/admin/ManageOrganizations.dart';

class AddOrganizationPage extends StatefulWidget {
  const AddOrganizationPage({super.key});

  @override
  State<AddOrganizationPage> createState() => _AddOrganizationPageState();
}

class _AddOrganizationPageState extends State<AddOrganizationPage> {
  final _formKey = GlobalKey<FormState>();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // Form controllers
  final _nameController = TextEditingController();
  final _placeController = TextEditingController();
  final _pinController = TextEditingController();
  final _postController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _establishedYearController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) return 'Please enter organization name';
    if (value.length < 3) return 'Username should be at least 3 characters';
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Name should contain only letters';
    }
    return null;
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) return 'Please enter username';
    if (value.length < 3) return 'Username should be at least 3 characters';
    if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
      return 'Username should contain only letters';
    }
    return null;
  }


  String? _validatePlaceOrPost(String? value) {
    if (value == null || value.isEmpty) return 'This field is required';
    if (value.length < 5) return 'Must be at least 5 characters';
    return null;
  }

  String? _validatePIN(String? value) {
    if (value == null || value.isEmpty) return 'Please enter PIN';
    if (value.length != 6 || !RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'PIN should contain exactly 6 digits';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Please enter phone number';
    if (value.length != 10 || !RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
      return 'Phone should contain exactly 10 digits, starting with 6, 7, 8, or 9';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter email';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validateYear(String? value) {
    final currentYear = DateTime.now().year;
    if (value == null || value.isEmpty) return 'Please enter established year';
    if (value.length != 4 || !RegExp(r'^\d{4}$').hasMatch(value)) {
      return 'Established year should be a 4-digit year';
    }
    if (int.parse(value) > currentYear) {
      return 'Established year should not be greater than $currentYear';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter password';
    if (value.length < 8 ||
        !RegExp(r'[A-Za-z]').hasMatch(value) ||
        !RegExp(r'\d').hasMatch(value) ||
        !RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password should be at least 8 characters, include a letter, a number, and a special character';
    }
    return null;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _imageFile != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        SharedPreferences sh = await SharedPreferences.getInstance();
        String? urlBase = sh.getString('url');
        if (urlBase == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Server URL not configured')),
          );
          return;
        }

        var uri = Uri.parse('$urlBase/admin_add_organization');
        var request = http.MultipartRequest('POST', uri)
          ..fields['name'] = _nameController.text
          ..fields['place'] = _placeController.text
          ..fields['pin'] = _pinController.text
          ..fields['post'] = _postController.text
          ..fields['phone'] = _phoneController.text
          ..fields['email'] = _emailController.text
          ..fields['established_year'] = _establishedYearController.text
          ..fields['username'] = _usernameController.text
          ..fields['password'] = _passwordController.text;

        // Add the image file
        var photoStream = http.ByteStream(_imageFile!.openRead());
        var length = await _imageFile!.length();
        var multipartFile = http.MultipartFile(
          'photo',
          photoStream,
          length,
          filename: _imageFile!.path.split('/').last,
        );
        request.files.add(multipartFile);

        var response = await request.send();
        var responseData = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseData);

        if (jsonResponse['status'] == 'ok') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Organization added successfully')),
            );
            Navigator.pop(context, true); // Return true to indicate success
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to add organization')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select an image')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Organization'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _imageFile != null
                      ? Image.file(_imageFile!, fit: BoxFit.cover)
                      : const Center(
                    child: Text('Tap to select organization image'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Organization Name'),
                validator: _validateName,
              ),
              TextFormField(
                controller: _placeController,
                decoration: const InputDecoration(labelText: 'Place'),
                validator: _validatePlaceOrPost,
              ),
              TextFormField(
                controller: _pinController,
                decoration: const InputDecoration(labelText: 'PIN'),
                keyboardType: TextInputType.number,
                validator: _validatePIN,
              ),
              TextFormField(
                controller: _postController,
                decoration: const InputDecoration(labelText: 'Post'),
                validator: _validatePlaceOrPost,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
                validator: _validatePhone,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              TextFormField(
                controller: _establishedYearController,
                decoration: const InputDecoration(labelText: 'Established Year'),
                keyboardType: TextInputType.number,
                validator: _validateYear,
              ),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: _validateUsername,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: _validatePassword,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Add Organization'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
