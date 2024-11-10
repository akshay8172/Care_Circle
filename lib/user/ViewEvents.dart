import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';


class ViewEvents extends StatefulWidget {
  const ViewEvents({super.key});

  @override
  State createState() => _ViewEventsState();
}

class _ViewEventsState extends State<ViewEvents> {
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
      String url = '$urls/ViewEvents';
      String lid = sh.getString('lid') ?? '';

      var response = await http.post(
        Uri.parse(url),
        body: {
          'user_id': lid,
        },
      );

      var jsondata = json.decode(response.body);
      if (jsondata['status'] == 'ok' && jsondata['events'] is List) {
        setState(() {
          events = List.from(jsondata['events']);
          filteredEvents = events; // Initially, all events are displayed
        });
      } else {
        print('Failed to fetch Events');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void sendRequest(String eventId) async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url') ?? '';
      String userId = sh.getString('lid') ?? '';

      // Construct the URL for sending the event request
      String url = '$urls/SendEventRequest';

      // Make the POST request to the server
      var response = await http.post(
        Uri.parse(url),
        body: {
          'user_id': userId,
          'event_id': eventId,
        },
      );

      // Decode the response
      var jsondata = json.decode(response.body);

      // Check the response status
      if (jsondata['status'] == 'ok') {
        // Successfully sent the request
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request sent successfully!')),
        );
        fetchMyEvents();
      } else {
        // Handle errors returned from the server
        String message = jsonDecode(response.body)['message'];
        Fluttertoast.showToast(msg: 'Sorry: $message');
      }
    } catch (e) {
      // Handle any exceptions that occur during the request
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }



  void searchEvents(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredEvents = events;
      });
    } else {
      setState(() {
        filteredEvents = events.where((event) {
          final eventName = event['event_name'].toLowerCase();
          final eventDate = event['event_date'].toLowerCase();
          return eventName.contains(query.toLowerCase()) ||
              eventDate.contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'View Active Events',
          style: TextStyle(color: Colors.white), // Set the text color to white
        ),
        backgroundColor: Colors.black, // Changed AppBar color to black
        iconTheme: const IconThemeData(color: Colors.white), // Set icon color to white
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: searchEvents,
              decoration: InputDecoration(
                hintText: 'Search events by name or date',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      searchQuery = '';
                      filteredEvents = events; // Reset to original list
                    });
                    searchEvents('');
                  },
                )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: filteredEvents.isNotEmpty
                ? ListView.builder(
              itemCount: filteredEvents.length,
              itemBuilder: (context, index) {
                final event = filteredEvents[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.pages_rounded, size: 30, color: Colors.blue),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Text(
                                event['event_name'],
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        if (event['photo'] != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              '$baseUrl${event['photo']}',
                              fit: BoxFit.cover,
                              height: 150,
                              width: double.infinity,
                            ),
                          ),
                        const SizedBox(height: 16.0),
                        Text(
                          event['event_details'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.normal, // Change to FontWeight.bold if needed
                            color: Colors.brown, // Set color as needed
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 20),
                            const SizedBox(width: 5.0),
                            Text(': ${event['posted_date']}'),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 20),
                            const SizedBox(width: 5.0),
                            Text(': ${event['event_date']}'),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 20),
                            const SizedBox(width: 5.0),
                            Text(': ${event['venue']}'),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Center(
                          child: event['already_requested'] == false
                              ? ElevatedButton(
                            onPressed: () => sendRequest(event['event_id'].toString()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green, // Change the button color here
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Adjust padding
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30), // Rounded corners
                              ),
                            ),
                            child: const Text(
                              'Send Request',
                              style: TextStyle(
                                fontSize: 18, // Change font size as needed
                                color: Colors.white, // Change text color if desired
                              ),
                            ),
                            )
                        : const Text(
                'Request Already Sent',
                style: TextStyle(
                fontSize: 16,
                color: Colors.red, // Change color as desired
                fontWeight: FontWeight.bold,
                ),
                ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
                : const Center(child: Text('No events available')), // Message when no events are found
          ),
        ],
      ),
    );
  }

}
