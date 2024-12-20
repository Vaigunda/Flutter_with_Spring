import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_stripe_web/flutter_stripe_web.dart';
import 'package:web/web.dart' as web;

String getUrlPort() => web.window.location.port;

String getReturnUrl() => web.window.location.href;

Future<void> pay() async {
  await WebStripe.instance.confirmPaymentElement(
    ConfirmPaymentElementOptions(
      confirmParams: ConfirmPaymentParams(return_url: getReturnUrl()),
    ),
  );
}

class PlatformPaymentElement extends StatelessWidget {
  const PlatformPaymentElement(this.clientSecret);

  final String? clientSecret;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: PaymentElement(
        autofocus: true,
        enablePostalCode: true,
        onCardChanged: (_) {},
        clientSecret: clientSecret ?? '',
      ),
    );
  }
}