import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:project_part2/models/food_item.dart';
import 'package:project_part2/screens/profile_screen.dart';
import 'package:project_part2/services/cart_store.dart';
import 'package:project_part2/services/firebase_service.dart';
import 'package:project_part2/widgets/nets_qr.dart';

//this screen handles the payment for that food item and shows a nets qr widget that finalises the order on success
class PaymentScreen extends StatelessWidget {
  final FoodItem item; //the item being paid for
  const PaymentScreen({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orders = GetIt.I<OrdersStore>(); //this accesses the orderstore in my card store in the service folder that holds the loclly reserved items

//this finalises the flow after successful payment, decrement the quantity of the food item in firestore, remove the local order list and shows success whih redirects users to the profile screen
    Future<void> _finalize(BuildContext ctx) async {
      try {
        await reserveOne(item.id);   // decrement quantity of the food item in my firestore
        orders.remove(item);         // this removes the item from local orders list 
        if (ctx.mounted) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(content: Text('Payment successful.')),
          );
          Navigator.pushAndRemoveUntil(
            ctx,
            MaterialPageRoute(builder: (_) => ProfileScreen()), //and redirects users to teh profile screen and claers intermediate routes
            (route) => route.isFirst,
          );
        }
      } catch (e) {
        if (ctx.mounted) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text('Failed to complete: $e')), //shows the failed to complete error
          );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        title: const Text('Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              Text(item.foodName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),//this is the item name
              const SizedBox(height: 8),
              Text('Amount payable: \$${item.discountedPrice.toStringAsFixed(2)}'), //this is teh total amount payable
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: NETSQR( //this nets qr widget handles the requesting of the qr, listening to webook, then show susccess or fail ui
                    amount: item.discountedPrice,          // this passes the payable amount of that food item for the user to pay
                    register: (ctx) => _finalize(ctx),     // this is called on successful payment
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
