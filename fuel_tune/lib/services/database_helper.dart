// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
//
// class DatabaseHelper {
//   static final DatabaseHelper instance = DatabaseHelper._init();
//
//   static Database? _database;
//
//   static const String _dbName = 'fuel_database.db';
//
//   static const int _dbVersion = 1;
//
//   DatabaseHelper._init();
//
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDB(_dbName);
//     return _database!;
//   }
//
//   Future<Database> _initDB(String fileName) async {
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, fileName);
//
//     return await openDatabase(
//       path,
//       version: _dbVersion,
//       onCreate: _createDB,
//       onUpgrade: _upgradeDB,
//     );
//   }
//
//   // Criação inicial do banco de dados
//   Future _createDB(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE abastecimentos (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         km_percorrido DOUBLE NOT NULL,
//         litros DOUBLE NOT NULL,
//         media_consumo DOUBLE NULL,
//         dt_abastecimento TEXT NOT NULL
//       )
//     ''');
//   }
//
//   // Atualização do banco de dados (caso necessário)
//   Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
//     if (oldVersion < 2) {
//       // Exemplo: Adicionar novas tabelas ou colunas
//       await db.execute('''
//         CREATE TABLE new_table (
//           id INTEGER PRIMARY KEY AUTOINCREMENT,
//           data TEXT NOT NULL
//         )
//       ''');
//     }
//   }
//
//   Future close() async {
//     final db = await instance.database;
//     db.close();
//   }
//
//   // Métodos CRUD (Create, Read, Update, Delete)
//
//   Future<int> insert(String table, Map<String, dynamic> data) async {
//     final db = await instance.database;
//     return await db.insert(table, data);
//   }
//
//   Future<List<Map<String, dynamic>>> queryAll(String table) async {
//     final db = await instance.database;
//     return await db.query(table);
//   }
//
//   Future<int> update(String table, Map<String, dynamic> data, String where, List<Object?> whereArgs) async {
//     final db = await instance.database;
//     return await db.update(
//       table,
//       data,
//       where: where,
//       whereArgs: whereArgs,
//     );
//   }
//
//   Future<int> delete(String table, String where, List<Object?> whereArgs) async {
//     final db = await instance.database;
//     return await db.delete(
//       table,
//       where: where,
//       whereArgs: whereArgs,
//     );
//   }
// }
