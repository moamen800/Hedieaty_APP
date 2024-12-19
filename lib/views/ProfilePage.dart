import 'package:flutter/material.dart';
import 'package:hedieaty/controllers/auth_controller.dart';
import 'package:hedieaty/controllers/event_controller.dart';
import 'package:hedieaty/controllers/gift_controller.dart';
import 'package:hedieaty/controllers/pledged_controller.dart';
import 'package:hedieaty/views/HomeFriendsListScreen.dart';
import 'package:hedieaty/views/MyPledgedGiftsPage.dart';
import 'package:hedieaty/views/EventListPage.dart';
import 'package:hedieaty/views/SignInPage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late AuthController _authController;
  late EventController _eventController;
  late GiftController _giftController;
  late PledgedController _pledgedController;

  String userName = '';
  String userEmail = '';
  String currentUserId = '';
  List<Map<String, dynamic>> userEvents = [];
  List<Map<String, dynamic>> pledgedGifts = [];
  int _selectedIndex = 3;

  @override
  void initState() {
    super.initState();
    _authController = AuthController();
    _eventController = EventController();
    _giftController = GiftController();
    _pledgedController = PledgedController();
    _fetchUserProfileAndEvents();
    _fetchPledgedGifts();
  }

  void _fetchUserProfileAndEvents() async {
    try {
      final userId = await _authController.getCurrentUserId();
      if (userId == null) throw Exception("No user is signed in.");

      setState(() => currentUserId = userId);

      final userProfile = await _authController.getUserProfile();
      if (userProfile != null) {
        setState(() {
          userName = userProfile['name'] ?? 'No Name';
          userEmail = userProfile['email'] ?? 'No Email';
        });
      }

      final events = await _eventController.fetchEventsForView(userId);
      setState(() => userEvents = events);
    } catch (e) {
      print('Error fetching user profile or events: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error fetching profile data.")),
      );
    }
  }

  void _fetchPledgedGifts() async {
    try {
      final userId = await _authController.getCurrentUserId();
      if (userId == null) throw Exception("No user is signed in.");

      final fetchedPledgedGifts = await _pledgedController.fetchPledgedGifts(userId);
      setState(() {
        pledgedGifts = fetchedPledgedGifts;
      });
    } catch (e) {
      print('Error fetching pledged gifts: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error fetching pledged gifts.")),
      );
    }
  }


  // Navigation Handler
  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0: // Navigate to HomeFriendsListScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeFriendsListScreen()),
        );
        break;

      case 1: // Navigate to Events Page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => EventListPage(
              friendName: '',
              userId: currentUserId,
            ),
          ),
        );
        break;

      case 2: // Navigate to Pledged Gifts Page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MyPledgedGiftsPage(
              userId: currentUserId,
              eventId: '', // Provide eventId if needed
            ),
          ),
        );
        break;

      case 3: // Stay on Profile Page
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeFriendsListScreen()),
            );
          },
        ),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xffba8fe3),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display User Name and Email
              Text(
                'Name: $userName',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Email: $userEmail',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              // User's Events Section
              const Text(
                'My Events:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              userEvents.isEmpty
                  ? const Text('No events found.')
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: userEvents.length,
                itemBuilder: (context, index) {
                  final event = userEvents[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(event['name']),
                      subtitle: Text(
                        'Date: ${event['date']}\n'
                            'Location: ${event['location']}\n'
                            '${event['description']}',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Pledged Gifts Section
              const Text(
                'My Pledged Gifts:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              pledgedGifts.isEmpty
                  ? const Text('No pledged gifts.')
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pledgedGifts.length,
                itemBuilder: (context, index) {
                  final gift = pledgedGifts[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(gift['name'] ?? 'Unnamed Gift'),
                      subtitle: Text(
                        'Category: ${gift['category']}\n'
                            'Description: ${gift['description']}\n'
                            'Price: \$${gift['price']}',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Sign out button
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await _authController.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => SignInPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        backgroundColor: const Color(0xffba8fe3),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Pledged'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}