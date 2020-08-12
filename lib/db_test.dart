import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final Future<Database> database = openDatabase(
    // Set the path to the database.
    join(await getDatabasesPath(), 'passport_database.db'),
    onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE passport(id INTEGER PRIMARY KEY, name TEXT, age INTEGER)",
      );
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
  );

  Future<void> insertPassport(Passport passport) async {
    final Database db = await database;

    await db.insert(
        'passport_database',
        passport.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  final jake = Passport(
    id: 1,
    name: 'Jake',
    age: 22,
  );

  await insertPassport(jake);

  Future<List<Passport>> passport() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query('passport_database');

    return List.generate(maps.length, (i) {
      return Passport(
        id: maps[i]['id'],
        name: maps[i]['name'],
        age: maps[i]['age'],
      );
    });
  }
  print(await passport());


  Future<void> updatePassport(Passport passport) async {
    final db = await database;

    await db.update(
      'passport',
      passport.toMap(),
      where: 'id = ?',
      whereArgs: [passport.id],

//  Note:
//  Always use whereArgs to pass arguments to a where statement.
//  This helps safeguard against SQL injection attacks.
//  Do not use string interpolation, such as where: "id = ${dog.id}"!
    );
  }
  await updatePassport(Passport(
    id: 0,
    name: 'Jake',
    age: 222,
  ));

  print(await passport());

  Future<void> deletePassport(int id) async {
    final db = await database;

    await db.delete(
      'passport',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

class Passport {
  final int id;
  final String name;
  final int age;

  Passport({this.id, this.name, this.age});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
    };
  }

  @override
  String toString() {
    return 'Passport{id: $id, name: $name, age: $age}';
  }
}