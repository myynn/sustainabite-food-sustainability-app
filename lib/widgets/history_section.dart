import 'package:flutter/material.dart';


// this is the history section for the profile page that i seperated
class HistorySection extends StatefulWidget {   //stateful because the selected food items in the filter chip changes
  const HistorySection({Key? key}) : super(key: key);

  @override
  _HistorySectionState createState() => _HistorySectionState();
}


class _HistorySectionState extends State<HistorySection> {
  final List<String> cuisines = ['All', 'Japanese', 'Western', 'Indian', 'Mexican']; // these are the filter options
  String selectedCuisine = 'Japanese'; //this is the default selection for the filter chip filter selected

  final List<Map<String, String>> allHistoryItems = [ // i hardcoded food items in the user history just for showing how the filterchip works
    {
      'title': 'Sushi pack',
      'imagePath': 'images/sushi.png',
      'cuisine': 'Japanese',
    },
    {
      'title': 'Green wraps',
      'imagePath': 'images/greenwrap.png',
      'cuisine': 'Western',
    },
    {
      'title': 'Burger',
      'imagePath': 'images/burger.png',
      'cuisine': 'Western',
    },
    {
      'title': 'Mashed potato',
      'imagePath': 'images/potatoes.png',
      'cuisine': 'Western',
    },
  ];

  @override
  Widget build(BuildContext context) { //this allows th list to be filtered based on the selected cuisine by the user
    final filteredItems = allHistoryItems
        .where((item) => item['cuisine'] == selectedCuisine)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text( // the history title for this section that i decided to add in later on
          'History',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(  //this creates the layout for the filterchips so that it doesnt overflow to the next line
          spacing: 8,
          children: cuisines.map((cuisine) {
            return FilterChip(
              label: Text(cuisine),
              selected: selectedCuisine == cuisine,
              onSelected: (_) {
                setState(() {
                  selectedCuisine = cuisine;
                });
              },
              backgroundColor: Color(0xFFDDE7DA),
              selectedColor: const Color(0xFFFFBF70), //this will make the filter change to orange when user selects it
              labelStyle: const TextStyle(color: Colors.black),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        ...filteredItems.map((item) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFDDE7DA), //maker the rounded box around each food item in the history section
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(  //listile is used to make the image on the left of the rounded box and the text to the rihgt
                leading: ClipRRect( //make the image rounded
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    item['imagePath']!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(item['title']!), //the history food item title and below is for the cuisine
                subtitle: Text(item['cuisine']!),
              ),
            )),
      ],
    );
  }
}