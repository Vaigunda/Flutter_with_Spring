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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                      'Terms and Conditions for MentorBoosters.com Application',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 20),
                  const Text('Last Updated: 03-02-25',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 80),
                  _buildColumn(
                    title: '1. Introduction',
                    content:
                        'Welcome to MentorBoosters.com, an online platform that connects mentors with small and medium-sized enterprises (SMEs) for mentorship and training. By accessing or using our application, you agree to comply with and be bound by these Terms and Conditions.',
                  ),
                  const SizedBox(height: 40),
                  _buildColumn(
                    title: '2. Definitions',
                    content:
                        ' • "Platform" refers to MentorBoosters.com and its associated mobile application. \n • "User" refers to any individual or entity that registers or uses the platform. \n • "Mentor" refers to individuals providing mentorship services.\n • "Mentee" refers to SMEs or individuals receiving mentorship services.\n • "Content" includes text, data, graphics, audio, video, and other materials shared on the platform.',
                  ),
                  const SizedBox(height: 40),
                  _buildColumn(
                    title: '3. User Eligibility',
                    content:
                        ' • Users must be at least 18 years old to create an account.\n • By registering, users confirm that they have the legal ability to enter into agreements.\n • MentorBoosters.com reserves the right to suspend or terminate accounts if false information is provided.',
                  ),
                  const SizedBox(height: 40),
                  _buildColumn(
                    title: '4. Registration and Account Management',
                    content:
                        ' • Users must provide accurate and complete information during registration.\n • Users are responsible for maintaining the confidentiality of their login credentials.\n • MentorBoosters.com is not liable for unauthorized access resulting from user negligence',
                  ),
                  const SizedBox(height: 40),
                  _buildColumn(
                    title: '5. Mentor and Mentee Responsibilities',
                    content:
                        ' • Mentors must provide accurate and professional guidance within their expertise.\n • Mentees agree to actively engage in mentorship programs and respect scheduled sessions.\n • Users must not engage in fraudulent, misleading, or unethical behavior.',
                  ),
                  const SizedBox(height: 40),
                  _buildColumn(
                    title: '6. Fees and Payments',
                    content:
                        ' • Some services may require payment, which will be communicated to users.\n • Payment transactions will be processed securely through third-party payment providers.\n • MentorBoosters.com is not responsible for payment disputes between mentors and mentees.',
                  ),
                  const SizedBox(height: 40),
                  _buildColumn(
                    title: '7. Content Ownership and Usage',
                    content:
                        ' • Users retain ownership of the content they upload but grant MentorBoosters.com a nonexclusive, royalty-free license to use, \n modify, and display such content for platformrelated purposes.\n • Users must not post copyrighted or infringing content without appropriate rights ',
                  ),
                  const SizedBox(height: 40),
                  _buildColumn(
                    title: ' 8. Privacy and Data Protection',
                    content:
                        ' • MentorBoosters.com adheres to applicable data protection laws.\n • User data will not be sold or shared with third parties without consent, except asrequired by law.\n • Users agree to the collection and processing of their data as described in the Privacy Policy.',
                  ),
                  const SizedBox(height: 40),
                  _buildColumn(
                    title: '9. Code of Conduct',
                    content:
                        ' • Users must interact respectfully and professionally.\n • Hate speech, harassment, discrimination, and any illegal activities are strictly prohibited.\n • MentorBoosters.com reserves the right to suspend or remove users violating these terms.',
                  ),
                  const SizedBox(height: 40),
                  _buildColumn(
                    title: '10. Limitation of Liability',
                    content:
                        ' • MentorBoosters.com is a facilitator and does not guarantee specific outcomes from mentorship.\n • The platform is not liable for any direct, indirect, or consequential damages arising from mentorship interactions.\n • Users agree to hold MentorBoosters.com harmless from claims resulting from their use of the platform.',
                  ),
                  const SizedBox(height: 40),
                  _buildColumn(
                    title: '11. Termination and Suspension',
                    content:
                        ' • MentorBoosters.com reserves the right to suspend or terminate accounts for violations of these terms.\n • Users may terminate their accounts at any time, but fees paid are non-refundable.',
                  ),
                  const SizedBox(height: 40),
                  _buildColumn(
                    title: '12. Amendments to Terms',
                    content:
                        ' • MentorBoosters.com may update these terms from time to time.\n • Users will be notified of significant changes and continued use of the platform constitutes acceptance.',
                  ),
                  const SizedBox(height: 40),
                  _buildColumn(
                    title: '13. Governing Law and Dispute Resolution',
                    content:
                        ' • These terms shall be governed by the laws of [Insert Jurisdiction].\n • Any disputes shall first be attempted to be resolved through negotiation; if unsuccessful,they will be subject to arbitration or court \n  proceedings in the applicable jurisdiction.',
                  ),
                  const SizedBox(height: 40),
                  _buildColumn(
                    title: '14. Contact Information',
                    content:
                        'For inquiries regarding these Terms and Conditions, please contact us at [Insert Contact Email].\nBy using MentorBoosters.com, you acknowledge that you have read, understood, and agree to these Terms and Conditions.',
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
      mainAxisAlignment: MainAxisAlignment.start,
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
              height: 2),
        ),
      ],
    );
  }
}
