import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:holidays/screens/companyauth/companyLogin.dart';
import 'package:holidays/screens/dashboard.dart';

import 'package:holidays/screens/home.dart';
import 'package:holidays/screens/companyauth/forgotpass.dart';
import 'package:holidays/screens/userauth/forgotpass.dart';
import 'package:holidays/screens/userauth/login.dart';
import 'package:holidays/screens/userauth/signup.dart';
import 'package:google_fonts/google_fonts.dart';
// ...
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:holidays/tst.dart';
import 'package:holidays/viewmodel/company/compuserviewmodel.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // var directory = await getApplicationDocumentsDirectory();
  //   Hive.init(directory.path);
  await Hive.initFlutter();
  await Hive.openBox('box');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => CompanyViewModel(),
          )
        ],
        child: MaterialApp(
          builder: EasyLoading.init(),
          title: 'Flutter Demo',
          theme: ThemeData(
            fontFamily: GoogleFonts.poppins().fontFamily,
          ),
          home: CompanyLoginPage(),
          routes: {
            EmpForgitPassword.idScreen: (context) => EmpForgitPassword(),
            EmpLoginPage.routeName: (context) => EmpLoginPage(),
            SignupPage.idScreen: (context) => SignupPage(),
            HomePage.routeName: (context) => HomePage()
          },
        ));
  }
}
