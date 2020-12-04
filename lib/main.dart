import 'package:rally/my_app.dart';
import 'package:rally/utils/app_config.dart';

Future<void> main() async {
  /// Init dev config
  Config(environment: Env.dev());
  await myMain();
}
