import 'package:flutter/widgets.dart';

import '../../domain/repositories/favorites_repository.dart';

/// Injects the [FavoritesRepository] into the tree.
///
/// Deliberately not `get_it` or `riverpod`. One dependency at the root of
/// one small app doesn't justify a container — this is twenty lines, it's
/// typed, and it's trivially overridable in a widget test:
///
/// ```dart
/// await tester.pumpWidget(
///   RepositoryScope(
///     repository: FakeFavoritesRepository(),
///     child: const AuroraApp(),
///   ),
/// );
/// ```
///
/// If a second repository ever appears, swap this for a proper container.
/// Until then, the ceremony isn't earning anything.
class RepositoryScope extends InheritedWidget {
  final FavoritesRepository repository;

  const RepositoryScope({
    super.key,
    required this.repository,
    required super.child,
  });

  static FavoritesRepository of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<RepositoryScope>();
    assert(
      scope != null,
      'RepositoryScope is missing from the widget tree.\n'
      'It must wrap the subtree that contains any screen reading favorites.',
    );
    return scope!.repository;
  }

  @override
  bool updateShouldNotify(RepositoryScope oldWidget) =>
      oldWidget.repository != repository;
}
