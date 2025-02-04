import 'package:flutter/material.dart';
import 'package:mentor/constants/ui.dart';
import 'package:mentor/shared/models/all_mentors.model.dart';

class ViewMentorScreen extends StatelessWidget {
  final AllMentors mentor;

  const ViewMentorScreen({required this.mentor});

  // Helper function to map category icon names to IconData
  IconData _getIconFromName(String iconName) {
    switch (iconName) {
      case 'FontAwesomeIcons.code':
        return Icons
            .code; // Replace with the FontAwesome icon if using the package
      case 'FontAwesomeIcons.penNib':
        return Icons.edit; // Replace with another relevant icon
      default:
        return Icons.help; // Fallback icon
    }
  }

  Widget _buildExperienceCard(BuildContext context, Experience experience) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: HoverableContainer(
        hover: false,
        context: context,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: Text(
                'Experiences',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            ListTile(
              title: Text(
                experience.role,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Company: ${experience.companyName}'),
                  Text('Start Date: ${experience.startDate}'),
                  Text('End Date: ${experience.endDate ?? "Present"}'),
                  if (experience.description != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        experience.description ?? '',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, Review review) {
    return HoverableContainer(
      context: context,
      hover: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 10, top: 10),
            child: Text(
              'Reviews',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
          ListTile(
            title: Text(
              review.message,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            subtitle: Text('Date: ${review.createDate}'),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateCard(BuildContext context, Certificate certificate) {
    return HoverableContainer(
      context: context,
      hover: false,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Certificates',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ListTile(
              title: Text(
                certificate.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text('Provided By: ${certificate.provideBy}'),
              leading: certificate.imageUrl != null
                  ? Image.network(
                      certificate.imageUrl,
                      width: 50,
                      height: 50,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image),
                    )
                  : const Text('No certificates available'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeachingScheduleCard(
      BuildContext context, FixedTimeSlot schedule) {
    return HoverableContainer(
      context: context,
      hover: false,
      child: ListTile(
        title: const Text(
          'Time Slots',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Start Time: ${schedule.timeStart}'),
            Text('End Time: ${schedule.timeEnd}'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(mentor.name),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 600;
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: HoverableContainer(
                hover: false,
                context: context,
                child: isWideScreen
                    ? SingleChildScrollView(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Center(
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                    CircleAvatar(
                                      backgroundImage:
                                          AssetImage(mentor.avatarUrl),
                                      radius: 120,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      mentor.name,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      mentor.role,
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ])),
                            ),
                            const VerticalDivider(),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  HoverableContainer(
                                    context: context,
                                    hover: false,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ListTile(
                                            title: const Text('Bio',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                            subtitle: Text(
                                              mentor.bio,
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 8),
                                  ...mentor.experiences.map((experience) =>
                                      _buildExperienceCard(
                                          context, experience)),

                                  if (mentor.reviews.isEmpty)
                                    const Text('')
                                  else
                                    ...mentor.reviews.map((reviews) =>
                                        _buildReviewCard(context, reviews)),

                                  // Certificates
                                  ...mentor.certificates.map((certificates) =>
                                      _buildCertificateCard(
                                          context, certificates)),

                                  // Categories
                                  HoverableContainer(
                                    hover: false,
                                    context: context,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const ListTile(
                                          title: Text('Categories',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600)),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child: Wrap(
                                            spacing: 8,
                                            children: mentor.categories
                                                .map((category) {
                                              return Chip(
                                                label: Text(category
                                                    .name), // Use dot notation for `name`
                                                avatar: Icon(
                                                  _getIconFromName(category
                                                      .icon), // Use helper function for `icon`
                                                  size: 16,
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        )
                                      ],
                                    ),
                                  ),

                                  // Pricing Info

                                  HoverableContainer(
                                    context: context,
                                    hover: false,
                                    child: ListTile(
                                      title: const Text('Pricing',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600)),
                                      subtitle: Text(
                                        '${mentor.free.price} ${mentor.free.unit.name}', // Use dot notation for nested objects
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 8),
                                  ...mentor.timeSlots.map((timeSlots) =>
                                      _buildTeachingScheduleCard(
                                          context, timeSlots)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                      child: Column(
                          children: [
                            CircleAvatar(
                              backgroundImage: AssetImage(mentor.avatarUrl),
                              radius: 80,
                            ),
                            Text(
                              'Bio',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, bottom: 16.0),
                              child: Text(
                                mentor.bio,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            const Divider(),
                            // Experiences
                            Text(
                              'Experiences',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            ...mentor.experiences.map((experience) =>
                                _buildExperienceCard(context, experience)),
                      
                            const Divider(),
                      
                            // Reviews
                            Text(
                              'Reviews',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            if (mentor.reviews.isEmpty)
                              const Text('')
                            else
                              ...mentor.reviews.map((reviews) =>
                                  _buildReviewCard(context, reviews)),
                            // Certificates
                            Text(
                              'Certificates',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            ...mentor.certificates.map((certificates) =>
                                _buildCertificateCard(context, certificates)),
                            const Divider(),
                            // Categories
                            Text(
                              'Categories',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Wrap(
                                spacing: 8,
                                children: mentor.categories.map((category) {
                                  return Chip(
                                    label: Text(category
                                        .name), // Use dot notation for `name`
                                    avatar: Icon(
                                      _getIconFromName(category
                                          .icon), // Use helper function for `icon`
                                      size: 16,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const Divider(),
                            // Pricing Info
                            Text(
                              'Pricing',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                '${mentor.free.price} ${mentor.free.unit.name}', // Use dot notation for nested objects
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            const Divider(),
                            // Teaching Schedules
                            Text(
                              'Time Slots',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            ...mentor.timeSlots.map((timeSlots) =>
                                _buildTeachingScheduleCard(context, timeSlots)),
                          ],
                        ),
                    ),
              ),
            ),
          );
        },

        // Padding(
        //   padding: const EdgeInsets.all(16.0),
        //   child: SingleChildScrollView(
        //     child: Column(
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: [
        //         // Avatar and Basic Details
        //         Center(
        //           child: Column(
        //             children: [
        //               CircleAvatar(
        //                 backgroundImage: AssetImage(mentor.avatarUrl),
        //                 radius: 50,
        //               ),
        //               const SizedBox(height: 8),
        //               Text(
        //                 mentor.name,
        //                 style: const TextStyle(
        //                   fontSize: 24,
        //                   fontWeight: FontWeight.bold,
        //                 ),
        //               ),
        //               Text(
        //                 mentor.role,
        //                 style: const TextStyle(
        //                   fontSize: 16,
        //                   color: Colors.grey,
        //                 ),
        //               ),
        //             ],
        //           ),
        //         ),
        //         const Divider(),
        //         // Bio
        //         Text(
        //           'Bio',
        //           style: Theme.of(context).textTheme.titleMedium,
        //         ),
        //         Padding(
        //           padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
        //           child: Text(
        //             mentor.bio,
        //             style: const TextStyle(fontSize: 16),
        //           ),
        //         ),
        //         const Divider(),
        //         // Experiences
        //         Text(
        //           'Experiences',
        //           style: Theme.of(context).textTheme.titleMedium,
        //         ),
        //         const SizedBox(height: 8),
        //         ...mentor.experiences.map(_buildExperienceCard),
        //         const Divider(),

        //         // Reviews
        //         Text(
        //           'Reviews',
        //           style: Theme.of(context).textTheme.titleMedium,
        //         ),
        //         if (mentor.reviews.isEmpty)
        //           const Text('No reviews available.')
        //         else
        //           ...mentor.reviews.map(_buildReviewCard),
        //         const Divider(),

        //         // Certificates
        //         Text(
        //           'Certificates',
        //           style: Theme.of(context).textTheme.titleMedium,
        //         ),
        //         const SizedBox(height: 8),
        //         ...mentor.certificates.map(_buildCertificateCard),
        //         const Divider(),
        //         // Categories
        //         Text(
        //           'Categories',
        //           style: Theme.of(context).textTheme.titleMedium,
        //         ),
        //         const SizedBox(height: 8),
        //         Wrap(
        //           spacing: 8,
        //           children: mentor.categories.map((category) {
        //             return Chip(
        //               label: Text(category.name), // Use dot notation for `name`
        //               avatar: Icon(
        //                 _getIconFromName(category.icon), // Use helper function for `icon`
        //                 size: 16,
        //               ),
        //             );
        //           }).toList(),
        //         ),
        //         const Divider(),
        //         // Pricing Info
        //         Text(
        //           'Pricing',
        //           style: Theme.of(context).textTheme.titleMedium,
        //         ),
        //         Padding(
        //           padding: const EdgeInsets.only(top: 8.0),
        //           child: Text(
        //             '${mentor.free.price} ${mentor.free.unit.name}', // Use dot notation for nested objects
        //             style: const TextStyle(fontSize: 16),
        //           ),
        //         ),
        //         const Divider(),
        //         // Teaching Schedules
        //         Text(
        //           'Time Slots',
        //           style: Theme.of(context).textTheme.titleMedium,
        //         ),
        //         const SizedBox(height: 8),
        //         ...mentor.timeSlots.map(_buildTeachingScheduleCard),
        //       ],
        //     ),
        //   ),
      ),
    );
  }
}
