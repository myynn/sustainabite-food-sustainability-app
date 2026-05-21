import 'package:project_part2/models/food_item.dart';
import 'package:flutter/foundation.dart';

//this is for the cart screen to store the data in the cart temporarily
//this holds a single in progress item for the item the user is viewing or preparing to add to cart
class CartStore {
  FoodItem? _current; //this is the currently selected item 
  FoodItem? get current => _current; //with a read only access to the item

  void set(FoodItem item) => _current = item; //this is set as the current item and replaces any existing items 
  void clear() => _current = null; //this clears the current item and sets it to null


  //this is the sum before any extra fees
  double get subtotal => _current?.discountedPrice ?? 0.0; // otherwise it will be 0.0 if there is currently no item
  double get total => subtotal; //this is the subtotal 
}

//this stores a list of ordered items 
class OrdersStore extends ChangeNotifier {
  final List<FoodItem> _orders = []; 
  List<FoodItem> get orders => List.unmodifiable(_orders);

  void add(FoodItem item) { _orders.add(item); notifyListeners(); } //this adds an item to the orders 
  void remove(FoodItem item) { _orders.remove(item); notifyListeners(); } //this removes a specific item 
  void clearAll() { _orders.clear(); notifyListeners(); } //this removes all items

  bool get isEmpty => _orders.isEmpty;
}
