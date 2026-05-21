import 'package:flutter/material.dart';

//this is my search bar widget that is used in the main screen
class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller; //with a configurable text controller for readinf and managing the search text field value
  final ValueChanged<String>? onChanged; //this is for an optional callback that will be triggered whenever the text changes do it is useful for live searching by the users

  const SearchBarWidget({
    Key? key,
    required this.controller,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFA1CEAF),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller, //this binds the search bar to an external controller
        onChanged: onChanged, //this fires callback on text changes by the user
        decoration: const InputDecoration(
          icon: Icon(Icons.search, color: Colors.black54), //the search icon
          hintText: 'Find meals to rescue', //the placholder text
          border: InputBorder.none,  //this is to remove teh default underline which i dont want on my search bar
        ),
        style: const TextStyle(color: Colors.black87),
      ),
    );
  }
}
