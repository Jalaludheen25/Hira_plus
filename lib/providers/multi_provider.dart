import 'package:canteen_app/providers/auth_provider.dart';
import 'package:canteen_app/providers/canteen_home_page_provider.dart';
import 'package:canteen_app/providers/date_provider.dart';
import 'package:canteen_app/providers/home_view_mode_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> getProviders() {
  return [
    ChangeNotifierProvider(create: (context) => AuthProvider()),
    ChangeNotifierProvider(create: (context) => DateProvider()),
    ChangeNotifierProvider(create: (context) => CanteenHomePageProvider(context)),
    ChangeNotifierProvider(create: (context) => HomeViewModeProvider()),
  ];
}
