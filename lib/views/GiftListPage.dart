import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hedieaty/controllers/gift_controller.dart';
import 'package:hedieaty/controllers/pledged_controller.dart';
import 'package:hedieaty/models/gift_model.dart';
import 'HomeFriendsListScreen.dart';
import 'MyPledgedGiftsPage.dart';
import 'GiftDetailsPage.dart';
import 'EventListPage.dart';
import 'ProfilePage.dart';

class GiftListPage extends StatefulWidget {
  final String userId;
  final String eventId;
  final bool isFriend;

  const GiftListPage({
    required this.userId,
    required this.eventId,
    required this.isFriend,
    Key? key,
  }) : super(key: key);

  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage>
    with SingleTickerProviderStateMixin {
  final GiftController _giftController = GiftController();
  final PledgedController _pledgedController = PledgedController();

  int _selectedIndex = 0;

  late final String originalUserId;
  late Map<String, bool> pledgedGiftsMap;

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    final currentUser = FirebaseAuth.instance.currentUser;
    originalUserId = currentUser?.uid ?? ''; // Retrieve the user ID from Firebase

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

    _loadPledgedGifts(); // Load pledged gifts for the original user
  }

  Future<void> _loadPledgedGifts() async {
    pledgedGiftsMap = {};
    try {
      final pledgedGifts = await _pledgedController.fetchPledgedGifts(originalUserId);
      pledgedGifts.forEach((gift) {
        pledgedGiftsMap[gift['id']] = true;
      });
    } catch (e) {
      print('Error loading pledged gifts: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0: // Navigate to Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeFriendsListScreen()),
        );
        break;

      case 1: // Navigate to My Events (Always Original User's Events)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => EventListPage(
              friendName: "",
              userId: originalUserId, // Always use the Firebase user ID
            ),
          ),
        );
        break;

      case 2: // Navigate to My Pledged Gifts
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MyPledgedGiftsPage(
              userId: originalUserId,
              eventId: widget.eventId,
            ),
          ),
        );
        break;

      case 3: // Navigate to Profile
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfilePage()),
        );
        break;

      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gift List',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff6a1b9a),
        elevation: 4,
      ),
      body: Stack(
        children: [
          // Background with purple gradient
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
            child: StreamBuilder<List<GiftModel>>(
              stream: _giftController.getGifts(widget.userId, widget.eventId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No gifts available.',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                final gifts = snapshot.data!;

                return ListView.builder(
                  itemCount: gifts.length,
                  itemBuilder: (context, index) {
                    final gift = gifts[index];
                    bool isOwnGift = gift.userId == originalUserId;
                    bool canUnpledge = pledgedGiftsMap.containsKey(gift.giftId);
                    bool isPledged = gift.status == 'pledged';

                    return Card(
                      color: isPledged
                          ? Colors.lightGreenAccent.withOpacity(0.5)
                          : Colors.white,
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(gift.name),
                        subtitle: Text(
                          'Category: ${gift.category} - \$${gift.price.toStringAsFixed(2)}',
                        ),
                        trailing: isOwnGift
                            ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isPledged)
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => GiftDetailsPage(
                                        userId: widget.userId,
                                        eventId: widget.eventId,
                                        gift: gift.toMap(),
                                        isFriend: widget.isFriend,
                                        giftId: gift.giftId,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            if (!isPledged)
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  await _deleteGift(gift.giftId);
                                },
                              ),
                          ],
                        )
                            : widget.isFriend
                            ? IconButton(
                          icon: Icon(
                            gift.status == 'pledged'
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.orangeAccent,
                          ),
                          onPressed: () async {
                            if (gift.status == 'available') {
                              await _pledgedController.togglePledgeStatus(
                                friendId: widget.userId,
                                eventId: widget.eventId,
                                giftId: gift.giftId,
                                isPledged: gift.status == 'pledged',
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      isPledged ? 'Gift unpledged!' : 'Gift pledged!'),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Only the user who pledged the gift can unpledge it'),
                                ),
                              );
                            }
                          },
                        )
                            : null,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GiftDetailsPage(
                                userId: widget.userId,
                                eventId: widget.eventId,
                                gift: gift.toMap(),
                                isFriend: widget.isFriend,
                                giftId: gift.giftId,
                              ),
                            ),
                          );
                        },
                      ),
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Pledged'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: widget.isFriend
          ? null
          : FloatingActionButton(
        onPressed: () => _showAddGiftDialog(context),
        backgroundColor: const Color(0xff9c27b0),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _deleteGift(String giftId) async {
    try {
      await _giftController.deleteGift(
        userId: widget.userId,
        eventId: widget.eventId,
        giftId: giftId,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gift deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete gift: $e')),
      );
    }
  }

  void _showAddGiftDialog(BuildContext context) {
    final _nameController = TextEditingController();
    final _categoryController = TextEditingController();
    final _descriptionController = TextEditingController();
    final _priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Gift'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Gift Name'),
                ),
                TextField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final name = _nameController.text.trim();
                final category = _categoryController.text.trim();
                final description = _descriptionController.text.trim();
                final price = double.tryParse(_priceController.text.trim()) ?? 0.0;

                if (name.isEmpty || category.isEmpty || price <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields!')),
                  );
                  return;
                }

                try {
                  await _giftController.addGift(
                    userId: widget.userId,
                    eventId: widget.eventId,
                    name: name,
                    category: category,
                    description: description,
                    price: price,
                  );
                  Navigator.pop(context); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gift added successfully!')),
                  );
                } catch (e) {
                  Navigator.pop(context); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add gift: $e')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}