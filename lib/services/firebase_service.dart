import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:project_part2/models/food_item.dart';

class FirebaseService {
  //this registers a new user with an email and password

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // this is a public mapper so main.dart can call fb.mapDocToFoodItem
  FoodItem mapDocToFoodItem(DocumentSnapshot<Map<String, dynamic>> d) {
    return _mapDocToFoodItem(
      d,
    );
  }

  FoodItem _mapDocToFoodItem(DocumentSnapshot<Map<String, dynamic>> d) {
    final data = d.data() ?? {};
    final ts = data['date'];
    final date =
        ts is Timestamp ? ts.toDate() : (ts is DateTime ? ts : DateTime.now());
    final GeoPoint? gp = data['location'] as GeoPoint?;
    return FoodItem(
      id: d.id,
      image: (data['image'] ?? '') as String,
      foodName: (data['foodName'] ?? '') as String,
      foodDescription: (data['foodDescription'] ?? '') as String,
      collectionTimeRange: (data['collectionTimeRange'] ?? '') as String,
      date: date,
      category: (data['category'] ?? '') as String,
      quantity: (data['quantity'] ?? 0) as int,
      originalPrice: (data['originalPrice'] as num?)?.toDouble() ?? 0.0,
      discountedPrice: (data['discountedPrice'] as num?)?.toDouble() ?? 0.0,
      estimateCO2SavedKg: (data['estimateCO2SavedKg'] as num?)?.toDouble() ?? 0.0,
      latitude: gp?.latitude ?? 0.0,
      longitude: gp?.longitude ?? 0.0,
      businessEmail: (data['businessEmail'] ?? '') as String,
    );
  }

  // this is the select all food items ordered by newest first in the main screen which is the default for what users see without any filters selected
  Stream<List<FoodItem>> getAllFoodItems({bool newestFirst = true}) {
    final q = _db.collection('food_items').orderBy('date', descending: newestFirst);
    return q.snapshots().map((s) => s.docs.map(mapDocToFoodItem).toList());
  }



  // this is my first advanced query for select with filter criteria for other than identifier for filtering the food items so only food items less than or equal to the selected max discounted price
  Future<List<FoodItem>> filterByMaxPrice(double maxPrice) async {
    final qs = await _db
        .collection('food_items')
        .where('discountedPrice', isLessThanOrEqualTo: maxPrice) //the results will show less than or equals to the max discounted price selected by the user
        .get();
    return qs.docs.map(mapDocToFoodItem).toList();
  }

  // this is my 2nd advanced query for select with multiple filter query for same fields for filtering based on mulitple selected categories for the food items
  Future<List<FoodItem>> filterByCategories(List<String> categories) async {
    if (categories.isEmpty) return [];
    final qs = await _db
        .collection('food_items')
        .where('category', whereIn: categories.take(10).toList())
        .get();
    return qs.docs.map(mapDocToFoodItem).toList();
  }

  // this is my 3rd advanced query for select with mulitple filter criteria for different fields for filtering based on category and less than or equal to of the discounted price of the food item
  Future<List<FoodItem>> filterCategoryAndPrice(String category, double maxPrice) async {
    final qs = await _db
        .collection('food_items')
        .where('category', isEqualTo: category) //for category selected 
        .where('discountedPrice', isLessThanOrEqualTo: maxPrice) //for max price less than or equals to selected
        .get();
    return qs.docs.map(mapDocToFoodItem).toList();
  }

  // this is my 4th advanced query for select with sort order for ordering food items by low to high food price
  Future<List<FoodItem>> listAllSortedByPrice({int limit = 50}) async {
    final qs = await _db
        .collection('food_items')
        .orderBy('discountedPrice') //to order the results by low to high food prices
        .limit(limit)
        .get();
    return qs.docs.map(mapDocToFoodItem).toList();
  }

  // this is my 5th advanced query for select with aggregation by count
  Future<int> countByCategory(String category) async {
    final agg = await _db
        .collection('food_items')
        .where('category', isEqualTo: category) //the category selected
        .count() //to count the number of food items in that category
        .get();
    return agg.count as int; 
  }

  // search prefix used for my search bar in my main screen
  Future<List<FoodItem>> searchByNamePrefix(String q, {int limit = 40}) async {
    final s = q.trim().toLowerCase();
    if (s.isEmpty) return [];
    final qs = await _db
        .collection('food_items')
        .orderBy('foodNameLower') //for lower case searches
        .startAt([s]) //starts with that character
        .endAt(['$s\uf8ff'])
        .limit(limit)
        .get();
    return qs.docs.map(mapDocToFoodItem).toList();
  }

  Future<UserCredential> register(email, password) {
    return FirebaseAuth.instance.createUserWithEmailAndPassword(
      //returns a usercredential object if successful
      email: email,
      password: password,
    );
  }

  Future<UserCredential> login(email, password) {
    //authenticates user using email and password
    return FirebaseAuth.instance.signInWithEmailAndPassword(
      //returns usercredential object upon success
      email: email,
      password: password,
    );
  }

  Stream<User?> getAuthUser() {
    //provides a stream to track if a user logs in or out
    return FirebaseAuth.instance.authStateChanges();
  }

  User? getCurrentUser() {
    //gets current user info
    return FirebaseAuth
        .instance
        .currentUser; //returns the currently logged in user or null if not signed in
  }

  Future<void> logout() {
    //logsout the currently authenticated user
    return FirebaseAuth.instance.signOut();
  }

  Future<void> forgotPassword(email) {
    //sends a reset email to the given email address to allow a reset of their password
    return FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  Future<void> changePassword(String newPassword) async {
    //changes the password of the currently signed in user
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.updatePassword(newPassword);
    }
  }

  Future<void> deleteAccount() async {
    //deletes the currently signed in users account from
    return FirebaseAuth.instance.currentUser!.delete();
  }

  Future<dynamic> signInWithGoogle() async {
    //initiates the google sign in with a specific client id and prompts the user to select a google account
    try {
      GoogleSignInAccount? googleUser =
          await GoogleSignIn(
            clientId: 'YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com',
          ).signIn();

      GoogleSignInAuthentication? googleAuth =
          await googleUser
              ?.authentication; //retrieves the oauth tokens and exchanges them for firebase credentials
      //signs in the user into firebase using those credentials
      OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      //catches and logs any errors that happen during google sign in process
      debugPrint('Google Sign-In failed: $e');
      return null;
    }
  }

  Future<UserCredential> signInWithGitHub() async {
    //sign in using github
    if (!kIsWeb) {
      throw UnsupportedError('GitHub sign-in only supported on web for now');
    }

    GithubAuthProvider githubProvider = GithubAuthProvider();

    // confirgures how github authentication behaves when you sign in a user through firebase using the githubauthprovider
    githubProvider.addScope(
      'read:user',
    ); //this is a permission that allows the app to read the user's public profile information
    githubProvider.setCustomParameters({
      'allow_signup': 'false',
      'prompt': 'login',
    });
    //prevents github from showing a sign up link in the pop up to restrict to login with existing github accounts only
    //forces github to show the login screen everytime rather than automatically selecting a previously signed in user

    return await FirebaseAuth.instance.signInWithPopup(
      githubProvider,
    ); //triggers a github login popup and signs in the user with the return credentials
  }
}

// create function for adding food item with custom document id
Future<void> addFoodItem(
  String base64Image,
  String foodName,
  String foodDescription,
  String collectionTimeRange,
  DateTime date,
  String category,
  int quantity,
  double originalPrice,
  double discountedPrice,
  double estimateCO2SavedKg,
  double latitude,
  double longitude,
) {
  // uses food name and email for custom document id
  final String? email = FirebaseAuth.instance.currentUser?.email;
  final String docId = "${email}_${foodName.replaceAll(' ', '_')}";

  return FirebaseFirestore.instance.collection('food_items').doc(docId).set({
    'image': base64Image,
    'foodName': foodName,
    'foodNameLower': foodName.toLowerCase(),
    'foodDescription': foodDescription,
    'collectionTimeRange': collectionTimeRange,
    'date': date,
    'category': category,
    'quantity': quantity,
    'originalPrice': originalPrice,
    'discountedPrice': discountedPrice,
    'estimateCO2SavedKg': estimateCO2SavedKg,
    'businessEmail': email,
    'location': GeoPoint(latitude, longitude),
    'createdAt': DateTime.now(),
  });
}

// read function, this is my select all query for my business screen to select all food items and display based on the currently signed in email
Stream<List<FoodItem>> getFoodItems() {
  final String? email = FirebaseAuth.instance.currentUser?.email;

  return FirebaseFirestore.instance
      .collection('food_items')
      .where('businessEmail', isEqualTo: email)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) {
              final data = doc.data();

              final ts = data['date'];
              final date =
                  ts is Timestamp
                      ? ts.toDate()
                      : (ts as DateTime? ?? DateTime.now());
              final gp = data['location'] as GeoPoint?;

              return FoodItem(
                id: doc.id,
                image: (data['image'] ?? '') as String,
                foodName: (data['foodName'] ?? '') as String,
                foodDescription: (data['foodDescription'] ?? '') as String,
                collectionTimeRange:
                    (data['collectionTimeRange'] ?? '') as String,
                date: date,
                category: (data['category'] ?? '') as String,
                quantity: (data['quantity'] ?? 0) as int,
                originalPrice: (data['originalPrice'] ?? 0).toDouble(),
                discountedPrice: (data['discountedPrice'] ?? 0).toDouble(),
                estimateCO2SavedKg:
                    (data['estimateCO2SavedKg'] ?? 0).toDouble(),
                latitude: gp?.latitude ?? 0.0,
                longitude: gp?.longitude ?? 0.0,
                businessEmail: (data['businessEmail'] ?? '') as String,
              );
            }).toList(),
      );
}

// this is my select one query for food item details that can be access in the main screen when users tap a food card
Future<FoodItem?> getFoodItemById(String docId) async {
  final doc =
      await FirebaseFirestore.instance
          .collection('food_items')
          .doc(docId)
          .get();

  if (!doc.exists) return null;

  final data = doc.data()!;
  final ts = data['date'];
  final date =
      ts is Timestamp ? ts.toDate() : (ts as DateTime? ?? DateTime.now());
  final gp = data['location'] as GeoPoint?;

  return FoodItem(
    id: doc.id,
    image: (data['image'] ?? '') as String,
    foodName: (data['foodName'] ?? '') as String,
    foodDescription: (data['foodDescription'] ?? '') as String,
    collectionTimeRange: (data['collectionTimeRange'] ?? '') as String,
    date: date,
    category: (data['category'] ?? '') as String,
    quantity: (data['quantity'] ?? 0) as int,
    originalPrice: (data['originalPrice'] ?? 0).toDouble(),
    discountedPrice: (data['discountedPrice'] ?? 0).toDouble(),
    estimateCO2SavedKg: (data['estimateCO2SavedKg'] ?? 0).toDouble(),
    latitude: gp?.latitude ?? 0.0,
    longitude: gp?.longitude ?? 0.0,
    businessEmail: (data['businessEmail'] ?? '') as String,
  );
}

// this is to update a food item based on the document id
Future<void> updateFoodItem(
  String foodName,
  String base64Image,
  String foodDescription,
  String collectionTimeRange,
  DateTime date,
  String category,
  int quantity,
  double originalPrice,
  double discountedPrice,
  double estimateCO2SavedKg,
  double latitude,
  double longitude,
) {
  final String? email = FirebaseAuth.instance.currentUser?.email;
  final String docId = "${email}_${foodName.replaceAll(' ', '_')}";

  return FirebaseFirestore.instance.collection('food_items').doc(docId).update({
    'image': base64Image,
    'foodDescription': foodDescription,
    'foodNameLower': foodName.toLowerCase(),
    'collectionTimeRange': collectionTimeRange,
    'date': date,
    'category': category,
    'quantity': quantity,
    'originalPrice': originalPrice,
    'discountedPrice': discountedPrice,
    'estimateCO2SavedKg': estimateCO2SavedKg,
    'location': GeoPoint(latitude, longitude),
    'updatedAt': DateTime.now(),
  });
}

//this is the delete function to delete a food item
Future<void> deleteFoodItem(String foodName) {
  final String? email = FirebaseAuth.instance.currentUser?.email;
  final String docId = "${email}_${foodName.replaceAll(' ', '_')}";

  return FirebaseFirestore.instance
      .collection('food_items')
      .doc(docId)
      .delete();
}

//this is the update function for after successful payment by the user to minus 1 of the quantity of that food item by the business
Future<void> reserveOne(String docId) async {
  final ref = FirebaseFirestore.instance.collection('food_items').doc(docId);
  await FirebaseFirestore.instance.runTransaction((tx) async {
    final snap = await tx.get(ref);
    if (!snap.exists) throw StateError('Item no longer exists'); //if item no longer exists, it will show item no longer exists

    final qty = (snap.data()?['quantity'] ?? 0) as int;
    if (qty <= 0) throw StateError('Sold out'); //if quantity is 0, it will show item sold out

    tx.update(ref, {'quantity': FieldValue.increment(-1)}); //this is the minus 1 of the food quantity for that food item
  });
}
