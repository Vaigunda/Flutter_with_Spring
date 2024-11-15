import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mentor/navigation/router.dart';
// import 'package:mentor/shared/models/category.model.dart';
// import 'package:mentor/shared/models/certificate.model.dart';
// import 'package:mentor/shared/models/experience.model.dart';
import 'package:mentor/shared/models/profile_mentor.model.dart';
// import 'package:mentor/shared/models/review.model.dart';
import 'package:mentor/shared/services/profile_mentor.service.dart';
import 'package:mentor/shared/shared.dart';

// import '../../shared/models/mentor.model.dart';
// import '../../shared/providers/mentors.provider.dart';
import '../../shared/views/button.dart';

class ProfileMentorScreen extends StatefulWidget {
  const ProfileMentorScreen({super.key, required this.profileId});
  final int profileId;

  @override
  State<ProfileMentorScreen> createState() => _ProfileMentorScreenState();
}

class _ProfileMentorScreenState extends State<ProfileMentorScreen>
    with SingleTickerProviderStateMixin {
  late ProfileMentor? mentor;
  late TabController _tabController;
  final ScrollController _scrollCtrl = ScrollController();
  List<String> tab = ["Overview", "Reviews", "Certificates"];

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
      ProfileMentor? fetchedMentor = await ProfileMentorService.fetchMentorById(widget.profileId);

      setState(() {
        mentor = fetchedMentor;
      });
    } catch (e) {
      // Handle the error, maybe show a message to the user
      print("Error fetching mentor: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
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
    )));
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
          onPressed: () {
            context.push('${AppRoutes.bookingMentor}/${mentor!.id}');
          },
        ),
        const SizedBox(width: 10),
        CustomButton(
          type: EButtonType.secondary,
          label: "Send message",
          onPressed: () {},
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
              ...[
              const SizedBox(height: 10),
              experiences()
            ],
              ...[
              const SizedBox(height: 10),
              skills()
            ]
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
                    'ul':
                        Style(margin: Margins.symmetric(vertical: 10)),
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
    future: ProfileMentorService.fetchMentorById(int.parse(review.createdById)),
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
              bottom: BorderSide(color: Theme.of(context).colorScheme.tertiary),
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
                          mentor != null ? mentor.name : "Unknown",
                          style: context.titleSmall,
                        ),
                        Text(
                          review.createDate != null
                              ? DateFormat("yyyy/MM/dd").format(review.createDate!)
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
                bottom:
                    BorderSide(color: Theme.of(context).colorScheme.tertiary))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Image.asset(certificate.imageUrl,
              width: MediaQuery.of(context).size.width),
          const SizedBox(height: 10),
          Text(certificate.name,
              style: context.titleMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          Text(certificate.provideBy,
              style: context.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 20),
          Text(certificate.createDate != null ? DateFormat("yyyy/MM/dd").format(certificate.createDate!) : "No Date",
              style: context.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ]));
  }

  Divider divider() {
    return Divider(
        height: 1,
        thickness: 0.5,
        color: Theme.of(context).colorScheme.tertiary);
  }
}
