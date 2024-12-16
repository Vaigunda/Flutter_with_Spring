import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

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
      return 1.5;
    } else if (width > 500) {
      return 1.3;
    } else if (width > 600) {
      return 1.5;
    } else {
      return 1.5;
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