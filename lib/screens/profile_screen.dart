
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:project_part2/models/food_item.dart';
import 'package:project_part2/screens/payment_screen.dart';
import 'package:project_part2/services/cart_store.dart';
import 'package:project_part2/widgets/app_drawer.dart';


// this screen is to allow users to view their profile details like their username, and the food item that they hve reserved to show the collection details and a "pay" button for my nets qr i implemented
class ProfileScreen extends StatefulWidget {  
  static String routeName = '/profile';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 1; //this helps to keep track of the selected tab on the bottom nav, so for this page, 1 is selected which is the profile page
  final OrdersStore orders = GetIt.I<OrdersStore>();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushNamed(context, '/main');
    } else if (index == 1) {
      Navigator.pushNamed(context, '/profile');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/business');
    }
  }

  Widget _buildNavIcon(IconData icon, int index) { // this is the green rounded box background around the icon on the bottom nav bar when user is on that page
    return Container(
      decoration: _selectedIndex == index
          ? BoxDecoration(
              color: Color(0xFFDDE7DA),
              borderRadius: BorderRadius.circular(16),
            )
          : null,
      padding: EdgeInsets.all(8),
      child: Icon(icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? 'Guest';
    //this gets the logged in users email or it will fllback to guest if not logged in

    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AnimatedBuilder(
          animation: orders, // animated builder allows rebuild when orderstore in my card store services changes
          builder: (context, _) {
            final hasOrders = orders.orders.isNotEmpty;

            return ListView(
              children: [
                const Text('Your account', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                // this is the profile card of the currently signed in user that displays their email
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFFDDE7DA), borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(color: const Color(0xFFA1CEAF), borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.all(12),
                        child: const Icon(Icons.person, size: 36, color: Colors.black), //this is the profile icon
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          email, //the email of the currently signed in user
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20), //this is teh meal rescued section
                const Text('Meal rescued', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                // this will show all the orders by the user in a list if not it will show an empty state
                if (!hasOrders)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFFDDE7DA), borderRadius: BorderRadius.circular(16)),
                    child: const Text('You currently don’t have orders. Find meals to rescue!  🪴'), //this will be shown if user currently doesnt have any orders
                  )
                else
                  ...orders.orders.map((it) => _OrderCard(it: it)).toList(), //this maps each order to a card widget
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar( //this is my bottom nav bar for the home, profile screen and business screen
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
    );
  }
}

//this is the card widget that displayed a reserved order by the user
class _OrderCard extends StatelessWidget {
  final FoodItem it;
  const _OrderCard({required this.it});

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('dd/MM/yyyy').format(it.date); //the date of the order will be displayed in dd/mm/yyyy

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFDDE7DA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(it.foodName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), //this is the food name the user ordered
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.access_time, size: 18), //this is the collection time range shown to the user for them to collect their meal
            const SizedBox(width: 6),
            Text(it.collectionTimeRange.isEmpty ? 'N/A' : it.collectionTimeRange),
          ]),
          const SizedBox(height: 6),
          Text('\$${it.discountedPrice.toStringAsFixed(2)}'), //this is the price the user has to pay which is the discounted price
          const SizedBox(height: 10),

          Text('Address:', style: TextStyle(color: Colors.green[900], fontWeight: FontWeight.bold)), //this is the address which will show the map below
          const SizedBox(height: 6),

          //this is the map using flutter map that shows the address for the user to collect it at teh location
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 150,
              width: double.infinity,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(it.latitude, it.longitude),
                  initialZoom: 14,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', //this is the base map layer
                    userAgentPackageName: 'com.example.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker( //and this is a marker that will mark the exact location on the map
                        point: LatLng(it.latitude, it.longitude),
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.location_on, size: 40, color: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // this is the pay button at the bottomm right of the card 
          Align(
            alignment: Alignment.bottomRight,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PaymentScreen(item: it)), //when user presses this it will redirect them to teh payment screen that will have the nets qr payment
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFBF70),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                minimumSize: const Size(120, 44),
              ),
              child: const Text('Pay'), //the pay text written on the button
            ),
          ),
        ],
      ),
    );
  }
}