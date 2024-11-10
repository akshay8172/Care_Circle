import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:care_circle_new/organization/Add_new_User.dart';

class ViewMyUsers extends StatefulWidget {
  final String userId;
  const ViewMyUsers({Key? key, required this.userId}) : super(key: key);

  @override
  _ViewMyUsersState createState() => _ViewMyUsersState();
}

class _ViewMyUsersState extends State<ViewMyUsers> {
  List<Map<String, dynamic>> users = [];
  String baseUrl = '';

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
      String url = '$urls/org_view_vol';
      var response = await http.post(
        Uri.parse(url),
        body: {
          'user_id': widget.userId,
        },
      );

      var jsondata = json.decode(response.body);
      if (jsondata['status'] == 'ok' && jsondata['users'] != null) {
        setState(() {
          users = List<Map<String, dynamic>>.from(jsondata['users']);
        });
      } else {
        print('Failed to fetch users');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> deleteUser(String volId) async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String url = '${sh.getString('url')}/org_delete_vol';
      var response = await http.post(
        Uri.parse(url),
        body: {
          'id': volId,
        },
      );

      var jsondata = json.decode(response.body);
      if (jsondata['status'] == 'ok') {
        // After successful deletion, refresh the user list
        fetchMyUsers();
      } else {
        print('Failed to delete user');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Users"),
      ),
      body: users.isEmpty
          ? Center(child: Text("No users available"))
          : ListView.builder(
        itemCount: users.length,
        itemBuilder: (BuildContext context, int index) {
          String imageUrl = '$baseUrl${users[index]['photo']}';
          final user = users[index];
          return Card(
            margin: EdgeInsets.all(10),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: user['photo'] != null
                            ? NetworkImage(imageUrl)
                            : null,
                        child: user['photo'] == null
                            ? Icon(Icons.person, size: 40)
                            : null,
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user['name'] ?? 'No Name',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              user['is_available']
                                  ? 'Available'
                                  : 'Unavailable',
                              style: TextStyle(
                                color: user['is_available']
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Delete User'),
                              content: Text(
                                  'Are you sure you want to delete this user?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    deleteUser(user['LOGIN'].toString());
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Yes'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('No'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        userInfoRow(Icons.cake, 'Age', user['age'].toString()),
                        userInfoRow(Icons.phone, 'Phone', user['phone'].toString()),
                        userInfoRow(Icons.location_on, 'Place', user['place']),
                        userInfoRow(Icons.mail, 'Email', user['email']),
                        userInfoRow(Icons.bloodtype, 'Blood Group', user['blood_group']),
                        userInfoRow(Icons.home, 'Post', user['post']),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final sh = await SharedPreferences.getInstance();
          String lid = sh.getString("lid").toString();
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNewUser(userId: lid),
            ),
          );

          if (result == true) {
            fetchMyUsers();
          }
        },
        backgroundColor: Colors.cyan,
        child: const Icon(Icons.add),
        tooltip: 'Add New User',
      ),
    );
  }

  Widget userInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.black),
          SizedBox(width: 10),
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(value),
        ],
      ),
    );
  }
}
