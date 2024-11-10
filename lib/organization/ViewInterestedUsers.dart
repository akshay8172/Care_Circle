import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ViewInterestedVolunteers extends StatefulWidget {
  final String id; // Event ID parameter

  const ViewInterestedVolunteers({Key? key, required this.id}) : super(key: key);

  @override
  State<ViewInterestedVolunteers> createState() => _ViewInterestedVolunteersState();
}

class _ViewInterestedVolunteersState extends State<ViewInterestedVolunteers> {
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];
  String baseUrl = '';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchMyUsers();
  }

  Future<void> fetchMyUsers() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url').toString();
      baseUrl = sh.getString('imgurl') ?? '';
      String url = '$urls/ViewInterestedVolunteers';
      var response = await http.post(
        Uri.parse(url),
        body: {
          'event_id': widget.id,
        },
      );

      // Decode the response directly from the response body
      var jsondata = json.decode(response.body); // Decode JSON response

      print('JSON Response =========++++++++=========: $jsondata');

      if (jsondata['status'] == 'ok' && jsondata['responses'] != null) {
        setState(() {
          users = List<Map<String, dynamic>>.from(jsondata['responses']);
          filteredUsers = users; // Initialize filtered list
        });
      } else {
        print('Failed to fetch users');
      }
    } catch (e) {
      print('Error: $e');
    }
  }



  void _showFullImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(imageUrl, fit: BoxFit.cover),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _searchUser(String query) {
    setState(() {
      searchQuery = query;
      filteredUsers = users
          .where((user) =>
          user['name'].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown.shade50,
      appBar: AppBar(
        title: const Text("Interested Volunteers"),
        backgroundColor: Colors.brown,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _searchUser,
              decoration: InputDecoration(
                hintText: 'Search by name',
                prefixIcon: Icon(Icons.search, color: Colors.brown),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.brown),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredUsers.isEmpty
                ? Center(
              child: Text(
                "No volunteers found",
                style: TextStyle(color: Colors.brown, fontSize: 18),
              ),
            )
                : ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (BuildContext context, int index) {
                String imageUrl = '$baseUrl${filteredUsers[index]['photo']}';
                final user = filteredUsers[index];
                return Card(
                  color: Colors.brown.shade100,
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => _showFullImage(imageUrl),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundImage: user['photo'] != null
                                ? NetworkImage(imageUrl)
                                : null,
                            child: user['photo'] == null
                                ? Icon(Icons.person, size: 30)
                                : null,
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.person, color: Colors.blueGrey),
                                  SizedBox(width: 8),
                                  Text(
                                    user['name'] ?? 'No Name',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.email, color: Colors.blueGrey),
                                  SizedBox(width: 8),
                                  Text(
                                    user['email'] ?? 'No Email',
                                    style: TextStyle(
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.phone, color: Colors.blueGrey),
                                  SizedBox(width: 8),
                                  Text(
                                    user['phone']?.toString() ?? 'No Phone', // Convert to string
                                    style: TextStyle(
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.cake, color: Colors.blueGrey),
                                  SizedBox(width: 8),
                                  Text(
                                    user['age']?.toString() ?? 'No Age', // Convert to string
                                    style: TextStyle(
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.transgender, color: Colors.blueGrey),
                                  SizedBox(width: 8),
                                  Text(
                                    user['gender'] ?? 'No Gender',
                                    style: TextStyle(
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.bloodtype, color: Colors.blueGrey),
                                  SizedBox(width: 8),
                                  Text(
                                    user['blood_group'] ?? 'No Blood Group',
                                    style: TextStyle(
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.date_range, color: Colors.blueGrey),
                                  SizedBox(width: 8),
                                  Text(
                                    user['date']?.toString() ?? 'No date', // Convert to string
                                    style: TextStyle(
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),


                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
