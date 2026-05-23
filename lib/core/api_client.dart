import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:kids_learning_flutter_app/core/notify_data.dart';
import 'package:kids_learning_flutter_app/providers/session_provider.dart';

class ApiClient {
  static const baseUrl = 'http://yehoshoualevivant.com/learn4kids';

  static Future<String> createPaymentIntent(int amount) async {

    print('CreatePaymentIntent 011111111111');
    print("${baseUrl}/create_payment_intent.php");
    print(jsonEncode({'amount': amount}));
    final response = await http.post(
    Uri.parse("${baseUrl}/create_payment_intent.php"),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'amount': amount}),
  );

    print('CreatePaymentIntent 022222222222');
    print(response);
    print('CreatePaymentIntent 0333333333333');
    print(jsonDecode(response.body));
  final data = jsonDecode(response.body);
  return data['clientSecret'];
}

  static Future<dynamic> get(String path) async {
    final res = await http.get(Uri.parse('$baseUrl$path'));
    return jsonDecode(res.body);
  }

  static Future<void> delete(String path) async {
    await http.delete(Uri.parse('$baseUrl$path'));
  }
  /*
    static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/account/login");
    print("$baseUrl/account/login");
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "login": email,
          "password": password,
          "role":"parent"
        }),
      );

      final data = jsonDecode(response.body);
      print(data);

      if (response.statusCode == 200) {
        print('login success'); print(data);
        return data;

      } else {
        print('SSSSSSSSSSSSSSSSSSSS');
        throw Exception(data["message"] ?? "Login failed");
      }
    } catch (e) {
      print('ZZZZZZZZZ');
      throw Exception("Connection error: $e");
    }
  }*/

  static Future<dynamic> post(String path, Map body) async {
    try {
      String token = SessionProvider.token != null
          ? SessionProvider.token!
          : '';
      //print(token);
      print('$baseUrl$path');
      /*dynamic top = {'Content-Type': 'application/json',
          if (token != '') "Authorization": "Bearer $token",
        };
      print(top);*/
      print(jsonEncode(body));
      final res = await http.post(
        Uri.parse('$baseUrl$path'),
        headers: {
          'Content-Type': 'application/json',
          if (token != '') "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );
      /*print('====================================================');
      print('');
      print(res.body);
      print('');
      print('====================================================');*/
      //print(SessionProvider.token);
      print('999999999999999999999999999999999999999999999999999999999999999');
      print(res.body);
      print('888888888888888888888888888888888888888888888888888888888888888');
      final dataResult = jsonDecode(res.body);
      print('777777777777777777777777777777777777777777777777777777777777777');
      return dataResult;
    } catch (e) {
      print(e);
    }
    /*final res = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );*/
    print('after the call');
    print('json result');
  }

  static Future<dynamic> postMultipart(
    String path,
    Map<String, String> fields,
    Uint8List fileBytes,
    String fileName,
  ) async {
    try {
      String token = SessionProvider.token ?? '';

      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl$path'));

      if (token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add form fields
      request.fields.addAll(fields);

      // Add file
      request.files.add(
        http.MultipartFile.fromBytes('audio', fileBytes, filename: fileName),
      );
      print('sssssssssssssssssssssssssssssssssssssss');
      var streamedResponse = await request.send();
      print('dddddddddddddddddddddddddddddddddddddd');
      var response = await http.Response.fromStream(streamedResponse);
      print('qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq');
      print(response.body);
      return jsonDecode(response.body);
    } catch (e) {
      print(e);
    }
  }
}
