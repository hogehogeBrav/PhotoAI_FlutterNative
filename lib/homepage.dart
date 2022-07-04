// homepage
import 'package:flutter/material.dart';

Widget _homePage() {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Home",
          textAlign: TextAlign.center,
        ),
        ElevatedButton(
          child: const Text('あそびかた'),
          style: ElevatedButton.styleFrom(
            primary: Colors.blue,
            onPrimary: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () async {
            final pref = await SharedPreferences.getInstance();
            pref.setBool('isAlreadyFirstLaunch', false);
            setState(() {});
          },
        ),
      ],
    ),
  );
}
