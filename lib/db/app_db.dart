import 'package:ep_feedmill/db/db_sql.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const _version = 2;
const _dbName = "ep_feedmill.db";

class AppDb {
  static final _instance = AppDb._internal();

  factory AppDb() => _instance;

  static Database _database;

  AppDb._internal();

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await initDatabase();
    return _database;
  }

  initDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _dbName);

    return await openDatabase(
      path,
      version: _version,
      onCreate: (Database db, int version) async {
        await db.execute(DbSql.createItemPackingTable);
        await db.execute(DbSql.createMrfFormulaCategoryTable);
        await db.execute(DbSql.createMrfPremixPlanDocTable);
        await db.execute(DbSql.createMrfPremixPlanDocDetailTable);

        await db.execute(DbSql.createTempPremixDetailTable);
        await db.execute(DbSql.createPremixTable);
        await db.execute(DbSql.createPremixDetailTable);

        await db.execute(DbSql.createLogTable);
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        debugPrint("on upgrade old db ver: " + oldVersion.toString());
        debugPrint("on upgrade new db ver: " + newVersion.toString());
        if (oldVersion <= 1) {
          debugPrint("execute migration 1");
          await db.execute("ALTER TABLE item_packing ADD COLUMN is_premix INTEGER DEFAULT 0");
        }
      },
    );
  }
}
