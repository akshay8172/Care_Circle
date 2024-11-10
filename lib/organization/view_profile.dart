import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:care_circle_new/organization/edit_profile.dart';
import 'package:care_circle_new/organization/ChangePassword.dart';

class MyProfile extends StatefulWidget {
  final String userId;

  const MyProfile({Key? key, required this.userId}) : super(key: key);

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  Map<String, dynamic>? profile;
  String baseUrl = '';

  @override
  void initState() {
    super.initState();
    fetchMyProfile();
  }

  Future<void> fetchMyProfile() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url').toString();
      baseUrl = sh.getString('imgurl') ?? '';
      String url = '$urls/org_view_profile'; // Ensure this endpoint matches the server
      var response = await http.post(
        Uri.parse(url),
        body: {
          'id': widget.userId,
        },
      );

      var jsondata = json.decode(response.body);
      if (jsondata['status'] == 'ok' && jsondata['profile'] is List && jsondata['profile'].isNotEmpty) {
        setState(() {
          profile = jsondata['profile'][0];
        });
      } else {
        print('Failed to fetch profile');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _showImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          child: Image.network(imageUrl, fit: BoxFit.cover),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal[100]!, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: profile != null
            ? Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _showImage(context, '$baseUrl${profile!['image']}'),
                child: Center( // Center the image horizontally
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.teal, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: profile!['image'] != null
                          ? NetworkImage('$baseUrl${profile!['image']}')
                          : const AssetImage('assets/default_profile.png') as ImageProvider,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              _buildProfileSection('Name', profile!['name'], Icons.person),
              _buildProfileSection('ID', profile!['id'], Icons.badge),
              _buildProfileSection('Place', profile!['place'], Icons.location_city),
              _buildProfileSection('Post', profile!['post'], Icons.work),
              _buildProfileSection('Pin', profile!['pin'], Icons.pin_drop),
              _buildProfileSection('Phone', profile!['phone'], Icons.phone),
              _buildProfileSection('Email', profile!['email'], Icons.email),
              _buildProfileSection('Established Year', profile!['established_year'], Icons.calendar_today),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        // Navigate to the EditProfile page and wait for the result
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfile(
                              name: profile!['name'].toString(),
                              place: profile!['place'].toString(),
                              pin: profile!['pin'].toString(),
                              post: profile!['post'].toString(),
                              phone: profile!['phone'].toString(),
                              email: profile!['email'].toString(),
                              establishedYear: profile!['established_year'].toString(),
                            ),
                          ),
                        );

                        // If the result indicates success, fetch the updated profile data
                        if (result == true) {
                          fetchMyProfile(); // Call the function to reload profile data
                        }
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Profile'),
                    ),
                    const SizedBox(height: 20), // Add spacing between buttons
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        // Navigate to the Change Password page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrgChangePassword(), // Make sure to create this page
                          ),
                        );
                      },
                      icon: const Icon(Icons.lock),
                      label: const Text('Change Password'),
                    ),
                  ],
                ),
              ),

            ],
          ),
        )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildProfileSection(String title, dynamic value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$title: ${value?.toString() ?? 'N/A'}', // Convert value to string
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

}
