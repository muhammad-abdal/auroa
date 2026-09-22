import 'package:aurora/core/layout/repository_scope.dart';
import 'package:aurora/core/theme/aurora_theme.dart';
import 'package:aurora/domain/repositories/favorites_repository.dart';
import 'package:aurora/presentation/about/about_screen.dart';
import 'package:aurora/presentation/favorites/favorites_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_favorites_repository.dart';

/// Wraps a screen in the minimum tree it needs: a repository scope, a
/// MaterialApp, and a Scaffold. Deliberately not `AuroraApp` — the shell
/// mounts the gallery, which mounts live shaders, which can't render in a
/// test environment. Screens under test are pumped directly.
Widget _host(Widget child, FavoritesRepository repository) {
  return RepositoryScope(
    repository: repository,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AuroraTheme.dark,
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('AboutScreen', () {
    testWidgets('renders the author name and both links', (tester) async {
      await tester.pumpWidget(
        _host(const AboutScreen(), FakeFavoritesRepository()),
      );
      // 500ms covers the 400ms name fade. pumpAndSettle would hang on a
      // screen that has an indefinite animation, so use a bounded pump.
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text(kAuthorName), findsOneWidget);
      expect(find.text('Repository'), findsOneWidget);
      expect(find.text('Live demo'), findsOneWidget);
    });
  });

  group('FavoritesScreen', () {
    testWidgets('shows the empty state when nothing is favorited', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(const FavoritesScreen(), FakeFavoritesRepository()),
      );
      await tester.pump();

      expect(find.text('No favorites yet.'), findsOneWidget);
    });

    testWidgets('exits the empty state once a favorite exists', (tester) async {
      final repository = FakeFavoritesRepository();
      await repository.toggle('aurora');

      await tester.pumpWidget(_host(const FavoritesScreen(), repository));
      await tester.pump();

      expect(find.text('No favorites yet.'), findsNothing);
    });
  });
}
