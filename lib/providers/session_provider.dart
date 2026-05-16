import 'dart:convert';

import 'package:kids_learning_flutter_app/providers/course_provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../core/api_client.dart';
import '../core/notify_data.dart';
import '../models/child.dart';
import '../models/news.dart';
import '../models/parent.dart';
import '../models/payment_model.dart';
import 'session_base.dart';

class SessionProvider extends SessionBase {
  String? role = null; // parent | child   NOT Used

  Child? tmpChild;
  Parent? tmpParent;
  bool get isLoggedIn => (role != null && (child != null || parent != null));

  List<News> latestNews = [];

  List<Child> children = [];
  bool isLoadingChildren = true;

  List<PaymentModel> paidPayments = [];
  List<PaymentModel> upcomingPayments = [];
  bool isLoadingPayments = false;

  static Child? child;
  static Parent? parent;
  static String? token = null;

  bool isLoading = false;
  bool isActivationCodeSending = false;
  String? errorMessage;
  bool isLoginLoading = false;

  SessionProvider() {}

  

  void setCurrentChildAsParent(Child? child) {
    parent!.currentChild = child;
    SessionProvider.child = child;
    CourseProvider.hasChargedAvailable = false;
    notifyListeners();
  }

  void setRole(String? currentRole) {
    role = currentRole;
    notifyListeners();
  }

  void setParent(Parent? value) {
    parent = value;
    notifyListeners();
  }

  void setChild(Child? value) {
    child = value;
    notifyListeners();
  }

  Future<bool> logout() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    bool statusResponse = false;
    try {
      final response = await ApiClient.post('/account/logout', {
        "child_id": child?.id,
        "parent_id": parent?.id,
      });
      //Map<String, dynamic> response = {'success': true,};

      // ✅ Example: handle response
      if (response['success'] == true) {
        statusResponse = true;
        role = null;
        SessionProvider.token = null;
        SessionProvider.child = null;
        SessionProvider.parent = null;
      } else {
        errorMessage = SessionBase.translator.getText('LogoutError');
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

  Future<bool> login(String selectedRole, String login, String pwd) async {
    isLoginLoading = true;
    errorMessage = null;
    notifyListeners();

    bool statusResponse = false;
    try {
      final response = await ApiClient.post('/account/login', {
        "role": selectedRole,
        "login": login,
        "password": pwd,
      });
      //Map<String, dynamic> response = {'success': true,};

      // ✅ Example: handle response
      if (response['success'] == true) {
        role = selectedRole;
        statusResponse = true;
        print('888888888888888888888888888888888888888888');
        if (selectedRole == NotifyData.ChoiceParent) {
          initializeLoginParent(response['data']);
          for (var element in children) {
            print('==========­>>> ' + element.passwordraw);
          }
        } else {
          initializeLoginChild(response['data']);
        }

      } else {
        print('login fail passed');
        errorMessage = SessionBase.translator.getText(
          selectedRole == NotifyData.ChoiceChild
              ? 'ChildLoginError'
              : 'ParentLoginError',
        );
        statusResponse = false;
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoginLoading = false;
      notifyListeners();
      return statusResponse;
    }
  }

  void initializeLoginParent(dynamic result) {
    String token = result["token"];

    // ==========================
    // BUILD CHILDREN LIST
    // ==========================

    List<Child> childrenList = [];

    for (var childJson in result["children"]) {
      childrenList.add(
        Child(
          id: childJson["id"],
          name: childJson["name"],
          login: childJson["login"],
          password: childJson["passwordraw"], 
          passwordraw: childJson["passwordraw"],// password not returned from API
        )..parentResponsible = childJson["parent_responsible"] == 1,
      );
    }

    // ==========================
    // BUILD PARENT
    // ==========================

    var parentJson = result["parent"];

    Parent parent = Parent(
      id: parentJson["id"],
      name: "${parentJson["first_name"]} ${parentJson["last_name"]}",
      login: parentJson["login"],
      password: "", 
      passwordraw: '',// not returned from API
      children: childrenList,
    );

    // Extra fields
    parent.firstName = parentJson["first_name"];
    parent.lastName = parentJson["last_name"];
    parent.email = parentJson["email"];

    SessionProvider.child = null;
    SessionProvider.parent = parent;
    SessionProvider.token = token;
    for (var child in childrenList) {
      print('=============>>>> ' + child.passwordraw);
    }
    print('77777777777777777777777777777777777777777');
  }

  void initializeLoginChild(dynamic result) {
    String token = result["token"];

    var childJson = result["child"];

    Child child = Child(
      id: childJson["id"],
      name: childJson["name"],
      login: childJson["login"],
      passwordraw: childJson["passwordraw"] ?? '',
      password: childJson["passwordraw"] ?? '', // not returned from API
    );

    // set optional values
    child.parentResponsible = childJson["parent_responsible"] == 1;

    SessionProvider.child = child;
    SessionProvider.parent = null;
    SessionProvider.token = token;
  }

  Future<bool> addChild(String login, String name, String pwd) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    bool statusResponse = false;
    try {
      final response = await ApiClient.post('/account/addChild', {
        "name": name,
        "login": login,
        "password": pwd,
        "parent_id": parent!.id,
      });
      //Map<String, dynamic> response = {'success': true,};

      // ✅ Example: handle response
      if (response['success'] == true) {
        statusResponse = true;
        parent?.children.add(
          Child(
            id: DateTime.now().toString(),
            name: name,
            login: login,
            password: pwd,
            passwordraw: pwd,
          ),
        );
      } else {
        errorMessage = SessionBase.translator.getText('AddChildToParentError');
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

  Future<bool> deleteChild(String id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    bool statusResponse = false;
    try {
      final response = await ApiClient.post('/account/deleteChild', {
        "child_id": id,
        "parent_id": parent!.id,
      });
      //Map<String, dynamic> response = {'success': true,};

      // ✅ Example: handle response
      if (response['success'] == true) {
        statusResponse = true;
        parent?.children.removeWhere((c) => c.id == id);
      } else {
        errorMessage = SessionBase.translator.getText(
          'DeleteChildToParentError',
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

  Future<bool> changeParentPassword(
    String firstName,
    String lastName,
    String newPassword,
  ) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    bool statusResponse = false;
    try {
      final response = await ApiClient.post('/account/changeParentPassword', {
        "first_name": firstName,
        "last_name": lastName,
        "new_password": newPassword,
        "parent_id": parent!.id,
      });
      //Map<String, dynamic> response = {'success': true,};

      // ✅ Example: handle response
      if (response['success'] == true) {
        statusResponse = true;
        parent?.firstName = firstName;
        parent?.lastName = lastName;
        parent?.password = newPassword;
      } else {
        errorMessage = SessionBase.translator.getText(
          'ChangeParentPasswordError',
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

  Future<bool> changeChildPassword(String name, String newPassword) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    bool statusResponse = false;
    try {
      final response = await ApiClient.post('/account/changeChildPassword', {
        "name": name,
        "new_password": newPassword,
        "child_id": child?.id,
        "parent_id": parent!.id,
      });
      //Map<String, dynamic> response = {'success': true,};

      // ✅ Example: handle response
      if (response['success'] == true) {
        statusResponse = true;
        child?.name = name;
        child?.password = newPassword;
      } else {
        errorMessage = SessionBase.translator.getText(
          'ChangePwdChildToParentError',
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

  Future<bool> changePasswordParentChild(
    String name,
    String newPassword,
    Child child,
  ) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    bool statusResponse = false;
    try {
      final response =
          await ApiClient.post('/account/changePasswordParentChild', {
            "name": name,
            "new_password": newPassword,
            "child_id": child.id,
            "parent_id": parent!.id,
          });
      //Map<String, dynamic> response = {'success': true,};

      // ✅ Example: handle response
      if (response['success'] == true) {
        statusResponse = true;
        parent?.children.firstWhere((element) => element.id == child.id).name =
            name;
        parent?.children
                .firstWhere((element) => element.id == child.id)
                .password =
            newPassword;
      } else {
        errorMessage = SessionBase.translator.getText(
          'ChangePwdChildToParentError',
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

  ///////////////////////////////////////////////////////////////////

  /// CREATE ACCOUNT
  Future<bool> createParentAccount({
    required String firstName,
    required String lastName,
    required String login,
    required String password,
    required String email,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    bool statusResponse = false;
    try {
      final response = await ApiClient.post('/createParent', {
        "first_name": firstName,
        "last_name": lastName,
        "login": login,
        "password": password,
        "email": email,
      });
      //Map<String, dynamic> response = {'success': true,};

      // ✅ Example: handle response
      if (response['success'] == true) {
        statusResponse = true;
      } else {
        print(response);
        errorMessage = SessionBase.translator.getText('CreateParentError');
        statusResponse = false;
      }
    } catch (e) {
      errorMessage = e.toString();
      print(e);
    } finally {
      isLoading = false;
      notifyListeners();
      return statusResponse;
    }
  }

  /// ACTIVATE ACCOUNT
  Future<bool> activateParentAccount({
    required String email,
    required String code,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    bool statusResponse = false;
    try {
      final response = await ApiClient.post('/account/activateParent', {
        "email": email,
        "code": code,
      });
      //Map<String, dynamic> response = {'success': true,};

      // ✅ Example: handle response
      if (response['success'] == true) {
        statusResponse = true;
      } else {
        errorMessage = SessionBase.translator.getText(
          'ActivateParentAccountError',
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

  /// RESEND ACTIVATION CODE ACCOUNT
  Future<bool> resendActivationCode({required String email}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    bool statusResponse = false;
    try {
      final response = await ApiClient.post(
        '/account/sendActivationCodeParent',
        {"email": email},
      );
      //Map<String, dynamic> response = {'success': true,};

      // ✅ Example: handle response
      if (response['success'] == true) {
        statusResponse = true;
      } else {
        errorMessage = SessionBase.translator.getText(
          'SendActivationCodeParentError',
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

  /// SEND RESET CODE
  Future<bool> sendResetCode({required String email}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    bool statusResponse = false;
    try {
      final response = await ApiClient.post(
        '/account/sendActivationCodeParent',
        {"email": email},
      );
      //Map<String, dynamic> response = {'success': true,};

      // ✅ Example: handle response
      if (response['success'] == true) {
        statusResponse = true;
      } else {
        errorMessage = SessionBase.translator.getText(
          'SendActivationCodeParentError',
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

  void _start() {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
  }

  void _end() {
    isLoading = false;
    notifyListeners();
  }

  /// RESET PASSWORD
  Future<bool> setParentAsReponsibleOfChild({
    required bool isResponsible,
    required Child child,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    bool statusResponse = false;
    try {
      final response = await ApiClient.post(
        '/account/setParentAsResponsibleOfChild',
        {"parent_id": parent!.id, "child_id": child.id},
      );
      //Map<String, dynamic> response = {'success': true,};

      // ✅ Example: handle response
      if (response['success'] == true) {
        statusResponse = true;
      } else {
        errorMessage = SessionBase.translator.getText(
          'SetParentAsResponsibleOfChildError',
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

  /// RESET PASSWORD
  Future<bool> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    bool statusResponse = false;
    try {
      final response = await ApiClient.post('/account/resetParentPassword', {
        "parent_id": parent!.id,
        "email": email,
        "code": code,
      });
      //Map<String, dynamic> response = {'success': true,};

      // ✅ Example: handle response
      if (response['success'] == true) {
        statusResponse = true;
      } else {
        errorMessage = SessionBase.translator.getText(
          'ResetParentPasswordError',
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

  ///////////////////////////////////////////////////////////////////
  Future<void> loadChildren() async {
    isLoadingChildren = true;
    errorMessage = null;
    notifyListeners();

    bool statusResponse = false;
    try {
      final response = await ApiClient.post('/account/parentLoadChildren', {
        "parent_id": parent!.id,
      });
      //Map<String, dynamic> response = {'success': true,};

      // ✅ Example: handle response
      if (response['success'] == true) {
        print('OK OK');
        List<Child> childrenList = (response["data"] as List)
            .map((e) => Child.fromJson(e))
            .toList();

        children = childrenList;
        print('OK OK =­> ' +children.length.toString());
        statusResponse = true;
      } else {
        errorMessage = SessionBase.translator.getText(
          'ParentLoadChildrenError',
        );
        statusResponse = false;
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoadingChildren = false;
      notifyListeners();
      return;
    }
  }

  Future<void> getLatestNews() async {
    // fetch from API
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    bool statusResponse = false;
    try {
      final response = await ApiClient.post('/account/getLatestNews', {
        "parentid": parent!.id,
      });
      //Map<String, dynamic> response = {'success': true,};

      // ✅ Example: handle response
      if (response['success'] == true) {
        statusResponse = true;
      } else {
        errorMessage = SessionBase.translator.getText('GetLatestNewsError');
        statusResponse = false;
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
      return;
    }
  }

  Future<void> sendEmail({
    required String subject,
    required String category,
    required String content,
  }) async {
    // call backend or email service
  }

  Future<void> loadPayments() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    bool statusResponse = false;
    try {
      print('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');
      final response = await ApiClient.post('/account/loadPayment', {
        "parent_id": parent!.id,
      });
      print('FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF');
      //Map<String, dynamic> response = {'success': true,};
      print(response);
      print('WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW');
      // ✅ Example: handle response
      if (response['success'] == true) {
        // Amount possitive is for pay transactions and negative one is to be expected
        print('DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD');
        List<PaymentModel> data = (response["data"] as List<dynamic>)
            .map((e) => PaymentModel.fromJson(e as Map<String, dynamic>))
            .toList();
        print('ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZz');
        paidPayments = data.where((x)=>x.amount >= 0).toList();
        upcomingPayments = data.where((x)=>x.amount < 0).toList();
        statusResponse = true;
      } else {
        errorMessage = SessionBase.translator.getText('LoadPaymentError');
        statusResponse = false;
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
      return;
    }
  }
}
