import 'package:sqflite/sqflite.dart';

import 'database_native.dart'
    if (dart.library.js_interop) 'database_web.dart'
    as platform;

/// Keeps the SQL schema and queries independent of the platform backend.
Future<Database> openProgressDatabase(OpenDatabaseOptions options) =>
    platform.openProgressDatabase(options);
