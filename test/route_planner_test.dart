import 'package:flutter_test/flutter_test.dart';

import 'package:goodlucksoft/models/hospital_models.dart';
import 'package:goodlucksoft/services/route_planner.dart';

void main() {
  test('shortest path and steps', () {
    final g = HospitalGraph(
      placesById: {
        'a': const Place(id: 'a', label: 'A'),
        'b': const Place(id: 'b', label: 'B'),
        'c': const Place(id: 'c', label: 'C'),
      },
      links: const [
        DirectedLink(from: 'a', to: 'b', how: 'go b'),
        DirectedLink(from: 'b', to: 'c', how: 'go c'),
        DirectedLink(from: 'b', to: 'a', how: 'back a'),
        DirectedLink(from: 'c', to: 'b', how: 'back b'),
      ],
    );
    const p = RoutePlanner();
    final path = p.placeIdsShortestPath(g, 'a', 'c');
    expect(path, ['a', 'b', 'c']);
    final steps = p.toSteps(g, path!);
    expect(steps.length, 3);
    expect(steps[1].howFromPrevious, 'go b');
    expect(steps[2].howFromPrevious, 'go c');
  });
}
