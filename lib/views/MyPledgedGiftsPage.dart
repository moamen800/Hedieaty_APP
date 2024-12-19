import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hedieaty/views/HomeFriendsListScreen.dart';
import 'package:hedieaty/views/EventListPage.dart';
import 'package:hedieaty/views/ProfilePage.dart';

class MyPledgedGiftsPage extends StatefulWidget {
  final String userId;
  final String eventId;

  const MyPledgedGiftsPage({
    required this.userId,
    required this.eventId,
    Key? key,
  }) : super(key: key);

  @override
  _MyPledgedGiftsPageState createState() => _MyPledgedGiftsPageState();
}

class _MyPledgedGiftsPageState extends State<MyPledgedGiftsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  /// Bottom navigation bar index
  int _selectedIndex = 2;

  /// Stream to get pledged gifts
  Stream<QuerySnapshot> _getPledgedGifts() {
    return _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('pledgedGifts')
        .snapshots();
  }

  /// Fetch the name of the user who owns the gift
  Future<String> _getUserName(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      return userDoc.data()?['name'] ?? 'Unknown User';
    } catch (e) {
      return 'Unknown User';
    }
  }

  /// Handle navigation when a tab is selected
  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0: // Navigate to Friends List
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeFriendsListScreen()),
        );
        break;

      case 1: // Navigate to Events List
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => EventListPage(
              friendName: "My",
              userId: _currentUserId!,
            ),
          ),
        );
        break;

      case 2: // Stay on Pledged Gifts Page
        break;

      case 3: // Navigate to Profile Page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfilePage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Pledged Gifts',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: const Color(0xffba8fe3),
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeFriendsListScreen(),
              ),
            );
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getPledgedGifts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No pledged gifts available.'));
          }

          final pledgedGifts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: pledgedGifts.length,
            itemBuilder: (context, index) {
              final gift = pledgedGifts[index];
              final giftData = gift.data() as Map<String, dynamic>;

              return FutureBuilder<String>(
                future: _getUserName(giftData['pledgedFrom']),
                builder: (context, userSnapshot) {
                  final userName = userSnapshot.data ?? 'Fetching user...';

                  return Card(
                    child: ListTile(
                      title: Text(giftData['name'] ?? 'Unnamed Gift'),
                      subtitle: Text(
                        'Category: ${giftData['category'] ?? 'Unknown'}\n'
                            'Price: \$${giftData['price']?.toStringAsFixed(2) ?? '0.00'}\n'
                            'Pledged From: $userName',
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
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
