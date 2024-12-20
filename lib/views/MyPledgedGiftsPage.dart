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

class _MyPledgedGiftsPageState extends State<MyPledgedGiftsPage>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  int _selectedIndex = 2;

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize Slide Transition Animation
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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> _getPledgedGifts() {
    return _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('pledgedGifts')
        .snapshots();
  }

  Future<String> _getUserName(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      return userDoc.data()?['name'] ?? 'Unknown User';
    } catch (e) {
      return 'Unknown User';
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
            builder: (_) => EventListPage(
              friendName: "My",
              userId: _currentUserId!,
            ),
          ),
        );
        break;
      case 2:
        break;
      case 3:
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
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff6a1b9a),
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
      body: Stack(
        children: [
          // Gradient Background
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
            child: StreamBuilder<QuerySnapshot>(
              stream: _getPledgedGifts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No pledged gifts available.',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
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
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          color: const Color(0xffd1c4e9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(
                              giftData['name'] ?? 'Unnamed Gift',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                            subtitle: Text(
                              'Category: ${giftData['category'] ?? 'Unknown'}\n'
                                  'Price: \$${giftData['price']?.toStringAsFixed(2) ?? '0.00'}\n'
                                  'Pledged From: $userName',
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
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