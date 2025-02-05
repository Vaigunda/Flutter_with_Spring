import 'dart:convert';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mentor/navigation/router.dart';
import 'package:mentor/shared/models/profile_mentor.model.dart';
import 'package:mentor/shared/services/profile_mentor.service.dart';
import 'package:mentor/shared/shared.dart';
import '../../shared/services/token.service.dart';
import '../../shared/views/button.dart';
import 'package:provider/provider.dart';
import 'package:mentor/provider/user_data_provider.dart';

class ProfileMentorScreen extends StatefulWidget {
  const ProfileMentorScreen({super.key, required this.profileId});
  final int profileId;

  @override
  State<ProfileMentorScreen> createState() => _ProfileMentorScreenState();
}

class _ProfileMentorScreenState extends State<ProfileMentorScreen>
    with SingleTickerProviderStateMixin {
  ProfileMentor? mentor;
  late TabController _tabController;
  final ScrollController _scrollCtrl = ScrollController();
  List<String> tab = ["Overview", "Reviews", "Certificates"];

  late String usertoken;
  late String userid;
  var provider;

  TabBar get _tabBar => TabBar(
          indicator: ShapeDecoration(
            shape: UnderlineInputBorder(
              borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 3,
                  style: BorderStyle.solid),
            ),
          ),
          labelPadding: const EdgeInsets.only(left: 20, right: 20),
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          labelStyle: context.labelMedium!
              .copyWith(color: Theme.of(context).colorScheme.primary),
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: [
            ...tab.map(
              (item) => Tab(
                  child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(item),
                ],
              )),
            )
          ]);
  @override
  void initState() {
    super.initState();

    provider = context.read<UserDataProvider>();
    usertoken = provider.usertoken;
    userid = provider.userid;

    _fetchMentorData();
    _tabController = TabController(length: tab.length, vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _tabController.dispose();
    _scrollCtrl.dispose();
  }

  Future<void> _fetchMentorData() async {
    try {
      ProfileMentor? fetchedMentor = await ProfileMentorService.fetchMentorById(
          widget.profileId, usertoken);

      setState(() {
        mentor = fetchedMentor;
      });
    } catch (e) {
      // Handle the error, maybe show a message to the user
      print("Error fetching mentor: $e");
    }
  }

  Future<void> saveReviews(String message, String rating) async {
    // Check if token has expired
    bool isExpired = JwtDecoder.isExpired(usertoken);
    if (isExpired) {
      final tokenService = TokenService();
      tokenService.checkToken(usertoken, context);
    } else {
      final url = Uri.parse('http://localhost:8080/api/reviews/create');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $usertoken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': message,
          'rating': rating.isNotEmpty ? int.parse(rating) : 0,
          'mentorId': widget.profileId,
          'userId': userid,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review is submitted successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception('Failed to add reviews');
      }
    }
  }


  void _showAddReviewsDialog(BuildContext context) {
  TextEditingController messageCtrl = TextEditingController();
   TextEditingController ratingCtrl = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(         
           borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 2,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title Section
              Container(
                width: 360,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Text(
                      "Share Your Feedback",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Please rate and share your experience.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Rating Section
              RatingBar.builder(
                initialRating: 3,
                minRating: 1,
                itemSize: 40,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4),
                itemBuilder: (context, index) {
                  return const Icon(
                    Icons.star,
                    color: Colors.yellow,
                  );
                },
                onRatingUpdate: print,
              ),
              const SizedBox(height: 16),
              // Text Input Section
              TextField(
                controller: messageCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Write your review here...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.teal.shade200),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 16),
              // Submit Button
              ElevatedButton(
                onPressed: () {
                         Navigator.pop(context);
                saveReviews(messageCtrl.text,
                    ratingCtrl.text); // Close dialog
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:  Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text(
                  "Submit Review",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

  

  @override
  Widget build(BuildContext context) {
    if (mentor == null) {
      // Show loading state or an error state if mentor is not fetched
      return Scaffold(
        appBar: AppBar(
          title: const Text("Loading..."),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Mentor data is fetched, proceed with building the profile screen
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          controller: _scrollCtrl,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                backgroundColor: Theme.of(context).colorScheme.surface,
                pinned: false,
                flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    background: Column(children: [
                      const SizedBox(height: 20),
                      headerProfile(),
                      const SizedBox(height: 15),
                      actions()
                    ])),
                forceElevated: innerBoxIsScrolled,
                expandedHeight: 370.0,
                bottom: PreferredSize(
                  preferredSize: _tabBar.preferredSize,
                  child: Material(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: _tabBar),
                ),
              )
            ];
          },
          body: TabBarView(
              controller: _tabController,
              children: [overviewProfile(), reviewMentor(), certificates()]),
        ),
      ),
    );
  }

  Widget headerProfile() {
    return Column(children: [
      Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage(mentor!.avatarUrl),
          ),
          if (mentor!.verified) ...[
            const Positioned(
                bottom: 5,
                right: 0,
                child: Icon(Icons.check_circle_outline_rounded,
                    color: Colors.green))
          ]
        ],
      ),
      Text(
        mentor!.name,
        style: context.titleLarge,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      ...[
        Text(
          mentor!.role,
          style: context.bodyMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        )
      ],
      const SizedBox(height: 20),
      Wrap(spacing: 15, children: [
        Column(
          children: [
            const Icon(Icons.credit_card),
            const SizedBox(height: 5),
            Text(
                mentor!.free == null
                    ? "No information"
                    : mentor!.free.price == 0
                        ? "Free"
                        : "\$${mentor!.free.price} / ${mentor!.free.unit.name}",
                style: const TextStyle(fontWeight: FontWeight.bold))
          ],
        ),
        Column(
          children: [
            const Icon(Icons.account_circle_rounded),
            const SizedBox(height: 5),
            Text(
              '${mentor!.numberOfMentoree} mentee',
              style: const TextStyle(fontWeight: FontWeight.bold),
            )
          ],
        ),
        Column(
          children: [
            const Icon(Icons.star_outline_rounded),
            const SizedBox(height: 5),
            Text(
              '${mentor!.rate} rating',
              style: const TextStyle(fontWeight: FontWeight.bold),
            )
          ],
        ),
      ])
    ]);
  }

  Widget actions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomButton(
          label: "Booking",
          borderRadius: 10,
          onPressed: () {
            context.push('${AppRoutes.bookingMentor}/${mentor!.id}');
          },
        ),
        const SizedBox(width: 10),
        CustomButton(
          type: EButtonType.secondary,
          borderRadius: 10,
          label: "Review",
          onPressed: () async {
            _showAddReviewsDialog(context);
          },
        )
      ],
    );
  }

// ------------------ overview tab----------------------
  Widget overviewProfile() {
    return SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              bio(),
              ...[const SizedBox(height: 10), experiences()],
              ...[const SizedBox(height: 10), skills()]
            ])));
  }

  Widget bio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("About", style: context.titleMedium),
        const SizedBox(height: 10),
        Text(
          mentor?.bio ?? "",
          softWrap: true,
        ),
        const SizedBox(height: 10),
        divider()
      ],
    );
  }

  Widget experiences() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("Experiences", style: context.titleMedium),
      const SizedBox(height: 10),
      for (var exp in mentor!.experiences) itemExperience(exp),
      const SizedBox(height: 10),
      divider()
    ]);
  }

  Widget itemExperience(Experience exp) {
    return Column(
      children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage(mentor!.avatarUrl),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exp.role,
                style: context.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                exp.companyName,
                style: context.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                "${exp.startDate != null ? DateFormat('yyyy/MM').format(exp.startDate!) : "N/A"} - ${exp.endDate != null ? DateFormat('yyyy/MM').format(exp.endDate!) : "Present"}",
                style: context.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (exp.description != null)
                Html(
                  data: exp.description,
                  shrinkWrap: true,
                  style: {
                    'body': Style(
                        margin: Margins.all(0), padding: HtmlPaddings.all(0)),
                    'p': Style(margin: Margins.only(top: 5)),
                    'ul': Style(margin: Margins.symmetric(vertical: 10)),
                  },
                )
            ],
          ))
        ]),
        const SizedBox(height: 10)
      ],
    );
  }

  Widget skills() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("Skills", style: context.titleMedium),
      const SizedBox(height: 10),
      Wrap(
        spacing: 5,
        runSpacing: 5,
        children: [for (var cate in mentor!.categories) itemSkill(cate)],
      )
    ]);
  }

  Widget itemSkill(Category cate) {
    return Chip(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      label: Text(
        cate.name,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      labelStyle: context.bodySmall!.copyWith(fontWeight: FontWeight.w600),
    );
  }
//--------------------END--------------------------------

// ------------------ reviews tab----------------------
  Widget reviewMentor() {
    return SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: mentor!.reviews.isEmpty
                ? Text("No review found", style: context.bodyMedium)
                : Column(children: [
                    for (var review in mentor!.reviews) itemReview(review)
                  ])));
  }

  Widget itemReview(Review review) {
    return FutureBuilder<ProfileMentor?>(
      future: ProfileMentorService.fetchMentorById(
          int.parse(review.createdById), usertoken),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Loading indicator
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // Display error
        } else {
          final mentor = snapshot.data;
          return Container(
            decoration: BoxDecoration(
              border: Border(
                bottom:
                    BorderSide(color: Theme.of(context).colorScheme.tertiary),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: mentor != null
                            ? AssetImage(mentor.avatarUrl)
                            : null,
                      ),
                      const SizedBox(width: 5),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.userName,
                            style: context.titleSmall,
                          ),
                          Text(
                            review.createDate != null
                                ? DateFormat("yyyy/MM/dd")
                                    .format(review.createDate!)
                                : "No Date",
                            style: context.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    review.message,
                    style: context.bodyMedium,
                    softWrap: true,
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

//--------------------END--------------------------------
  Widget certificates() {
    return SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: mentor!.certificates.isEmpty
                ? Text("No certificate found", style: context.bodyMedium)
                : Column(
                    children: [
                      for (var certificate in mentor!.certificates)
                        itemCertificate(certificate)
                    ],
                  )));
  }

  Widget itemCertificate(Certificate certificate) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).colorScheme.tertiary),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          certificate.imageUrl.isNotEmpty
              ? Image.network(
                  certificate.imageUrl,
                  width: MediaQuery.of(context).size.width,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text("No Certificate Found",
                          style: context.bodyMedium),
                    );
                  },
                )
              : Center(
                  child:
                      Text("No Certificate Found", style: context.bodyMedium),
                ),
          const SizedBox(height: 10),
          Text(
            certificate.name,
            style: context.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            certificate.provideBy,
            style: context.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          Text(
            certificate.createDate != null
                ? DateFormat("yyyy/MM/dd").format(certificate.createDate!)
                : "No Date",
            style: context.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Divider divider() {
    return Divider(
        height: 1,
        thickness: 0.5,
        color: Theme.of(context).colorScheme.tertiary);
  }
}
