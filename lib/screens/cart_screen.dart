import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:project_part2/models/food_item.dart';
import 'package:project_part2/services/cart_store.dart';
import 'package:project_part2/screens/profile_screen.dart';
import 'package:project_part2/services/notification_service.dart';

//this shows teh current item the user intends to reserve called the reserve list but in here i named it cart screen
class CartScreen extends StatelessWidget {
  static String routeName = '/cart';
  CartScreen({Key? key}) : super(key: key);

  //the cart and order store from my services folder via get it
  final CartStore cart = GetIt.I<CartStore>();
  final OrdersStore orders = GetIt.I<OrdersStore>();

  //decodes the bae64 to image provider for display
  ImageProvider? _img(String b64) {
    if (b64.isEmpty) return null;
    try {
      return MemoryImage(base64Decode(b64));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final FoodItem? it = cart.current; //the single reserved item in progress

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        title: const Text('Reserve list'),
      ),
      body:
          it ==
                  null //if there are no items in cartstore, show an empty state alse it will show teh filled view
              ? const _EmptyCart()
              : _CartFilled(
                it: it,
                imageProvider: _img(it.image),
                onReserve: () async {
                  // this moves the item to ordersoter and clears teh cart
                  orders.add(it);
                  cart.clear();

                  // show local notification service which is one of my additional features
                  await NotificationService.showNotification(
                    title: 'Thank you!',
                    body: 'You just saved a meal and helped the planet 🌱',
                  );
                  //this is to tell users that they have recieved successfully and redirects them to teh profile screen

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reserved successfully.')),
                    );
                    Navigator.pushReplacementNamed(
                      context,
                      ProfileScreen.routeName,
                    );
                  }
                },
              ),
    );
  }
}

//an empty state widget when there is nothing in cartstore
class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Your reserve list is empty.\nFind meals to rescue! 🪴',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

//ui shown wehn ther is an item to return
class _CartFilled extends StatelessWidget {
  final FoodItem it; //this is the item being reserved
  final ImageProvider? imageProvider; //to preview the image but it may be null
  final VoidCallback
  onReserve; //handler when the user confirms the reserve of that food item

  const _CartFilled({
    Key? key,
    required this.it,
    required this.imageProvider,
    required this.onReserve,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('dd/MM/yyyy').format(it.date);

    return Column(
      children: [
        // the top section scrolls if needed as content grows
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // the card with imaeg on the top and basic item details info below
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDE7DA),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // rounded image on top of the card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: 200,
                          child:
                              imageProvider == null
                                  ? Container(
                                    color: const Color(0xFFA1CEAF),
                                    alignment: Alignment.center,
                                    child: const Text('No image'),
                                  )
                                  : Image(
                                    image: imageProvider!,
                                    fit: BoxFit.cover,
                                  ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      //  all the titel, price and reminder to byo container text below image
                      Text( 
                        it.foodName, //the food name
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('\$${it.discountedPrice.toStringAsFixed(2)}'), //the discounted price
                      const SizedBox(height: 6),
                      const Text(
                        'Remember to BYO container!', //to remind users to bring their own container
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // the bottom green panel fixed to the bottom, full width
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFFA1CEAF),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subtotal / Total
              Text(
                'Subtotal: \$${it.discountedPrice.toStringAsFixed(2)}', //the subtotal price
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 4),
              Text(
                'Total: \$${it.discountedPrice.toStringAsFixed(2)}', //the discounted price
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // the collection time range
              Row(
                children: [
                  const Icon(Icons.access_time, size: 23),
                  const SizedBox(width: 8),
                  Text(
                    it.collectionTimeRange.isEmpty
                        ? 'N/A'
                        : it.collectionTimeRange,
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // the date
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 23),
                  const SizedBox(width: 8),
                  Text(dateLabel),
                ],
              ),
              const SizedBox(height: 34),

              // and a preview of the map pickup location for the users
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(it.latitude, it.longitude),
                      initialZoom: 14,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker( //this shows the marker on the map
                            point: LatLng(it.latitude, it.longitude),
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_on,
                              size: 40,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // this is the reserve button with confirm alert dialog
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: 
                          (ctx) => AlertDialog( //an alert dialog used to ask users if they want to confirm to reserve the item
                            title: const Text("Reserve item"),
                            content: const Text("Yes, I'll reserve this item!"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text("Cancel"), //to cancel rserving the item
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text(
                                  "Confirm", //to confirm they want to reserve the item
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                    );
                    if (ok == true) onReserve(); //it will proceed if user confirms
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFBF70),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Reserve', //the text reserve on the orange button
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
