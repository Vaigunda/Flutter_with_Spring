import 'package:flutter/material.dart';

import '../../constants/ui.dart';

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
                  'Why Choose Us?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 46),
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
                    Flexible(
                      child: Text(
                        'We believe in your success and that Data-driven Mentorship \n can help you achieve the best results for your business, \n regardless of your field or target market.',
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 4,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: getCrossAxisCount(context),
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
                  SizedBox(
                    height: 10,
                  )
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
      return 0.8;
    } else if (width > 800) {
      return 1.2;
    } else if (width > 750) {
      return 1.1;
    } else if (width > 700) {
      return 1;
    } else if (width > 650) {
      return 0.9;
    } else if (width > 600) {
      return 0.8;
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
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Card(
        elevation: 10,
        shadowColor: Colors.black,
        color: const Color.fromARGB(255, 251, 236, 212),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.orange,
              radius: 80,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 78,
                child: ShaderMask(
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
                    size: 100,
                    color: Colors.white, // Adjust icon color if needed
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 15,
                letterSpacing: 1.5,
                color: Colors.black
              ),
            ),
          ],
        ),
      ),
    );
  }
}
