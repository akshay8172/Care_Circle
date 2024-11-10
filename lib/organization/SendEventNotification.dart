import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';


class SendEventNotification extends StatefulWidget {
  final String userId;
  const SendEventNotification({Key? key, required this.userId}) : super(key: key);

  @override
  State<SendEventNotification> createState() => _SendEventNotificationState();
}

class _SendEventNotificationState extends State<SendEventNotification> {
  final _eventNameController = TextEditingController();
  final _eventDetailsController = TextEditingController();
  final _eventDateController = TextEditingController();
  final _eventCountController = TextEditingController();
  final _venueController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;

  Future<void> sendEventNotification() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String? urlBase = sh.getString('url');
      if (urlBase == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server URL not configured')),
        );
        return;
      }

      var uri = Uri.parse('$urlBase/OrgSendEventNotification');
      var request = http.MultipartRequest('POST', uri)
        ..fields['org_id'] = widget.userId
        ..fields['event_name'] = _eventNameController.text
        ..fields['event_details'] = _eventDetailsController.text
        ..fields['event_date'] = _eventDateController.text
        ..fields['count'] = _eventCountController.text
        ..fields['venue'] = _venueController.text;

      if (_selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'event_photo',
          _selectedImage!.path,
        ));
      }

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);

      if (jsonResponse['status'] == 'ok') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event notification sent successfully')),
          );
          Navigator.pop(context, true); // This signals success
        }
      }
      else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsonResponse['error'] ?? 'Failed to send event notification')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again later.')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _eventDateController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Event Notification'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _eventNameController,
                  decoration: const InputDecoration(labelText: 'Event Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an event name';
                    } else if (value.length < 3) {
                      return 'Event name must be at least 3 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),
                TextFormField(
                  controller: _eventDetailsController,
                  decoration: const InputDecoration(labelText: 'Event Details'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter event details';
                    } else if (value.length < 5) {
                      return 'Event details must be at least 5 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),
                TextFormField(
                  controller: _eventDateController,
                  decoration: const InputDecoration(
                    labelText: 'Event Date (YYYY-MM-DD)',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a date';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _eventCountController,
                  decoration: const InputDecoration(labelText: 'Count'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    // Limit input to 5 digits
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(5),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a count';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _venueController,
                  decoration: const InputDecoration(labelText: 'Venue'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a venue';
                    } else if (value.length < 5) {
                      return 'Venue must be at least 5 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _selectImage,
                  child: const Text('Select Event Photo'),
                ),
                const SizedBox(height: 10),
                if (_selectedImage != null)
                  Center(
                    child: Image.file(
                      _selectedImage!,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  const Center(child: Text('No image selected')),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: sendEventNotification,
                    child: const Text('Send Notification'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
