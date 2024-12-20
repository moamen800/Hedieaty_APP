import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hedieaty/controllers/home_controller.dart';
import 'package:hedieaty/controllers/event_controller.dart';
import 'package:hedieaty/controllers/auth_controller.dart';
import 'package:hedieaty/main.dart';
import 'package:hedieaty/views/MyPledgedGiftsPage.dart';
import 'package:hedieaty/views/EventListPage.dart';
import 'package:hedieaty/views/ProfilePage.dart';
import 'package:hedieaty/views/SignInPage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class HomeFriendsListScreen extends StatefulWidget {
  const HomeFriendsListScreen({super.key});

  @override
  _HomeFriendsListScreenState createState() => _HomeFriendsListScreenState();
}

class _HomeFriendsListScreenState extends State<HomeFriendsListScreen>
    with SingleTickerProviderStateMixin {
  final HomeController _homeController = HomeController();
  final EventController _eventController = EventController();
  final AuthController _authController = AuthController();

  late Future<List<Map<String, dynamic>>> _friendsFuture;
  String searchQuery = '';
  int _selectedIndex = 0;
  Map<String, String> userData = {};
  List<Map<String, dynamic>> filteredFriends = [];
  StreamSubscription<QuerySnapshot>? _notificationSubscription;

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
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

    _fetchFriends();
    _fetchUserData();

    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        _notificationSubscription?.cancel();
        _notificationSubscription = null;
      } else {
        _listenForNotifications();
      }
    });
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _listenForNotifications() {
    _notificationSubscription?.cancel();
    _notificationSubscription = null;

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      _notificationSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('notifications')
          .where('read', isEqualTo: false)
          .snapshots()
          .listen((snapshot) {
        for (var doc in snapshot.docs) {
          final notification = doc.data() as Map<String, dynamic>;
          _showLocalNotification(
            notification['senderName'] ?? 'Someone',
            '${notification['giftName'] ?? 'a gift'} has been pledged!',
          );

          doc.reference.update({'read': true});
        }
      });
    }
  }

  void _showLocalNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'gift_channel',
      'Gift Notifications',
      channelDescription: 'Notifications for pledged gifts',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }

  void _fetchFriends() async {
    String? userId = await _authController.getCurrentUserId();

    if (userId != null) {
      setState(() {
        _friendsFuture = _homeController.getFriendsForView(userId);
      });
      _friendsFuture.then((friends) {
        setState(() {
          filteredFriends = friends;
        });
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: No user is signed in.")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => SignInPage()),
      );
    }
  }

  void _fetchUserData() async {
    final user = await _authController.getUserProfile();
    if (user != null) {
      setState(() => userData = user);
      _listenForNotifications();
    }
  }

  void _filterFriends(String query) {
    setState(() {
      searchQuery = query;
      filteredFriends = filteredFriends
          .where((friend) =>
          friend['name']!.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    });
  }

  void _signOut() async {
    await _notificationSubscription?.cancel();
    _notificationSubscription = null;

    await _authController.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => SignInPage()));
  }

  Future<void> _onItemTapped(int index) async {
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeFriendsListScreen()),
        );
        break;

      case 1:
        String? userId = await _authController.getCurrentUserId();
        if (userId != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => EventListPage(friendName: 'My Events', userId: userId),
            ),
          );
        }
        break;

      case 2:
        String? userId = await _authController.getCurrentUserId();
        if (userId != null) {
          try {
            List<Map<String, dynamic>> events =
            await _eventController.fetchEventsForView(userId);

            if (events.isNotEmpty) {
              String eventId = events.first['id'];
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => MyPledgedGiftsPage(
                    userId: userId,
                    eventId: eventId,
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("No events found for this user.")),
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error fetching events: $e")),
            );
          }
        }
        break;

      case 3:
        String? userId = await _authController.getCurrentUserId();
        if (userId != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => ProfilePage()),
          );
        }
        break;

      default:
        break;
    }
  }

  void _deleteFriend(String friendId) async {
    String? userId = await _authController.getCurrentUserId();
    if (userId != null) {
      await _homeController.deleteFriend(userId, friendId);
      _fetchFriends();
    }
  }

  Widget _buildFriendTile(Map<String, dynamic> friend) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: friend['profilePicture'] != null
              ? AssetImage(friend['profilePicture']!)
              : const AssetImage('assets/images/profile1.png'),
        ),
        title: Text(friend['name']!,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black87)),
        subtitle: Text('View Events for ${friend['name']}',
            style: const TextStyle(color: Colors.black54)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.event, color: Colors.blue),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EventListPage(
                        friendName: friend['name']!, userId: friend['friendId']),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteFriend(friend['friendId']),
            ),
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
          'Friends List',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),

        backgroundColor: const Color(0xff6a1b9a),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout , color: Colors.white),
            onPressed: _signOut,
          ),
        ],
        elevation: 4,
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
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search friends...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.black54),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: _filterFriends,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      String? userId = await _authController.getCurrentUserId();
                      if (userId != null) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EventListPage(friendName: 'Add Your Own Events', userId: userId),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff6a1b9a),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    ),
                    child: const Text(
                      'Add Your Own Events',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _friendsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError ||
                          !snapshot.hasData ||
                          snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text('No friends found.',
                              style: TextStyle(color: Colors.white)),
                        );
                      }
                      return ListView(
                        children: filteredFriends
                            .map((friend) => _buildFriendTile(friend))
                            .toList(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String? userId = await _authController.getCurrentUserId();
          if (userId != null) {
            _homeController.addFriendManually(context, userId, _fetchFriends);
          }
        },
        backgroundColor: const Color(0xff9c27b0),
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        backgroundColor: const Color(0xff6a1b9a),
        type: BottomNavigationBarType.fixed,
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