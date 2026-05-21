import 'package:flutter/material.dart';

//this is for the payment screen to show when the payment succeeds
class NETSSuccess extends StatelessWidget {
  const NETSSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset('images/greenTick.png', width: MediaQuery.of(context).size.width * 0.5), //the image of the nets success green tick when success in the payment
        SizedBox(height: 10),
        Text('Transaction Successful!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), //text saying that the transaction is successful
        SizedBox(height: 10),
    ]);
  }
}