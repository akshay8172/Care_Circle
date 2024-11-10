import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:care_circle_new/user/EditProfile.dart';

class ViewProfile extends StatefulWidget {
  const ViewProfile({super.key});

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  Map<String, dynamic>? profile;
  String baseUrl = '';
  bool isAvailable = false;

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
      String lid = sh.getString("lid").toString();

      String url = '$urls/user_view_profile'; // Ensure this endpoint matches the server
      var response = await http.post(
        Uri.parse(url),
        body: {
          'id': lid,
        },
      );

      var jsondata = json.decode(response.body);
      if (jsondata['status'] == 'ok' && jsondata['profile'] is List && jsondata['profile'].isNotEmpty) {
        setState(() {
          profile = jsondata['profile'][0];
          isAvailable = profile!['is_available'] == true;
        });
      } else {
        print('Failed to fetch profile');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> updateAvailability(bool status) async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url').toString();
      String lid = sh.getString("lid").toString();

      String url = '$urls/update_availability';
      var response = await http.post(
        Uri.parse(url),
        body: {
          'id': lid,
          'is_available': status ? '1' : '0',
        },
      );

      var jsondata = json.decode(response.body);
      if (jsondata['status'] == 'ok') {
        setState(() {
          isAvailable = status;
        });
      } else {
        print('Failed to update availability');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: profile!['photo'] != null
                    ? NetworkImage('$baseUrl${profile!['photo']}')
                    : const AssetImage('assets/images/admin_image.png') as ImageProvider,
              ),
            ),

            const SizedBox(height: 20),
            // Toggle Availability Status
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Icon(
                  isAvailable ? Icons.check_circle : Icons.cancel,
                  color: isAvailable ? Colors.green : Colors.red,
                ),
                title: const Text(
                  'Availability',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(isAvailable ? 'Available' : 'Not Available'),
                trailing: Switch(
                  value: isAvailable,
                  onChanged: (value) {
                    updateAvailability(value);
                  },
                ),
              ),
            ),

            buildProfileCard('Name', profile!['name'].toString(), Icons.person),
            buildProfileCard('Organization', profile!['org_name'].toString(), Icons.business),
            buildProfileCard('Organization Phone', profile!['org_phone'].toString(), Icons.phone),
            buildProfileCard('Organization Email', profile!['org_email'].toString(), Icons.email),
            buildProfileCard('Age', profile!['age'].toString(), Icons.cake),
            buildProfileCard('Phone', profile!['phone'].toString(), Icons.phone_android),
            buildProfileCard('Place', profile!['place'].toString(), Icons.location_city),
            buildProfileCard('Pin', profile!['pin'].toString(), Icons.pin_drop),
            buildProfileCard('Post', profile!['post'].toString(), Icons.work),
            buildProfileCard('Gender', profile!['gender'].toString(), Icons.person_outline),
            buildProfileCard('Email', profile!['email'].toString(), Icons.email),
            buildProfileCard('Blood Group', profile!['blood_group'].toString(), Icons.bloodtype),


          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (profile != null) {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProfile(
                  name: profile?['name'].toString() ?? 'No Name',
                  phone: profile?['phone'].toString() ?? 'No Number',
                  place: profile?['place'].toString() ?? 'No Place',
                  pin: profile?['pin'].toString() ?? 'No Pin',
                  post: profile?['post'].toString() ?? 'No Post',
                  email: profile?['email'].toString() ?? 'No Email',
                  image: profile?['photo'] != null ? '$baseUrl${profile?['photo']}' : '',
                ),
              ),
            );

            if (result == true) {
              fetchMyProfile(); // Reload data if the profile was updated
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Profile data is not available.'),
              backgroundColor: Colors.red,
            ));
          }
        },
        child: const Icon(Icons.edit),
        tooltip: 'Edit Profile',
      ),



    );
  }

  Widget buildProfileCard(String label, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value.isNotEmpty ? value : 'Not available'),
      ),
    );
  }
}
