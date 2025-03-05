// import 'dart:convert'; // Import this for jsonDecode
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import '../../utils/app_utils.dart';
// import '../constants/api_urls.dart';
// import '../screens/BottomNavigationScreen/bottom_navigation.dart';

// class LoginService {
//   static Future<String> login(String number, String enteredOtp, BuildContext context) async {
//     final hasNetwork = await AppUtils.hasInternet();
//     if (hasNetwork) {
//       try {
//         final url = Uri.parse(ApiUrls.verifyOtp());
//         debugPrint('login url: ${ApiUrls.verifyOtp()}');
//         final body = {"mobile": number, "otp": enteredOtp};
//         debugPrint('login body: $body');
//         final response = await http.post(url, body: body);

//         if (response.statusCode == 200) {
//           // Navigate to bottom navigation screen upon success
//           AppUtils.navigateTo(context, const AdminBottomNavigation(selectedIndex: 0)); // Log and return response
//           debugPrint("login response----${response.body.toString()}");
//           return response.body.toString();
//         } else if (response.statusCode == 500) {
//           debugPrint("Server Down: ${response.body.toString()}");
//           if (context.mounted) {
//             AppUtils.showInSnackBarNormal('status code: 500 - Server Down', context);
//           }
//           return '';
//         } else if (response.statusCode == 400 || response.statusCode == 401) {
//           // Decode the response body to access the message
//           final decodedResponse = jsonDecode(response.body);
//           final errorMessage = decodedResponse["message"] ?? "Unknown error"; // Safely access the message field

//           if (context.mounted) {
//             AppUtils.showInSnackBarNormal(errorMessage, context);
//           }
//           return '';
//         }
//       } catch (e) {
//         if (context.mounted) {
//           AppUtils.showInSnackBarNormal("login response----${e.toString()}", context);
//         }
//         return e.toString();
//       }
//     } else {
//       return 'No internet connection';
//     }
//     return '';
//   }
// }
