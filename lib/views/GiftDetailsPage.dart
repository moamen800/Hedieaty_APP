import 'package:flutter/material.dart';
import 'package:hedieaty/controllers/gift_controller.dart';
import 'package:hedieaty/views/MyPledgedGiftsPage.dart';
import 'HomeFriendsListScreen.dart';
import 'EventListPage.dart';

class GiftDetailsPage extends StatefulWidget {
  final String userId;
  final String eventId;
  final Map<String, dynamic> gift;
  final bool isFriend; // Indicates if the user is a friend

  const GiftDetailsPage({
    required this.userId,
    required this.eventId,
    required this.gift,
    required this.isFriend,
    Key? key,
  }) : super(key: key);

  @override
  _GiftDetailsPageState createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _statusController;
  late TextEditingController _priceController;

  final GiftController _giftController = GiftController();
  int _selectedIndex = 0;

  bool get _isPledged => widget.gift['status'] == 'pledged';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.gift['name']);
    _descriptionController = TextEditingController(text: widget.gift['description']);
    _categoryController = TextEditingController(text: widget.gift['category']);
    _statusController = TextEditingController(text: widget.gift['status']);
    _priceController = TextEditingController(text: widget.gift['price'].toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _statusController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_isPledged || widget.isFriend) return; // Prevent saving if the gift is pledged or user is a friend

    final price = double.tryParse(_priceController.text) ?? 0.0;

    await _giftController.editGift(
      userId: widget.userId,
      eventId: widget.eventId,
      giftId: widget.gift['id'],
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
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeFriendsListScreen()));
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EventListPage(
            friendName: 'My Events',
            userId: widget.userId,
          ),
        ),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MyPledgedGiftsPage(
            userId: widget.userId,
            eventId: widget.eventId,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isFriend ? 'Gift Details' : 'Edit Gift Details'),
        backgroundColor: const Color(0xffba8fe3),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Gift Name',
                border: OutlineInputBorder(),
              ),
              enabled: !widget.isFriend && !_isPledged, // Disable if the user is a friend or the gift is pledged
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              enabled: !widget.isFriend && !_isPledged,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              enabled: !widget.isFriend && !_isPledged,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _statusController,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              enabled: false, // Always disable the status field
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              enabled: !widget.isFriend && !_isPledged,
            ),
            const SizedBox(height: 20),
            if (!widget.isFriend) // Show Save Changes button only if not a friend
              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffba8fe3),
                ),
              ),
          ],
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
        ],
      ),
    );
  }
}
