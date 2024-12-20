import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hedieatyfinal/controllers/gift_controller.dart';
import 'package:hedieatyfinal/views/MyPledgedGiftsPage.dart';
import 'HomeFriendsListScreen.dart';
import 'EventListPage.dart';
import 'ProfilePage.dart';

class GiftDetailsPage extends StatefulWidget {
  final String userId;
  final String eventId;
  final String giftId;
  final Map<String, dynamic> gift;
  final bool isFriend;

  const GiftDetailsPage({
    required this.userId,
    required this.eventId,
    required this.giftId,
    required this.gift,
    required this.isFriend,
    Key? key,
  }) : super(key: key);

  @override
  _GiftDetailsPageState createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage>
    with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _statusController;
  late TextEditingController _priceController;

  final GiftController _giftController = GiftController();
  int _selectedIndex = 0;
  late final String originalUserId;
  bool get _isPledged => widget.gift['status'] == 'pledged';

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.gift['name']);
    _descriptionController = TextEditingController(text: widget.gift['description']);
    _categoryController = TextEditingController(text: widget.gift['category']);
    _statusController = TextEditingController(text: widget.gift['status']);
    _priceController = TextEditingController(text: widget.gift['price'].toString());

    final currentUser = FirebaseAuth.instance.currentUser;
    originalUserId = currentUser?.uid ?? '';

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
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _statusController.dispose();
    _priceController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_isPledged || widget.isFriend) return;

    final price = double.tryParse(_priceController.text) ?? 0.0;

    try {
      await _giftController.editGift(
        userId: widget.userId,
        eventId: widget.eventId,
        giftId: widget.giftId,
        name: _nameController.text,
        description: _descriptionController.text,
        category: _categoryController.text,
        status: _statusController.text,
        price: price,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gift details updated successfully!')),
      );

      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update gift details!')),
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
            builder: (_) => EventListPage(
              friendName: "",
              userId: originalUserId,
            ),
          ),
        );
        break;
      case 2:
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
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ProfilePage(),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isFriend ? 'Gift Details' : 'Edit Gift Details'),
        backgroundColor: const Color(0xff6a1b9a),
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  _buildTextField(_nameController, 'Gift Name', !widget.isFriend && !_isPledged),
                  const SizedBox(height: 16),
                  _buildTextField(_descriptionController, 'Description', !widget.isFriend && !_isPledged),
                  const SizedBox(height: 16),
                  _buildTextField(_categoryController, 'Category', !widget.isFriend && !_isPledged),
                  const SizedBox(height: 16),
                  _buildTextField(_statusController, 'Status', false),
                  const SizedBox(height: 16),
                  _buildTextField(_priceController, 'Price', !widget.isFriend && !_isPledged, isNumeric: true),
                  const SizedBox(height: 24),
                  if (!widget.isFriend)
                    ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff9c27b0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Pledged'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, bool isEnabled, {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          filled: true,
          fillColor: Colors.white,
        ),
        enabled: isEnabled,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
    );
  }
}