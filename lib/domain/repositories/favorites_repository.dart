import 'package:flutter/foundation.dart';

import '../entities/shader_params.dart';
import '../entities/shader_spec.dart';

/// Storage contract for favorited shaders and their customized parameters.
///
/// This is the only interface in the domain layer. There are deliberately
/// no use cases — every operation here is a one-line delegate, and six
/// classes that each wrap a single method call is ceremony, not
/// architecture. Add use cases the moment real orchestration appears.
///
/// Note the `package:flutter/foundation.dart` import: [Listenable] lives
/// there, not in `flutter/widgets`. Foundation is the primitive half of
/// Flutter with no rendering or UI dependency, so it's acceptable here.
/// A truly pure-Dart domain would expose a `Stream<void>` instead.
abstract interface class FavoritesRepository {
  /// Ids of every favorited shader, in insertion order.
  List<String> get ids;

  bool isFavorite(String id);

  /// Adds if absent, removes if present.
  Future<void> toggle(String id);

  /// Returns the saved params for [spec], or [ShaderSpec.defaults] if the
  /// user has never customized it.
  ShaderParams paramsFor(ShaderSpec spec);

  Future<void> saveParams(String id, ShaderParams params);

  /// Clears saved params so [paramsFor] returns defaults again.
  Future<void> resetParams(String id);

  /// Fires whenever the favorites set changes. Screens listen to this
  /// rather than polling, so a toggle in the gallery updates the
  /// favorites tab without a rebuild cascade.
  Listenable get changes;
}
