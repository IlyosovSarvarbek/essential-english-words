import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

Future<Database> openProgressDatabase(OpenDatabaseOptions options) =>
    databaseFactoryFfiWeb.openDatabase('essential_words.db', options: options);
