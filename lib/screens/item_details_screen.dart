// lib/screens/item_details_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:project_part2/screens/cart_screen.dart';
import 'package:project_part2/services/cart_store.dart';

import '../models/food_item.dart';
import '../services/firebase_service.dart';

//this is my select on query for basic crud
//this is to show the details of that food item selected by the user in the main screen like image, map location, c02 saved info, etc, and a add to reserve list button which will redirect users to the reserve list/cart screen 
class ItemDetailsScreen extends StatelessWidget {
  final String docId;
  const ItemDetailsScreen({Key? key, required this.docId}) : super(key: key);
  static const double _imageHeight = 160; //this is the layout constants for the top image section
  static const double _imageRadius = 16;
  static const double _gapBelowImage = 30;

//to decode the base64 image to an imageprovider that returns null if invalid or empty
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
    return FutureBuilder<FoodItem?>(
      future: getFoodItemById(docId), //this fetches the item by the document id, this is my select one query to show item details of that one selected item
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) { //this is the loading state
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()), 
          );
        }
        if (!snap.hasData || snap.data == null) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: Text('Item not found')), //shows an error item not found if item is not found
          );
        }

        final it = snap.data!;
        final img = _img(it.image);
        final dateLabel = DateFormat('yyyy/MM/dd').format(it.date);
        final screenH = MediaQuery.of(context).size.height; //this is to compute the minimum height of teh green panel so ite opens tall enough on all devices
        final topSafe = MediaQuery.of(context).padding.top;
        const appBarH = kToolbarHeight;
        final double minPanelH = (screenH - topSafe - appBarH - _imageHeight - _gapBelowImage)
            .clamp(0, double.infinity)
            .toDouble();

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            //this is the back arrow of the app bar
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // this is the top imag of the food item
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(_imageRadius),
                    child: SizedBox(
                      height: _imageHeight,
                      width: double.infinity,
                      child: img == null
                          ? Container(
                              color: const Color(0xFFDDE7DA),
                              alignment: Alignment.center,
                              child: const Text('No image'),
                            )
                          : FittedBox( // this is to scale the image to prevent crop
                              fit: BoxFit.contain,
                              child: Image(image: img),
                            ),
                    )
                  ),
                ),
                const SizedBox(height: _gapBelowImage),

                //the bottom green item details panel
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: minPanelH),
                  child: Container(
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
                      //this is to make the title and price at the top right
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // this is for the left quantity time and date
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  it.foodName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                // these are the icons for shopping cart for quantity left
                                Row(
                                  children: [
                                    const Icon(Icons.shopping_cart, size: 18),
                                    const SizedBox(width: 6),
                                    Text('${it.quantity} left'), //the quantity of the items left
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 18), //this is the clock icon
                                    const SizedBox(width: 6),
                                    Text(it.collectionTimeRange.isEmpty //and this is teh collection time range for users collection time
                                        ? 'N/A'
                                        : it.collectionTimeRange),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 18), //this is the calendar icon and then show the date
                                    const SizedBox(width: 6),
                                    Text(dateLabel),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // this is the price on the top right of this bottom rectangle section
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDDE7DA),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$${it.discountedPrice.toStringAsFixed(2)}', //this is the discounted price in bold
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Original: \$${it.originalPrice.toStringAsFixed(2)}', //this is the original price below
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // this is the food description section
                      const Text('Food description',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDDE7DA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          it.foodDescription.isEmpty
                              ? 'No description.' //to show if no description
                              : it.foodDescription,
                        ),
                      ),

                      const SizedBox(height: 16),

                      //this is the location flutter map which is centred
                      const Center(
                        child: Text('Pickup location', //to show users the pickup location for that food item
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          height: 220,
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
                                  Marker( //shows a marker for the pick up location on the map
                                    point: LatLng(it.latitude, it.longitude),
                                    width: 40,
                                    height: 40,
                                    child: const Icon(Icons.location_on,
                                        size: 40, color: Colors.red),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // this is the sustainability part to show the c02 users can save from rescuing the meal
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDDE7DA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Save ${it.estimateCO2SavedKg.toStringAsFixed(1)} Kg of CO₂ emissions.', //to tell them how much c02 they can save from being emitted if food oges to waste
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'BYO container and reusable utensils for extra impact!', //remind them to remember to bring their own container
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

                      // the orange add to reserve list button
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            final cart = GetIt.I<CartStore>();
                            cart.set(it); // put the selected food item into the cart/ reserve list screen
                            Navigator.pushNamed(context, CartScreen.routeName); //and redirect them to the cart screen/reserve list screen
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFBF70),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 60, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Add to reserve list', //the text on the button which says add to reserve list
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
