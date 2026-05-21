import 'package:flutter/material.dart';


//this is from the filter dropdown bottom formfield in the main screen
class FilterDropdown extends StatelessWidget {
  final String selectedValue;  //selectedvalue is the current selected item on the dropdown
  final List<String> options;  //options is the list of strings that is in the dropdown
  final ValueChanged<String?> onChanged; //this triggers the callback when the user selects the option in the dorpdown

  const FilterDropdown({
    Key? key,
    required this.selectedValue,
    required this.options,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container( //this is the design of the dropdoqn box which is green colour and has rounded edges
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFDDE7DA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline( //this hides the options first
        child: DropdownButton<String>(
          value: selectedValue,
          icon: const Icon(Icons.arrow_drop_down),
          dropdownColor: const Color(0xFFA1CEAF),
          style: const TextStyle(color: Colors.black),
          borderRadius: BorderRadius.circular(12),
          items: options.map((String value) {  //this maps the options into the doepdownmenuitem widget
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}