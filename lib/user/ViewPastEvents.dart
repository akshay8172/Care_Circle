import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';


class ViewPastEvents extends StatefulWidget {
  const ViewPastEvents({super.key});

  @override
  State createState() => _ViewPastEventsState();
}

class _ViewPastEventsState extends State<ViewPastEvents> {
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
      String url = '$urls/ViewPastEvents';
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
          'View Past Events',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey,
        iconTheme: const IconThemeData(color: Colors.white),
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
                            fontWeight: FontWeight.normal,
                            color: Colors.brown,
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
                      ],
                    ),
                  ),
                );
              },
            )
                : const Center(
              child: Text(
                'No past events to show',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
