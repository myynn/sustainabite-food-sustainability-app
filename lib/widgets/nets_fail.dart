import 'package:flutter/material.dart';

class NETSFail extends StatelessWidget {
  const NETSFail({super.key});

//this is for the payment screen to show when the payment fails
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset('images/redCross.png', width: MediaQuery.of(context).size.width * 0.5), //the image of the nets fail red cross when there is an error in the payment
        SizedBox(height: 10),
        Text('Transaction Failed!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), //text saying that the transaction failed
        SizedBox(height: 10),
    ]);
  }
}