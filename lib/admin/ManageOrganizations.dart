import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ManageOrganizationsPage extends StatefulWidget {
  const ManageOrganizationsPage({super.key});

  @override
  State<ManageOrganizationsPage> createState() => _ManageOrganizationsPageState();
}

class _ManageOrganizationsPageState extends State<ManageOrganizationsPage> {
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

    String url = '$urlBase/admin_view_organization';
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
          print("Failed to fetch organizations: ${data['message']}");
          setState(() => isLoading = false);
        }
      } else {
        print("Failed to load organizations. Status code: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching organizations: $e");
      setState(() => isLoading = false);
    }
  }

  Widget _buildOrganizationCard(Map<String, dynamic> organization) {
    bool isBlocked = organization['LOGIN'] == 'blocked';

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
                        _buildInfoRow(Icons.location_city, organization['place']),
                        _buildInfoRow(Icons.pin_drop, organization['pin']),
                        _buildInfoRow(Icons.location_on, organization['post']),
                        _buildInfoRow(Icons.phone, organization['phone']),
                        _buildInfoRow(Icons.verified_user, organization['LOGIN']),
                        _buildInfoRow(Icons.email, organization['email']),
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
                isBlocked
                    ? ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.green,
                  ),
                  onPressed: () => _confirmUnblock(organization['id']),
                  icon: const Icon(Icons.lock_open),
                  label: const Text('Unblock'),
                )
                    : ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  onPressed: () => _confirmDelete(organization['id']),
                  icon: const Icon(Icons.block),
                  label: const Text('Block'),
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
              style: const TextStyle(color: Colors.black87),
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
          title: const Text('Block Organization'),
          content: const Text('Are you sure you want to Block this organization?'),
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
          title: const Text('Unblock Organization'),
          content: const Text('Are you sure you want to Unblock this organization?'),
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
    String url = '$urlBase/admin_block_organization';

    try {
      var response = await http.post(
        Uri.parse(url),
        body: json.encode({'orgId': orgId}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'ok') {
          print("Organization Blocked successfully");
          return true;
        }
        print("Failed to Block organization: ${data['message']}");
      } else {
        print("Failed to Block organization. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error Blocking organization: $e");
    }
    return false;
  }

  Future<bool> unblockOrganization(int orgId) async {
    if (urlBase.isEmpty) {
      print("URL not found in SharedPreferences");
      return false;
    }
    String url = '$urlBase/admin_unblock_organization';

    try {
      var response = await http.post(
        Uri.parse(url),
        body: json.encode({'orgId': orgId}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'ok') {
          print("Organization Unblocked successfully");
          return true;
        }
        print("Failed to Unblock organization: ${data['message']}");
      } else {
        print("Failed to Unblock organization. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error UnBlocking organization: $e");
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Organizations'),
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
            'No listed organizations Found.',
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