import 'package:flutter/material.dart';

//this is for the text fields in the add item form screen
class CustomTextField extends StatelessWidget {
  final String label; //this is the title text above each field input
  final TextEditingController
  controller; //this controls the value inside the field
  final bool isNumber;
  final IconData? icon;
  final VoidCallback? onTap; //this is the ontap for the text to speech addtional feature

  const CustomTextField({
    Key? key,
    required this.label,
    required this.controller,
    this.isNumber = false,
    this.icon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ), //this displays the label text above the field
        const SizedBox(height: 4),
        Container(
          //all the input fields have common rounded edges and green colour
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFDDE7DA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              if (icon !=
                  null) //this is to allow an icon to be inside the input field as i added an image icon inside the upload image section of the form
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(icon, color: Colors.grey[700]),
                ),
              Expanded(
                //this is to make sure that the text that the user inputs fills in the horizontal space
                child: TextFormField(
                  controller: controller,
                  onTap: onTap, //on tap for the text to speech
                  keyboardType:
                      isNumber
                          ? TextInputType.number
                          : TextInputType
                              .text, //this is to set the data type of the input like number or text
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                  validator: (value) {
                    //the form validator that i am not using as i straight away allow navigation from the done button back to the business page
                    if (value == null || value.isEmpty) {
                      return 'This field cannot be empty'; //makes sure that the field is not empty
                    }
                    if (isNumber && double.tryParse(value) == null) {
                      return 'Enter a valid number'; //makes sure that the field has the correct data type
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
