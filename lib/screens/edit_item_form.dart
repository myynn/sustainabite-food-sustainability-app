// lib/screens/edit_item_form.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../widgets/custom_text_field.dart';
import '../widgets/custom_dropdown.dart';
import '../services/firebase_service.dart';
import '../models/food_item.dart';

//this is the screen to edit an existing food item document and it already prefills the fields based on the original data from firestore
class EditItemForm extends StatefulWidget {
  final String docId; //the specific doc id the user is editing
  const EditItemForm({Key? key, required this.docId}) : super(key: key);

  @override
  State<EditItemForm> createState() => _EditItemFormState();
}

class _EditItemFormState extends State<EditItemForm> {
  
  final _form = GlobalKey<FormState>(); //to validate and save the form

  final nameController = TextEditingController(); //read only name preview as i wont allow users to edit the item name
  final descriptionController = TextEditingController(); //description input
  final timeController = TextEditingController(); //and collection time input
 
  // these are the dropdown backend values which are kept as strings to match my dropdowns
  String selectedOriginalPrice = '8.50';
  String selectedDiscountedPrice = '4.50';
  String selectedCO2Saved = '3.50';
  String selectedCategory = 'Western';

  // to make the quantity slider as whole numbers
  double quantity = 1;


  File? _imageFile;            // the newly picked image from the gallery if any
  String _base64Image = '';    // this persists the base64 image saved to firestore

//this picks the image from the gallery and converts to base 64 for storage
  Future<void> _pickImageFromGallery() async {
    final XFile? file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 900,
      imageQuality: 75,
    );
    if (file != null) {
      final f = File(file.path);
      setState(() {
        _imageFile = f;
        _base64Image = base64Encode(f.readAsBytesSync());
      });
    }
  }

  //this is the calendar section using table calendar my additional feature
  DateTime _focusedDay = DateTime.now(); //current calendar page
  DateTime? _selectedDay; //the chosen date which is required

  Widget _buildCalendarCard() { //this is the calendar card which is used to pick the items date
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFDDE7DA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TableCalendar(
        firstDay: DateTime(2000),
        lastDay: DateTime(2100),
        focusedDay: _focusedDay,
        headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (sel, foc) {
          setState(() {
            _selectedDay = sel;
            _focusedDay = foc;
          });
        },
        calendarStyle: const CalendarStyle(
          todayDecoration: BoxDecoration(color: Color(0xFFA1CEAF), shape: BoxShape.circle),
          selectedDecoration: BoxDecoration(color: Color(0xFF8BC39A), shape: BoxShape.circle),
        ),
      ),
    );
  }

  // this is the location flutter map and geolocator
  LatLng _mapCenter = const LatLng(1.3521, 103.8198); // default the area to around singapore area
  LatLng? _pickedLatLng; //users selected location

//this uses the device gps to se the map center and picked location
  Future<void> _useMyLocation() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied.')), //this is to show that the location permission is denied
        );
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      setState(() {
        _mapCenter = LatLng(pos.latitude, pos.longitude);
        _pickedLatLng = _mapCenter;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not get location: $e')), //this is to tell that they could not get the location
      );
    }
  }

//the map picker to let users tap and set a pickup location
  Widget _buildMapPicker() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFFDDE7DA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: _mapCenter,
            initialZoom: 13,
            onTap: (tapPosition, latlng) {
              setState(() => _pickedLatLng = latlng);
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            if (_pickedLatLng != null)
              MarkerLayer( //the marker used for the map
                markers: [
                  Marker(
                    point: _pickedLatLng!,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_on, size: 40, color: Colors.red),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // this loads the exiisting items details
  Future<FoodItem?> _loadItem() => getFoodItemById(widget.docId);

  void _prefill(FoodItem item) {
    // the text fields
    nameController.text = item.foodName;              // the food name is read only i wont allow users to change the food name once it is created
    descriptionController.text = item.foodDescription;
    timeController.text = item.collectionTimeRange;

    // the dropdown button sections
    selectedCategory = item.category;
    selectedOriginalPrice = item.originalPrice.toStringAsFixed(2);
    selectedDiscountedPrice = item.discountedPrice.toStringAsFixed(2);
    selectedCO2Saved = item.estimateCO2SavedKg.toStringAsFixed(2);

    // the slider for food quantity
    quantity = item.quantity.toDouble();

    // the date 
    _selectedDay = item.date;
    _focusedDay = item.date;

    //  the image
    _base64Image = item.image; // this keeps the original  base64 and only replace if user uploads new
    _imageFile = null;         // this is the preview from base64 if no new file

    //  the map
    if (item.latitude != null && item.longitude != null) {
      _pickedLatLng = LatLng(item.latitude!, item.longitude!);
      _mapCenter = _pickedLatLng!;
    }
  }

//to decide which preview to show new file or existing or none
  ImageProvider? _imagePreview() {
    if (_imageFile != null) {
      return FileImage(_imageFile!);
    }
    if (_base64Image.isNotEmpty) {
      try {
        return MemoryImage(base64Decode(_base64Image));
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  // this to save and update and validats the inputs for the existing firestore document
  Future<void> _update(FoodItem original) async {
    final isValid = _form.currentState!.validate();
    //this requires a check for the image, date and location
    if (_base64Image.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload an image.')),
      );
      return;
    }
    if (_selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date.')),
      );
      return;
    }
    if (_pickedLatLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick a location or use current location.')),
      );
      return;
    }
    if (!isValid) return;

    try {
      //this converts the dropdown strings to doubles
      final originalPrice = double.parse(selectedOriginalPrice);
      final discountedPrice = double.parse(selectedDiscountedPrice);
      final co2 = double.parse(selectedCO2Saved);

      // it is important to keep using original.foodName so the document id is the same as the one stored in firestore
      await updateFoodItem(
        original.foodName,              // this keeps the document id stable
        _base64Image, // this stores the base64 image
        descriptionController.text.trim(),
        timeController.text.trim(),
        _selectedDay!, //ensures it is non null due to earlier checks
        selectedCategory,
        quantity.toInt(),
        originalPrice,
        discountedPrice,
        co2,
        _pickedLatLng!.latitude, //also safe due to earlier checks
        _pickedLatLng!.longitude,
      );

      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Food item updated.')),
      );
      Navigator.pop(context); //users go back after success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update: $e')),
      );
    }
  }

  @override
  void dispose() {
    //this is to clean up controllers to avoid memory leaks
    nameController.dispose();
    descriptionController.dispose();
    timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FoodItem?>(
      future: _loadItem(), //this loads the existing item once
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()), //the loading state
          );
        } //if the item not found
        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: Text('Item not found')),
          );
        }

        final item = snapshot.data!;
        // the prefill exactly once after first time
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // this is to avoid re running on every rebuild
          if (nameController.text.isEmpty && _selectedDay == null && _base64Image.isEmpty) {
            _prefill(item);
            setState(() {}); // this is to refresh ui with prefilled values
          }
        });

        final dateLabel = _selectedDay == null //selected date label
            ? 'No Date Chosen'
            : 'Picked date: ${DateFormat('dd/MM/yyyy').format(_selectedDay!)}';

        return Scaffold(
          resizeToAvoidBottomInset: true, //scrolls when the keyboard shows
          backgroundColor: Colors.white,
          appBar: AppBar(
            automaticallyImplyLeading: true,
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'Edit item',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
          ),
          body: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFA1CEAF),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // this is teh image upload and preview
                    const Text('Upload image', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 120,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDDE7DA),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _imagePreview() == null
                                ? const Center(child: Text('No image'))
                                : Image(image: _imagePreview()!, fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon( //picking the image from teh library
                          onPressed: _pickImageFromGallery,
                          icon: const Icon(Icons.image),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFBF70),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          label: const Text('Upload from gallery'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // the food name is read only to keep document id stable
                    const Text('Food name', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDE7DA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        nameController.text,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 8),

                    CustomTextField(label: "Food description", controller: descriptionController),
                    const SizedBox(height: 8),
                    CustomTextField(
                      label: "Collection time range (e.g. 22:00 - 22:30)",
                      controller: timeController,
                    ),
                    const SizedBox(height: 8),

                    // the calendar
                    const Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    _buildCalendarCard(),
                    const SizedBox(height: 6),
                    Text(dateLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),

                    // the category dropown
                    CustomDropdown(
                      label: "Category",
                      value: selectedCategory,
                      items: const ['Western', 'Japanese', 'Indian', 'Korean'],
                      onChanged: (val) => setState(() => selectedCategory = val!),
                    ),
                    const SizedBox(height: 12),

                    // the quantity slider
                    const Text("Quantity", style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: quantity,
                            onChanged: (val) => setState(() => quantity = val.roundToDouble()),
                            min: 1,
                            max: 20,
                            divisions: 19,
                            activeColor: Colors.green[800],
                          ),
                        ),
                        Text('${quantity.toInt()}',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // the prices and amount of c02 saved dropdwons
                    CustomDropdown(
                      label: "Original price",
                      value: selectedOriginalPrice,
                      items: const ['6.00', '6.50', '7.00', '7.50', '8.00', '8.50', '9.00', '9.50', '10.00', '10.50', '11.00', '11.50', '12.00'],
                      onChanged: (val) => setState(() => selectedOriginalPrice = val!),
                    ),
                    const SizedBox(height: 8),
                    CustomDropdown(
                      label: "Discounted price",
                      value: selectedDiscountedPrice,
                      items: const ['2.50', '3.00', '3.50', '4.00', '4.50', '5.00', '5.50', '6.00', '6.50', '7.00', '7.50', '8.00', '8.50', '9.00', '9.50', '10.00'],
                      onChanged: (val) => setState(() => selectedDiscountedPrice = val!),
                    ),
                    const SizedBox(height: 8),
                    CustomDropdown(
                      label: "Estimated CO₂ saved (Kg)",
                      value: selectedCO2Saved,
                      items: const ['1.25', '2.00', '3.50', '4.75'],
                      onChanged: (val) => setState(() => selectedCO2Saved = val!),
                    ),
                    const SizedBox(height: 16),

                    // the map picker
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Pickup location', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextButton.icon(
                          onPressed: _useMyLocation,
                          icon: const Icon(Icons.my_location),
                          label: const Text('Use my location'),
                          style: TextButton.styleFrom(foregroundColor: Colors.black87),
                        ),
                      ],
                    ),
                    _buildMapPicker(),
                    const SizedBox(height: 20),

                    // to update the item
                    Center(
                      child: ElevatedButton(
                        onPressed: () => _update(item),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFBF70),
                          padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          foregroundColor: Colors.black,
                        ),
                        child: const Text("Save changes", //the text save changes on the button
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
