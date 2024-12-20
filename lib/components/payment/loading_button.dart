import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:mentor/provider/user_data_provider.dart';

class LoadingButton extends StatefulWidget {
  final Future Function()? onPressed;
  final String text;
  final String bookingData;

  const LoadingButton({super.key, required this.onPressed, required this.text, 
    required this.bookingData});

  @override
  _LoadingButtonState createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12)),
              onPressed:
                  (_isLoading || widget.onPressed == null) ? null : _loadFuture,
              child: _isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ))
                  : Text(widget.text),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadFuture() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onPressed!();
      _showSuccessDialog('Payment was successful!');
    } on StripeException catch (e) {
      // Handle Stripe-specific errors here
      _handleStripeError(e);
    } catch (e) {
      _showErrorDialog('An unexpected error occurred. Please try again later.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to handle different Stripe errors based on the error code
  void _handleStripeError(StripeException e) {
    String errorMessage = 'An error occurred. Please try again later.';
    if (e.error.type == 'card_error') {
      errorMessage = 'There was an issue with your card. Please check the details and try again.';
    } else {
      // Other error types (network issues, API errors, etc.)
      errorMessage = 'An error occurred while processing your payment. Please try again later.';
    }
    _showErrorDialog(errorMessage);
  }

  // Show error message in a dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Payment Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    
  }

  // Show success message in a dialog
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Payment Successful'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close the dialog
                await submitBooking();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> submitBooking() async {

    var provider = context.read<UserDataProvider>();
    String usertoken = provider.usertoken;

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
          // Successfully booked
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment and Schedule booking successfully!'),
              duration: Duration(seconds: 3),
              backgroundColor: Colors.green,
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