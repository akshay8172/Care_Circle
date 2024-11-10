import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ManageUserPage extends StatefulWidget {
  const ManageUserPage({super.key});

  @override
  State<ManageUserPage> createState() => _ManageUserPageState();
}

class _ManageUserPageState extends State<ManageUserPage> {
  List<Map<String, dynamic>> organizations = [];
  late String urlBase;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeUrlBase();
  }

  Future<void> _initializeUrlBase() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    urlBase = sh.getString('url') ?? '';
    await fetchOrganizations();
  }

  String _getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return '';
    }
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    final fullUrl = '$urlBase/$cleanPath';
    print("Full Image URL: $fullUrl");
    return fullUrl;
  }

  Widget _buildOrganizationImage(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) {
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.business, size: 50, color: Colors.grey),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        _getFullImageUrl(photoUrl),
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print("Error loading image: $error");
          return Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.error, size: 50, color: Colors.grey),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }

  Future<void> fetchOrganizations() async {
    setState(() => isLoading = true);

    if (urlBase.isEmpty) {
      print("URL not found in SharedPreferences");
      setState(() => isLoading = false);
      return;
    }

    String url = '$urlBase/admin_view_users';
    print("Fetching from URL: $url");

    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'ok') {
          setState(() {
            organizations = List<Map<String, dynamic>>.from(data['org']);
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Widget _buildOrganizationCard(Map<String, dynamic> organization) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildOrganizationImage(organization['photo']),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            organization['name']?.toString() ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildInfoRow(Icons.person, organization['name']),
                        _buildInfoRow(Icons.cake, organization['age']), // Example icon for age
                        _buildInfoRow(Icons.phone, organization['phone']),
                        _buildInfoRow(Icons.person_outline, organization['gender']),
                        _buildInfoRow(Icons.email, organization['email']),
                        _buildInfoRow(
                            Icons.location_on,
                            '${organization['place']}, ${organization['post']}, ${organization['pin']}' // Combine fields
                        ),
                        _buildInfoRow(Icons.business, organization['org']),
                        _buildInfoRow(Icons.bloodtype, organization['blood_group']),
                        _buildInfoRow(Icons.verified, organization['status']),
                        _buildInfoRow(Icons.access_time, organization['is_available']
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.lock_open, color: Colors.green), // Unblock icon
                  onPressed: () => _confirmUnblock(organization['id']),
                  tooltip: 'Unblock', // Optional: tooltip for accessibility
                ),
                IconButton(
                  icon: const Icon(Icons.block, color: Colors.red), // Block icon
                  onPressed: () => _confirmDelete(organization['id']),
                  tooltip: 'Block', // Optional: tooltip for accessibility
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.black,
            size: 20.0,
          ),
          const SizedBox(width: 8.0), // Space between icon and text
          Expanded(
            child: Text(
              value?.toString() ?? 'N/A',
              style: const TextStyle(color: Colors.brown),
            ),
          ),
        ],
      ),
    );
  }


  void _confirmDelete(int orgId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Block User'),
          content: const Text('Are you sure you want to Block this User?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final success = await blockOrganization(orgId);
                if (success) {
                  await fetchOrganizations();
                }
              },
              child: const Text('Block'),
            ),
          ],
        );
      },
    );
  }

  void _confirmUnblock(int orgId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Unblock User'),
          content: const Text('Are you sure you want to Unblock this User?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final success = await unblockOrganization(orgId);
                if (success) {
                  await fetchOrganizations();
                }
              },
              child: const Text('Unblock'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> blockOrganization(int orgId) async {
    if (urlBase.isEmpty) {
      print("URL not found in SharedPreferences");
      return false;
    }
    String url = '$urlBase/admin_block_users';

    try {
      var response = await http.post(
        Uri.parse(url),
        body: json.encode({'orgId': orgId}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'ok') {
          print("User Blocked successfully");
          return true;
        }
        print("Failed to Block User: ${data['message']}");
      } else {
        print("Failed to Block User. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error Blocking User: $e");
    }
    return false;
  }

  Future<bool> unblockOrganization(int orgId) async {
    if (urlBase.isEmpty) {
      print("URL not found in SharedPreferences");
      return false;
    }
    String url = '$urlBase/admin_unblock_users';

    try {
      var response = await http.post(
        Uri.parse(url),
        body: json.encode({'orgId': orgId}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'ok') {
          print("User Unblocked successfully");
          return true;
        }
        print("Failed to Unblock User: ${data['message']}");
      } else {
        print("Failed to Unblock User. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error UnBlocking User: $e");
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage User'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : organizations.isEmpty
            ? const Center(
          child: Text(
            'No listed Users Found.',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        )
            : ListView.builder(
          itemCount: organizations.length,
          itemBuilder: (context, index) => _buildOrganizationCard(organizations[index]),
        ),
      ),
    );
  }
}