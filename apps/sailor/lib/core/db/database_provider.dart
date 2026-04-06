import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:ev_protocol_veilid/ev_protocol_veilid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Opens the SQLite database in the app's documents directory.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'sailor.db'));
    return NativeDatabase.createInBackground(file);
  });
}

/// Global database provider — single instance across the app.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(_openConnection());
  ref.onDispose(db.close);
  return db;
});
