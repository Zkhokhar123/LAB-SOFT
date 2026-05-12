import '../models/hospital_models.dart';

class RoutePlanner {
  const RoutePlanner();

  /// Shortest path (fewest hops) on directed graph. Returns null if unreachable.
  List<String>? placeIdsShortestPath(HospitalGraph g, String startId, String endId) {
    if (!g.placesById.containsKey(startId) || !g.placesById.containsKey(endId)) {
      return null;
    }
    if (startId == endId) return [startId];

    final adj = <String, List<String>>{};
    for (final l in g.links) {
      adj.putIfAbsent(l.from, () => []).add(l.to);
    }

    final q = <String>[startId];
    final visited = {startId};
    final parent = <String, String>{};

    while (q.isNotEmpty) {
      final u = q.removeAt(0);
      for (final v in adj[u] ?? const []) {
        if (visited.contains(v)) continue;
        visited.add(v);
        parent[v] = u;
        if (v == endId) {
          return _reconstruct(parent, startId, endId);
        }
        q.add(v);
      }
    }
    return null;
  }

  List<String> _reconstruct(Map<String, String> parent, String start, String end) {
    final path = <String>[end];
    var cur = end;
    while (cur != start) {
      cur = parent[cur]!;
      path.add(cur);
    }
    return path.reversed.toList();
  }

  List<NavStep> toSteps(HospitalGraph g, List<String> placeIds) {
    if (placeIds.isEmpty) return [];
    final steps = <NavStep>[];
    for (var i = 0; i < placeIds.length; i++) {
      final id = placeIds[i];
      final place = g.placesById[id]!;
      final how = i == 0 ? null : g.instructionBetween(placeIds[i - 1], id);
      steps.add(NavStep(placeId: id, placeLabel: place.label, howFromPrevious: how));
    }
    return steps;
  }
}
