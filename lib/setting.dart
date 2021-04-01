import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent/android_intent.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_settings/app_settings.dart';


class AskForPermission extends StatefulWidget {
  @override
  _AskForPermissionState createState() => _AskForPermissionState();
}

class _AskForPermissionState extends State<AskForPermission>{
  final PermissionHandler permissionHandler = PermissionHandler();
  Map<PermissionGroup, PermissionStatus> permissions;

  void initState() {
    super.initState();
    requestLocationPermission();
   // _gpsService();
  }

  Future<bool> _requestPermission(PermissionGroup permission) async {
    final PermissionHandler _permissionHandler = PermissionHandler();
    var result = await _permissionHandler.requestPermissions([permission]);
    if (result[permission] == PermissionStatus.granted) {
      return true;
    }
    return false;
  }

/*Checking if your App has been Given Permission*/
  Future<bool> requestLocationPermission({Function onPermissionDenied}) async {
    var granted = await _requestPermission(PermissionGroup.location);
    if (granted != true) {
      requestLocationPermission();
    }
    debugPrint('requestContactsPermission $granted');
    return granted;
  }

/*Show dialog if GPS not enabled and open settings location*/
  Future _checkGps() async {
    if (!(await Geolocator.isLocationServiceEnabled())) {
      if (Theme.of(context).platform == TargetPlatform.android) {
        showDialog(
            barrierDismissible: false, // Ngăn hộp thoại đóng khi chạm bên ngoài
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(

                title: Text(
                    "Không thể xác định được vị trí\nBạn chưa bật truy cập vị trí"),
                content: const Text(
                    'Hãy chắc chắn rằng bạn bật GPS và thử lại\nVui lòng bật để trải nghiệm app'),
                actions: <Widget>[
                  new FlatButton(
                    onPressed: () => exit(0),
                    textColor: Theme.of(context).primaryColor,
                    child: Text('Đóng'),
                  ),
                  new FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                      AppSettings.openLocationSettings();
                      // Navigator.of(context, rootNavigator: true).pop();

                      //_gpsService();
                      // exit(0);

                    },

                    textColor: Theme.of(context).primaryColor,
                    child: Text('Bật'),
                  ),
                ],
              );
            });
      }

    }
    // else{
    //   getCurrentLocation();
    // }
  }

/*Check if gps service is enabled or not*/
  Future _gpsService() async {
    if (!(await Geolocator.isLocationServiceEnabled())) {
      _checkGps();
      return null;
    } else
      //SystemNavigator.pop();
      getCurrentLocation();
      return true;
  }

  var locationMessage = '';
  String latitude;
  String longitude;

  void getCurrentLocation() async {
    var position = await Geolocator.getCurrentPosition();
    var lat = position.latitude;
    var long = position.longitude;
    // nếu chưa bật GPS
    // passing this to latitude and longitude strings
    latitude = "$lat";
    longitude = "$long";

    setState(() {
      locationMessage = "Vĩ độ : $lat và Kinh độ: $long";
    });
  }

  void googleMap() async {
    String googleUrl =
        "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";

    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else
      throw ("Không thể mở google maps");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ứng dụng vị trí người dùng',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on,
                size: 45.0,
                color: Colors.white,
              ),
              SizedBox(
                height: 20.0,
              ),
              Text(
                "Lấy vị trị hiện tại",
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
              Text(
                locationMessage,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              SizedBox(
                height: 05.0,
              ),

              // button for taking the location
              FlatButton(
                color: Colors.white,
                onPressed: () {
                  _gpsService();
                },
                child: Text("Lấy ngay tại đây"),
              ),

              FlatButton(
                color: Colors.white,
                onPressed: () {
                  googleMap();
                },
                child: Text("Mở GoogleMap"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
