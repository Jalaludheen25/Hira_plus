// navigation_helper.dart
import 'package:flutter/material.dart';
import 'dart:developer' as dev;

// Global navigator key for use in navigation and notification handling
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void navigateTo({
  required BuildContext context,
  required String route,
  Object? arguments,
  bool useRootNavigator = false,
}) {
  dev.log('Navigating to route: $route', name: 'NavigationHelper');
  if (useRootNavigator) {
    Navigator.of(context, rootNavigator: true).pushNamed(route, arguments: arguments);
  } else {
    Navigator.of(context).pushNamed(route, arguments: arguments);
  }
}

void navigateReplaceTo({
  required BuildContext context,
  required String route,
  Object? arguments,
}) {
  dev.log('Navigating and replacing with route: $route', name: 'NavigationHelper');
  Navigator.of(context).pushReplacementNamed(route, arguments: arguments);
}

void navigatePRTo({
  required BuildContext context,
  required String route,
  Object? arguments,
}) {
  dev.log('Navigating and removing until route: $route',
      name: 'NavigationHelper');
  Navigator.of(context).pushNamedAndRemoveUntil(
    route,
    (route) => false,
    arguments: arguments,
  );
}

void navigateBack(BuildContext context) {
  dev.log('Navigating back', name: 'NavigationHelper');
  Navigator.of(context).pop();
}

bool canNavigateBack(BuildContext context) {
  final canPop = Navigator.of(context).canPop();
  dev.log('Can navigate back: $canPop', name: 'NavigationHelper');
  return canPop;
}

void navigateToWidget({
  required BuildContext context,
  required Widget route,
}) {
  dev.log('Navigating to widget: ${route.runtimeType}',
      name: 'NavigationHelper');
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => route));
}

void navigatePRToWidget({
  required BuildContext context,
  required Widget route,
}) {
  dev.log('Navigating and removing until widget: ${route.runtimeType}',
      name: 'NavigationHelper');
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => route),
    (route) => false,
  );
}

void navigateWithLeftToRightAnimation({
  required BuildContext context,
  required Widget page,
}) {
  dev.log('Navigating with animation to widget: ${page.runtimeType}',
      name: 'NavigationHelper');
  Navigator.of(context).push(PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(-1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  ));
}

void navigatePRToGlobal({
  required String route,
  Object? arguments,
}) {
  dev.log('Navigating and removing until route (global): $route', name: 'NavigationHelper');
  navigatorKey.currentState?.pushNamedAndRemoveUntil(
    route,
    (route) => false,
    arguments: arguments,
  );
}
