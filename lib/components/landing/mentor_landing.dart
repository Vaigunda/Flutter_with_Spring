// ignore_for_file: library_private_types_in_public_api, avoid_unnecessary_containers, use_super_parameters, duplicate_ignore

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:mentor/terms_condition.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/ui.dart';
import '../../navigation/router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MentorLanding(),
    );
  }
}

class MentorLanding extends StatefulWidget {
  const MentorLanding({super.key});

  @override
  _MentorLandingPageState createState() => _MentorLandingPageState();
}

class _MentorLandingPageState extends State<MentorLanding> {
  final ScrollController _scrollController = ScrollController();

  bool isUserLoggedIn = false;
  final GlobalKey _featuresKey = GlobalKey();
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
                              const SizedBox(width: 10),
                              Image.asset('assets/images/app-icon.png'),
                              Text('MentorBoosters',
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                            ],
                          ),
                          Row(
                            children: [
                              MyHoverButton(
                                onPressed: () {
                                },
                                text: 'Home',
                              ),
                              const SizedBox(width: 20),
                              MyHoverButton(
                                onPressed: () {
                                  context.push(AppRoutes.aboutus);
                                },
                                text: 'About Us',
                              ),
                              const SizedBox(width: 20),
                              MyHoverButton(
                                onPressed: () {
                                  context.push(AppRoutes.contactus);
                                },
                                text: 'Contact Us',
                              ),
                              const SizedBox(width: 20),
                              GestureDetector(
                                onTap: () {
                                  context.push(AppRoutes.login);
                                },
                                child: Container(
                                  height: 30,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.blue[800],

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
                              const SizedBox(width: 10),
                              Text('Mentor Booster',
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
                height: 600,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/terms_header.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Expanded(
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
                                        child: Text(
                                          'Mentor Boosters E-Learning ',
                                          style: TextStyle(
                                            fontSize: 70,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        'Connect with expert mentors, gain real-world insights, and accelerate your learning journey. \n Flexible, personalized, and interactive mentorship to help you achieve your goals—anytime, anywhere! ',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
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
                                          'Mentor Boosters E-Learning',
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
                    ],
                  ),
                ),
              ),
              // Section 2 - Features
              Column(
                children: [
                  const SizedBox(
                    height: 60,
                  ),
                  const Text(
                    textAlign: TextAlign.center,
                    "Transform Your Career, Fast-Track Your Success",
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    textAlign: TextAlign.center,
                    "Whether you're just starting or looking to make a big career leap, our platform offers unmatched mentorship to guide you on your path.",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                      height: 600,
                      child: Image.asset("assets/images/mentor_screen.png")),
                  const SizedBox(
                    height: 60,
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(color: Colors.grey[100]),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 10.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 60),
                          const Text(
                            "Why Choose Mentor Booster?",
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 40),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: getCrossAxisCount(context),
                              crossAxisSpacing: 16.0,
                              mainAxisSpacing: 16.0,
                              childAspectRatio:
                                  getChildAspectRatioFromWidth(screenWidth),
                            ),
                            itemCount: 4,
                            itemBuilder: (context, index) {
                              final cardData = mentorData[index];

                              return MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: HoverableContainer(
                                  hover: false,
                                  context: context,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.transparent,
                                          radius: 60,
                                          child: ClipOval(
                                            child: Image.asset(
                                              cardData['image']!,
                                              fit: BoxFit.cover,
                                              // width: 40,
                                              // height: 60,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Text(
                                            textAlign: TextAlign.center,
                                            cardData['title']!,
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 20),
                                        Text(cardData['description']!,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 8,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400)),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: MediaQuery.of(context).size.width > 800
                    ? const EdgeInsets.all(60)
                    : const EdgeInsets.all(10),
                child: HoverableContainer(
                  context: context,
                  hover: false,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      bool isSmallScreen = constraints.maxWidth < 1000;
                      return isSmallScreen
                          ? Column(
                              children: [
                                SizedBox(
                                  height: 400,
                                  child:
                                      Image.asset('assets/images/connects.jpg'),
                                ),
                                const SizedBox(height: 20),
                                Column(
                                  children: [
                                    const Text(
                                      textAlign: TextAlign.center,
                                      'What is Mentor Booster?',
                                      style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 40),
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        textAlign: TextAlign.center,
                                        'Mentor Booster is your ultimate online learning platform designed to connect learners \n'
                                        'with experienced mentors across various fields. Whether you are looking to develop new skills, \n'
                                        'advance in your career, or gain expert guidance, Mentor Booster \n'
                                        'provides a structured and interactive learning \n'
                                        'experience',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ),
                                    const SizedBox(height: 40),
                                    SizedBox(
                                      width: 400,
                                      height: 40,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue[800],
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5))),
                                          onPressed: () {
                                            context.push(AppRoutes.login);
                                          },
                                          child: const Text(
                                            'Learn More',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    )
                                  ],
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                SizedBox(
                                  height: 400,
                                  child:
                                      Image.asset('assets/images/connects.jpg'),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    children: [
                                      const Text(
                                        'What is Mentor Booster?',
                                        style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 40),
                                      const Text(
                                        textAlign: TextAlign.center,
                                        'Mentor Booster is your ultimate online learning platform designed to connect learners \n'
                                        'with experienced mentors across various fields. Whether you are looking to develop new skills, \n'
                                        'advance in your career, or gain expert guidance, Mentor Booster \n'
                                        'provides a structured and interactive learning \n'
                                        'experience',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      const SizedBox(height: 40),
                                      SizedBox(
                                        width: 400,
                                        height: 40,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue[800],
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5))),
                                          onPressed: () {
                                              context.push(AppRoutes.login);
                                          },
                                          child: const Text(
                                            'Learn More',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                    },
                  ),
                ),
              ),

              Container(
                decoration: BoxDecoration(color: Colors.grey[100]),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    bool isWideScreen = constraints.maxWidth > 700;
                    int cardsPerRow = isWideScreen ? 4 : 1;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 10.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 60),
                          const Text(
                            textAlign: TextAlign.center,
                            " A Global Community of Like-Minded Professionals",
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                            textAlign: TextAlign.center,
                            "Our impact speaks volumes, showcasing the success of our members worldwide.",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
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
                              childAspectRatio:
                                  getChildAspectRatioh(screenWidth),
                            ),
                            itemCount: globalData.length,
                            itemBuilder: (context, index) {
                              final cardData = globalData[index];

                              return MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: HoverableContainer(
                                  context: context,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            cardData['name']!,
                                            style: TextStyle(
                                                fontSize: 44,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green[800]),
                                          ),
                                          const SizedBox(height: 20),
                                          Text(
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 3,
                                              textAlign: TextAlign.center,
                                              cardData['location']!,
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
              Column(children: [
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  textAlign: TextAlign.center,
                  "Meet Our Newest Mentors",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  textAlign: TextAlign.center,
                  "Get to know some of the mentors who are ready to guide you to success.",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 60,
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: getCrossAxisCount(context),
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: childAspectRatio,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    switch (index) {
                      case 0:
                        return FeatureCard(
                          imageUrl: "assets/images/avatar-12.png",
                          title: 'Zaack Aleem',
                          description: 'Software Engineer',
                        );
                      case 1:
                        return FeatureCard(
                          imageUrl: "assets/images/avatar-9.png",
                          title: 'Grace Dannel',
                          description: 'UI/UX Designer',
                        );
                      case 2:
                        return FeatureCard(
                          imageUrl: "assets/images/avatar-3.png",
                          title: 'Blessy Nograra',
                          description: 'Mentor',
                        );
                      case 3:
                        return FeatureCard(
                          imageUrl: "assets/images/avatar-11.png",
                          title: 'Rohan norato sero',
                          description: 'Product Manager',
                        );
                      default:
                        return Container(); // Return an empty container if index is out of range
                    }
                  },
                ),
                const SizedBox(
                  height: 60,
                )
              ]),

              LayoutBuilder(
                builder: (context, constraints) {
                  bool isSmallScreen = constraints.maxWidth < 1200;

                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: isSmallScreen
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: contentWidgets(),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: contentWidgets(),
                          ),
                  );
                },
              ),

              const SizedBox(
                height: 60,
              ),

              SingleChildScrollView(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    bool isMobile = constraints.maxWidth < 800;

                    return Container(
                      height:
                          isMobile ? null : 640, // Adjust height for desktop
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.grey[100]),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          const Center(
                              child: Text(
                            'Testimonials',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 30),
                          )),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: CarouselSlider.builder(
                              itemCount: teamData.length,
                              itemBuilder: (context, index, realIndex) {
                                return _buildTeamMember(
                                  teamData[index]['imageUrl'] ?? '',
                                  [
                                    teamData[index]['name'] ?? 'Unknown Name',
                                    teamData[index]['carrer'] ??
                                        'Unknown Carrer',
                                    teamData[index]['review'] ??
                                        'Unknown Review',
                                  ],
                                );
                              },
                              options: CarouselOptions(
                                height: isMobile ? 400 : 550,
                                autoPlay: true,
                                enlargeCenterPage: true,
                                viewportFraction: isMobile ? 1.5 : 0.4,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    currentIndex =
                                        index; // Update current index
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
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
                child: Center(
                  // Ensures the Column is centered
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 20,
                        runSpacing: 10,
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Privacy Policy',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              context.push(AppRoutes.termsPage);
                            },
                            child: const Text(
                              'Terms & Conditions',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                          Column(
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            TermsAndConditionsPage()),
                                  );
                                },
                                child: const Text(
                                  'Contact Us',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                              const SizedBox(height: 5),
                              // const Text(
                              //   "Hello@mentorboosters.com",
                              //   style: TextStyle(color: Colors.white),
                              // ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          IconButton(
                            icon: const Icon(Ionicons.logo_facebook, size: 20),
                            color: Colors.white,
                            onPressed: () => launchUrlStart(url: ""),
                          ),
                          IconButton(
                            icon: const Icon(Ionicons.logo_instagram, size: 20),
                            color: Colors.white,
                            onPressed: () => launchUrlStart(url: ""),
                          ),
                          IconButton(
                            icon: const Icon(Ionicons.logo_youtube, size: 20),
                            color: Colors.white,
                            onPressed: () => launchUrlStart(url: ""),
                          ),
                          IconButton(
                            icon: const Icon(Ionicons.logo_google_playstore,
                                size: 20),
                            color: Colors.white,
                            onPressed: () => launchUrlStart(url: ""),
                          ),
                          IconButton(
                            icon: const Icon(Ionicons.logo_apple_appstore,
                                size: 20),
                            color: Colors.white,
                            onPressed: () => launchUrlStart(url: ""),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        '© 2025 MentorBoosters. All rights reserved.',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ))
          //),
        ]));
  }

  List<Widget> contentWidgets() {
    return [
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          children: [
            SizedBox(
              height: 400,
              width: 480,
              child: Image.asset('assets/images/videocall.jpg'),
            ),
          ],
        ),
      ),
      const SizedBox(width: 20, height: 20), // Spacing
      Column(
        children: [
          const Text(
            'How It Works?',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          Text(
            textAlign: TextAlign.center,
            'Mentors in your desired field. Once you choose a mentor, schedule a session at your \n '
            'convenience—whether it’s a one-on-one consultation or a group discussion. Engage in live, s \n'
            'interactive session where you can ask questions, receive personalized guidance, and gain  \n'
            'industry-specific insights. Our mentors provide tailored learning experiences, helping you \n'
            'develop new skills, navigate career challenges, and achieve your goals. \n'
            'With flexible scheduling, affordable pricing, and a thriving community of learners, \n'
            'Mentor Booster empowers you to learn anytime, anywhere,\n'
            'and grow at your own pace.',
            style: TextStyle(
                fontSize: MediaQuery.of(context).size.width > 1200 ? 16 : 18,
                fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 400,
            height: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
              ),
              onPressed: () {
                  context.push(AppRoutes.login);
              },
              child: const Text(
                'Get Started',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    ];
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

  final List<Map<String, String>> mentorData = [
    {
      'image': 'assets/images/business.jpg',
      'title': 'Expert-Led Mentorship',
      'description':
          'Learn from experienced mentors across various industries. Gain valuable insights, personalized advice, and real-world knowledge to help you grow professionally and personally'
    },
    {
      'image': 'assets/images/target.jpg',
      'title': 'Career Growth & Development',
      'description':
          'Enhance your career prospects by learning in-demand skills. Get expert advice on career transitions, entrepreneurship, and professional growth from those who have been there.'
    },
    {
      'image': 'assets/images/doller.jpg',
      'title': 'Affordable & Accessible',
      'description':
          'High-quality mentorship at an affordable cost. Our platform ensures that everyone, regardless of background, has access to expert guidance and learning opportunities.'
    },
    {
      'image': 'assets/images/design.jpg',
      'title': 'Flexible Learning Anytime',
      'description':
          'Schedule mentorship sessions at your convenience. Learn at your own pace, whether through one-on-one guidance, group discussions, or interactive workshops.'
    },
    {
      'image': 'assets/images/techu.png',
      'title': 'Engaging Community',
      'description':
          'Join a supportive community of learners and mentors. Share experiences, collaborate, and expand your network with professionals who share your interests and ambitions.'
    },
    {
      'image': 'assets/images/idea.jpg',
      'title': 'Personalized Guidance',
      'description':
          'Get tailored learning experiences based on your goals. Our mentors provide customized strategies, skill development tips, and industry-specific knowledge to accelerate your progress.'
    },
    {
      'image': 'assets/images/industry.png',
      'title': 'Live & Interactive Sessions',
      'description':
          'Engage in real-time learning with interactive sessions. Ask questions, discuss challenges, and receive instant feedback from mentors to enhance your understanding.'
    },
    {
      'image': 'assets/images/others.png',
      'title': 'Multi-Industry Expertise',
      'description':
          'Explore mentorship in various fields like business, technology, finance, arts, and more. Learn directly from professionals who bring real-world experience and insights'
    },
  ];

  final List<Map<String, String>> mentorstart = [
    {
      'name': '1. Find Your Mentor',
      'location':
          'Use our search to find mentors who match your goals, industry, or skill set.'
    },
    {
      'name': '2. Schedule a Session',
      'location':
          'Pick a time that suits you, and book a 1:1 session with your mentor.'
    },
    {
      'name': '3. Grow Together',
      'location':
          'Engage in meaningful conversations, gain insights, and take actionable steps.'
    },
  ];

  List<Map<String, String>> teamData = [
    {
      'imageUrl': 'assets/images/avatar-4.png',
      'name': 'Jamesh sarur',
      'carrer': 'BusinessOwner/Entrepreneur',
      'review':
          "Great sessions and mentoring. Very open, helpfull and practical feedback on how to take my studies and career to the next level "
    },
    {
      'imageUrl': 'assets/images/avatar-6.png',
      'name': 'Aleens cateriga',
      'carrer': 'UiUx/Designer',
      'review':
          "Aleens cateriga, thank you for the great conversation, analysis and helping me to properly approach the challenges I face!"
    },
    {
      'imageUrl': 'assets/images/avatar-8.png',
      'name': 'Williams Bond caro',
      'carrer': 'Development',
      'review':
          "Williams Bond caro was very helpful with my specific question. She brought a very structured framework for me to navigate. ",
    },
    {
      'imageUrl': 'assets/images/avatar-10.png',
      'name': 'Farina hijab',
      'carrer': 'Business/Finance',
      'review':
          "Farina hijab was super friendly and helpful, asking the right questions to understand my current challenges quickly. "
    },
  ];

 Widget _buildTeamMember(String imageUrl, List<String> details) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 350),
      child: Stack(
        children: [
          HoverableContainer(
            context: context,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 60,
                    child: ClipOval(
                      child: Image.asset(
                        imageUrl,
                        fit: BoxFit.cover,
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
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    details[2], // Description
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
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
            title: const Text('Home'),
            onTap: () {
              _scrollToSection(_featuresKey);
            },
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            title: const Text('About Us'),
            onTap: () {
              context.push(AppRoutes.aboutus);
            },
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            title: const Text('Contact Us'),
            onTap: () {
              context.push(AppRoutes.contactus);
            },
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            title: const Text('Login'),
            onTap: () {
              context.push(AppRoutes.login);
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
          padding: const EdgeInsets.all(20),
          child: Container(
            height: 400,
            width: 400,
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
                SizedBox(
                  height: 200,
                  width: 300,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(
                        widget.imageUrl,
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
                        fontSize: 20.0,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                    onPressed: () {
                      context.go(AppRoutes.login);
                    },
                    child: const Text(
                      'View Mentors',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ))
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

class MyHoverButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;

  // ignore: use_super_parameters
  const MyHoverButton({required this.onPressed, required this.text, Key? key})
      : super(key: key);

  @override
  _MyHoverButtonState createState() => _MyHoverButtonState();
}

class _MyHoverButtonState extends State<MyHoverButton> {
  bool _isHovered = false; // Initialize the variable properly

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: widget.onPressed,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontSize: _isHovered ? 22 : 16, // Zoom effect
                fontWeight: _isHovered ? FontWeight.bold : FontWeight.bold,
                color: _isHovered ? Colors.blue[800] : Colors.black,
              ),
          child: Text(widget.text),
        ),
      ),
    );
  }
}

double getChildAspectRatioFromWidth(double width) {
  if (width > 1300) {
    return 0.9;
  } else if (width > 1200) {
    return 0.7;
  } else if (width > 1000) {
    return 1.4;
  } else if (width > 900) {
    return 1.2;
  } else if (width > 800) {
    return 1;
  } else if (width > 750) {
    return 1.1;
  } else if (width > 700) {
    return 0.9;
  } else if (width > 650) {
    return 0.8;
  } else if (width > 600) {
    return 0.7;
  } else if (width > 500) {
    return 1.2;
  } else if (width > 300) {
    return 0.8;
  } else {
    return 0.6;
  }
}

int getCrossAxisCount(BuildContext context) {
  double width = MediaQuery.of(context).size.width;

  if (width > 1200) {
    return 4;
  } else if (width > 600) {
    return 2;
  } else {
    return 1;
  }
}

double getChildAspectRatioh(double width) {
  if (width > 1300) {
    return 2;
  } else if (width > 1200) {
    return 2;
  } else if (width > 700) {
    return 0.9;
  } else if (width > 600) {
    return 2.5;
  } else if (width > 400) {
    return 2;
  } else if (width > 300) {
    return 1.4;
  } else {
    return 0.8;
  }
}
