import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

//this is the nets sandbox api for qr code payments which is one of my additional features
class NETSService {
  // API credentials for accessing the NETS sandbox environment
  final String API_KEY = 'NETS_API_KEY';
  final String PROJECT_ID = 'NETS_PROJECT_ID';

  // Stream subscription used to listen to Server-Sent Events (SSE)
  StreamSubscription<String>? SSEsubscription;

  // Cancels the SSE stream if active
  void cancelWebhook() {
    SSEsubscription?.cancel();
    debugPrint('Webhook stream cancelled');
  }

  // Sends a request to generate a NETS QR payment transaction
  Future<Response> requestAPI({required double amount}) async { //the payment amount in dollars 
  Uri url = Uri.parse('https://sandbox.nets.openapipaas.com/api/v1/common/payments/nets-qr/request'); //this is teh nets api endpoint for qr code requests

//the post request with required json body and headers
  final response = await post(
    url,
    body: jsonEncode({
      'txn_id': 'sandbox_nets|m|YOUR_TRANSACTION_ID',
      'amt_in_dollars': double.parse(amount.toStringAsFixed(2)), //to format the amount of dollars to 2 decimals
      'notify_mobile': 0,
    }),
    headers: {
      'Content-Type': 'application/json',
      'api-key': API_KEY,
      'project-id': PROJECT_ID,
    },
  );
  return response;
}

  // Listens for real-time payment status updates from NETS using SSE
  Future<Response> webhookAPI(String txnRetrievalRef) async {
    final maxRetries = 2;
    var attempt = 0;
    bool success = false;

    while (attempt < maxRetries && !success) {
      debugPrint("Webhook Attempt: $attempt");
      try {
        final client = Client();
        final url = Uri.parse( //this constructs the webhook url with query parameters
          'https://sandbox.nets.openapipaas.com/api/v1/common/payments/nets/webhook?txn_retrieval_ref=$txnRetrievalRef',
        );


        final request = Request('GET', url)//this creates a http get request with sse headers
          ..headers.addAll({
            'Accept': 'text/event-stream',
            'Connection': 'keep-alive',
            'api-key': API_KEY,
            'project-id': PROJECT_ID,
          });

        final streamedResponse = await client.send(request); //this sends the request

        // If the stream starts successfully
        if (streamedResponse.statusCode == 200) {
          final completer = Completer<Response>();
          final buffer = StringBuffer();

          // Listen to the SSE stream
          SSEsubscription = streamedResponse.stream
              .transform(utf8.decoder)
              .listen(
                (chunk) {
                  buffer.write(chunk);
                  // Complete the future if 'data:' is received
                  if (buffer.toString().contains('data:')) {
                    completer.complete(Response(buffer.toString(), 200));
                  }
                },
                onError: (e) {
                  debugPrint("Stream error: $e");
                  completer.completeError(e);
                },
                onDone: () {
                  // Handle completion if stream ends
                  if (!completer.isCompleted) {
                    completer.complete(Response(buffer.toString(), 200));
                  }
                  client.close();
                },
              );

          final response = await completer.future;
          success = true;
          return response;
        }
      } catch (e) {
        debugPrint("Webhook error: $e");
      } finally {
        attempt++;
        await Future.delayed(Duration(seconds: 2));
      }
    }

    // If all retry attempts fail
    return Response('{"error": "Max retry attempts reached"}', 500, headers: {'Content-Type': 'application/json'});
  }

  // Queries the latest payment status using the transaction retrieval reference
  Future<Response> queryAPI(String txnRetrievalRef) async {
    try {
      Uri url = Uri.parse('https://sandbox.nets.openapipaas.com/api/v1/common/payments/nets-qr/query');

      final response = await post(
        url,
        body: jsonEncode({
          'txn_retrieval_ref': txnRetrievalRef,
          'frontend_timeout_status': 1, // Indicates frontend timeout scenario
        }),
        headers: {
          'Content-Type': 'application/json',
          'api-key': API_KEY,
          'project-id': PROJECT_ID,
        },
      );

      debugPrint(response.toString());
      return response;
    } catch (e) {
      debugPrint("Exception: $e");
      return Response('{"error": "Error occurred: $e"}', 500, headers: {'Content-Type': 'application/json'});
    }
  }
}
