import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/drug.dart';

class DrugRepository {
  static List<Drug>? _drugs;

  static Future<List<Drug>> load() async {
    if (_drugs != null) return _drugs!;

    final jsonStr = await rootBundle.loadString('assets/drug_database.json');
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    final list = (data['drugs'] as List)
        .map((e) => Drug.fromJson(e as Map<String, dynamic>))
        .toList();

    _drugs = list;
    return list;
  }

  static List<Drug> search(String query) {
    if (_drugs == null) return [];
    if (query.isEmpty) return _drugs!;
    final q = query.toLowerCase();
    return _drugs!
        .where((d) => d.name.toLowerCase().contains(q))
        .toList();
  }
}
