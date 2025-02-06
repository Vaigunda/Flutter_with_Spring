import 'package:flutter/material.dart';

class AboutUs extends StatefulWidget {
  const AboutUs({super.key});

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ABOUT US Section
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'ABOUT US',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'At Mentor Boosters, we are dedicated to empowering small and medium-sized business \n owners by connecting them with expert mentors who provide personalized guidance for success. \n Our mission is to bridge the gap between ambition and achievement, \n fostering a community where entrepreneurs can thrive.',
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                        letterSpacing: 1),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40),
                  Text(
                    'Our Story',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
                     textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Mentor Boosters was founded by two dynamic professionals who recognized a critical gap in mentorship  \n resources for entrepreneurs and small business owners.',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40),
                  Text(
                    'Visionaries Behind Mentor Boosters.',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Mr. Nurudeen Osidipe, our CEO, brings over 14 years of experience in financial planning and strategic management. As a Certified Chartered Accountant, he has a proven track record of enhancing profitability and operational efficiency for various organizations. His leadership ensures that Mentor Boosters remains aligned with its mission to drive impactful mentormentee relationships.\n \n Mrs.Azeezat Omowunmi Ojekunle, our COO, is a financial expert with over 14 years of experience in tax advisory, compliance, and corporate strategy. She holds a degree in Animal Production and Health and has furthered  her expertise with an online certification in Business Analytics from Harvard Business School in 2020. Her focus on operational excellence ensures a seamless experience for both mentors and mentees. Together, they have combined their expertise and resources to create a trusted platform for entrepreneurs seeking mentorship in diverse areas such as finance, leadership, marketing, and business strategy. ',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.justify,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            // "Why choose us?" Section
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Why choose us?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
                ),
              ],
            ),
            const SizedBox(
              height: 40,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      textAlign: TextAlign.center,
                      'We believe in your success and that Data-driven Mentorship \n can help you achieve the best results for your business, \n regardless of your field or target market. ',
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                          letterSpacing: 1),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
                crossAxisSpacing: 20,
                mainAxisSpacing: 50,
                childAspectRatio: getChildAspectRatioFromWidth(width),
                children: const [
                  AboutusCard(
                    icon: Icons.public,
                    title: "Global experience",
                    description:
                        "We have worked with multinational companies, as well as\nsmaller businesses from all continents.",
                  ),
                  AboutusCard(
                    icon: Icons.diamond,
                    title: "Quality for value",
                    description:
                        "Our motto is to provide only the highest quality to\nour clients, no matter the circumstances.",
                  ),
                  AboutusCard(
                    icon: Icons.handshake,
                    title: "Favorable terms",
                    description:
                        "Each project we work on is tailored to the\nparticular client’s needs, not the other way\naround.",
                  ),
                  AboutusCard(
                    icon: Icons.verified,
                    title: "High standards",
                    description:
                        "We take data seriously, meaning that we only\ndeliver work that we can be proud of.",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static double getChildAspectRatioFromWidth(double width) {
    if (width > 1200) {
      return 2;
    } else if (width > 800) {
      return 1.3;
    } else if (width > 750) {
      return 1.1;
    } else if (width > 700) {
      return 1;
    } else if (width > 650) {
      return 0.9;
    } else if (width > 600) {
      return 0.8;
    } else {
      return 1.7;
    }
  }
}

class AboutusCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const AboutusCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ShaderMask(
          shaderCallback: (Rect bounds) {
            return const LinearGradient(
              colors: [Colors.pinkAccent, Colors.orangeAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: Icon(
            icon,
            size: 160,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontWeight: FontWeight.w400, fontSize: 15, letterSpacing: 1.5),
        ),
      ],
    );
  }
}
