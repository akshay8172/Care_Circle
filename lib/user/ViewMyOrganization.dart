import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:care_circle_new/user/ChatWithOrg.dart';

class ViewMyOrganization extends StatefulWidget {
  const ViewMyOrganization({super.key});

  @override
  State<ViewMyOrganization> createState() => _ViewMyOrganizationState();
}

class _ViewMyOrganizationState extends State<ViewMyOrganization> {
  Map<String, dynamic>? org;
  String baseUrl = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMyOrganization();
  }

  Future<void> fetchMyOrganization() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url') ?? '';
      baseUrl = sh.getString('imgurl') ?? '';
      String lid = sh.getString("lid") ?? '';

      String url = '$urls/ViewMyOrganization';
      var response = await http.post(
        Uri.parse(url),
        body: {
          'user_id': lid,
        },
      );

      var jsondata = json.decode(response.body);
      if (jsondata['status'] == 'ok' && jsondata['profile'] is List && jsondata['profile'].isNotEmpty) {
        setState(() {
          org = jsondata['profile'][0];
          isLoading = false;
        });
      } else {
        print('Failed to fetch organization data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _showImageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Semi-transparent background
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  color: Colors.black87,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              // Image
              InteractiveViewer(
                panEnabled: true,
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 4,
                child: Image.network(
                  '$baseUrl${org!['photo']}',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 50,
                    );
                  },
                ),
              ),
              // Close button
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Organization'),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            // Profile Section with Single Image
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Single Organization Image with Tap Gesture
                  GestureDetector(
                    onTap: org!['photo'] != null ? _showImageDialog : null,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.blueAccent,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 80,
                            backgroundColor: Colors.white,
                            backgroundImage: org!['photo'] != null
                                ? NetworkImage('$baseUrl${org!['photo']}')
                                : const AssetImage('assets/images/placeholder.png')
                            as ImageProvider,
                          ),
                          if (org!['photo'] != null)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withOpacity(0.1),
                                ),
                                // child: const Icon(
                                //   // Icons.zoom_in,
                                //   color: Colors.white,
                                //   size: 40,
                                // ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Organization Name
                  Text(
                    org!['name'] ?? 'No Name',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Established in ${org!['established_year']}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  SizedBox(height: 12), // Add some spacing between the text and button

                  ElevatedButton(
                    onPressed: () async {
                      SharedPreferences sh = await SharedPreferences.getInstance();
                      sh.setString('clid',org!['LOGIN'].toString());
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyChatPage(title: '',)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Set the background color to green
                    ),
                    child: Icon(Icons.chat),
                  ),
                ],
              ),
            ),

            // Organization Details Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Organization Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Info Cards
                  buildInfoCard(
                    Icons.location_city,
                    'Address',
                    org!['place'].toString(),
                    Colors.indigo,
                  ),
                  buildInfoCard(
                    Icons.pin_drop,
                    'Pin Code',
                    org!['pin'].toString(),
                    Colors.red,
                  ),
                  buildInfoCard(
                    Icons.location_on,
                    'Post',
                    org!['post'].toString(),
                    Colors.orange,
                  ),
                  buildInfoCard(
                    Icons.phone,
                    'Phone',
                    org!['phone'].toString(),
                    Colors.green,
                  ),
                  buildInfoCard(
                    Icons.email,
                    'Email',
                    org!['email'].toString(),
                    Colors.purple,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoCard(IconData icon, String title, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          value.isNotEmpty ? value : 'Not available',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}