import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:care_circle_new/main_files/login.dart';
import 'package:care_circle_new/organization/view_users.dart';
import 'package:care_circle_new/organization/view_events.dart';
import 'package:care_circle_new/organization/view_profile.dart';
import 'package:care_circle_new/organization/ViewAvalableUsers.dart';
import 'package:care_circle_new/organization/ViewFeedbacks.dart';
import 'package:care_circle_new/organization/ViewComplaints.dart';
import 'package:care_circle_new/organization/ChatWithAdmin.dart';


class OrganizationHome extends StatefulWidget {
  const OrganizationHome({Key? key}) : super(key: key);

  @override
  State<OrganizationHome> createState() => _OrganizationHomeState();
}


class _OrganizationHomeState extends State<OrganizationHome> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'Home Page',
            style: TextStyle(color: Colors.white), // Set the text color to white
          ),
        backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),

        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: (){
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Login()),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Banner Section
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    image: AssetImage('assets/images/circle.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Navigation Cards
              Card(
                elevation: 5,
                child: ListTile(
                  leading: Icon(Icons.list),
                  title: Text('Manage Profile'),
                  onTap: () async {
                    final sh = await SharedPreferences.getInstance();
                    String lid = sh.getString("lid").toString();
                    Navigator.push(context, MaterialPageRoute(builder: (context) => MyProfile(userId: lid),
                    ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 5,
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Manage Users'),
                  onTap: () async {
                    final sh = await SharedPreferences.getInstance();
                    String lid = sh.getString("lid").toString();
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ViewMyUsers(userId: lid),
                    ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 5,
                child: ListTile(
                  leading: Icon(Icons.comment),
                  title: Text('Chat With Admin'),
                  onTap: () async {
                    SharedPreferences sh = await SharedPreferences.getInstance();
                    sh.setString('clid',1.toString());
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyChatPage(title: '',)),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 5,
                child: ListTile(
                  leading: Icon(Icons.people_alt),
                  title: Text('View Available Volunteer'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ViewMyAvailableUsers()),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 5,
                child: ListTile(
                  leading: Icon(Icons.report_outlined),
                  title: Text('Manage Complaints'),
                  onTap: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ViewComplaints()),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 5,
                child: ListTile(
                  leading: Icon(Icons.star),
                  title: Text('View Feedbacks'),
                  onTap: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ViewFeedbacks()),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 5,
                child: ListTile(
                  leading: Icon(Icons.send),
                  title: Text('Manage Events'),
                  onTap: () async {
                    final sh = await SharedPreferences.getInstance();
                    String lid = sh.getString("lid").toString();
                    // Navigate to Manage Complaints Page
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ViewEvents(userId: lid),
                    ),
                    );
                  },
                ),
              ),
              // Product Categories

            ],
          ),
        ),
      ),
    );
  }
}

