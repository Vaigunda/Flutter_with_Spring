import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:mentor/navigation/router.dart';
import '../../constants/ui.dart';
import '../../provider/user_data_provider.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen(
      {super.key,
      required this.amount,
      required this.id,
      required this.name,
      required this.bookingData});
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
    final response = await http.get(
      Uri.parse('http://localhost:8080/api/user/profile/$userId'),
      headers: {
        "content-type": "application/json",
        'Authorization': 'Bearer $usertoken'
      },
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
        Uri.parse(
            'http://localhost:8080/api/payment/createPaymentIntent'), // Replace with your backend endpoint
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
      if (e.toString() == "Exception: Please fill in the complete card details.") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill in the complete card details.'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      } else if (e.toString() == "StripeError<String?>(message: Your card has insufficient funds. Try a different card., code: card_declined)") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your card has insufficient funds. Try a different card.'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment Failed : Please check the details.'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController cvvController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    var isWeb = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(title: const Text("Stripe Payment Gateway")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Material(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    buildCustomTextRow(),
                  ],
                ),
                isWeb
                    ? Row(
                        children: [
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(
                                  'assets/images/credit.png',
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.blue),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      children: [
                                        ListTile(
                                            leading: Radio(
                                                value: 1,
                                                groupValue: 1,
                                                onChanged: (val) {}),
                                            title: const Text(
                                                "Credit & Debit cards",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            subtitle: const Text(
                                                "Transaction fee may apply"),
                                            trailing: Image.asset(
                                                'assets/images/visa.png')),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              TextField(
                                                controller: nameController,
                                                decoration:
                                                    const InputDecoration(
                                                  labelText: "Cardholder Name",
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              CardField(
                                                onCardChanged: (card) {
                                                  setState(() {
                                                    _card = card;
                                                  });
                                                },
                                                decoration:
                                                    const InputDecoration(
                                                        labelText:
                                                            "Card Number",
                                                        border:
                                                            OutlineInputBorder(),
                                                        suffixIcon: Icon(
                                                            Icons.credit_card)),
                                              ),
                                              const SizedBox(height: 10),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: TextField(
                                                      controller: cvvController,
                                                      keyboardType:
                                                          TextInputType.number,
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter
                                                            .digitsOnly
                                                      ],
                                                      decoration:
                                                          const InputDecoration(
                                                        labelText: "End Date",
                                                        border:
                                                            OutlineInputBorder(),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: TextField(
                                                      controller: cvvController,
                                                      keyboardType:
                                                          TextInputType.number,
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter
                                                            .digitsOnly
                                                      ],
                                                      decoration:
                                                          const InputDecoration(
                                                        labelText: "CVV",
                                                        border:
                                                            OutlineInputBorder(),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              Row(
                                                children: [
                                                  Checkbox(
                                                      value: false,
                                                      onChanged: (val) {}),
                                                  const Expanded(
                                                    child: Text(
                                                        "I have read and accept the terms of use, rules of flight, and privacy policy"),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              Center(
                                                child: SizedBox(
                                                  width: 340,
                                                  child: ElevatedButton(
                                                    style:
                                                        ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          Colors.blue,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8)),
                                                    ),
                                                    onPressed: _processPayment,
                                                    child: const Text("Pay Now",
                                                        style: TextStyle(
                                                            color: Colors.white)),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                /* Column(
                        children: [
                          CardField(
                            onCardChanged: (card) {
                              setState(() {
                                _card = card;
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'Card Number',
                              fillColor:
                                  Colors.white, // Set background color to white
                              filled: true, // Fill the background with the color
                              hintStyle: TextStyle(
                                  color: Colors.black), // Set hint text color
                            ),
                            style: const TextStyle(
                                color:
                                    Colors.black), // Set text color for card number
                          ),
                          const SizedBox(height: 50),
                          ElevatedButton(
                            onPressed: _processPayment,
                            child: const Text("Pay"),
                          ),*/
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.blue),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  ListTile(
                                      leading: Radio(
                                          value: 1,
                                          groupValue: 1,
                                          onChanged: (val) {}),
                                      title: const Text("Credit & Debit cards",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      subtitle: const Text(
                                          "Transaction fee may apply"),
                                      trailing: Image.asset(
                                          'assets/images/visa.png')),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextField(
                                          controller: nameController,
                                          decoration: const InputDecoration(
                                            labelText: "Cardholder Name",
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        CardField(
                                          onCardChanged: (card) {
                                            setState(() {
                                              _card = card;
                                            });
                                          },
                                          decoration: const InputDecoration(
                                              labelText: "Card Number",
                                              border: OutlineInputBorder(),
                                              suffixIcon:
                                                  Icon(Icons.credit_card)),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                controller: cvvController,
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly
                                                ],
                                                decoration:
                                                    const InputDecoration(
                                                  labelText: "End Date",
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: TextField(
                                                controller: cvvController,
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly
                                                ],
                                                decoration:
                                                    const InputDecoration(
                                                  labelText: "CVV",
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Checkbox(
                                                value: false,
                                                onChanged: (val) {}),
                                            const Expanded(
                                              child: Text(
                                                  "I have read and accept the terms of use, rules of flight, and privacy policy"),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                            ),
                                            onPressed: _processPayment,
                                            child: const Text("Pay Now",
                                                style: TextStyle(
                                                    color: Colors.white)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> submitBooking() async {
    try {
      // Send the POST request to your backend API
      var response = await http.post(
        Uri.parse(
            'http://localhost:8080/api/bookings'), // Replace with your actual API endpoint
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
          Uri.parse(
              'http://localhost:8080/api/notify/createNotification'), // Replace with your actual API endpoint
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
