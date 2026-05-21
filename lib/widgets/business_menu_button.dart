import 'package:flutter/material.dart';


//this is the business menu bottom sheet dialog button beside the business logo in the business screen
class BusinessMenuButton extends StatelessWidget {
  final VoidCallback onPressed; //this opens the bottom dialog when tapped

  const BusinessMenuButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration( //changes the colour rounded corners and the text of the button which is the 3 dots
          color: Color(0xFFFFBF70),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Text(
          '•••',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}