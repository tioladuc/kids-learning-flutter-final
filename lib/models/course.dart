class Course {
  final String code;
  final String name;
  final double amount;
  final DateTime? expiryDate;
  final String validity; // "1 month", "1 year", "1 term"
  final bool isRegistered;
  final String description;
  String? url;
  String? level;

  Course({
    required this.code,
    required this.name,
    required this.amount,
    this.expiryDate,
    required this.validity,
    required this.isRegistered,
    required this.description,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    Course course = Course(
      code: json["code"],
      name: json["name"],
      amount: double.parse(json["amount"].toString()),
      validity: json["validity"],
      description: json["description"],
      
      expiryDate: null,
      isRegistered: false,
    );
    course.url = json["url"]??'';
    course.level = json["level"] ?? '';
    return course;
  }
  
}

//////////////////////////////////////////////
class VisitedCourse {
  final Course course;
  final int timeSpent;
  final DateTime lastDateConnection;

  VisitedCourse(this.course, this.timeSpent, this.lastDateConnection);
}

class NeverDoneCourse {
  final Course course;
  final DateTime pickedDate;

  NeverDoneCourse(this.course, this.pickedDate);
}

