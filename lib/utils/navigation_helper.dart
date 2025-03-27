// navigation_helper.dart
import 'package:flutter/material.dart';

// Global navigator key for use in navigation and notification handling
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void navigateTo({
  required BuildContext context,
  required String route,
  Object? arguments,
}) {
  Navigator.of(context).pushNamed(route, arguments: arguments);
}

void navigateReplaceTo({
  required BuildContext context,
  required String route,
  Object? arguments,
}) {
  Navigator.of(context).pushReplacementNamed(route, arguments: arguments);
}

void navigatePRTo({
  required BuildContext context,
  required String route,
  Object? arguments,
}) {
  Navigator.of(context).pushNamedAndRemoveUntil(
    route,
    (route) => false,
    arguments: arguments,
  );
}

void navigateBack(BuildContext context) {
  Navigator.of(context).pop();
}

bool canNavigateBack(BuildContext context) {
  return Navigator.of(context).canPop();
}

void navigateToWidget({
  required BuildContext context,
  required Widget route,
}) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => route));
}

void navigatePRToWidget({
  required BuildContext context,
  required Widget route,
}) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => route),
    (route) => false,
  );
}

void navigateWithLeftToRightAnimation({
  required BuildContext context,
  required Widget page,
}) {
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
