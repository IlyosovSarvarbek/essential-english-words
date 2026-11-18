import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;

Future<Database> openProgressDatabase(OpenDatabaseOptions options) async {
  if (Platform.isWindows || Platform.isLinux) {
    ffi.sqfliteFfiInit();
    final directory = await getApplicationSupportDirectory();
    return ffi.databaseFactoryFfi.openDatabase(
      p.join(directory.path, 'databases', 'essential_words.db'),
      options: options,
    );
  }
  return databaseFactory.openDatabase(
    p.join(await getDatabasesPath(), 'essential_words.db'),
    options: options,
  );
}
