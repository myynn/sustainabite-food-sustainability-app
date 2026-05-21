import 'package:flutter/material.dart';


//this is for the food cards in the main screen
class FoodCard extends StatelessWidget { // this is the inputs required to build the card which i passed from the main.dart
  final ImageProvider<Object>? imageProvider;
  final String title;
  final String originalPrice;
  final String discountedPrice;
  final String co2Saved;

  const FoodCard({  
    Key? key,
    required this.imageProvider,
    required this.title,
    required this.originalPrice,
    required this.discountedPrice,
    required this.co2Saved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container( //this is the card around each food item detials
      width: 160,
      margin: EdgeInsets.only(right: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFDDE7DA), //the light green background of each card
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 100,
                width: double.infinity,
                color: const Color(0xFFDDE7DA),
                child: imageProvider == null
                    ? const Center(child: Text('No image'))
                    : Image(image: imageProvider!, fit: BoxFit.cover), //the image
              ),
            ),
        const SizedBox(height: 6),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)), //these are all the details of all the food items
          Text(
            'Original: \$${originalPrice}', //the original price in green
            style: TextStyle(color: Colors.green),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${discountedPrice}', //the discounted price
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('${co2Saved}Kg of CO₂', style: TextStyle(fontSize: 12)), //the amount of c02 saved for that food
            ],
          ),
        ],
      ),
    );
  }
}
