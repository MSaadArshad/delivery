import 'package:flutter/material.dart';
import 'package:delivery/login.dart' as login;
import 'package:delivery/order.dart' as order;

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case 'order':
      return MaterialPageRoute(builder: (context) => const order.View());
    default:
      return MaterialPageRoute(builder: (context) => const login.View());
  }
}

