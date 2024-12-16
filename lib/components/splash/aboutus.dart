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
    return Scaffold(
      appBar: AppBar(),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Why choose us?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 56),
                ),
              ],
            ),
            SizedBox(
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  textAlign: TextAlign.center,
                  'We believe in your success and that Data-driven Mentorship can help you \n achieve the best results for your business, regardless of your field or target\n market. ',
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                      letterSpacing: 1.5),
                ),
              ],
            ),
            SizedBox(
              height: 120,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AboutusCard(
                  icon: Icons.public,
                  title: "Global experience",
                  description:
                      "We have worked with multinational companies, as well as\n smaller businesses from all continents.",
                ),
                AboutusCard(
                  icon: Icons.diamond,
                  title: "Quality for value",
                  description:
                      "Our motto is to provide only the highest quality to \n our clients, no matter the circumstances.",
                ),
              ],
            ),
            SizedBox(
              height: 120,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AboutusCard(
                  icon: Icons.handshake,
                  title: "Favorable terms",
                  description:
                      "Each project we work on is tailored to the \n particular client’s needs, not the other way \n around.",
                ),
                AboutusCard(
                  icon: HugeIcons.strokeRoundedAward05,
                  title: "High standards",
                  description:
                      "We take data seriously, meaning that we only \n deliver work that we can be proud of.",
                ),
              ],
            ),
            SizedBox(
              height: 120,
            ),
          ],
        ),
      ),
    );
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
