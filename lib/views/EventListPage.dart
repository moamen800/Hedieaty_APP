import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hedieatyfinal/controllers/event_controller.dart';
import 'HomeFriendsListScreen.dart';
import 'MyPledgedGiftsPage.dart';
import 'GiftListPage.dart';
import 'ProfilePage.dart';

class EventListPage extends StatefulWidget {
  final String friendName;
  final String userId;

  const EventListPage({required this.friendName, required this.userId, Key? key}) : super(key: key);

  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> with SingleTickerProviderStateMixin {
  final EventController _eventController = EventController();
  late Future<List<Map<String, dynamic>>> _eventsFuture;
  int _selectedIndex = 1;
  late String _currentUserId;
  bool _isFriend = true;
  String _sortOption = 'Name';

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    _isFriend = _currentUserId != widget.userId;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1), // Start above the screen
      end: const Offset(0, 0), // End at its position
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward(); // Start the animation
    _fetchEvents();
  }

  void _fetchEvents() {
    _eventsFuture = _eventController.fetchEventsForView(widget.userId).then((events) {
      if (_sortOption == 'Name') {
        events.sort((a, b) => a['name'].compareTo(b['name']));
      } else if (_sortOption == 'Date') {
        events.sort((a, b) => DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])));
      }
      return events;
    });
  }

  void _addEvent() async {
    if (!_isFriend) {
      final newEvent = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => _AddEventDialog(),
      );

      if (newEvent != null) {
        await _eventController.addEvent(
          userId: widget.userId,
          name: newEvent['name']!,
          date: newEvent['date']!,
          location: newEvent['location']!,
          description: newEvent['description']!,
        );
        setState(() => _fetchEvents());
      }
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
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeFriendsListScreen()),
        );
        break;

      case 1:
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

      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MyPledgedGiftsPage(userId: _currentUserId, eventId: ""),
          ),
        );
        break;

      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProfilePage()),
        );
        break;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xff6a1b9a),
        actions: [
          DropdownButton<String>(
            value: _sortOption,
            icon: const Icon(Icons.sort, color: Colors.white),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _sortOption = newValue;
                  _fetchEvents();
                });
              }
            },
            items: <String>['Name', 'Date']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff6a1b9a), Color(0xff9c27b0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SlideTransition(
            position: _slideAnimation,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _eventsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No events found.',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                final events = snapshot.data!;
                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: const Color(0xffd1c4e9),
                      child: ListTile(
                        title: Text(event['name']!,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        subtitle: Text('Date: ${event['date']} \nLocation: ${event['location']}'),
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
                            : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editEvent(event),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteEvent(event['id']!),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _isFriend
          ? null
          : FloatingActionButton(
        backgroundColor: const Color(0xff9c27b0),
        onPressed: _addEvent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        backgroundColor: const Color(0xff6a1b9a),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'My Events'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Pledged Gifts'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _AddEventDialog extends StatefulWidget {
  @override
  __AddEventDialogState createState() => __AddEventDialogState();
}

class __AddEventDialogState extends State<_AddEventDialog> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedDate = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Event'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Event Name')),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );

                if (pickedDate != null) {
                  setState(() {
                    _selectedDate = "${pickedDate.toLocal()}".split(' ')[0];
                  });
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Event Date',
                  border: OutlineInputBorder(),
                ),
                child: _selectedDate.isEmpty
                    ? const Text('Select Date')
                    : Text(_selectedDate),
              ),
            ),
            const SizedBox(height: 16),
            TextField(controller: _locationController, decoration: const InputDecoration(labelText: 'Event Location')),
            const SizedBox(height: 16),
            TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Event Description')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            final newEvent = {
              'name': _nameController.text,
              'date': _selectedDate,
              'location': _locationController.text,
              'description': _descriptionController.text,
            };
            Navigator.pop(context, newEvent);
          },
          child: const Text('Save'),
        ),
      ],
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