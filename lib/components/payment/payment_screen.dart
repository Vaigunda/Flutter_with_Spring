import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:mentor/navigation/router.dart';
import '../../provider/user_data_provider.dart';

class PaymentScreen extends StatefulWidget {

  const PaymentScreen({super.key, required this.amount, required this.id,
  required this.name, required this.bookingData});
  final int amount;
  final int id;
  final String name;
  final String bookingData;

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  CardFieldInputDetails? _card;
  var provider;
  late String usertoken;
  late String userid;
  late String username;

  late Map<String, dynamic> userData;

  @override
  void initState() {

    provider = context.read<UserDataProvider>();
    usertoken = provider.usertoken;
    userid = provider.userid;
    username = provider.name;

    getUserDetails();
    super.initState();
  }

  Future<void> getUserDetails() async {
    int userId = int.parse(userid);
    final response =
        await http.get(Uri.parse('http://localhost:8080/api/user/profile/$userId'),
            headers: {"content-type": "application/json",
            'Authorization': 'Bearer $usertoken'},
            );

    var parsed = response.body;
    userData = jsonDecode(parsed);
  }

  Future<void> _processPayment() async {
    try {
      if (_card == null || !_card!.complete) {
        throw Exception("Please fill in the complete card details.");
      }

      // Create a PaymentIntent on your backend and get the clientSecret
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/payment/createPaymentIntent'), // Replace with your backend endpoint
        headers: {
          'Authorization': 'Bearer $usertoken',
          'Content-Type': 'application/json', // Ensure the API expects JSON
        },
        body: json.encode({
          "amount": widget.amount,
          "currency": "cad",
        }),
      );

      final clientSecret = jsonDecode(response.body)["clientSecret"];
      // Confirm the payment
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(
              name: userData['name'],
              email: userData['emailId'],
              //phone: "+123456789",
            ),
          ),
        ),
      );
      await submitBooking();
      context.go(AppRoutes.home);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment Failed: $e'),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stripe Payment Gateway")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CardField(
              onCardChanged: (card) {
                setState(() {
                  _card = card;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Card Number',
                fillColor: Colors.white, // Set background color to white
                filled: true, // Fill the background with the color
                hintStyle: TextStyle(color: Colors.black), // Set hint text color
              ),
              style: TextStyle(color: Colors.black), // Set text color for card number
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: _processPayment,
              child: const Text("Pay"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> submitBooking() async {
    try {
        // Send the POST request to your backend API
        var response = await http.post(
          Uri.parse('http://localhost:8080/api/bookings'), // Replace with your actual API endpoint
          headers: {
            'Authorization': 'Bearer $usertoken',
            'Content-Type': 'application/json', // Ensure the API expects JSON
          },
          body: jsonDecode(widget.bookingData),
        );
        if (response.statusCode == 200) {
          String mentorName = widget.name;        
          var notifyBody = jsonEncode({
            "mentorId": widget.id,
            "recipientId": int.parse(userid),
            "title": "New Booking",
            "message": "$username booked $mentorName",
          });

          var notifyRes = await http.post(
            Uri.parse('http://localhost:8080/api/notify/createNotification'), // Replace with your actual API endpoint
            headers: {
              'Authorization': 'Bearer $usertoken',
              'Content-Type': 'application/json', // Ensure the API expects JSON
            },
            body: notifyBody,
          );
 
          if (notifyRes.statusCode == 200) {
            // Successfully booked
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment and Schedule booking successfully!'),
                duration: Duration(seconds: 3),
                backgroundColor: Colors.green,
              ),
            );
            context.go(AppRoutes.home);
          }
        } else if (response.statusCode == 400) {
          String output = response.body;
          // Something went wrong, handle the error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(output),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          // Something went wrong, handle the error
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to submit booking. Please try again.'),
              duration: Duration(seconds: 3),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred. Please try again.'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
  }
}