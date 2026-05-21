
//this fooditem contains all the details for a single food listing, this model is used throuhgout the app in additemform, profilescreen, etc
class FoodItem {
  String id; //firestore doc id
  String image; //base64 encoded string of the image
  String foodName; //name of the food item
  String foodDescription; //description of hte food item
  String collectionTimeRange; //collection time range based on businesses users selction
  DateTime date; //date available for collection
  String category; //categroy of the food item like western
  int quantity; //whole number quantity the food item available
  double originalPrice; //the orginal price before discount
  double discountedPrice; //the discounted pricee the user is selling it at
  double estimateCO2SavedKg; //the estimated c02 that will be saved if someone buys it and it doesnt go to waste
  double latitude; //the pickup location coordinates latititude and longititude
  double longitude;
  String businessEmail; //the email of the currently signed in user that will use the same for the businesses email

  FoodItem({
    required this.id,
    required this.image,
    required this.foodName,
    required this.foodDescription,
    required this.collectionTimeRange,
    required this.date,
    required this.category,
    required this.quantity,
    required this.originalPrice,
    required this.discountedPrice,
    required this.estimateCO2SavedKg,
    required this.latitude,
    required this.longitude,
    required this.businessEmail,
  });
}
