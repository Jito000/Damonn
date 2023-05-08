import 'package:flutter/material.dart';

import 'custom_color.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> customSnackBar(BuildContext context,String message){
  return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Padding(
      padding: const EdgeInsets.all(6.0),
      child: Text(message),
    ),
    duration: const Duration(milliseconds: 1000),
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.only(left: 12, right: 12, bottom: 108),
    backgroundColor: Color(customColorBlue()),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ));
}