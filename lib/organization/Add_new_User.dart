import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddNewUser extends StatefulWidget {
  final String userId;
  const AddNewUser({Key? key, required this.userId}) : super(key: key);

  @override
  State<AddNewUser> createState() => _AddNewUserState();
}

class _AddNewUserState extends State<AddNewUser> {
  final _formKey = GlobalKey<FormState>();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // Form controllers
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _placeController = TextEditingController();
  final _pinController = TextEditingController();
  final _postController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  String? _selectedGender;
  String? _selectedBloodGroup;

  // Blood group options
  final List<String> _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

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

        var uri = Uri.parse('$urlBase/org_add_vol');
        var request = http.MultipartRequest('POST', uri)
          ..fields['org_id'] = widget.userId
          ..fields['name'] = _nameController.text
          ..fields['age'] = _ageController.text
          ..fields['phone'] = _phoneController.text
          ..fields['place'] = _placeController.text
          ..fields['pin'] = _pinController.text
          ..fields['post'] = _postController.text
          ..fields['gender'] = _selectedGender!
          ..fields['email'] = _emailController.text
          ..fields['blood_group'] = _selectedBloodGroup!;

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
              const SnackBar(content: Text('User added successfully')),
            );
            Navigator.pop(context, true); // Return true to indicate success
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to add User')),
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
        title: const Text('Add New Volunteer'),
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
                    child: Text('Tap to select Volunteer image'),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Form fields
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Volunteer Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter User name';
                  }
                  // Check if the name contains only letters and spaces
                  if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
                    return 'Name should contain only letters';
                  }
                  // Check if the name is at least 3 characters long
                  if (value.length < 3) {
                    return 'Name should be at least 3 characters long';
                  }
                  return null;
                },
              ),

              TextFormField(
                controller: _placeController,
                decoration: const InputDecoration(labelText: 'Place'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter place';
                  }
                  if (value.length < 3) {
                    return 'Place should be at least 3 characters long';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _pinController,
                decoration: const InputDecoration(labelText: 'PIN'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter PIN';
                  }
                  if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                    return 'PIN should be 6 digits';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _postController,
                decoration: const InputDecoration(labelText: 'Post'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter post';
                  }
                  if (value.length < 3) {
                    return 'Post should be at least 3 characters long';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  // Regular expression for 10 digits, starting with 6, 7, 8, or 9
                  if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
                    return 'Phone number should be 10 digits and start with 6, 7, 8, or 9';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter email' : null,
              ),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Age';
                  }
                  final age = int.tryParse(value);
                  if (age == null || age < 18 || age > 60) {
                    return 'Age should be between 18 and 60';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedBloodGroup,
                decoration: const InputDecoration(labelText: 'Blood Group'),
                items: _bloodGroups
                    .map((bloodGroup) =>
                    DropdownMenuItem(value: bloodGroup, child: Text(bloodGroup)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBloodGroup = value;
                  });
                },
                validator: (value) =>
                value == null ? 'Please select a blood group' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: ['Male', 'Female', 'Other']
                    .map((gender) =>
                    DropdownMenuItem(value: gender, child: Text(gender)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                validator: (value) =>
                value == null ? 'Please select a gender' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Add Volunteer'),
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
    _ageController.dispose();
    _placeController.dispose();
    _pinController.dispose();
    _postController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
