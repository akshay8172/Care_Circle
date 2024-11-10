import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:care_circle_new/admin/ManageOrganizations.dart';

class UserRegistration extends StatefulWidget {
  const UserRegistration({super.key});

  @override
  State<UserRegistration> createState() => _UserRegistrationState();
}

class _UserRegistrationState extends State<UserRegistration> {
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
              // Image picker
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

              // Form fields
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Organization Name'),
                validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter organization name' : null,
              ),
              TextFormField(
                controller: _placeController,
                decoration: const InputDecoration(labelText: 'Place'),
                validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter place' : null,
              ),
              TextFormField(
                controller: _pinController,
                decoration: const InputDecoration(labelText: 'PIN'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter PIN' : null,
              ),
              TextFormField(
                controller: _postController,
                decoration: const InputDecoration(labelText: 'Post'),
                validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter post' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter phone number' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter email' : null,
              ),
              TextFormField(
                controller: _establishedYearController,
                decoration: const InputDecoration(labelText: 'Established Year'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter established year' : null,
              ),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter username' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter password' : null,
              ),
              const SizedBox(height: 20),
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

  @override
  void dispose() {
    _nameController.dispose();
    _placeController.dispose();
    _pinController.dispose();
    _postController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _establishedYearController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}