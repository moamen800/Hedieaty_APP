import 'package:flutter/material.dart';
import 'package:hedieatyfinal/controllers/auth_controller.dart';
import 'package:hedieatyfinal/controllers/event_controller.dart';
import 'package:hedieatyfinal/controllers/pledged_controller.dart';
import 'package:hedieatyfinal/controllers/home_controller.dart';
import 'package:hedieatyfinal/views/HomeFriendsListScreen.dart';
import 'package:hedieatyfinal/views/MyPledgedGiftsPage.dart';
import 'package:hedieatyfinal/views/EventListPage.dart';
import 'package:hedieatyfinal/views/SignInPage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late AuthController _authController;
  late EventController _eventController;
  late PledgedController _pledgedController;
  late HomeController _homeController;

  String userName = '';
  String userEmail = '';
  String currentUserId = '';
  List<Map<String, dynamic>> userEvents = [];
  List<Map<String, dynamic>> pledgedGifts = [];
  int _selectedIndex = 3;
  bool isEditingName = false;
  final TextEditingController _nameController = TextEditingController();

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _authController = AuthController();
    _eventController = EventController();
    _pledgedController = PledgedController();
    _homeController = HomeController();

    _fetchUserProfileAndEvents();
    _fetchPledgedGifts();

    // Initialize Slide Animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
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
          _nameController.text = userName;
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

  Future<void> _saveNameChanges() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name cannot be empty.")),
      );
      return;
    }

    try {
      await _authController.updateUser(currentUserId, {'name': newName});
      await _homeController.updateFriendsName(currentUserId, currentUserId, newName);

      setState(() {
        userName = newName;
        isEditingName = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name updated successfully.")),
      );
    } catch (e) {
      print('Error saving name changes: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save name changes.")),
      );
    }
  }

  void _onItemTapped(int index) {
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
            builder: (_) => EventListPage(friendName: '', userId: currentUserId),
          ),
        );
        break;

      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MyPledgedGiftsPage(userId: currentUserId, eventId: ''),
          ),
        );
        break;

      case 3:
        break;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildTile({required String title, required String subtitle}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: const Color(0xffd1c4e9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.black87)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xff6a1b9a),
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: isEditingName
                            ? TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Edit Name',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                          ),
                        )
                            : Text(
                          'Name: $userName',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                      IconButton(
                        icon: Icon(isEditingName ? Icons.check : Icons.edit),
                        onPressed: () {
                          if (isEditingName) {
                            _saveNameChanges();
                          } else {
                            setState(() => isEditingName = true);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Email: $userEmail', style: const TextStyle(fontSize: 16, color: Colors.black)),
                  const SizedBox(height: 20),
                  const Text('My Events:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                  ...userEvents.map((event) => _buildTile(title: event['name'], subtitle: 'Date: ${event['date']}')),
                  const SizedBox(height: 20),
                  const Text('My Pledged Gifts:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                  ...pledgedGifts.map((gift) => _buildTile(title: gift['name'] ?? 'Unnamed Gift', subtitle: 'Price: \$${gift['price']}')),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        await _authController.signOut();
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SignInPage()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Pledged Gifts'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}