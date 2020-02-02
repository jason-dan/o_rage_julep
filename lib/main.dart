import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:orange_julep/services/location_service.dart';
import 'package:provider/provider.dart';
import 'package:orange_julep/datamodels/user_location.dart';
import 'package:great_circle_distance/great_circle_distance.dart';
import 'package:geodesy/geodesy.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserLocation>(
      create: (context) => LocationService().locationStream,
      child: MaterialApp(
          title: 'Flutter Compass Demo',
          theme: ThemeData(brightness: Brightness.dark),
          darkTheme: ThemeData.dark(),
          home: Scaffold(
              body: Container(
                child: Compass(),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/julep1.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              )
          )
      )
    );
  }
}

class Compass extends StatefulWidget {

  Compass({Key key}) : super(key: key);

  @override
  _CompassState createState() => _CompassState();
}

class _CompassState extends State<Compass> {
  bool _metric = true;
  double _heading = 0;

  @override
  void initState() {

    super.initState();
    FlutterCompass.events.listen(_onData);
  }

  void _onData(double x) => setState(() { _heading = x; });

  final TextStyle _style = TextStyle(
    color: Colors.red[50].withOpacity(0.9),
    fontSize: 32,
    fontWeight: FontWeight.w200,
  );

  double calcBearing(double lat1, double lon1, double lat2, double lon2) {
    Geodesy geodesy = Geodesy();
    LatLng l1 = LatLng(lat1, lon1);
    LatLng l2 = LatLng(lat2, lon2);
    
    double bearing = Geodesy().bearingBetweenTwoGeoPoints(l1, l2);
    return bearing;
  }
  String calcDist(double lat1, double lon1, double lat2, double lon2) {
    var gcd = new GreatCircleDistance.fromDegrees(latitude1: lat1, longitude1: lon1, latitude2: lat2, longitude2: lon2);
    double dist = gcd.haversineDistance();
    String _formattedDist;

    if (dist >= 500) {
      _formattedDist = (dist/1000).toStringAsFixed(1) + " km";
    }
    else {
      _formattedDist = (dist).toStringAsFixed(1) + " km";
    }

    return _formattedDist;
  }

  @override
  Widget build(BuildContext context) {

    var userLocation = Provider.of<UserLocation>(context);

    double lat1 = userLocation?.latitude;
    double lon1 = userLocation?.longitude;
    double lat2 = 45.495682;
    double lon2 = -73.656840;

    double compassAngle = calcBearing(lat1, lon1, lat2, lon2)-_heading;
    compassAngle = compassAngle.abs();

    return CustomPaint(
        foregroundPainter: CompassPainter(angle: compassAngle),
        child: Center(child: Text(calcDist(lat1, lon1, lat2, lon2), style: _style))
    );
  }
}

class CompassPainter extends CustomPainter {

  CompassPainter({ @required this.angle }) : super();

  final double angle;
  double get rotation => -2 * pi * (angle / 360);

  Paint get _brush => new Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  @override
  void paint(Canvas canvas, Size size) {

    Paint circle = _brush
      ..color = Colors.indigo[400].withOpacity(0.6);

    Paint needle = _brush
      ..color = Colors.red[400];

    double radius = min(size.width / 2.2, size.height / 2.2);
    Offset center = Offset(size.width / 2, size.height / 2);
    Offset start = Offset.lerp(Offset(center.dx, radius), center, .4);
    Offset end = Offset.lerp(Offset(center.dx, radius), center, 0.1);

    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawLine(start, end, needle);
    canvas.drawCircle(center, radius, circle);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}


