import 'package:flutter/material.dart';
import 'package:mentor/shared/models/all_mentors.model.dart';

class ViewMentorScreen extends StatelessWidget {
  final AllMentors mentor;

  const ViewMentorScreen({required this.mentor});

  
  // Helper function to map category icon names to IconData
  IconData _getIconFromName(String iconName) {
    switch (iconName) {
      case 'FontAwesomeIcons.code':
        return Icons.code; // Replace with the FontAwesome icon if using the package
      case 'FontAwesomeIcons.penNib':
        return Icons.edit; // Replace with another relevant icon
      default:
        return Icons.help; // Fallback icon
    }
  }

  Widget _buildExperienceCard(Experience experience) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      child: ListTile(
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
    );
  }

  Widget _buildReviewCard(Review review) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      child: ListTile(
        title: Text(
          review.message,
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
        subtitle: Text('Date: ${review.createDate}'),
      ),
    );
  }

  Widget _buildCertificateCard(Certificate certificate) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      child: ListTile(
        title: Text(
          certificate.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Provided By: ${certificate.provideBy}'),
        leading: Image.asset(certificate.imageUrl, width: 50, height: 50),
      ),
    );
  }

  Widget _buildTeachingScheduleCard(FixedTimeSlot schedule) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      child: ListTile(
        title: const Text(
          'Time Slots',
          style: TextStyle(fontWeight: FontWeight.bold),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar and Basic Details
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage(mentor.avatarUrl),
                      radius: 50,
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
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Bio
              Text(
                'Bio',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                child: Text(
                  mentor.bio,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              // Experiences
              Text(
                'Experiences',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...mentor.experiences.map(_buildExperienceCard),
              const Divider(),

              // Reviews
              Text(
                'Reviews',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...mentor.reviews.map(_buildReviewCard),
              const Divider(),

              // Certificates
              Text(
                'Certificates',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...mentor.certificates.map(_buildCertificateCard),
              const Divider(),
              // Categories
              Text(
                'Categories',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: mentor.categories.map((category) {
                  return Chip(
                    label: Text(category.name), // Use dot notation for `name`
                    avatar: Icon(
                      _getIconFromName(category.icon), // Use helper function for `icon`
                      size: 16,
                    ),
                  );
                }).toList(),
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
              // Teaching Schedules
              Text(
                'Time Slots',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...mentor.timeSlots.map(_buildTeachingScheduleCard),
            ],
          ),
        ),
      ),
    );
  }
}
