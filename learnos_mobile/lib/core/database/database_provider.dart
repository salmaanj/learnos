import 'package:flutter/foundation.dart';

import 'app_database.dart';

class DatabaseProvider extends ChangeNotifier {
  late final AppDatabase database;

  DatabaseProvider() {
    database = AppDatabase();
  }

  @override
  void dispose() {
    database.closeDatabase();
    super.dispose();
  }
}