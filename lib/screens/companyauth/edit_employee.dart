import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:holidays/screens/companyauth/showemployes.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:http/http.dart' as http;
import '../../models/company/viewemployeedata.dart';
import '../../viewmodel/company/compuserviewmodel.dart';
import '../../widget/constants.dart';
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class EditEmployee extends StatefulWidget {
  final Employee emp;
  final String email;
  final String first_name;
  final String last_name;
  final String mobile;

  const EditEmployee(
      {super.key,
      required this.emp,
      required this.email,
      required this.first_name,
      required this.last_name,
      required this.mobile});

  @override
  State<EditEmployee> createState() => _EditEmployeeState();
}

class _EditEmployeeState extends State<EditEmployee> {
  late StreamSubscription subscription;

  bool isDeviceConnected = false;
  bool isAlertSet = false;
  @override
  void initState() {
    getConnectivity();
    _nameFirst.text = widget.first_name;
    _nameLast.text = widget.last_name;
    _phone.text = widget.mobile;
    _email.text = widget.email;
    _totalLeaves.text = widget.emp.leaveQuota.toString();
    _hours.text = "20";

    super.initState();
    selectedDays = {
      0: widget.emp.days.sunday == 1,
      1: widget.emp.days.monday == 1,
      2: widget.emp.days.tuesday == 1,
      3: widget.emp.days.wednesday == 1,
      4: widget.emp.days.thursday == 1,
      5: widget.emp.days.friday == 1,
      6: widget.emp.days.saturday == 1,
    };
  }

  getConnectivity() =>
      subscription = Connectivity().onConnectivityChanged.listen(
        (ConnectivityResult result) async {
          isDeviceConnected = await InternetConnectionChecker().hasConnection;
          if (!isDeviceConnected && isAlertSet == false) {
            showDialogBox();
            setState(() => isAlertSet = true);
          }
        },
      );

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameFirst = TextEditingController();
  final TextEditingController _nameLast = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  final TextEditingController _totalLeaves = TextEditingController();
  final TextEditingController _hours = TextEditingController();
  Map<int, bool> selectedDays = {};
  bool obsCheck = false;
  bool obsCheck1 = false;
  String errMsg = "";
  bool isLoading = false;

  void editEmployeeInfo(String token, String id) async {
    setState(() {
      isLoading = true;
    });
    const String requestLeaveUrl =
        'https://jporter.ezeelogix.com/public/api/company-update-employee-data';

    final response = await http.post(Uri.parse(requestLeaveUrl), headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    }, body: {
      "company_id": id,
      "employee_id": widget.emp.id.toString(),
      "first_name": _nameFirst.text.trim(),
      "last_name": _nameLast.text.trim(),
      "email": _email.text.trim(),
      "phone": _phone.text,
      "password": _password.text,
      "password_confirmation": _confirmPassword.text,
      "total_leaves": _totalLeaves.text,
      "sunday": selectedDays[0]== true? "1":"0",
      "monday": selectedDays[1]== true? "1":"0",
      "tuesday": selectedDays[2]== true? "1":"0",
      "wednesday": selectedDays[3]== true? "1":"0",
      "thursday": selectedDays[4]== true? "1":"0",
      "friday": selectedDays[5]== true? "1":"0",
      "saturday": selectedDays[6]== true? "1":"0",
    });
    if (response.statusCode == 200) {
      // Leave request successful
      Fluttertoast.showToast(
          msg: "Employee Data Updated Successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);

      final jsonData = json.decode(response.body);
      print(jsonData);
      setState(() {
        isLoading = false;
      });

      Navigator.of(context).pop();
    } else {
      print(response.statusCode);
      // Error occurred
      Fluttertoast.showToast(
          msg: "Employee Data Could not Updated ",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);

      setState(() {
        isLoading = false;
      });
      print('Error: ${response.reasonPhrase}');
      // Handle error scenario
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // final screenheight = MediaQuery.of(context).size.height;
    // double fontSize;
    double title;
    //double heading;

    // Adjust the font size based on the screen width
    if (screenWidth < 320) {
      // fontSize = 11.0;
      title = 16;
      // heading = 10; // Small screen (e.g., iPhone 4S)
    } else if (screenWidth < 375) {
      //  fontSize = 12.0;
      title = 20;

      // heading = 12; // Medium screen (e.g., iPhone 6, 7, 8)
    } else if (screenWidth < 414) {
      //fontSize = 15.0;
      title = 22;

      // heading = 14; // Large screen (e.g., iPhone 6 Plus, 7 Plus, 8 Plus)
    } else if (screenWidth < 600) {
      //  fontSize = 19.0;
      title = 26;

      //  heading = 18; // Large screen (e.g., iPhone 6 Plus, 7 Plus, 8 Plus)
    } else {
      // fontSize = 22.0;
      title = 19;

      //  heading = 30; // Extra large screen or unknown device
    }

    Size size = MediaQuery.of(context).size;
    final comViewModel = Provider.of<CompanyViewModel>(context);
    final token = comViewModel.token;
    final user = comViewModel.user;
    final companyId = user!.id;
    return Scaffold(
        backgroundColor: appbar,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: appbar,
          leading: IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (ctx) => ShowEmployee()));
              },
              icon: const Icon(
                CupertinoIcons.left_chevron,
                color: Colors.black,
              )),
        ),
        body: SingleChildScrollView(
          child: SafeArea(
              child: SizedBox(
            width: size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Edit Employee Details",
                  style:
                      TextStyle(fontSize: title, fontWeight: FontWeight.bold),
                ).pOnly(left: 24),
                const SizedBox(
                  height: 25,
                ),
                Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameFirst,
                            // initialValue: widget.first_name ,
                            decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: Container(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        right: BorderSide(
                                            width: 1.0, color: Colors.black),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      color: red,
                                    )),
                              ),
                              labelText: widget.first_name.toString(),
                            ),
                            obscureText: false,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your first name';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _nameLast,
                            decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: Container(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        right: BorderSide(
                                            width: 1.0, color: Colors.black),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      color: red,
                                    )),
                              ),
                              labelText: widget.last_name.toString(),
                            ),
                            obscureText: false,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your last name';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _phone,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: Container(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        right: BorderSide(
                                            width: 1.0, color: Colors.black),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.phone_android_rounded,
                                      color: red,
                                    )),
                              ),
                              labelText: widget.mobile.toString(),
                            ),
                            obscureText: false,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your mobile number';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: Container(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        right: BorderSide(
                                            width: 1.0, color: Colors.black),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.mail,
                                      color: red,
                                    )),
                              ),
                              labelText: widget.email.toString(),
                            ),
                            obscureText: false,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!value.contains("@")) {
                                return "Please enter valid email";
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _totalLeaves,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: Container(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        right: BorderSide(
                                            width: 1.0, color: Colors.black),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.edit_note_sharp,
                                      color: red,
                                    )),
                              ),
                              labelText: 'Total Leaves',
                            ),
                            obscureText: false,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter total leaves';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _hours,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: Container(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        right: BorderSide(
                                            width: 1.0, color: Colors.black),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.access_time,
                                      color: red,
                                    )),
                              ),
                              labelText: 'Hours per day',
                            ),
                            obscureText: false,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter hours';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                            "Working Days",
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          SizedBox(
                            height: size.height / 4,
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4),
                              itemCount: 7,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: dayCard(index),
                                );
                              },
                            ),
                          ),
                          Text(
                            errMsg,
                            style: const TextStyle(color: Colors.red),
                          )
                        ],
                      ),
                    )),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Center(
                    child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate() &&
                              selectedDays.values.contains(true)) {
                            editEmployeeInfo(token!, companyId.toString());
                          } else if (!selectedDays.values.contains(true)) {
                            setState(() {
                              errMsg = "Please select working days";
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(10)),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text("Save Employee")),
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Cancel"),
                  ),
                )
              ],
            ),
          )),
        ));
  }

  Container dayCard(int index) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Column(
          children: [
            Text(
              _getDayOfWeek(index),
              style: const TextStyle(fontSize: 12),
            ),
            Checkbox(
              value: selectedDays[index] ?? false,
              onChanged: (bool? value) {
                setState(() {
                  selectedDays[index] = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getDayOfWeek(int index) {
    switch (index) {
      case 0:
        return 'Sunday';
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      default:
        return '';
    }
  }

  showDialogBox() => showCupertinoDialog<String>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Text('No Connection'),
          content: const Text('Please check your internet connectivity'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.pop(context, 'Cancel');
                setState(() => isAlertSet = false);
                isDeviceConnected =
                    await InternetConnectionChecker().hasConnection;
                if (!isDeviceConnected && isAlertSet == false) {
                  showDialogBox();
                  setState(() => isAlertSet = true);
                }
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
}
