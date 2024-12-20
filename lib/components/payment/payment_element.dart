import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'loading_button.dart';
import 'payment_element_web.dart';
import 'package:provider/provider.dart';
import 'package:mentor/provider/user_data_provider.dart';

class PaymentElementExample extends StatefulWidget {

  const PaymentElementExample({super.key, required this.amount,
  required this.bookingData});
  final int amount;
  final String bookingData;

  @override
  _ThemeCardExampleState createState() => _ThemeCardExampleState();
}

class _ThemeCardExampleState extends State<PaymentElementExample> {
  String? clientSecret;

  @override
  void initState() {
    getClientSecret();
    super.initState();
  }

  Future<void> getClientSecret() async {
    try {
      final client = await createPaymentIntent();
      setState(() {
        clientSecret = client;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Stripe Integration'),
      ),
      body: Column(
        children: [
          Container(
              child: clientSecret != null
                  ? PlatformPaymentElement(clientSecret)
                  : const Center(child: CircularProgressIndicator())),
          LoadingButton(onPressed: pay, text: 'Pay', bookingData: widget.bookingData),
        ],
      ),
    );
  }

  Future<String> createPaymentIntent() async {
    var provider = context.read<UserDataProvider>();
    String usertoken = provider.usertoken;

    try {
      var paymentBody = jsonEncode({
        "amount": widget.amount,
        "currency": 'cad',// Currency(cad - canada)
      });

      final response = await http.post(
        Uri.parse('http://localhost:8080/api/payment/createPaymentIntent'), // Replace with your actual API endpoint
        headers: {
          'Authorization': 'Bearer $usertoken',
          'Content-Type': 'application/json',
        },
        body: paymentBody,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.body);
        return map['clientSecret'];
      } else {
        throw Exception(
            "Failed to create payment intent: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Failed to create payment intent: $e");
    }
  }
}