import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AppComplaint extends StatefulWidget {
  const AppComplaint({super.key});

  @override
  State<AppComplaint> createState() => _AppComplaintState();
}

class _AppComplaintState extends State<AppComplaint> {
  final TextEditingController complaintController = TextEditingController();
  List complaints = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchComplaints();
  }


  // View Complaint Function
  void fetchComplaints() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url') ?? '';
    String lid = sh.getString("lid").toString();
    final Uri apiUrl = Uri.parse('$url/ViewMyComplaints');

    try {
      final response = await http.post(apiUrl, body: {'id': lid});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'ok') {
          setState(() {
            complaints = data['complaint'];
            isLoading = false;
          });
        } else {
          Fluttertoast.showToast(msg: 'Failed to load complaints.');
          setState(() {
            isLoading = false;
          });
        }
      } else {
        Fluttertoast.showToast(msg: 'Network Error');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      setState(() {
        isLoading = false;
      });
    }
  }

  // Send Complaint Function
  void sendComplaint() async {
    String complaint = complaintController.text.trim();
    if (complaint.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter your complaint');
      return;
    }
    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url') ?? '';
    String lid = sh.getString("lid").toString();
    final Uri apiUrl = Uri.parse('$url/SendAppComplaint');

    try {
      final response = await http.post(apiUrl, body: {
        'id': lid,
        'complaint': complaint,
      });

      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status == 'ok') {
          Fluttertoast.showToast(msg: 'Complaint sent successfully!');
          complaintController.clear(); // Clear the input after sending
          fetchComplaints(); // Refresh the complaints list
        } else {
          Fluttertoast.showToast(msg: 'Failed to send complaint. Please try again.');
        }
      } else {
        Fluttertoast.showToast(msg: 'Network Error');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }


  // Delete complaint Function
  void deleteComplaint(String complaintId) async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url') ?? '';
    final Uri apiUrl = Uri.parse('$url/DeleteMyComplaint');

    try {
      final response = await http.post(apiUrl, body: {
        'complaint_id': complaintId,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'ok') {
          Fluttertoast.showToast(msg: 'Complaint deleted successfully!');
          fetchComplaints(); // Refresh the complaints list
        } else {
          Fluttertoast.showToast(msg: data['message'] ?? 'Failed to delete complaint.');
        }
      } else {
        Fluttertoast.showToast(msg: 'Network Error');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Complaints'),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : complaints.isEmpty
          ? Center(child: Text('No complaints yet.', style: TextStyle(fontSize: 18, color: Colors.black54)))
          : ListView.builder(
        itemCount: complaints.length,
        itemBuilder: (context, index) {
          final complaint = complaints[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(Icons.warning, color: Colors.orange),
              title: Text(complaint['complaint'], style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Text('Date: ${complaint['date']}', style: TextStyle(color: Colors.grey[700])),
                  Text('Reply: ${complaint['reply'] ?? 'No reply yet'}', style: TextStyle(color: Colors.grey[700])),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  // Confirm before deleting
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Delete Complaint'),
                        content: Text('Are you sure you want to delete this complaint?'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text('Delete'),
                            onPressed: () {
                              deleteComplaint(complaint['id'].toString());
                              Navigator.of(context).pop(); // Close the dialog
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('New Complaint'),
                content: TextField(
                  controller: complaintController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Type your complaint here...',
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Text('Send'),
                    onPressed: () {
                      sendComplaint();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }
}
