import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/profile.model.dart';

class ProfileProvider {
  static ProfileProvider get shared => ProfileProvider();

  Future<MentorProfileModel> getProfile(String userId, String usertoken) async {

    int userid = int.parse(userId);
    final response =
        await http.get(Uri.parse('http://localhost:8080/api/mentors/$userid'),
            headers: {
              "content-type": "application/json",
              'Authorization': 'Bearer $usertoken'},
        );

    var parsed = response.body;
    Map<String, dynamic> map = jsonDecode(parsed);

    List<dynamic> expe = map['experiences'];
    List<WorkExperienceModel> expes = [];

    for (var experience in expe) {
      Map<String, dynamic> exp = experience as Map<String, dynamic>;

      WorkExperienceModel model = WorkExperienceModel(
        company: exp['company_name'] ?? 'Unknown Company',
        jobTitle: exp['role'] ?? 'Unknown Role',
        period: '${exp['start_date'] ?? 'Unknown Start'} to ${exp['end_date'] ?? 'Unknown End'}',
      );
      expes.add(model);
    }

    List<dynamic> category = map['categories'];
    List<String> categories = [];

    for (var cate in category) {
      Map<String, dynamic> ca = cate as Map<String, dynamic>;
      categories.add(ca['name']?? '');
    }
    List<dynamic> cert = map['certificates'];
    List<CertificateModel> certificate = [];

    for (var certifi in cert) {
      Map<String, dynamic> ce = certifi as Map<String, dynamic>;

      CertificateModel model = CertificateModel(
        name: ce['name'] ?? '',
        provideBy: ce['provide_by'] ?? '',
        date: ce['create_date'] ?? '',
        imageURL: ce['image_url'] ?? '',
      );
      certificate.add(model);
    }
    
    return MentorProfileModel(
      name: map['name'],
      avatar: map['avatarUrl'],
      title: map['role'],
      about:map['bio'],
      experiences: expes,
      skills: categories,
      certificates: certificate,
    );
  }

  Future<UserProfileModel> getUserProfile(String userId, String usertoken) async {
    int userid = int.parse(userId);
    final response =
        await http.get(Uri.parse('http://localhost:8080/api/user/profile/$userid'),
            headers: {"content-type": "application/json",
            'Authorization': 'Bearer $usertoken'},
            );

    var parsed = response.body;
    Map<String, dynamic> map = jsonDecode(parsed);
      return UserProfileModel(
            name: map['name'],
            emailId: map['emailId'],
            userName: map['userName'],
            age: map['age'],
            gender:map['gender']);
    }
}
