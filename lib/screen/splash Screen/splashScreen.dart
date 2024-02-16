import 'package:flutter/material.dart';

import '../home Screen/map.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 8), () {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const TrackingMap2()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.amberAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // FlutterLogo(size: 150),
            SizedBox(height: 20),
            Text(
              'Booking',
              style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
