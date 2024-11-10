import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';


class ViewFeedbacks extends StatefulWidget {
  const ViewFeedbacks({super.key});

  @override
  State<ViewFeedbacks> createState() => _ViewFeedbacksState();
}

class _ViewFeedbacksState extends State<ViewFeedbacks> {
  List<dynamic>? feedbacks;
  String baseUrl = '';

  @override
  void initState() {
    super.initState();
    fetchFeedbacks();
  }


  Future<void> fetchFeedbacks() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url') ?? '';
      baseUrl = sh.getString('imgurl') ?? '';
      String lid = sh.getString("lid") ?? '';

      String url = '$urls/ViewFeedbacks';
      var response = await http.post(
        Uri.parse(url),
        body: {
          'org_id': lid,
        },
      );

      var jsondata = json.decode(response.body);
      if (jsondata['status'] == 'ok' && jsondata['feedbacks'] is List && jsondata['feedbacks'].isNotEmpty) {
        setState(() {
          feedbacks = jsondata['feedbacks'];
        });
      } else {
        // Show toast message when no feedbacks available
        Fluttertoast.showToast(
          msg: "No complaints available",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
        // Stop reloading by ensuring the data fetch flag doesn't trigger again
      }
    } catch (e) {
      print('Error: $e');
      Fluttertoast.showToast(
        msg: "Error fetching feedbacks",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
  }


  void _showImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Image.network(imageUrl),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Feedbacks'),
      ),
      body: feedbacks == null
          ? Center()
          : ListView.builder(
        itemCount: feedbacks!.length,
        itemBuilder: (context, index) {
          var feedback = feedbacks![index];
          String? eventPhoto = feedback['photo']; // Handle potential null
          String imageUrl = (eventPhoto != null && eventPhoto.isNotEmpty)
              ? '$baseUrl$eventPhoto'
              : ''; // Construct image URL safely

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feedback['event'] ?? 'No Event Name',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          feedback['sender'] ?? 'Unknown Sender',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          feedback['event_date'] ?? 'No Date',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        SizedBox(height: 4),
                        Text(
                          feedback['feedback'] ?? 'No Feedback',
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 4),
                        RatingBarIndicator(
                          rating: feedback['rating']?.toDouble() ?? 0,
                          itemCount: 5,
                          itemSize: 20.0,
                          direction: Axis.horizontal,
                          itemBuilder: (context, index) => Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                        ),
                        SizedBox(height: 4),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () => _showImage(imageUrl),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                          imageUrl,
                          height: 60,
                          width: 60,
                          fit: BoxFit.cover,
                        )
                            : Container(
                          height: 60,
                          width: 60,
                          color: Colors.grey, // Placeholder if no image
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
