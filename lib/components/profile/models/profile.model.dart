class MentorProfileModel {
  final String name;
  final String avatar;
  final String title;
  final String about;
  final List<WorkExperienceModel> experiences;
  final List<String> skills;
  final List<CertificateModel> certificates;

  MentorProfileModel(
      {required this.name,
      required this.avatar,
      required this.title,
      required this.about,
      required this.experiences,
      required this.skills,
      required this.certificates});
}

class WorkExperienceModel {
  final String company;
  final String jobTitle;
  final String period;

  WorkExperienceModel(
      {required this.company, required this.jobTitle, required this.period});
}

class CertificateModel {
  final String name;
  final String provideBy;
  final String date;
  final String imageURL;

  CertificateModel(
      {required this.name, required this.provideBy, 
      required this.date, required this.imageURL});
}

class UserProfileModel {
  final String name;
  final String emailId;
  final String userName;
  final int age;
  final String gender;
  

  UserProfileModel(
      {required this.name,
      required this.emailId,
      required this.userName,
      required this.age,
      required this.gender});
}
