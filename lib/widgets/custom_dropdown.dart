import 'package:flutter/material.dart';


//this is for the reusable dropdwon widget in the add item form
class CustomDropdown extends StatelessWidget {
  final String label; //this is the label of the dropdown like original price of the food item
  final String value; //this is the currently selected item from the options
  final List<String> items; //this is the list of options in the dropdown
  final void Function(String?) onChanged; //this is to allow the new value to be displayed after it is selected by the user

  const CustomDropdown({
    Key? key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column( //to ensure that the label is on the top of the dropdown box
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(  //gives the rounded corners and a green colour
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFDDE7DA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline( //to remove the default outline of the dropdown box as i dont want the outline and dont have it in the wireframe
            child: DropdownButton<String>(
              value: value, //the value of the current selected item
              isExpanded: true, //ensure that it dropsdown in a horizontal way 
              icon: Container( //makes that green circle around the arrow icon in the dropdown 
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFFA1CEAF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_drop_down),
              ),
              dropdownColor: const Color(0xFFA1CEAF), //makes the corners of the dropdown rounded and green colour
              borderRadius: BorderRadius.circular(12),
              items: items.map((val) { //makes the item list into the dropdown menu
                return DropdownMenuItem<String>(
                  value: val,
                  child: Text(val),
                );
              }).toList(),
              onChanged: onChanged, //is the value when the user selects a new item
            ),
          ),
        ),
      ],
    );
  }
}