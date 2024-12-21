import 'package:hack_town_front/pages/main_pages/route_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hack_town_front/dtos/event_route.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final List<String> items;
  final String selectedValue;
  final ValueChanged<String?> onChanged;

  const CustomDropdown({
    Key? key,
    required this.label,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                canvasColor: Colors.white,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedValue,
                  isExpanded: true,
                  onChanged: onChanged,
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  style: const TextStyle(color: Colors.black),
                  items: items.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(value),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TimePickerWidget extends StatelessWidget {
  final String label;
  final TimeOfDay selectedTime;
  final ValueChanged<TimeOfDay?> onChanged;

  const TimePickerWidget({
    Key? key,
    required this.label,
    required this.selectedTime,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 5),
          Container(
            width: 400,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: ElevatedButton(
              onPressed: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                  builder: (BuildContext context, Widget? child) {
                    return Theme(
                      data: ThemeData.light().copyWith(
                        primaryColor: Colors.black,
                        timePickerTheme: const TimePickerThemeData(
                          backgroundColor: Colors.white,
                          hourMinuteColor: Colors.black12,
                          hourMinuteTextColor: Colors.black,
                          dialHandColor: Colors.black12,
                          dialTextColor: Colors.black,
                          dayPeriodColor: Colors.black12,
                        ),
                        colorScheme: const ColorScheme.light(
                          primary: Colors.black,
                          onPrimary: Colors.white,
                          onSurface: Colors.black,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null && picked != selectedTime) {
                  onChanged(picked);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
              child: Text(
                selectedTime.format(context),
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FindButton extends StatelessWidget {
  final Map<String, dynamic> data;
  final Future<http.Response> Function(Map<String, dynamic>) sendDataToServer;

  const FindButton({
    Key? key,
    required this.data,
    required this.sendDataToServer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: ElevatedButton(
        onPressed: () async {
          // Log the collected data
          print('Collected data: $data');

          // Show loading dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return const Center(
                child: SpinKitFadingCircle(
                  size: 150,
                  color: Colors.white,
                ),
              );
            },
          );

          try {
            final response = await sendDataToServer(data);
            Map<String, dynamic> responseData = jsonDecode(utf8.decode(response.bodyBytes));

            List<dynamic> list = responseData["routes"];
            List<EventRouteDTO> routes = [];
            for (var item in list) {
              Map<String, dynamic> map = item;
              routes.add(EventRouteDTO.fromMap(map));
            }

            // Dismiss the loading dialog
            Navigator.of(context, rootNavigator: true).pop();

            // Navigate to the RoutePage
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => RoutePage(routeData: routes)),
            );

          } catch (e) {
            // Handle error and dismiss the loading dialog
            Navigator.of(context, rootNavigator: true).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e')),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 40.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: Colors.black12,
        ),
        child: Text(
          "test_page.find".tr(),
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}

Future<http.Response> sendDataToServer(Map<String, dynamic> data) async {
    final client = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;


    try {

      var request = await http.post(
        Uri.parse('${dotenv.env["BASE_URL"]!}/api/UserRequests'),
        body: jsonEncode(data),
        headers: {'Content-Type': 'application/json'}
        );

      // final request = await client.postUrl(
      //     Uri.parse('${dotenv.env["BASE_URL"]!}/api/UserRequests'));
      // request.headers.set('Content-Type', 'application/json; charset=UTF-8');
      // request.write(jsonEncode(data));
      // final response = await request.close();

      return request;
    } finally {
      client.close();
    }
  }

  // Future<http.Response> convertHttpClientResponseToHttpResponse(HttpClientResponse response) async {
  //   final responseData = await response.transform(utf8.decoder).join();
  //   final headers = <String, String>{};
  //   response.headers.forEach((name, values) {
  //     headers[name] = values.join(', ');
  //   });
  //   return http.Response(responseData, response.statusCode, headers: headers);
  // }