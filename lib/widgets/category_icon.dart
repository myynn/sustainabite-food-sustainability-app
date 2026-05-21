import 'package:flutter/material.dart';


//this is for the orange icon buttons on the main screen
class CategoryIcon extends StatelessWidget {
  final IconData icon; //this is the code where i must pass in an icon, label it like "meals", and an optional tap action
  final String label;
  final VoidCallback? onTap;

  const CategoryIcon({
    Key? key,
    required this.icon,
    required this.label,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column( //the category icons are structured vertically using a column with an icon at the top and label below it is surrounded by a rounded orange box
      children: [
        InkWell( //this is for tappable icons
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFBF70),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon( //to adjust the icon size and colour
              icon,
              color: Colors.black,
              size: 36,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text( //this is the lable text under the icon in the orange rounded box
          label,
          style: const TextStyle(fontSize: 14), // Optional: slightly larger label
        ),
      ],
    );
  }
}
      
