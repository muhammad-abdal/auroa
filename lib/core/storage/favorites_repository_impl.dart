import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../domain/entities/shader_params.dart';
import '../../domain/entities/shader_spec.dart';
import '../../domain/repositories/favorites_repository.dart';
import 'shader_params_model.dart';

/// Hive-backed implementation of [FavoritesRepository].
///
/// Two boxes, no adapters, no codegen:
///   `favorites` : id -> true
///   `params`    : id -> Map<String, Object>
///
/// Both boxes are opened once at boot and kept open for the app's lifetime.
/// Hive boxes are cheap handles; there's no reason to close them per screen.
class HiveFavoritesRepository implements FavoritesRepository {
  static const String _favoritesBoxName = 'favorites';
  static const String _paramsBoxName = 'params';

  final Box<dynamic> _favorites;
  final Box<dynamic> _params;

  HiveFavoritesRepository._(this._favorites, this._params);

  /// Call from `main()` after `Hive.initFlutter()`.
  static Future<HiveFavoritesRepository> open() async {
    final favorites = await Hive.openBox<dynamic>(_favoritesBoxName);
    final params = await Hive.openBox<dynamic>(_paramsBoxName);
    return HiveFavoritesRepository._(favorites, params);
  }

  // ── Favorites ──────────────────────────────────────────────────────

  @override
  List<String> get ids =>
      _favorites.keys.whereType<String>().toList(growable: false);

  @override
  bool isFavorite(String id) => _favorites.containsKey(id);

  @override
  Future<void> toggle(String id) async {
    if (isFavorite(id)) {
      await _favorites.delete(id);
    } else {
      await _favorites.put(id, true);
    }
  }

  // ── Params ─────────────────────────────────────────────────────────

  @override
  ShaderParams paramsFor(ShaderSpec spec) {
    final raw = _params.get(spec.id);
    if (raw is! Map) return spec.defaults;
    return ShaderParamsModel.tryFromMap(raw) ?? spec.defaults;
  }

  @override
  Future<void> saveParams(String id, ShaderParams params) =>
      _params.put(id, ShaderParamsModel.toMap(params));

  @override
  Future<void> resetParams(String id) => _params.delete(id);

  // ── Change notification ────────────────────────────────────────────

  @override
  Listenable get changes => _favorites.listenable();
}
