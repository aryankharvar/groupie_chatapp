import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

Widget customLoader({String loaderName="Chat.json",double width=220}) {
  return Center(
    child: Lottie.asset(
      "assets/json/$loaderName",
      width: width,
      animate: true,
      repeat: true,
      reverse: false,
    ),
  );
}
