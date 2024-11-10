import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';


class ViewComplaints extends StatefulWidget {
  const ViewComplaints({super.key});

  @override
  State<ViewComplaints> createState() => _ViewComplaintsState();
}

class _ViewComplaintsState extends State<ViewComplaints> {
  List<dynamic>? complaints;
  String baseUrl = '';

  @override
  void initState() {
    super.initState();
    fetchComplaints();
  }

  Future<void> fetchComplaints() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url') ?? '';
      baseUrl = sh.getString('imgurl') ?? '';
      String lid = sh.getString("lid") ?? '';

      String url = '$urls/AdminViewComplaint';
      var response = await http.post(
        Uri.parse(url),
        // body: {
        //   'org_id': lid,
        // },
      );

      var jsondata = json.decode(response.body);
      if (jsondata['status'] == 'ok' && jsondata['complaints'] is List && jsondata['complaints'].isNotEmpty) {
        setState(() {
          complaints = jsondata['complaints'];
        });
      } else {
        Fluttertoast.showToast(
          msg: "No Complaint available",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> sendReply(int complaintId, String reply) async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url') ?? '';

      String url = '$urls/AdminSendReply'; // Replace with your actual endpoint for sending replies
      var response = await http.post(
        Uri.parse(url),
        body: {
          'complaint_id': complaintId.toString(),
          'reply': reply,
        },
      );

      var jsondata = json.decode(response.body);
      if (jsondata['status'] == 'ok') {
        fetchComplaints(); // Refresh complaints after sending reply
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reply sent successfully!')),
        );
      } else {
        print('Failed to send reply');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Complaints', style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold)),
        backgroundColor: Colors.lightGreen,
      ),
      body: Container(
        color: Colors.green[100], // Slight green background
        child: complaints == null
            ? Center()
            : complaints!.isEmpty
            ? Center(
          child: Text(
            'No complaints available',
            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontFamily: 'Arial'),
          ),
        )
            : ListView.builder(
          itemCount: complaints!.length,
          itemBuilder: (context, index) {
            var complaint = complaints![index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              elevation: 4, // Add elevation for a better shadow effect
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.person, size: 20, color: Colors.grey[600]),
                        SizedBox(width: 8),
                        Text(
                          '${complaint['user'] ?? 'Unknown User'}',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600], fontFamily: 'Arial'),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.date_range, size: 20, color: Colors.grey[600]),
                        SizedBox(width: 8),
                        Text(
                          '${complaint['date'] ?? 'No Date'}',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600], fontFamily: 'Arial'),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.comment, size: 20, color: Colors.green),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${complaint['complaint'] ?? 'No Complaint'}',
                            style: TextStyle(fontSize: 16, fontFamily: 'Arial'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    complaint['reply'] == 'pending' || complaint['reply'].isEmpty
                        ? ElevatedButton(
                      onPressed: () {
                        showReplyDialog(complaint['id']);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Button color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // Rounded corners
                        ),
                      ),
                      child: const Text('Send Reply', style: TextStyle(fontFamily: 'Arial')),
                    )
                        : Row(
                      children: [
                        Icon(Icons.reply, size: 20, color: Colors.brown),
                        SizedBox(width: 8),
                        Text(
                          '${complaint['reply']}',
                          style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.brown),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }


  void showReplyDialog(int complaintId) {
    TextEditingController replyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Send Reply', style: TextStyle(fontFamily: 'Arial')),
          content: TextField(
            controller: replyController,
            decoration: const InputDecoration(hintText: 'Enter your reply'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(fontFamily: 'Arial')),
            ),
            TextButton(
              onPressed: () {
                sendReply(complaintId, replyController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Send', style: TextStyle(fontFamily: 'Arial')),
            ),
          ],
        );
      },
    );
  }
}
