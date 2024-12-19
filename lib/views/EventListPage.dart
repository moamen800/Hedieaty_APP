import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hedieaty/controllers/event_controller.dart';
import 'package:hedieaty/views/HomeFriendsListScreen.dart';
import 'package:hedieaty/views/MyPledgedGiftsPage.dart';
import 'package:hedieaty/views/GiftListPage.dart';
import 'package:hedieaty/views/ProfilePage.dart';

class EventListPage extends StatefulWidget {
  final String friendName;
  final String userId;

  const EventListPage({required this.friendName, required this.userId, Key? key}) : super(key: key);

  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final EventController _eventController = EventController();
  late Future<List<Map<String, dynamic>>> _eventsFuture;
  int _selectedIndex = 1;
  late String _currentUserId;
  bool _isFriend = true;

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    _isFriend = _currentUserId != widget.userId;
    _fetchEvents();
  }

  void _fetchEvents() {
    _eventsFuture = _eventController.fetchEventsForView(widget.userId);
  }

  void _addEvent() async {
    if (!_isFriend) {
      await _eventController.addEvent(
        userId: widget.userId,
        name: 'New Event',
        date: '2024-12-12',
        location: 'Sample Location',
        description: 'Event Description',
      );
      setState(() => _fetchEvents());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can only add your own events.")),
      );
    }
  }

  void _deleteEvent(String eventId) async {
    if (!_isFriend) {
      await _eventController.deleteEvent(widget.userId, eventId);
      setState(() => _fetchEvents());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can only delete your own events.")),
      );
    }
  }

  void _editEvent(Map<String, dynamic> event) async {
    if (!_isFriend) {
      final updatedEvent = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => _EditEventDialog(event: event),
      );

      if (updatedEvent != null) {
        await _eventController.updateEvent(
          userId: widget.userId,
          eventId: updatedEvent['id']!,
          name: updatedEvent['name']!,
          date: updatedEvent['date']!,
          location: updatedEvent['location']!,
          description: updatedEvent['description']!,
        );
        setState(() => _fetchEvents());
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can only edit your own events.")),
      );
    }
  }

  void _onItemTapped(int index) async {
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0: // Navigate to HomeFriendsListScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeFriendsListScreen()),
        );
        break;

      case 1: // Navigate to My Events
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => EventListPage(
              friendName: "My",
              userId: _currentUserId,
            ),
          ),
        );
        break;

      case 2: // Navigate to Pledged Gifts
        String? userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MyPledgedGiftsPage(userId: _currentUserId, eventId: ""),
            ),
          );
        }
        break;

      case 3: // Navigate to Profile
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProfilePage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeFriendsListScreen()),
            );
          },
        ),
        title: Text(
          _isFriend
              ? "${widget.friendName.isEmpty ? "My" : widget.friendName} Events"
              : "My Events",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xffba8fe3),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No events found.'));
          }

          final events = snapshot.data!;
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                color: const Color(0xffcebff7),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(
                    event['name']!,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: ${event['date']}'),
                      Text('Location: ${event['location']}'),
                      Text('Description: ${event['description']}'),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GiftListPage(
                          userId: widget.userId,
                          eventId: event['id']!,
                          isFriend: _isFriend,
                        ),
                      ),
                    );
                  },
                  trailing: _isFriend
                      ? null
                      : PopupMenuButton<int>(
                    onSelected: (value) {
                      if (value == 0) _editEvent(event);
                      if (value == 1) _deleteEvent(event['id']!);
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem<int>(value: 0, child: Text('Edit')),
                      const PopupMenuItem<int>(value: 1, child: Text('Delete')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: _isFriend
          ? null
          : FloatingActionButton(
        backgroundColor: const Color(0xffba8fe3),
        onPressed: _addEvent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        backgroundColor: const Color(0xffba8fe3),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'My Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Pledged Gifts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _EditEventDialog extends StatelessWidget {
  final Map<String, dynamic> event;

  const _EditEventDialog({required this.event});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController(text: event['name']);
    final dateController = TextEditingController(text: event['date']);
    final locationController = TextEditingController(text: event['location']);
    final descriptionController = TextEditingController(text: event['description']);

    return AlertDialog(
      title: const Text('Edit Event'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Event Name')),
            TextField(controller: dateController, decoration: const InputDecoration(labelText: 'Event Date')),
            TextField(controller: locationController, decoration: const InputDecoration(labelText: 'Event Location')),
            TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Event Description')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            final updatedEvent = {
              'id': event['id'],
              'name': nameController.text,
              'date': dateController.text,
              'location': locationController.text,
              'description': descriptionController.text,
            };
            Navigator.pop(context, updatedEvent);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
