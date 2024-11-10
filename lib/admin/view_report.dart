import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ViewReport extends StatefulWidget {
  const ViewReport({super.key});

  @override
  State<ViewReport> createState() => _ViewReportState();
}

class _ViewReportState extends State<ViewReport> {
  List<Map<String, dynamic>> events = [];
  List<Map<String, dynamic>> filteredEvents = [];
  String baseUrl = '';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchMyEvents();
  }

  Future<void> fetchMyEvents() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url') ?? '';
      baseUrl = sh.getString('imgurl') ?? '';
      String url = '$urls/AdminViewEvents';
      var response = await http.post(
        Uri.parse(url),
      );

      var jsondata = json.decode(response.body);
      if (jsondata['events'] is List) {
        setState(() {
          events = List<Map<String, dynamic>>.from(jsondata['events']);
          filteredEvents = events; // Initialize filtered list
        });
      } else {
        print('Failed to fetch Events');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void updateSearch(String query) {
    setState(() {
      searchQuery = query;
      filteredEvents = events.where((event) {
        return event['event_name']
            .toLowerCase()
            .contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Reports'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearchDialog();
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFE7D5C3), // Slight brown background
      body: filteredEvents.isEmpty
          ? (events.isEmpty
          ? const Center(
        child: Text(
          'No reports to show',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : const Center(child: CircularProgressIndicator()))
          : ListView.builder(
        itemCount: filteredEvents.length,
        itemBuilder: (context, index) {
          final event = filteredEvents[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: const Color(0xFFD5E8D4), // Light green card background
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['event_name'],
                    style: const TextStyle(
                        fontSize: 20, // Smaller font size
                        fontWeight: FontWeight.bold,
                        color: Colors.teal),
                  ),
                  const SizedBox(height: 10),
                  if (event['photo_url'] != null)
                    GestureDetector(
                      onTap: () {
                        // Show enlarged image
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: SizedBox(
                              height: 300,
                              width: 300,
                              child: Image.network(
                                '$baseUrl/${event['photo_url']}',
                                fit: BoxFit.cover,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          '$baseUrl/${event['photo_url']}',
                          height: 80, // Smaller image
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),

                  // Event Details Section
                  const Text(
                    'Event Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  ExpansionTile(
                    title: Row(
                      children: const [
                        Icon(Icons.info_outline, size: 16),
                        SizedBox(width: 8),
                        Text('Details', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(event['event_details'], style: const TextStyle(fontSize: 14)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Dates Section
                  ExpansionTile(
                    title: Row(
                      children: const [
                        Icon(Icons.date_range, size: 16),
                        SizedBox(width: 8),
                        Text('Dates', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    children: [
                      ListTile(
                        title: Text('Posted: ${event['posted_date']}', style: const TextStyle(fontSize: 14)),
                      ),
                      ListTile(
                        title: Text('Event Date: ${event['event_date']}', style: const TextStyle(fontSize: 14)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Status and Venue Section
                  ExpansionTile(
                    title: Row(
                      children: const [
                        Icon(Icons.location_on, size: 16),
                        SizedBox(width: 8),
                        Text('Venue & Status', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    children: [
                      ListTile(
                        title: Text('Status: ${event['status']}', style: const TextStyle(fontSize: 14)),
                      ),
                      ListTile(
                        title: Text('Venue: ${event['venue']}', style: const TextStyle(fontSize: 14)),
                      ),
                      ListTile(
                        title: Text('Responses: ${event['response_count']}', style: const TextStyle(fontSize: 14)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Organizer Section
                  const Text(
                    'Organized By',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  ListTile(
                    title: Text(event['organization']['name'], style: const TextStyle(fontSize: 14)),
                    subtitle: Text(event['organization']['place'], style: const TextStyle(fontSize: 12)),
                  ),

                  // Respondents Section
                  const Text(
                    'Respondents:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: event['respondents'].length,
                    itemBuilder: (context, respondentIndex) {
                      final respondent = event['respondents'][respondentIndex];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          '${respondent['name']} (Phone: ${respondent['phone']}, Email: ${respondent['email']})',
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }


  void showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Events'),
        content: TextField(
          onChanged: updateSearch,
          decoration: const InputDecoration(
            hintText: 'Enter event name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
