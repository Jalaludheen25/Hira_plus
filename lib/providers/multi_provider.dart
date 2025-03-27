import 'package:canteen_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> getProviders() {
  return [ChangeNotifierProvider(create: (context) => AuthProvider())];
}
