import 'package:flutter/material.dart';

import '../data/hospital_repository.dart';
import '../models/hospital_models.dart';
import '../services/route_planner.dart';

class NavHomePage extends StatefulWidget {
  const NavHomePage({super.key, this.repository});

  /// Optional — tests can inject a repository with preloaded / fake data.
  final HospitalRepository? repository;

  @override
  State<NavHomePage> createState() => _NavHomePageState();
}

class _NavHomePageState extends State<NavHomePage> {
  late final HospitalRepository _repo;
  final _planner = const RoutePlanner();

  HospitalGraph? _graph;
  Object? _loadError;
  String? _fromId;
  String? _toId;
  List<NavStep>? _steps;

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? HospitalRepository();
    _load();
  }

  Future<void> _load() async {
    try {
      final g = await _repo.loadGraph();
      if (!mounted) return;
      setState(() {
        _graph = g;
        final ids = g.placesById.keys.toList()..sort();
        _fromId = ids.isNotEmpty ? ids.first : null;
        _toId = ids.length > 1 ? ids[1] : (ids.isNotEmpty ? ids.first : null);
        _loadError = null;
      });
    } catch (e, st) {
      debugPrint('$e\n$st');
      if (!mounted) return;
      setState(() => _loadError = e);
    }
  }

  Future<void> _reload() async {
    _repo.clearCache();
    setState(() {
      _graph = null;
      _steps = null;
      _loadError = null;
    });
    await _load();
  }

  void _computeRoute() {
    final g = _graph;
    if (g == null || _fromId == null || _toId == null) return;
    if (_fromId == _toId) {
      setState(() {
        _steps = [
          NavStep(
            placeId: _fromId!,
            placeLabel: g.placesById[_fromId!]!.label,
            howFromPrevious: null,
          ),
        ];
      });
      return;
    }
    final ids = _planner.placeIdsShortestPath(g, _fromId!, _toId!);
    if (ids == null) {
      setState(() => _steps = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No offline route between these points. Please ask staff or update the hospital map file.',
          ),
        ),
      );
      return;
    }
    setState(() => _steps = _planner.toSteps(g, ids));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Nishtar Navigator')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Could not load hospital data.\n$_loadError', textAlign: TextAlign.center),
          ),
        ),
      );
    }

    if (_graph == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final g = _graph!;
    final places = g.placesById.values.toList()
      ..sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nishtar Navigator'),
        actions: [
          IconButton(
            tooltip: 'Reload map data',
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Card(
            color: theme.colorScheme.errorContainer.withValues(alpha: 0.35),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                g.aboutNote ?? 'Verify all directions with hospital administration before use.',
                style: theme.textTheme.bodySmall?.copyWith(height: 1.45),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Offline guide', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
            'Choose your current area and your destination ward or facility. Everything runs on your phone — no internet needed after install.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          Text('I am near', style: theme.textTheme.labelLarge),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: _fromId, // ignore: deprecated_member_use
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: [
              for (final p in places)
                DropdownMenuItem(value: p.id, child: Text(p.label, overflow: TextOverflow.ellipsis)),
            ],
            onChanged: (v) => setState(() {
              _fromId = v;
              _steps = null;
            }),
          ),
          const SizedBox(height: 16),
          Text('I need to go to', style: theme.textTheme.labelLarge),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: _toId, // ignore: deprecated_member_use
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: [
              for (final p in places)
                DropdownMenuItem(value: p.id, child: Text(p.label, overflow: TextOverflow.ellipsis)),
            ],
            onChanged: (v) => setState(() {
              _toId = v;
              _steps = null;
            }),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _computeRoute,
            icon: const Icon(Icons.directions_walk),
            label: const Text('Show walking route'),
          ),
          if (_steps != null) ...[
            const SizedBox(height: 28),
            Text('Steps', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ..._steps!.asMap().entries.map((e) {
              final i = e.key;
              final s = e.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Step ${i + 1}',
                        style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary),
                      ),
                      const SizedBox(height: 4),
                      Text(s.placeLabel, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                      if (s.howFromPrevious != null) ...[
                        const SizedBox(height: 8),
                        Text(s.howFromPrevious!, style: theme.textTheme.bodyMedium?.copyWith(height: 1.45)),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
