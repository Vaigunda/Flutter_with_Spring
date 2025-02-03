import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TermsAndConditionsPage(),
    );
  }
}

class TermsAndConditionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var isWeb = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with image
            Container(
              height: 480,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/terms_header.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: Text(
                  'Terms and Conditions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isWeb ? 64 : 40,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Lobster',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Terms content section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child:Column(
                      children: [
                        _buildColumn(
                          title: 'Introduction',
                          content:
                              'Welcome to Mentor Booster! These Terms and Conditions govern your use of our platform, which connects learners with expert mentors for online courses and guidance. By accessing or using our services, you agree to comply with these terms. If you do not agree with any part of these terms, please refrain from using our platform.',
                        ),
                       const SizedBox(height: 40),
                         _buildColumn(
                          title: 'User Eligibility',
                          content:
                              'To use Mentor Booster, you must be at least 18 years old or have the consent of a parent or legal guardian. By registering, you confirm that the information provided is accurate and that you are legally capable of entering into this agreement.',
                        ),
                       const SizedBox(height: 40),
                        _buildColumn(
                          title: 'Account Registration',
                          content:
                              'Users must provide accurate and complete details during registration.You are responsible for maintaining the confidentiality of your account credentials.Any unauthorized use of your account should be reported immediately. Mentor Booster is not liable for losses resulting from unauthorized access.',
                        ),
                       const SizedBox(height: 40),
                        _buildColumn(
                          title: 'Booking and Payments',
                          content:
                              'Users can book mentors for online classes based on availability.Payment for sessions must be completed through our platform before the scheduled session.Refunds and cancellations are subject to our Cancellation Policy.',
                        ),
                       const SizedBox(height: 40),
                         _buildColumn(
                          title: 'Mentor Responsibilities',
                          content:
                              'Mentors on Mentor Booster are expected to deliver high-quality, professional instruction while upholding ethical standards. They should provide accurate information, engage with learners responsibly, and create a positive learning environment. Any form of misleading information, unprofessional behavior, or violation of ethical guidelines may lead to immediate removal from the platform. Mentor Booster strives to maintain a trusted learning space, and mentors are required to adhere to the highest standards of professionalism.',
                        ),
                       const SizedBox(height: 40),
                        _buildColumn(
                          title: 'User Conduct',
                          content:
                              'Users are expected to interact respectfully with mentors and follow all platform guidelines while using Mentor Booster. A positive, respectful atmosphere is essential for effective learning, and any form of harassment, abuse, or inappropriate behavior will not be tolerated. Such actions will result in immediate suspension or termination of the user’s account. Mentor Booster is committed to providing a safe and supportive environment for both learners and mentors.',
                        ),
                       const SizedBox(height: 40),
                         _buildColumn(
                          title: 'Intellectual Property',
                          content:
                              'All course materials, videos, and content provided by mentors on Mentor Booster remain the intellectual property of the respective mentors. Users are prohibited from recording, distributing, or reproducing any content without explicit permission from the mentor. This ensures that the rights of content creators are respected and that the materials are used solely for the intended purpose of learning. ',
                        ),
                       const SizedBox(height: 40),
                         _buildColumn(
                          title: ' Amendments to Terms',
                          content:
                              'We reserve the right to modify these Terms and Conditions at any time. Changes will be updated on this page, and continued use of the platform implies acceptance of the revised terms.',
                        ),
                        
                      ],
                    ),
            ),
            const SizedBox(height: 40),
            
          ],
        ),
      ),
    );
  }

  Widget _buildColumn({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            wordSpacing: 2,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }


}
