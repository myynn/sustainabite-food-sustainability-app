// lib/screens/add_item_form.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:project_part2/services/notification_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../widgets/custom_text_field.dart';
import '../widgets/custom_dropdown.dart';
import '../services/firebase_service.dart'; 


//this screen is for the add item form for users that have a smalll business to add an item for the app
//my additional features in this form include the image picker, table calendar for adding date, flutter map, latlong2, and geolocator for the location
//flutter text to speech for when users press the text field and it will say text like enter food name, and a local notifcation using flutter local notification upon successful submission
class AddItemForm extends StatefulWidget {
  final Map<String, String>? existingItem; 
  const AddItemForm({Key? key, this.existingItem}) : super(key: key);

  @override
  State<AddItemForm> createState() => _AddItemFormState();
}

class _AddItemFormState extends State<AddItemForm> {
  
  final _form = GlobalKey<FormState>(); //form validation/state

  final nameController = TextEditingController(); //food name
  final descriptionController = TextEditingController(); //description
  final timeController = TextEditingController(); //time collection range
  final FlutterTts _tts = FlutterTts(); //my additional feature text to speech for certain text fields


  @override
  void initState() {
    super.initState();
    _initTts(); //to configure text to speech once
  }

  Future<void> _initTts() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    try {
      await _tts.speak(text);
    } catch (_) {}
  }

  String selectedOriginalPrice = '8.50';
  String selectedDiscountedPrice = '4.50';
  String selectedCO2Saved = '3.50';
  String selectedCategory = 'Western';

  // to ensure that the quantity slider is only whole numbers
  double quantity = 1;

  // image from gallery only
  File? _imageFile; //picked file preview
  String _base64Image = ''; //this is what we will persist to firestore

//to pick an image from the gallery and encode to base64 for storage
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

  //date selection i used using table calendar one of my additional featuers
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

//a clander card to select the availability or collection date
  Widget _buildCalendarCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFDDE7DA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TableCalendar(
        firstDay: DateTime.now(), //this is to block past dates, so user cant select dates from the past
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

  // the location using flutter map and geolocator one of my additional features
  LatLng _mapCenter = LatLng(1.3521, 103.8198); //default area is singapore area
  LatLng? _pickedLatLng; //the users selected point

//this uses the device gps to centre the mao and set the pickup coordinates
  Future<void> _useMyLocation() async {
    try {
      // ask teh users for permission to access their location if needed
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied.')),
        );
        return;
      }

//to get the users current position
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      setState(() {
        _mapCenter = LatLng(pos.latitude, pos.longitude);
        _pickedLatLng = _mapCenter;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not get location: $e')),
      );
    }
  }

//a small map picker to allow users to tap the map to select the pickup marker
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
              MarkerLayer(
                markers: [
                  Marker( //this is the marker on the map
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

  // to save and validate the new item to firestore via addfooditem
  Future<void> _submitForm() async {
    final isValid = _form.currentState!.validate();

//i used snackbar to require all fields to ensure no empty fields
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
        const SnackBar(content: Text('Please pick a location on the map or use current location.')),
      );
      return;
    }
    if (!isValid) return;

    try {
      // this is to convert the dropdown to strings
      final originalPrice = double.parse(selectedOriginalPrice);
      final discountedPrice = double.parse(selectedDiscountedPrice);
      final co2 = double.parse(selectedCO2Saved);

//this is to persist to backend
      await addFoodItem(
        _base64Image,
        nameController.text.trim(),
        descriptionController.text.trim(),
        timeController.text.trim(), // free text range
        _selectedDay!, // the date from calendar
        selectedCategory,
        quantity.toInt(),
        originalPrice,
        discountedPrice,
        co2,
        _pickedLatLng!.latitude,
        _pickedLatLng!.longitude,
      );

//using local notification and text to speech
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Food item added!')),
      );
      await _speak("Submission successful");
      await NotificationService.showNotification(
        title: 'Item added',
        body: '“${nameController.text.trim()}” is now available for customers!',
      );
      Navigator.pop(context); //to allow users to return to previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
      );
    }
  }

  @override
  void dispose() {
    _tts.stop(); //to stop the text to speech
    nameController.dispose();
    descriptionController.dispose();
    timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = _selectedDay == null
        ? 'No Date Chosen'
        : 'Picked date: ${DateFormat('dd/MM/yyyy').format(_selectedDay!)}';

    return Scaffold(
      resizeToAvoidBottomInset: true, //to prevent keyboard overlap
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Add item',
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
                // for uploading of image and preview
                const Text('Upload image', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    //this is the preview box either the chosen image file or a placholder
                    Container(
                      width: 120,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDE7DA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _imageFile == null
                          ? const Center(child: Text('No image'))
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(_imageFile!, fit: BoxFit.cover),
                            ),
                    ),
                    const SizedBox(width: 12),
                    //users to pick an image from their gallery
                    ElevatedButton.icon(
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

                // the text fields for food name, descrtiption, and collection time range, using my widget custom text field
                //these are the 3 text fields i implemented text to speech for, when they tap the text field they will get the sound like enter food name
                CustomTextField(label: "Food name", controller: nameController, onTap: () => _speak("Enter food name"),), //the text to speech
                const SizedBox(height: 8),
                CustomTextField(label: "Food description", controller: descriptionController, onTap: () => _speak("Enter food description"),), //the text to speech
                const SizedBox(height: 8),
                CustomTextField(
                  label: "Collection time range (e.g. 22:00 - 22:30)",
                  controller: timeController,
                  onTap: () => _speak("Enter collection time range, for example, 22 00 to 22 30"), //the text to speech
                ),
                const SizedBox(height: 8),

                // calendar field
                const Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                _buildCalendarCard(),
                const SizedBox(height: 6),
                Text(dateLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),

                // category section using my widget dropdown
                CustomDropdown(
                  label: "Category",
                  value: selectedCategory,
                  items: const ['Western', 'Japanese', 'Indian', 'Korean'],
                  onChanged: (val) => setState(() => selectedCategory = val!),
                ),
                const SizedBox(height: 12),

                //quantity section that users will select using the slider
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

                // customdropdown section again for my prices, and estimates c02 saved
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
                    const Text('Pickup location', style: TextStyle(fontWeight: FontWeight.bold)), //to allow users to select and get the location based on theri current loation
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

                //save button to submit the form
                Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFBF70),
                      padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      foregroundColor: Colors.black,
                    ),
                    child: const Text("Done", style: TextStyle(fontWeight: FontWeight.bold)), //the done text on the submit button
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
