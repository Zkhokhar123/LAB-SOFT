class Place {
  const Place({required this.id, required this.label});

  final String id;
  final String label;
}

class DirectedLink {
  const DirectedLink({required this.from, required this.to, required this.how});

  final String from;
  final String to;
  final String how;
}

class NavStep {
  const NavStep({required this.placeId, required this.placeLabel, this.howFromPrevious});

  final String placeId;
  final String placeLabel;

  /// Instruction to reach this place from the previous step (null for start).
  final String? howFromPrevious;
}

class HospitalGraph {
  const HospitalGraph({
    required this.placesById,
    required this.links,
    this.version = 1,
    this.aboutNote,
  });

  final int version;
  final String? aboutNote;
  final Map<String, Place> placesById;
  final List<DirectedLink> links;

  String? instructionBetween(String fromId, String toId) {
    for (final l in links) {
      if (l.from == fromId && l.to == toId) return l.how;
    }
    return null;
  }
}
