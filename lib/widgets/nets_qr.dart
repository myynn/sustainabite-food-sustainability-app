import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:project_part2/services/nets_service.dart';
import 'package:project_part2/widgets/nets_fail.dart';
import 'package:project_part2/widgets/nets_success.dart';

//this is for displaying a qr code for payment screen, it tracks the payment via webhook and updates the ui according to whether success or fail
class NETSQR extends StatefulWidget {
  final double amount;  //the amount the users have to pay based on the price of that food item           
  final void Function(BuildContext) register; //the callback to run after successful payment registering an order

  const NETSQR({
    Key? key,
    required this.amount,          
    required this.register,
  }) : super(key: key);

  @override
  State<NETSQR> createState() => _NETSQRState();
}

class _NETSQRState extends State<NETSQR> {
  NETSService netsService = GetIt.instance<NETSService>(); //service instance for nets api calls injected via getit

  Uint8List? qrCode; //base 64 qr code image bytes
  String? txnRetrievalRef; //transaction reference id from nets
  String? responseCode; //response code from nets api
  String? message; //message by webhook
 
  int? timeLeft = 300; //the countdown timer for qr code validity is 5 min
  String formattedTime = '';

  late Timer _timer; //a periodic timer instance

  @override
  void initState() {
    super.initState();
    getQrCode(); // Initialize QR code and start webhook

    // Start countdown timer for QR code validity
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft! > 0) {
        setState(() {
          timeLeft = timeLeft! - 1;
          formattedTime =
              '${(timeLeft! ~/ 60).toString().padLeft(2, '0')}:${(timeLeft! % 60).toString().padLeft(2, '0')}';
        });
      } else {
        timer.cancel(); // Stop the timer when it reaches zero
        netsService.cancelWebhook(); // Cancel webhook if time runs out
        queryAPI(txnRetrievalRef!); // Check final transaction status
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel(); // Cancel the timer when widget is disposed
    netsService.cancelWebhook(); // Cancel webhook when widget is disposed
  }

  // Requests the QR code from the NETS service and decodes it for display.
  // Initiates the webhook listener for the transaction.
  void getQrCode() async {
    Response requestResponse = await netsService.requestAPI(amount: widget.amount,);
    var data = requestResponse.body;
    var decodedData = jsonDecode(data);
    setState(() {
      qrCode = base64Decode(decodedData['result']['data']['qr_code']); //stores the qr code image
    });
    txnRetrievalRef = decodedData['result']['data']['txn_retrieval_ref']; //saves the transaction reference and start webhook listener

    getWebHookAPI(txnRetrievalRef);
  }

  // Listens for updates on the QR transaction using webhook,
  // Extracts message and response code from the stream.
  void getWebHookAPI(txnRetrievalRef) async {
    print('txnRetrievalRef: $txnRetrievalRef');

    Response requestResponse = await netsService.webhookAPI(txnRetrievalRef);
    final responseBody = requestResponse.body;

    if (responseBody.contains('data:')) {
      String jsonData = responseBody.split('data:')[1]; //extract and parses the json payload from sse message
      var decodedData = jsonDecode(jsonData);

      setState(() {
        message = decodedData['message'];
        responseCode = decodedData['response_code'];
      });
    }
  }

  // Makes a final query to the NETS API to get the transaction status in case the QR code expires or the webhook doesn't return in time.
  void queryAPI(String txnRetrievalRef) async {
    Response requestResponse = await netsService.queryAPI(txnRetrievalRef);
    var data = requestResponse.body;
    var decodedData = jsonDecode(data);
    setState(() {
      responseCode = decodedData['result']['data']['response_code'];
    });
  }

  // Builds the QR code widget along with timer and info image.
  Widget displayQRCode() {
    return Column(
      children: [
        Image.memory(qrCode!),
        responseCode == '00'
            ? Center()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  formattedTime,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
        Image.asset(
          'images/netsQrInfo.png',
          width: MediaQuery.of(context).size.width * 0.8,
        ),
        SizedBox(height: 10),
      ],
    );
  }

  // Builds the UI based on the QR code and transaction state.
  // Displays QR code, success/fail status, and registration button.
  @override
  Widget build(BuildContext context) {
    final bool isSuccess = message == 'QR code scanned' && responseCode == '00';
    
    return Column(
      children: [
        qrCode != null &&
                timeLeft! > 0 &&
                responseCode == null &&
                message == null
            ? displayQRCode()
            : isSuccess
                ? NETSSuccess()
                : responseCode != null
                    ? NETSFail()
                    : message == "Timeout"
                        ? displayQRCode()
                        : SizedBox.shrink(),
        AnimatedSwitcher( //this only shows the thank you button after successful payment
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: isSuccess
              ? ElevatedButton(
                  key: const ValueKey('thankyou_btn'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFBF70),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                  ),
                  onPressed: () => widget.register(context),
                  child: const Text('Thank you for saving a meal!'),
                )
              : const SizedBox.shrink(), //this makes sure that there is nothing before the success
        ),
      ],
    );
  }
}
