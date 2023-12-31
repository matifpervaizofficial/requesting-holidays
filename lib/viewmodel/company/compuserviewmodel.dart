// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:holidays/screens/companyauth/companydashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../models/company/compusermodel.dart';
import '../../screens/companyauth/otp.dart';
import '../../widget/popuploader.dart';

class CompanyViewModel extends ChangeNotifier {
  CompanyUser? _user;
  String? _token;
  String? _logoUrl;

  CompanyUser? get user => _user;
  String? get token => _token;
  String? get logoUrl => _logoUrl;

  Future<void> performLogin(
      String email, String password, BuildContext context) async {
    const String apiUrl = 'https://jporter.ezeelogix.com/public/api/login';
    const String imgurl = "https://jporter.ezeelogix.com/public/upload/logo/";

    PopupLoader.show();

    final response = await http.post(Uri.parse(apiUrl),
        body: {'email': email, 'password': password, 'user_type': '1'});
    PopupLoader.hide();

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      if (jsonData['status'] == 'Success') {
        final userJson = jsonData['data']['user'];
        final token = jsonData['data']['token'];
        //final logoUrl = jsonData['data']['user']['logo'];

        _user = CompanyUser.fromJson(userJson);
        _token = token;
        _logoUrl = '$imgurl';

        // Store data in shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', _token!);
        // Serialize and store user object if needed
        print(jsonData);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CompanyDashBoard()),
        );
        notifyListeners();
      } else {
        // Login failed
        String errorMessage = jsonData['message'];
        Fluttertoast.showToast(
          msg: errorMessage,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        print('Login failed');
      }
    } else {
      Fluttertoast.showToast(
        msg: "Verify your email",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CompanyOtpScreen(email: email),
        ),
      );
      print(response);
      print('Error: ${response.reasonPhrase}');

      // Error occurred
      print('Error: ${response.reasonPhrase}');
    }
  }

  // Future<void> retrieveUserDataFromSharedPreferences() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   _token = prefs.getString('token');
  //   // Retrieve and deserialize user object if stored

  //   // Notify listeners about the updated data
  //   notifyListeners();
  // }
  Future<void> retrieveUserDataFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    // Retrieve and deserialize user object if stored

    if (_token != null && _token!.isNotEmpty) {
      // User is already logged in, fetch user data if needed
      // Set the user object based on the fetched data
      // _user = ...

      // Notify listeners about the updated data
      notifyListeners();
    }
  }

  Future<void> retrieveUserDataFromHive() async {
    await Hive.openBox('loginBox');
    var loginBox = Hive.box('loginBox');
    _token = loginBox.get('token') as String?;

    // Notify listeners about the updated data
    notifyListeners();
  }

  Future<void> signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    // Clear any other stored user data if needed

    _user = null;
    _token = null;

    // Notify listeners about the updated data
    notifyListeners();
  }
}
