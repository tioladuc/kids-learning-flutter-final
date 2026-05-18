import 'package:kids_learning_flutter_app/providers/course_provider.dart';

import '../core/api_client.dart';
import '../models/child.dart';
import '../models/course.dart';
import '../models/course_statistics.dart';
import 'session_base.dart';

class InnerStatistic {
  final int id;
  final String childId;
  final String courseCode;
  final int idItemCourse;
  final int timeSpent;
  final DateTime lastConnection;
  final String courseName;

  InnerStatistic({
    required this.id,
    required this.childId,
    required this.courseCode,
    required this.idItemCourse,
    required this.timeSpent,
    required this.lastConnection,
    required this.courseName,
  });

  factory InnerStatistic.fromJson(Map<String, dynamic> json) {
    return InnerStatistic(
      id: json["id"],
      childId: json["child_id"],
      courseCode: json["course_code"],
      idItemCourse: json["id_item_course"],
      timeSpent: json["time_spent"],
      lastConnection: DateTime.parse(json["last_connection"]),
      courseName: json["course_name"],
    );
  }
}
///////////////////////////////////////////////////

class StatisticsProvider extends SessionBase {
  bool isLoading = false;
  String? errorMessage;

  String? lastConnectionTime;
  String? lastConnectionDuration;

  List<VisitedCourse> visitedCourses = [];
  List<Course> completedCourses = [];
  List<NeverDoneCourse> neverDoneCourses = [];

  List<CourseStatistics> courseStatistics = [];

  Future<Child> loadStatistics(Child child) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    Child statusResponse = Child(id: '', login: '', name: '', password: '', passwordraw: '', level:'', codeparent: '');
    try {
      final response = await ApiClient.post('/statistics/loadVisitedCourses', {
        "child_id": child.id,
      });
      //Map<String, dynamic> response = {'success': true,};
      print(response['success']);
      // ✅ Example: handle response
      if (response['success'] == true) {
        //print(response);
        List<InnerStatistic> statistics = List<InnerStatistic>.from(
          response["data"].map((e) => InnerStatistic.fromJson(e)),
        );
        print(
          '99999999999999999999999999999999999 = ' +
              statistics.length.toString(),
        );
        //print(response);
        lastConnectionTime = '';
        lastConnectionDuration = '';
        DateTime? latestDate;

        if (statistics.isNotEmpty) {
          latestDate = statistics
              .map((e) => e.lastConnection)
              .reduce((a, b) => a.isAfter(b) ? a : b);
          lastConnectionTime = latestDate.toString();
          lastConnectionDuration = statistics
              .where(
                (s) =>
                    s.lastConnection.year == latestDate!.year &&
                    s.lastConnection.month == latestDate.month &&
                    s.lastConnection.day == latestDate.day,
              )
              .fold(0, (sum, s) => sum + s.timeSpent)
              .toString();
          child.completedTasks = statistics
              .where((e) => e.idItemCourse != 0)
              .length;
          child.totalTasks = statistics.length;
          final int totalTimeMinutes = statistics.fold(
            0,
            (sum, s) => sum + s.timeSpent,
          );
          child.totalTimeMinutes = totalTimeMinutes;
          List<String> dates = [];
          statistics.forEach(
            (x) => dates.add(
              x.lastConnection.year.toString() +
                  '-' +
                  x.lastConnection.month.toString() +
                  '-' +
                  x.lastConnection.day.toString(),
            ),
          );
          child.streakDays = dates.toSet().length;
        }
        lastConnectionDuration = lastConnectionDuration! + ' min';
        /*******************/
        final courseProvider = CourseProvider();
        await courseProvider.loadChildPendingCourses(child.id);
        await courseProvider.loadChildAvailableCourses(child.id);
        List<Course> coursesAll = courseProvider.availableCourses;
        for (Course course in courseProvider.pendingCourses) {
          if (!coursesAll.any((t) => t.code == course.code)) {
            coursesAll.add(course);
          }
        }
        neverDoneCourses.clear();
        for (var c in coursesAll) {
          if(!statistics.any((t)=>t.courseCode==c.code)){
            neverDoneCourses.add(NeverDoneCourse(c, DateTime.now()));
          }
          else {
            final lastDateT = statistics
              .where((element) => element.courseCode==c.code).toList();
            DateTime t = lastDateT.elementAt(0).lastConnection;
            for (var elt in lastDateT) {
              t = t.isBefore(elt.lastConnection) ? elt.lastConnection : t;
            }

            final total = statistics.where((element) => element.courseCode==c.code).fold(0, (sum, s) => sum + s.timeSpent);
            visitedCourses.add(VisitedCourse(c, total, t));
           }
        }
      } else {
        errorMessage = SessionBase.translator.getText(
          'GetBasicInformationError',
        );
        //statusResponse = false;
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
      return child;
    }
  }

  Future<Child> getBasicInformation(Child child) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    Child statusResponse = Child(id: '', login: '', name: '', password: '', passwordraw: '', level:'', codeparent: '');
    try {
      final response = await ApiClient.post('/statistics/getBasicInformation', {
        "childid": child.id,
      });
      //Map<String, dynamic> response = {'success': true,};

      // ✅ Example: handle response
      if (response['success'] == true) {
        //statusResponse = true;
      } else {
        errorMessage = SessionBase.translator.getText(
          'GetBasicInformationError',
        );
        //statusResponse = false;
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
      return statusResponse;
    }
  }

  Future<bool> loadVisitedCourses(Child childId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    bool statusResponse = false;
    try {
      final response = await ApiClient.post('/statistics/loadVisitedCourses', {
        "childid": childId,
      });
      //Map<String, dynamic> response = {'success': true,};

      // ✅ Example: handle response
      if (response['success'] == true) {
        statusResponse = true;
      } else {
        errorMessage = SessionBase.translator.getText(
          'LoadVisitedCoursesError',
        );
        statusResponse = false;
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
      return statusResponse;
    }
  }

  Future<bool> loadCompletedCourses(Child childId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    bool statusResponse = false;
    try {
      final response = await ApiClient.post(
        '/statistics/loadCompletedCourses',
        {"childid": childId},
      );
      //Map<String, dynamic> response = {'success': true,};

      // ✅ Example: handle response
      if (response['success'] == true) {
        statusResponse = true;
      } else {
        errorMessage = SessionBase.translator.getText(
          'LoadCompletedCoursesError',
        );
        statusResponse = false;
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
      return statusResponse;
    }
  }

  Future<bool> loadNeverDoneCourses(Child childId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    bool statusResponse = false;
    try {
      final response = await ApiClient.post(
        '/statistics/loadNeverDoneCourses',
        {"childid": childId},
      );
      //Map<String, dynamic> response = {'success': true,};

      // ✅ Example: handle response
      if (response['success'] == true) {
        statusResponse = true;
      } else {
        errorMessage = SessionBase.translator.getText(
          'LoadNeverDoneCoursesError',
        );
        statusResponse = false;
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
      return statusResponse;
    }
  }

  Future<bool> loadCourseStatistics(Child childId, Course courseId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    bool statusResponse = false;
    try {
      final response = await ApiClient.post(
        '/statistics/loadCourseStatistics',
        {"childid": childId, "courseid": courseId},
      );
      //Map<String, dynamic> response = {'success': true,};

      // ✅ Example: handle response
      if (response['success'] == true) {
        statusResponse = true;
      } else {
        errorMessage = SessionBase.translator.getText(
          'LoadCourseStatisticsError',
        );
        statusResponse = false;
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
      return statusResponse;
    }
  }
}
