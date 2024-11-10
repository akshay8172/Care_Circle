import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SendComplaintAboutEvent extends StatefulWidget {
  final String eventId;

  const SendComplaintAboutEvent({Key? key, required this.eventId}) : super(key: key);

  @override
  State<SendComplaintAboutEvent> createState() => _SendComplaintAboutEventState();
}

class _SendComplaintAboutEventState extends State<SendComplaintAboutEvent> {
  TextEditingController complaintController = TextEditingController();

  Future<void> submitComplaint() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String lid = sh.getString("lid").toString();
    String url = '${sh.getString('url')}/SendComplaintAboutEvent';

    var response = await http.post(
      Uri.parse(url),
      body: {
        'id': lid,
        'event_id': widget.eventId,
        'complaint': complaintController.text,
      },
    );

    var responseData = json.decode(response.body);
    if (responseData['status'] == 'ok') {
      Fluttertoast.showToast(msg: 'Complaint submitted successfully');
      Navigator.pop(context, true); // Pass `true` to indicate success
    } else {
      Fluttertoast.showToast(msg: 'Already Submitted, Check the complaint page to see reply');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Complaint'),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Complaint',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: complaintController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Write your complaint here',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: submitComplaint,
                child: const Text('Submit Complaint'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
