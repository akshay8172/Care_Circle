import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:care_circle_new/user/SendFeedbackAboutEvent.dart';
import 'package:care_circle_new/user/SendComplaintAboutEvent.dart';

class ViewMorePastEvents extends StatefulWidget {
  final String eventId;

  const ViewMorePastEvents({Key? key, required this.eventId}) : super(key: key);

  @override
  State<ViewMorePastEvents> createState() => _ViewMorePastEventsState();
}

class _ViewMorePastEventsState extends State<ViewMorePastEvents> {
  List events = [];
  List filteredEvents = [];
  String baseUrl = '';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchMyEvents();
  }

  Future fetchMyEvents() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url') ?? '';
      baseUrl = sh.getString('imgurl') ?? '';
      String url = '$urls/ViewMorePastEvents';

      var response = await http.post(
        Uri.parse(url),
        body: {
          'event_id': widget.eventId,
        },
      );

      var jsondata = json.decode(response.body);
      if (jsondata['status'] == 'ok' && jsondata['events'] is List) {
        setState(() {
          events = List.from(jsondata['events']);
          filteredEvents = events;
        });

        for (var event in filteredEvents) {
          await fetchEventFeedbackAndComplaints(event['id'].toString());
        }
      } else {
        print('Failed to fetch Events');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> fetchEventFeedbackAndComplaints(String eventId) async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url') ?? '';
      String lid = sh.getString("lid") ?? '';

      // Fetch feedbacks
      var feedbackResponse = await http.post(
        Uri.parse('$urls/ViewPostedEventFeedback'),
        body: {
          'event_id': eventId,
          'user_id': lid
        },
      );

      var feedbackData = json.decode(feedbackResponse.body);
      print('Feedback Data: $feedbackData');

      // Fetch complaints
      var complaintResponse = await http.post(
        Uri.parse('$urls/ViewEventComplaintReply'),
        body: {
          'event_id': eventId,
          'user_id': lid
        },
      );

      var complaintData = json.decode(complaintResponse.body);
      print('Complaint Data: $complaintData');

      setState(() {
        var eventIndex = filteredEvents.indexWhere((event) => event['id'].toString() == eventId);
        if (eventIndex != -1) {
          if (feedbackData['status'] == 'ok') {
            filteredEvents[eventIndex]['feedbacks'] = feedbackData['events'] ?? [];
          }
          if (complaintData['status'] == 'ok') {
            filteredEvents[eventIndex]['complaints'] = complaintData['events'] ?? [];
          }
        }
      });
    } catch (e) {
      print('Error in fetchEventFeedbackAndComplaints: $e');
      Fluttertoast.showToast(
        msg: "Failed to load feedback and complaints",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }

  Widget _buildFeedbackCard(Map feedback) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3.0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.feedback_outlined, color: Colors.blue),
                const SizedBox(width: 8.0),
                const Text(
                  'Feedback',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  feedback['date'] ?? 'No date',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            if (feedback['rating'] != null) ...[
              _buildRatingStars(double.parse(feedback['rating'].toString())),
              const SizedBox(height: 8.0),
            ],
            Text(
              feedback['feedback'] ?? 'No feedback provided',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintCard(Map complaint) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3.0,
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.report_problem_outlined, color: Colors.red.shade700),
                const SizedBox(width: 8.0),
                const Text(
                  'Complaint',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  complaint['date'] ?? 'No date',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              complaint['complaint'] ?? 'No complaint details',
              style: const TextStyle(fontSize: 14),
            ),
            if (complaint['reply'] != null && complaint['reply'] != 'No reply yet') ...[
              const SizedBox(height: 8.0),
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.reply, size: 16, color: Colors.grey),
                        SizedBox(width: 4.0),
                        Text(
                          'Reply:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      complaint['reply'],
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Past Events',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.brown,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: filteredEvents.isNotEmpty
                ? ListView.builder(
              itemCount: filteredEvents.length,
              itemBuilder: (context, index) {
                final event = filteredEvents[index];
                final bool hasFeedback = event['has_feedback'] ?? false;
                final bool hasComplaint = event['has_complaint'] ?? false;

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // Event Details Section
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.event, size: 28, color: Colors.blue),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  child: Text(
                                    event['event_name'],
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12.0),
                            GestureDetector(
                              onTap: () => showEnlargedImage('$baseUrl${event['photo']}'),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  '$baseUrl${event['photo']}',
                                  fit: BoxFit.cover,
                                  height: 200,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            Text(
                              event['event_details'],
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12.0),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 20, color: Colors.black54),
                                const SizedBox(width: 5.0),
                                Text(': ${event['event_date']}', style: const TextStyle(color: Colors.black54)),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 20, color: Colors.black54),
                                const SizedBox(width: 5.0),
                                Text(': ${event['venue']}', style: const TextStyle(color: Colors.black54)),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Conditionally show Feedback and Complaints Buttons
                      if (!hasFeedback || !hasComplaint) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              if (!hasFeedback)
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SendFeedbackAboutEvent(eventId: event['id'].toString()),
                                        ),
                                      );
                                      if (result == true) {
                                        fetchMyEvents();
                                      }
                                    },
                                    icon: const Icon(Icons.feedback),
                                    label: const Text("Give Feedback"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                              if (!hasFeedback && !hasComplaint)
                                const SizedBox(width: 8.0),
                              if (!hasComplaint)
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SendComplaintAboutEvent(eventId: event['id'].toString()),
                                        ),
                                      );
                                      if (result == true) {
                                        fetchMyEvents();
                                      }
                                    },
                                    icon: const Icon(Icons.report_problem),
                                    label: const Text("File Complaint"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],

                      // Feedback and Complaints Sections
                      if (event['feedbacks']?.isNotEmpty ?? false) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Divider(),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            children: [
                              ...event['feedbacks'].map<Widget>((feedback) => _buildFeedbackCard(feedback)).toList(),
                            ],
                          ),
                        ),
                      ],

                      if (event['complaints']?.isNotEmpty ?? false) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Divider(),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            children: [
                              ...event['complaints'].map<Widget>((complaint) => _buildComplaintCard(complaint)).toList(),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 16.0),
                    ],
                  ),
                );
              },
            )
                : const Center(
              child: Text(
                'No past events to show',
                style: TextStyle(fontSize: 20, color: Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showEnlargedImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SizedBox(
          height: 400,
          child: Image.network(imageUrl, fit: BoxFit.cover),
        ),
      ),
    );
  }
}