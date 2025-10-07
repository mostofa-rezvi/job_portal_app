import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

void initializeDatabaseFactory() {
  if (identical(0, 0.0)) {
    databaseFactory = databaseFactoryFfiWeb;
    print('DEBUG: Initializing database factory for WEB (IndexedDB)');
  } else {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    print('DEBUG: Initializing database factory for MOBILE/DESKTOP (FFI)');
  }
}