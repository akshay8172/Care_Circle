import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:care_circle_new/organization/SendEventNotification.dart';
import 'package:care_circle_new/organization/ViewInterestedUsers.dart';

class ViewEvents extends StatefulWidget {
  final String userId;
  const ViewEvents({Key? key, required this.userId}) : super(key: key);

  @override
  State<ViewEvents> createState() => _ViewEventsState();
}

class _ViewEventsState extends State<ViewEvents> {
  List<Map<String, dynamic>> events = [];
  List<Map<String, dynamic>> filteredEvents = [];
  String baseUrl = '';
  TextEditingController nameController = TextEditingController();
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    fetchMyEvents();
  }

  Future<void> fetchMyEvents() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url').toString();
      baseUrl = sh.getString('imgurl') ?? '';
      String url = '$urls/ViewMyEvents';
      var response = await http.post(
        Uri.parse(url),
        body: {
          'user_id': widget.userId,
        },
      );

      var jsondata = json.decode(response.body);
      if (jsondata['status'] == 'ok' && jsondata['events'] is List) {
        setState(() {
          events = List<Map<String, dynamic>>.from(jsondata['events']);
          filteredEvents = events; // Initial load of all events
        });
      } else {
        print('Failed to fetch Events');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void filterEvents() {
    setState(() {
      filteredEvents = events.where((event) {
        final nameMatches = nameController.text.isEmpty ||
            event['event_name']
                .toLowerCase()
                .contains(nameController.text.toLowerCase());
        final dateMatches = selectedDate == null ||
            event['event_date'] == selectedDate.toString();

        return nameMatches && dateMatches;
      }).toList();
    });
  }

  // Future<void> pickDate() async {
  //   DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.now(),
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime(2101),
  //   );
  //   if (picked != null && picked != selectedDate) {
  //     setState(() {
  //       selectedDate = picked;
  //       filterEvents(); // Update search based on the picked date
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Events',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Search by Name',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => filterEvents(),
                  ),
                ),
                const SizedBox(width: 10),
                // IconButton(
                //   icon: const Icon(Icons.date_range),
                //   onPressed: pickDate,
                // ),
              ],
            ),
          ),
          Expanded(
            child: filteredEvents.isEmpty
                ? const Center(
              child: Text(
                'NO EVENTS AVAILABLE',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            )
                : ListView.builder(
              itemCount: filteredEvents.length,
              itemBuilder: (context, index) {
                final event = filteredEvents[index];
                return EventCard(
                  event: event,
                  baseUrl: baseUrl,
                  onViewVolunteers: (eventId) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewInterestedVolunteers(
                            id: eventId.toString()),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final sh = await SharedPreferences.getInstance();
          String lid = sh.getString("lid").toString();
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SendEventNotification(userId: lid),
            ),
          );
          if (result == true) {
            fetchMyEvents(); // Reload data after adding a new event
          }
        },
        backgroundColor: Colors.cyan,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final String baseUrl;
  final void Function(int) onViewVolunteers;

  const EventCard({
    required this.event,
    required this.baseUrl,
    required this.onViewVolunteers,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event['event_name'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.deepPurple,
                fontFamily: 'Georgia',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.event, color: Colors.black),
                const SizedBox(width: 6),
                Text(
                  ': ${event['event_date']}',
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.person, color: Colors.black),
                const SizedBox(width: 6),
                Text(
                  '${event['count']}',
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 12),
            event['photo'] != null
                ? Image.network(
              '$baseUrl${event['photo']}',
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                        (loadingProgress.expectedTotalBytes ?? 1)
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const Text('No image available',
                    style: TextStyle(color: Colors.red));
              },
            )
                : const Text('No image available',
                style: TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            Text(
              'Details: ${event['event_details']}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 15),
            Text(
              'Venue: ${event['venue']}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Center(
              child: ElevatedButton(
                onPressed: () => onViewVolunteers(event['id']),
                style: ElevatedButton.styleFrom(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text('View Interested Volunteers',
                    style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
