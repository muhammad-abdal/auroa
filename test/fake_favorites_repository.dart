import 'package:aurora/domain/entities/shader_params.dart';
import 'package:aurora/domain/entities/shader_spec.dart';
import 'package:aurora/domain/repositories/favorites_repository.dart';
import 'package:flutter/foundation.dart';

/// In-memory [FavoritesRepository] for tests.
///
/// No Hive, no platform channels, no filesystem. Every widget test that
/// needs a repository uses this, which is the payoff of having the
/// interface in the first place.
class FakeFavoritesRepository implements FavoritesRepository {
  final Set<String> _ids = <String>{};
  final Map<String, ShaderParams> _params = <String, ShaderParams>{};

  /// Bumps on every write so `ListenableBuilder` rebuilds. A plain
  /// `ValueNotifier<int>` is enough — nothing reads the value, only
  /// listens for the change.
  final ValueNotifier<int> _notifier = ValueNotifier<int>(0);

  @override
  List<String> get ids => _ids.toList(growable: false);

  @override
  Listenable get changes => _notifier;

  @override
  bool isFavorite(String id) => _ids.contains(id);

  @override
  Future<void> toggle(String id) async {
    if (!_ids.remove(id)) _ids.add(id);
    _notifier.value++;
  }

  @override
  ShaderParams paramsFor(ShaderSpec spec) => _params[spec.id] ?? spec.defaults;

  @override
  Future<void> saveParams(String id, ShaderParams params) async {
    _params[id] = params;
    _notifier.value++;
  }

  @override
  Future<void> resetParams(String id) async {
    _params.remove(id);
    _notifier.value++;
  }
}
