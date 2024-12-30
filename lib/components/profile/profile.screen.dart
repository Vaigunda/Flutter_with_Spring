import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:mentor/components/profile/providers/profile.provider.dart';
import '../../shared/models/all_mentors.model.dart';
import '../admin/edit_mentor.screen.dart';
import '/shared/utils/extensions.dart';
import '../../navigation/router.dart';
import '../../shared/views/button.dart';
import 'models/profile.model.dart';
import 'package:provider/provider.dart';
import 'package:mentor/provider/user_data_provider.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  var provider;
  late String userId;
  late String userType;
  late String usertoken;

  MentorProfileModel? profile;

  UserProfileModel? userProfile;

  var isMentor = false; //switch to true to setting teaching schedule

  @override
  void initState() {
    super.initState();
    provider = context.read<UserDataProvider>();
    userId = provider.userid;
    userType = provider.usertype;
    usertoken = provider.usertoken;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userType == 'User') {
        loadUserProfile();
      }
      
      if (userType == 'Mentor') {
        loadMentorProfile();
      }
    });
  }

  Future<void> loadUserProfile() async {
    try {
      final fetchedUserProfile =
          await ProfileProvider.shared.getUserProfile(userId, usertoken);

      setState(() {
        userProfile = fetchedUserProfile;
      });
    } catch (e) {
      debugPrint("Error loading user profile: $e");
    }
  }

  Future<void> loadMentorProfile() async {
    try {
      final fetchedProfile =
          await ProfileProvider.shared.getProfile(userId, usertoken);

      setState(() {
        profile = fetchedProfile;
      });
    } catch (e) {
      debugPrint("Error loading mentor profile: $e");
    }
  }

  Future<void> loadMentor() async {
    try {
      int userid = int.parse(userId);
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/mentors/$userid'),
        headers: {
          "content-type": "application/json",
          'Authorization': 'Bearer $usertoken',
        },
      );

      if (response.statusCode == 200) {
        var parsed = response.body;
        Map<String, dynamic> map = jsonDecode(parsed);
        AllMentors mentor = AllMentors.fromJson(map);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditMentorScreen(mentor: mentor),
          ),
        );
      } else {
        throw Exception('Failed to load mentor: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Error loading mentor detail: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          "Profile",
          style: context.headlineMedium,
        ),
        actions: [
          IconButton(
              onPressed: () {
                context.push(AppRoutes.settings);
              },
              icon: const Icon(FontAwesomeIcons.gear))
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  if (userType == 'Mentor')
                    profile == null
                        ? const CircularProgressIndicator()
                        : _info(),
                  if (userType == 'User')
                    userProfile == null
                        ? const CircularProgressIndicator()
                        : _profileinfo(),
                  if (userType == 'User' && userProfile != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: _usertiles(),
                    ),
                  if (userType == 'Mentor' && profile != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: _tiles(),
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _info() {
    if (profile == null) {
      return const CircularProgressIndicator();
    }

    return Center(
      child: Column(
        children: [
          Text(
            profile!.name,
            style: context.titleLarge,
          ),
          Text(
            profile!.title,
            style: context.bodyMedium,
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /*if (isMentor)
                CustomButton(
                  label: "Setting schedule",
                  onPressed: () {
                    context.push(AppRoutes.settingTeachingSchedule);
                  },
                )
              else
                CustomButton(
                  label: "Become Mentor",
                  onPressed: () {
                    context.push('${AppRoutes.becomeMentor}/1');
                  },
                ),*/
              CustomButton(
                label: "Edit Mentor",
                onPressed: loadMentor,
              ),
              const SizedBox(width: 10),
              CustomButton(
                label: "My schedule",
                onPressed: () {
                  context.go(AppRoutes.mySchedule);
                },
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _tiles() {
    return Column(
        // direction: Axis.vertical,
        // spacing: 16,
        children: [
          about(),
          const SizedBox(
            height: 10,
          ),
          workExperience(),
          /*const SizedBox(
            height: 10,
          ),
          buildTile(FontAwesomeIcons.graduationCap, "Education"),*/
          const SizedBox(
            height: 10,
          ),
          skills(),
          const SizedBox(
            height: 10,
          ),
          //buildTile(FontAwesomeIcons.certificate, "Certificates"),
          certificates(),
          /*const SizedBox(
            height: 10,
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                GoRouter.of(context).push(AppRoutes.settings);
              },
              child: buildTile(FontAwesomeIcons.gears, "Settings",
                  FontAwesomeIcons.arrowRight),
            ),
          ),*/
          const SizedBox(
            height: 20,
          )
        ]);
  }

  Widget _usertiles() {
    return Column(
        // direction: Axis.vertical,
        // spacing: 16,
        children: [
          other(),
          const SizedBox(
            height: 20,
          )
        ]);
  }

  Widget _profileinfo() {
    if (userProfile == null) {
      return const CircularProgressIndicator();
    }

    return Center(
      child: Column(
        children: [
          Text(
            userProfile!.name,
            style: context.titleLarge,
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 10),
              CustomButton(
                label: "My schedule",
                onPressed: () {
                  context.go(AppRoutes.mySchedule);
                },
              )
            ],
          )
        ],
      ),
    );
  }

  Widget buildTile(IconData leadingIcon, String title,
      [IconData? trallingIcon]) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).cardColor),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFF22D3EE)),
            height: 48,
            width: 48,
            child: Icon(
              leadingIcon,
              color: Theme.of(context).cardColor,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                title,
                style: context.titleMedium,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
          /*Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 0, 0, 0),
            child: SizedBox(
              width: 26,
              height: 26,
              child: FloatingActionButton.small(
                heroTag: title,
                elevation: 1,
                backgroundColor: context.colors.primary,
                onPressed: () {},
                child: Icon(
                  trallingIcon ?? FontAwesomeIcons.plus,
                  size: 10,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          )*/
        ],
      ),
    );
  }

  Widget buildOtherTile(IconData leadingIcon, String title,
      [IconData? trallingIcon]) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).cardColor),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFF22D3EE)),
            height: 48,
            width: 48,
            child: Icon(
              leadingIcon,
              color: Theme.of(context).cardColor,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                title,
                style: context.titleMedium,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 0, 0, 0),
            child: SizedBox(
              width: 26,
              height: 26,
              child: FloatingActionButton.small(
                heroTag: title,
                elevation: 1,
                backgroundColor: context.colors.primary,
                onPressed: () {
                  // Navigate to EditUserScreen using context.push
                  context.push('/edit-user/${userId}');
                },
                child: Icon(
                  trallingIcon ?? FontAwesomeIcons.plus,
                  size: 10,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget about() {
    return Container(
      //padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).cardColor),
      child: Column(children: [
        buildTile(
            FontAwesomeIcons.circleUser, "About", FontAwesomeIcons.pencil),
        devider(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Text(
            profile!.about,
            style: context.bodyMedium,
            overflow: TextOverflow.ellipsis,
            maxLines: 4,
          ),
        )
      ]),
    );
  }

  Widget other() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).cardColor),
      child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildOtherTile(
                      FontAwesomeIcons.circleUser, "Other Details", FontAwesomeIcons.pencil),
                  /*IconButton(
                    icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                    onPressed: () {
                      // Navigate to EditUserScreen using context.push
                      context.push('/edit-user/${userId}');
                    },
                  ),*/
                  devider(),
                  const SizedBox(
                    width: 20,
                  ),
                  Row(
                    children: [
                      Text(
                          'Email ID : ',
                          style: context.titleSmall,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 4,
                        ),
                      Text(
                        userProfile!.emailId,
                        style: context.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Row(
                    children: [
                      Text(
                          'Age : ',
                          style: context.titleSmall,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 4,
                        ),
                      Text(
                        userProfile!.age.toString(),
                        style: context.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Row(
                    children: [
                      Text(
                          'Gender : ',
                          style: context.titleSmall,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 4,
                        ),
                      Text(
                        userProfile!.gender,
                        style: context.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
        );
  }

  Widget devider() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Divider(
        color: Theme.of(context).colorScheme.outline,
        height: 0.5,
        thickness: 0.5,
      ),
    );
  }

  Widget workExperience() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).cardColor),
      child: Column(children: [
        buildTile(FontAwesomeIcons.bagShopping, "Experience"),
        devider(),
        ...profile!.experiences.map((exp) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          exp.jobTitle,
                          style: context.titleSmall,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 4,
                        ),
                      ),
                      /*Icon(
                        FontAwesomeIcons.pencil,
                        color: Theme.of(context).colorScheme.primary,
                        size: 16,
                      )*/
                    ],
                  ),
                  Text(
                    exp.company,
                    style: context.bodySmall,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 4,
                  ),
                  Text(
                    exp.period,
                    style: context.bodySmall,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 4,
                  )
                ],
              ),
            ))
      ]),
    );
  }

  Widget skills() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).cardColor),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        buildTile(
            FontAwesomeIcons.bagShopping, "Categories", FontAwesomeIcons.pencil),
        devider(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Wrap(
            spacing: 10.0,
            runSpacing: 10.0,
            children: [...profile!.skills.map(chip)],
          ),
        )
      ]),
    );
  }

  Chip chip(String text) {
    return Chip(
      backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
      label: Text(
        text,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      labelStyle: context.bodySmall!.copyWith(fontWeight: FontWeight.w600),
    );
  }

  Widget certificates() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).cardColor),
      child: Column(children: [
        buildTile(FontAwesomeIcons.bagShopping, "Certificates"),
        devider(),
        ...profile!.certificates.map((cert) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          cert.name,
                          style: context.titleSmall,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 4,
                        ),
                      ),
                      /*Icon(
                        FontAwesomeIcons.pencil,
                        color: Theme.of(context).colorScheme.primary,
                        size: 16,
                      )*/
                    ],
                  ),
                  Text(
                    cert.provideBy,
                    style: context.bodySmall,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 4,
                  ),
                  Text(
                    cert.date,
                    style: context.bodySmall,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 4,
                  )
                ],
              ),
            ))
      ]),
    );
  }
}