import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:project_part2/models/food_item.dart';
import 'package:project_part2/screens/add_item_form.dart';
import 'package:project_part2/screens/edit_item_form.dart';
import 'package:project_part2/services/firebase_service.dart';
import 'package:project_part2/widgets/app_drawer.dart';
import 'package:project_part2/widgets/business_menu_button.dart';

//this is my business screen for users that have small food business to sell their surplus food at a cheaper price also has my basic crud here
// this is to decode base64 safely for the card preview
ImageProvider? _base64ToImage(String b64) {
  if (b64.isEmpty) return null;
  try {
    return MemoryImage(base64Decode(b64));
  } catch (_) {
    return null;
  }
}

class BusinessScreen extends StatefulWidget {
  static String routeName = '/business';
  const BusinessScreen({Key? key}) : super(key: key);

  @override
  _BusinessScreenState createState() => _BusinessScreenState();
}

class _BusinessScreenState extends State<BusinessScreen> {
  int _selectedIndex = 2; //since the business screen index is 2 this helps keep track which page the user is on


  void _onItemTapped(int index) { //handles the bottom nav bar routing
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushNamed(context, '/main');
    } else if (index == 1) {
      Navigator.pushNamed(context, '/profile');
    }
  }

  Widget _buildNavIcon(IconData icon, int index) { //the green rounded box around the icon on the bottom nav if the user is on that page
    return Container(
      decoration: _selectedIndex == index
          ? BoxDecoration(
              color: const Color(0xFFDDE7DA),
              borderRadius: BorderRadius.circular(16),
            )
          : null,
      padding: const EdgeInsets.all(8),
      child: Icon(icon),
    );
  }

  void _showAddItemForm() { //for the add item form to open it
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddItemForm()), //user redirected to teh add item form screen
    );
  }

//an alert dialog to ask users to confrim deleting their item
  void _confirmDeleteItem(BuildContext context, String foodName) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text("Delete item"),
      content: const Text("Are you sure you want to permanently delete this item?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text("Cancel"), //for cancelling the deletion
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(ctx).pop(); // close the popup dialog
            try {
              await deleteFoodItem(foodName); // this has my basic delete function from firebase service
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Item deleted successfully.")),
              );
            } catch (e) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Deletion failed: $e")),
              );
            }
          },
          child: const Text("Delete", style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(), //this is the menu sidebar
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary, //the app bar uses the green theme colour
      ),
      bottomNavigationBar: BottomNavigationBar( //this is for the bottom nav bar to allow the users to navigate to the home, profile and business screen
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: const Color(0xFFA1CEAF),
        selectedItemColor: Colors.black,
        items: [
          BottomNavigationBarItem(icon: _buildNavIcon(Icons.home, 0), label: 'Home'),
          BottomNavigationBarItem(icon: _buildNavIcon(Icons.person, 1), label: 'Profile'),
          BottomNavigationBarItem(icon: _buildNavIcon(Icons.store, 2), label: 'Business'),
        ],
      ),
      body: Padding(  //this is the main content of the business screen
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center, 
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(32),
                  child: const Icon(Icons.lunch_dining, size: 100, color: Colors.white), //instead of using an image for the business logo i used an icon instead
                ),
                const SizedBox(width: 12),
                BusinessMenuButton(
                  onPressed: () {
                    showModalBottomSheet(  //the bottom sheet dialog i used for the user to view and edit their business account details
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
                      ),
                      builder: (context) => Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            color: const Color(0xFFDDE7DA),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: const Text('Business account',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                          const ListTile(leading: Icon(Icons.store), title: Text('View business account')), //this is inside the bottom sheet dialog
                          const ListTile(leading: Icon(Icons.edit), title: Text('Edit business account')),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16), //this is the business details card where the user has input when they sign up for a business account in the app
              decoration: BoxDecoration(
                color: const Color(0xFFDDE7DA),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('YumBurgers restaurant', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 18),
                      SizedBox(width: 6),
                      Text('today 22:00 - 22:30'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Flipping burgers and fighting food waste, one meal at a time!',
                    style: TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(  //this opens the add item form page when the user presses the add item button to allow them to fill in the form
                onPressed: _showAddItemForm,
                icon: const Icon(Icons.add),
                label: const Text('Add item'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFBF70),
                  foregroundColor: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<FoodItem>>(
                stream: getFoodItems(), // the select all query to get all the food items by that business
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Failed to load items: ${snapshot.error}')); //error message for failing to load items
                  }
                  final items = snapshot.data ?? [];
                  if (items.isEmpty) {
                    return const Center(child: Text('No items yet. Tap "Add item" to create one.')); //to show if no items created by the user yet
                  }

                  return GridView.builder( //grid view used to display the food items
                    itemCount: items.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.65,
                    ),
                    itemBuilder: (context, index) {
                      final it = items[index];
                      final imgProvider = _base64ToImage(it.image);

                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFDDE7DA),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [ //for the image to be inlined with the edit button
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  children: [
                                    //image of the food item
                                    Container(
                                      height: 130,
                                      width: double.infinity,
                                      color: const Color(0xFFDDE7DA),
                                      child: imgProvider == null
                                          ? const Center(child: Text('No image'))
                                          : Image(
                                              image: imgProvider,
                                              height: 130,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                    // edit button at the top right fo each food card
                                    Positioned(
                                      top: 6,
                                      right: 6,
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.edit, size: 17),
                                        label: const Text('Edit'),
                                        onPressed: () {
                                          Navigator.push( //which will redirect users to the edit form screen
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => EditItemForm(docId: it.id),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFFFBF70),
                                          foregroundColor: Colors.black,
                                          textStyle: const TextStyle(fontSize: 15),
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // the title food name
                                  Text(
                                    it.foodName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  // the original price of the food item
                                  Text(
                                    'Original: \$${it.originalPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(color: Colors.green),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // the discounted price of the food item in bold
                                      Text(
                                        '\$${it.discountedPrice.toStringAsFixed(2)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                      ),
                                      // the amount of c02 saved in bold
                                      Text(
                                        '${it.estimateCO2SavedKg.toStringAsFixed(1)}Kg of CO₂',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Center(
                                    child: ElevatedButton.icon( //the delete button which will give the alert dialog above to ask users if they want to confirm deletion
                                      onPressed: () => _confirmDeleteItem(context, it.foodName),
                                      icon: const Icon(Icons.delete, size: 17),
                                      label: const Text('Delete'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFFFBF70),
                                        foregroundColor: Colors.black,
                                        textStyle: const TextStyle(fontSize: 15),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

          ],
        ),
      ),
    );
    
  }
}