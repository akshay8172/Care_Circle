import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SendFeedbackAboutEvent extends StatefulWidget {
  final String eventId;

  const SendFeedbackAboutEvent({Key? key, required this.eventId}) : super(key: key);

  @override
  State<SendFeedbackAboutEvent> createState() => _SendFeedbackAboutEventState();
}

class _SendFeedbackAboutEventState extends State<SendFeedbackAboutEvent> {
  int rating = 0;
  TextEditingController feedbackController = TextEditingController();

  Future<void> submitFeedback() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String lid = sh.getString("lid").toString();
    String url = '${sh.getString('url')}/SendFeedbackAboutEvent';

    var response = await http.post(
      Uri.parse(url),
      body: {
        'id': lid,
        'event_id': widget.eventId,
        'feedback': feedbackController.text,
        'rating': rating.toString(),
      },
    );

    var responseData = json.decode(response.body);
    if (responseData['status'] == 'ok') {
      Fluttertoast.showToast(msg: 'Feedback submitted successfully');
      Navigator.pop(context, true); // Pass `true` to indicate success
    } else {
      Fluttertoast.showToast(msg: 'Already Submitted');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Feedback'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rate the Event',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    setState(() {
                      rating = index + 1;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 20),
            const Text(
              'Your Feedback',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: feedbackController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Write your feedback here',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: submitFeedback,
                child: const Text('Submit Feedback'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
