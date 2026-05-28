import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:kids_learning_flutter_app/providers/session_provider.dart';

import '../core/api_client.dart';
import '../models/course.dart';
import 'session_base.dart';

class CourseProvider extends SessionBase {
  bool isLoading = false;
  bool isLoadingAvailable = false;
  bool isLoadingPickCourse = false;
  bool isLoadingPending = false;
  bool isLoadingPayCourse = false;
  bool isLoadingRemove = false;
  bool isLoadingPickCourseAction = false;
  String? errorMessage;

  static bool hasChargedAvailable = false;

  List<Course> pendingCourses = [];
  List<Course> pickCourses = [];
  List<Course> availableCourses = [];

  static Future<void> startWebUrlCourse(String code) async{
     final response = await ApiClient.post('/course/urlCourseEntering', {
        "child_id": SessionProvider.child!.id,
        "course": code,
      });

      if (response['success'] == true) {
        SessionProvider.child!.name += response['data']['message'];
      }
      else{
        SessionProvider.child!.name += "error";
      }
  }
  static Future<void> endWebUrlCourse(String code) async{
     final response = await ApiClient.post('/course/urlCourseLeaving', {
        "child_id": SessionProvider.child!.id,
        "course": code,
      });

      if (response['success'] == true) {
        SessionProvider.child!.name += response['data']['message'];
      }
      else{
        SessionProvider.child!.name += "error";
      }
  }

  Future<bool> loadChildPendingCourses(String childId) async {
    isLoadingPending = true;
    errorMessage = null;
    notifyListeners();

    bool statusResponse = false;
    try {
      final response = await ApiClient.post('/course/loadChildPendingCourses', {
        "child_id": childId,
      });
      //Map<String, dynamic> response = {'success': true,};

      // ✅ Example: handle response
      if (response['success'] == true) {
        pendingCourses = [];
        for (var item in response["data"]) {
          pendingCourses.add(Course.fromJson(item));
        }
        statusResponse = true;
      } else {
        errorMessage = SessionBase.translator.getText(
          'LoadChildPendingCoursesError',
        );
        statusResponse = false;
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoadingPending = false;
      notifyListeners();
      return statusResponse;
    }
  }

  Future<bool> loadChildAvailableCourses(String childId) async {
    //if(hasChargedAvailable) return true;
    isLoadingAvailable = true;
    errorMessage = null;
    notifyListeners();

    bool statusResponse = false;
    try {
      final response = await ApiClient.post(
        '/course/loadChildAvailableCourses',
        {"child_id": childId},
      );
      //Map<String, dynamic> response = {'success': true,};

      // ✅ Example: handle response
      if (response['success'] == true) {
        availableCourses = [];
        for (var item in response["data"]) {
          availableCourses.add(Course.fromJson(item));
        }
        //print(childId);
        hasChargedAvailable = true;
        statusResponse = true;
      } else {
        errorMessage = SessionBase.translator.getText(
          'LoadChildPendingCoursesError',

          ///Duclair change the constant
        );
        statusResponse = false;
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoadingAvailable = false;
      notifyListeners();
      return statusResponse;
    }
  }

  Future<bool> loadChildPickCourses(String childId) async {
    isLoadingPickCourse = true;
    errorMessage = null;
    notifyListeners();

    bool statusResponse = false;
    try {
      final response = await ApiClient.post('/course/loadChildPickCourses', {
        "child_id": childId,
      });
      //Map<String, dynamic> response = {'success': true,};

      // ✅ Example: handle response
      if (response['success'] == true) {
        pickCourses = [];
        for (var item in response["data"]) {
          pickCourses.add(Course.fromJson(item));
        }
        statusResponse = true;
      } else {
        errorMessage = SessionBase.translator.getText(
          'LoadChildPickCoursesError',
        );
        statusResponse = false;
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoadingPickCourse = false;
      notifyListeners();
      return statusResponse;
    }
  }

  Future<bool> makePaymentStripe(int amount) async {
  try {
    print('the payment final WWWWW = ' + amount.toString());
    final clientSecret = await ApiClient.createPaymentIntent(amount); // $10
    print('the payment final PPPP');
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'Kids Learning App',
      ),
    );
    print('the payment final XXXX');
    await Stripe.instance.presentPaymentSheet();

    print("✅ Payment successful");
    return true;
  } catch (e) {
    print("❌ Payment failed: $e");
    return false;
  }
}

  Future<bool> payCourse({
    required String childId,
    required String courseCode,
    required double amount,
  }) async {
    isLoadingPayCourse = true;
    errorMessage = null;
    notifyListeners();

    bool statusResponse = false;
    try {

      print({
        "child_id": childId,
        "course_code": courseCode,
        "amount": amount,
      });
      print('payment begining');
      final response = await ApiClient.post('/course/payCourse', {
        "child_id": childId,
        "course_code": courseCode,
        "amount": amount,
      });
      //Map<String, dynamic> response = {'success': true,};

      print('Before payment 01');
      print(response);
      // ✅ Example: handle response
      if (response['success'] == true) {
        print('Before payment 02');
        statusResponse = true;
        loadChildAvailableCourses(childId);
      } else {
        print('Before payment 03 FAIL');
        errorMessage = SessionBase.translator.getText('PayCourseError');
        statusResponse = false;
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoadingPayCourse = false;
      notifyListeners();
      return statusResponse;
    }
  }

  Future<bool> removeCourse({
    required String childId,
    required String courseCode,
  }) async {
    isLoadingRemove = true;
    errorMessage = null;
    notifyListeners();

    bool statusResponse = false;
    try {
      final response = await ApiClient.post('/course/removeCourse', {
        "child_id": childId,
        "course_code": courseCode,
      });
      //Map<String, dynamic> response = {'success': true,};

      // ✅ Example: handle response
      if (response['success'] == true) {
        statusResponse = true;
        loadChildAvailableCourses(childId);
        loadChildPickCourses(childId);
        loadChildPendingCourses(childId);
      } else {
        errorMessage = SessionBase.translator.getText('RemoveCourseError');
        statusResponse = false;
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoadingRemove = false;
      notifyListeners();
      return statusResponse;
    }
  }

  Future<bool> pickCourse(String childId, String courseCode) async {
    isLoadingPickCourseAction = true;
    errorMessage = null;
    notifyListeners();

    bool statusResponse = false;
    try {
      final response = await ApiClient.post('/course/pickCourse', {
        "child_id": childId,
        "course_code": courseCode,
      });
      //Map<String, dynamic> response = {'success': true,};
      print(response);
      // ✅ Example: handle response
      if (response['success'] == true) {
        statusResponse = true;
        CourseProvider.hasChargedAvailable = false;
        loadChildAvailableCourses(childId);
        loadChildPickCourses(childId);
      } else {
        errorMessage = SessionBase.translator.getText('PickCourseError');
        statusResponse = false;
      }
    } catch (e) {
      print(e);
      errorMessage = e.toString();
    } finally {
      isLoadingPickCourseAction = false;
      notifyListeners();
      return statusResponse;
    }
    
  }
}
