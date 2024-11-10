import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:care_circle_new/organization/ChatWithUser.dart';

class ViewMyAvailableUsers extends StatefulWidget {
  const ViewMyAvailableUsers({Key? key}) : super(key: key);

  @override
  _ViewMyAvailableUsersState createState() => _ViewMyAvailableUsersState();
}

class _ViewMyAvailableUsersState extends State<ViewMyAvailableUsers> {
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];
  String baseUrl = '';
  String searchQuery = '';
  String? selectedGender;

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
      String url = '$urls/org_view_available_vol';
      String lid = sh.getString('lid').toString();
      var response = await http.post(
        Uri.parse(url),
        body: {
          'id': lid,
        },
      );

      var jsondata = json.decode(response.body);
      if (jsondata['status'] == 'ok' && jsondata['users'] != null) {
        setState(() {
          users = List<Map<String, dynamic>>.from(jsondata['users']);
          filteredUsers = users;  // Initially, display all users
        });
      } else {
        print('Failed to fetch users');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _filterUsers() {
    setState(() {
      filteredUsers = users.where((user) {
        final matchesGender = selectedGender == null || user['gender'] == selectedGender;
        final matchesName = user['name']
            .toString()
            .toLowerCase()
            .contains(searchQuery.toLowerCase());
        return matchesGender && matchesName;
      }).toList();
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown.shade50,
      appBar: AppBar(
        title: Text("View Available Users"),
        backgroundColor: Colors.brown,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Search by name',
                      prefixIcon: Icon(Icons.search, color: Colors.brown),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      searchQuery = value;
                      _filterUsers();
                    },
                  ),
                ),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedGender,
                  hint: Text("Gender"),
                  items: <String>['Male', 'Female', 'Other']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedGender = newValue;
                      _filterUsers();
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredUsers.isEmpty
                ? Center(
              child: Text(
                "No users available",
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => _showFullImage(imageUrl),
                              child: CircleAvatar(
                                radius: 40,
                                backgroundImage: user['photo'] != null
                                    ? NetworkImage(imageUrl)
                                    : null,
                                child: user['photo'] == null
                                    ? Icon(Icons.person, size: 40)
                                    : null,
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user['name'] ?? 'No Name',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.brown.shade800,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    user['is_available'] ?? false
                                        ? 'Unavailable'
                                        : 'Available',
                                    style: TextStyle(
                                      color: (user['is_available'] ?? false)
                                          ? Colors.red
                                          : Colors.green,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Divider(color: Colors.brown.shade400),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            children: [
                              // User information rows
                              userInfoRow(Icons.cake, '', user['age'].toString()),
                              userInfoRow(Icons.phone, '', user['phone'].toString()),
                              userInfoRow(Icons.location_city, '', user['place'].toString()),
                              userInfoRow(Icons.home, '', user['post'].toString()),
                              userInfoRow(Icons.location_on, '', user['pin'].toString()),
                              userInfoRow(Icons.male, '', user['gender'].toString()),
                              userInfoRow(Icons.mail, '', user['email'].toString()),
                              userInfoRow(Icons.bloodtype, '', user['blood_group'].toString()),

                              // Add ElevatedButton below user information
                              ElevatedButton(
                                onPressed: () async {
                                  SharedPreferences sh = await SharedPreferences.getInstance();
                                  sh.setString('clid',user['LOGIN'].toString());
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
                        )

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

  Widget userInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.brown),
          SizedBox(width: 10),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.brown.shade700,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.brown.shade600),
            ),
          ),
        ],
      ),
    );
  }
}
