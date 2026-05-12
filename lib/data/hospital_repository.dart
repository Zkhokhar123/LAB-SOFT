import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/hospital_models.dart';

class HospitalRepository {
  HospitalGraph? _cached;

  void clearCache() {
    _cached = null;
  }

  Future<HospitalGraph> loadGraph() async {
    if (_cached != null) return _cached!;
    final raw = await rootBundle.loadString('assets/data/hospital_graph.json');
    final map = jsonDecode(raw) as Map<String, dynamic>;
    final version = (map['version'] as num?)?.toInt() ?? 1;
    final about = map['about'] as String?;

    final placesList = map['places'] as List<dynamic>? ?? [];
    final placesById = <String, Place>{};
    for (final p in placesList) {
      final m = p as Map<String, dynamic>;
      final id = m['id'] as String;
      placesById[id] = Place(id: id, label: m['label'] as String);
    }

    final linksRaw = map['links'] as List<dynamic>? ?? [];
    final links = <DirectedLink>[];
    for (final l in linksRaw) {
      final m = l as Map<String, dynamic>;
      links.add(
        DirectedLink(
          from: m['from'] as String,
          to: m['to'] as String,
          how: m['how'] as String,
        ),
      );
    }

    _cached = HospitalGraph(
      version: version,
      aboutNote: about,
      placesById: placesById,
      links: links,
    );
    return _cached!;
  }
}
