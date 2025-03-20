// ignore_for_file: library_private_types_in_public_api

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/ui.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: GaurangaLandingPage(),
    );
  }
}

class GaurangaLandingPage extends StatefulWidget {
  const GaurangaLandingPage({super.key});

  @override
  _GaurangaLandingPageState createState() => _GaurangaLandingPageState();
}

class _GaurangaLandingPageState extends State<GaurangaLandingPage> {
  final ScrollController _scrollController = ScrollController();

  bool isUserLoggedIn = false;
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _pricingKey = GlobalKey();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _dedicationKey = GlobalKey();
  int currentIndex = 0;

  // Scroll to specific section
  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext!;
    Scrollable.ensureVisible(
      context,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    double childAspectRatio = screenWidth > 600 ? 0.9 : 1;
    return Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(controller: _scrollController, slivers: [
          SliverAppBar(
            pinned: true,
            //expandedHeight: 60.0,
            forceElevated: false,
            collapsedHeight: 80.0,
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                if (screenWidth > 800) {
                  return FlexibleSpaceBar(
                    //collapseMode: CollapseMode.pin,
                    background: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 50),
                      color: Colors.transparent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 20,
                                backgroundImage:
                                    AssetImage("assets/images/sign_in.jpg"),
                              ),
                              SizedBox(width: 10),
                              Text('MentorBoosters',
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                            ],
                          ),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () => _scrollToSection(_featuresKey),
                                child: Text('Features',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                              ),
                              const SizedBox(width: 20),
                              TextButton(
                                onPressed: () => _scrollToSection(_pricingKey),
                                child: Text('Purpose',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                              ),
                              const SizedBox(width: 20),
                              TextButton(
                                onPressed: () => _scrollToSection(_aboutKey),
                                child: Text('About Us',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                              ),
                              const SizedBox(width: 20),
                              TextButton(
                                onPressed: () =>
                                    _scrollToSection(_dedicationKey),
                                child: Text('Dedication',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                              ),
                              const SizedBox(width: 20),
                              GestureDetector(
                                onTap: () {
                                  // if (isUserLoggedIn) {
                                  //   Get.to(const Home());
                                  // } else {
                                  //   //  Get.to(const LoginScreen());
                                  // }
                                },
                                child: Container(
                                  height: 30,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 239, 186, 107),
                                    //color: Colors.black,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Center(
                                      child: Text(
                                    "Login",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  )),
                                ),
                              ),
                              const SizedBox(width: 20),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  // Mobile View (Width <= 800)
                  return FlexibleSpaceBar(
                    background: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 20),
                      color: Colors.transparent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 20,
                                backgroundImage:
                                    AssetImage("assets/images/sign_in.jpg"),
                              ),
                              SizedBox(width: 10),
                              Text('Gauranga',
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                            ],
                          ),
                          // Menu Icon for Mobile
                          Builder(
                            builder: (context) => IconButton(
                              icon: Icon(Icons.menu,
                                  color: Get.isDarkMode
                                      ? Colors.white
                                      : Colors.black),
                              onPressed: () {
                                final RenderBox button =
                                    context.findRenderObject() as RenderBox;
                                _showPopupMenu(context, button);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ),

          // Body (Scrollable)
          SliverList(
              delegate: SliverChildListDelegate(
            [
              //controller: _scrollController,
              // child: Column(
              //   crossAxisAlignment: CrossAxisAlignment.center,
              //   children: [
              Container(
                height: 800,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                        'https://storage.googleapis.com/msgsndr/1xymNZ4jUrO97uCm1dn5/media/66f507878fdba16e6ade42ca.jpeg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Center(
                  child: Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //const SizedBox(height: 10),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth > 800) {
                              return const Column(
                                children: [
                                  Center(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(70, 300, 0, 0),
                                      child: Text(
                                        'THE GOLDEN AVATAR',
                                        style: TextStyle(
                                          fontSize: 80,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return const Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(height: 40),
                                  Center(
                                    child: Text(
                                      'THE GOLDEN AVATAR',
                                      style: TextStyle(
                                        fontSize: 40,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Section 2 - Features
              Column(
                children: [
                  const Text(
                    "Transform Your Career, Fast-Track Your Success",
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    "Whether you're just starting or looking to make a big career leap, our platform offers unmatched mentorship to guide you on your path.",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Image.asset("assets/images/laptop_screen.jpg")
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: Theme.of(context).brightness == Brightness.light
                      ? const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 249, 220, 202),
                            Color.fromARGB(255, 246, 210, 236),
                            Color.fromARGB(255, 233, 212, 247),
                            Color.fromARGB(255, 203, 215, 250),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    bool isWideScreen = constraints.maxWidth > 600;
                    int cardsPerRow = isWideScreen ? 4 : 1;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 10.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 60),
                          const Text(
                            " A Global Community of Like-Minded Professionals",
                            style: TextStyle(
                                fontSize: 36, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                            "Our impact speaks volumes, showcasing the success of our members worldwide.",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: cardsPerRow,
                              crossAxisSpacing: 16.0,
                              mainAxisSpacing: 16.0,
                              childAspectRatio: isWideScreen ? 2 : 1.1,
                            ),
                            itemCount: globalData.length,
                            itemBuilder: (context, index) {
                              final cardData = globalData[index];

                              return MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: Padding(
                                  padding: MediaQuery.of(context).size.width <
                                          600
                                      ? const EdgeInsets.fromLTRB(60, 0, 60, 0)
                                      : const EdgeInsets.all(10.0),
                                  child: HoverableContainer(
                                    context: context,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            cardData['name']!,
                                            style: const TextStyle(
                                                fontSize: 44,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 20),
                                          Text(cardData['location']!,
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 60),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: Theme.of(context).brightness == Brightness.light
                      ? const LinearGradient(
                          colors: [
                            Colors.white,
                            Color.fromARGB(255, 246, 245, 222),
                            Colors.white,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                ),
                child: Padding(
                  padding: MediaQuery.of(context).size.width < 600
                      ? const EdgeInsets.fromLTRB(20, 20, 20, 20)
                      : const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            MediaQuery.of(context).size.width > 600 ? 3 : 1,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: childAspectRatio,
                      ),
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        switch (index) {
                          case 0:
                            return FeatureCard(
                              imageUrl:
                                  "https://storage.googleapis.com/msgsndr/1xymNZ4jUrO97uCm1dn5/media/66f6987469753621555c6aca.jpeg",
                              title: 'ABOUT US',
                              description:
                                  'At Gauranga, our mission is to empower individuals and businesses with innovative software solutions that simplify complexity, enhance productivity',
                            );
                          case 1:
                            return FeatureCard(
                              imageUrl:
                                  "https://storage.googleapis.com/msgsndr/1xymNZ4jUrO97uCm1dn5/media/66f698ebf6cf753b3d3e96d9.jpeg",
                              title: 'MISSION',
                              description:
                                  'At Gauranga, our mission is to empower individuals and businesses with innovative software solutions that simplify complexity, enhance productivity',
                            );
                          case 2:
                            return FeatureCard(
                              imageUrl:
                                  "https://storage.googleapis.com/msgsndr/1xymNZ4jUrO97uCm1dn5/media/66f69872697536edfd5c6ac8.jpeg",
                              title: 'VISION',
                              description:
                                  'At Gauranga, our mission is to empower individuals and businesses with innovative software solutions that simplify complexity, enhance productivity',
                            );
                          default:
                            return Container(); // Return an empty container if index is out of range
                        }
                      },
                    )
                  ]),
                ),
              ),
              Container(
                height: 100,
                width: double.infinity,
                // color: Theme.of(context).containerColor,
                child: Center(
                  child: GradientText(
                    'DEDICATION',
                    key: _dedicationKey,
                    style: const TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    colors: const [
                      Colors.blue,
                      Colors.pink,
                      Colors.teal,
                    ],
                  ),
                ),
              ),
              SingleChildScrollView(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    bool isMobile = constraints.maxWidth < 800;

                    return Container(
                      height:
                          isMobile ? null : 300, // Adjust height for desktop
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient:
                            Theme.of(context).brightness == Brightness.light
                                ? const LinearGradient(
                                    colors: [
                                      Colors.white,
                                      Color.fromARGB(255, 246, 245, 222),
                                      Colors.white,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: CarouselSlider.builder(
                          itemCount: teamData.length,
                          itemBuilder: (context, index, realIndex) {
                            return _buildTeamMember(
                              teamData[index]['imageUrl'] ?? '',
                              [
                                teamData[index]['name'] ?? 'Unknown Name',
                                teamData[index]['location'] ??
                                    'Unknown Location',
                              ],
                            );
                          },
                          options: CarouselOptions(
                            height: isMobile ? 400 : 450,
                            autoPlay: true,
                            enlargeCenterPage: true,
                            viewportFraction: isMobile ? 1.5 : 0.3,
                            onPageChanged: (index, reason) {
                              setState(() {
                                currentIndex = index; // Update current index
                              });
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: teamData.map((teamMember) {
                  int index = teamData.indexOf(teamMember);
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: currentIndex == index
                        ? 16.0
                        : 8.0, // Indicator size animation
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 2.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          currentIndex == index ? Colors.orange : Colors.grey,
                    ),
                  );
                }).toList(),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                color: Colors.black87,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton(
                            onPressed: () {
                              //Get.to(const PrivacyPolicyScreen());
                            },
                            child: const Text('Privacy Policy',
                                style: TextStyle(color: Colors.white))),
                        TextButton(
                            onPressed: () {
                              //  Get.to(const TermsAndConditionsPage());
                            },
                            child: const Text('Terms of Service',
                                style: TextStyle(color: Colors.white))),
                        TextButton(
                            onPressed: () {
                              //   Get.to(const ContactUsScreen());
                            },
                            child: const Text('Contact Us',
                                style: TextStyle(color: Colors.white))),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Ionicons.logo_facebook,
                            size: 20,
                          ),
                          color: Colors.white, // Set the color of the icon
                          onPressed: () => launchUrlStart(
                              url: "https://www.facebook.com/gaurangaaaa/"),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(
                            Ionicons.logo_instagram,
                            size: 20,
                          ),
                          color: Colors.white,
                          onPressed: () => launchUrlStart(
                              url: "https://www.instagram.com/gaurangaaaaaa/"),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(
                            Ionicons.logo_youtube,
                            size: 20,
                          ),
                          color: Colors.white,
                          onPressed: () => launchUrlStart(
                              url: "https://www.youtube.com/@gaurangaaa"),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(
                            Ionicons.logo_google_playstore,
                            size: 20,
                          ),
                          color: Colors.white,
                          onPressed: () => launchUrlStart(
                              url:
                                  "https://play.google.com/store/apps/details?id=com.adhirat.app&pcampaignid=web_share"),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(
                            Ionicons.logo_apple_appstore,
                            size: 20,
                          ),
                          color: Colors.white,
                          onPressed: () => launchUrlStart(
                              url:
                                  "https://apps.apple.com/au/app/gauranga/id6466571735"),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: Image.network(
                            'https://storage.googleapis.com/msgsndr/1xymNZ4jUrO97uCm1dn5/media/66f6962f4988915f6aecff5e.png',
                            height: 20,
                            width: 20,
                          ),
                          color: Colors.white,
                          onPressed: () => launchUrlStart(
                              url: "https://gaura.codemagic.app/"),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: Image.network(
                            'https://storage.googleapis.com/msgsndr/1xymNZ4jUrO97uCm1dn5/media/66eaa609c19a100eaba0c153.png',
                            height: 25,
                            width: 25,
                          ),
                          onPressed: () =>
                              launchUrlStart(url: "https://adhirat.com/"),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: Image.network(
                            'https://storage.googleapis.com/msgsndr/1xymNZ4jUrO97uCm1dn5/media/66eaaa7f0fbb91af273af478.png',
                            height: 25,
                            width: 25,
                          ),
                          onPressed: () =>
                              launchUrlStart(url: "https://www.eqbis.com/"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      '© 2024 GAURANGA App. All rights reserved.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ))
          //),
        ]));
  }

  Future<void> launchUrlStart({required String url}) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw 'Could not launch $url';
    }
  }

  final List<Map<String, String>> globalData = [
    {'name': '96%', 'location': 'Satisfied Mentees'},
    {'name': '8K', 'location': 'Mentors Ready to Empower You'},
    {'name': '160+', 'location': 'Countries Represented by Our Community'},
    {'name': '2,500', 'location': 'Monthly Connections'},
  ];
  List<Map<String, String>> teamData = [
    {
      'imageUrl':
          'https://storage.googleapis.com/msgsndr/1xymNZ4jUrO97uCm1dn5/media/66f0274f3b00e2d103ee46b4.webp',
      'name': 'Jayapataka Swami',
      'location': 'USA',
    },
    {
      'imageUrl':
          'https://storage.googleapis.com/msgsndr/1xymNZ4jUrO97uCm1dn5/media/66f0276efd064b3cd7b00985.jpeg',
      'name': 'Srila Prabhupada',
      'location': 'Calcutta',
    },
    {
      'imageUrl':
          'https://storage.googleapis.com/msgsndr/1xymNZ4jUrO97uCm1dn5/media/66f027824b96a97df6c4b7fd.jpeg',
      'name': 'Gauranga',
      'location': 'Australia',
    },
    {
      'imageUrl':
          'https://storage.googleapis.com/msgsndr/1xymNZ4jUrO97uCm1dn5/media/66f0287ab32e470eb93c973a.jpeg',
      'name': 'ISKCON Sydney',
      'location': 'Australia',
    },
  ];

  Widget _buildTeamMember(String imageUrl, List<String> details) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 350,
        ),
        child: Container(
          height: 150,
          width: 300,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(15), // Rounded corners
            boxShadow: [
              BoxShadow(
                color:
                    Colors.grey.withAlpha((0.5 * 255).round()), // Shadow color
                blurRadius: 10, // Softness of the shadow
                spreadRadius: 2, // How much the shadow spreads
                offset: const Offset(0, 5), // Shadow position
              ),
            ],
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min, // Allow the column to shrink if needed
            children: [
              const SizedBox(height: 20),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      imageUrl,
                      height: 300,
                      width: 300,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                details[0], // Name
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                details[1], // Location
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(
                  height: 20), // Add padding at the bottom to avoid overflow
            ],
          ),
        ),
      ),
    );
  }

  final ScrollController controller = ScrollController();

  void _showPopupMenu(BuildContext context, RenderBox button) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset buttonPosition =
        button.localToGlobal(Offset.zero, ancestor: overlay);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        buttonPosition.dx,
        buttonPosition.dy + button.size.height,
        overlay.size.width - buttonPosition.dx - button.size.width,
        overlay.size.height - buttonPosition.dy - button.size.height,
      ),
      items: [
        PopupMenuItem(
          child: ListTile(
            title: const Text('Features'),
            onTap: () {
              _scrollToSection(_featuresKey);
            },
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            title: const Text('Purpose'),
            onTap: () {
              _scrollToSection(_pricingKey);

              // Navigator.pushNamed(context, '/pricing');
              // Navigator.of(context).pop();
            },
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            title: const Text('About Us'),
            onTap: () {
              _scrollToSection(_aboutKey);
            },
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            title: const Text('Dedication'),
            onTap: () {
              _scrollToSection(_dedicationKey);
            },
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            title: const Text('Login'),
            onTap: () {
              //  Get.to(const LoginScreen());
              //Navigator.pushNamed(context, '/about');
              // Navigator.of(context).pop();
            },
          ),
        ),
      ],
    );
  }
}

// ignore: must_be_immutable
class FeatureCard extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String description;
  Color? color;

  FeatureCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.description,
    this.color,
  });

  @override
  _FeatureCardState createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onEnter(bool hover) {
    setState(() {
      _isHovered = hover;
      if (_isHovered) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _onEnter(true),
      onExit: (_) => _onEnter(false),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Padding(
          padding: MediaQuery.of(context).size.width < 600
              ? const EdgeInsets.fromLTRB(80, 5, 80, 5) // Mobile padding
              : const EdgeInsets.all(0),
          child: AnimatedContainer(
            height: 400,
            width: 400,
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? Colors.orangeAccent
                      : Colors.grey.withAlpha((0.2 * 255).round()),
                  spreadRadius: _isHovered ? 2 : 3,
                  blurRadius: _isHovered ? 2 : 3,
                ),
              ],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        widget.imageUrl,
                        height: 200,
                        width: 300,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 28.0,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;

  const CustomCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                imageUrl,
                height: 300,
                width: 250,
                fit: BoxFit.fill,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              title,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 32.0,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 22.0,
                    color: Colors.grey[600],
                  ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

final pricingData = [
  {
    "title": "DEVOTEES",
    "buttonText": "Get started for free",
    "imageUrl":
        'https://storage.googleapis.com/msgsndr/1xymNZ4jUrO97uCm1dn5/media/66f52f739fb6e5b5fafe9f57.jpeg',
    "features": [
      "Free Audio",
      "Free Video",
      "Free Gallery",
    ]
  },
  {
    "title": "TEMPLES",
    "buttonText": "Get started with Pro",
    "imageUrl":
        'https://storage.googleapis.com/msgsndr/1xymNZ4jUrO97uCm1dn5/media/66f52f6ef0f2247ef42bf1d4.jpeg',
    "features": [
      "Unlimited blocks",
      "Unlimited editors",
      "Unlimited dashboards",
    ]
  },
  {
    "title": "SANKIRTAN",
    "buttonText": "Get started with Premier",
    "imageUrl":
        'https://storage.googleapis.com/msgsndr/1xymNZ4jUrO97uCm1dn5/media/66f52f71b3c24ebfe5e3455b.jpeg',
    "features": [
      "Advanced permissions",
      "Early access to features",
      "Unlimited alerts",
    ]
  },
  {
    "title": "KIRTANS",
    "buttonText": "Get started with Enterprise",
    "imageUrl":
        'https://storage.googleapis.com/msgsndr/1xymNZ4jUrO97uCm1dn5/media/66f52f6f8fdba13d50de5b06.jpeg',
    "features": [
      "Data catalog",
      "Audit logs",
      "SAML-based SSO",
    ]
  }
];
