import 'package:aurora/core/theme/breakpoints.dart';
import 'package:flutter/material.dart';

import '../core/layout/layout_scope.dart';
import '../core/theme/design_tokens.dart';
import '../presentation/about/about_screen.dart';
import '../presentation/favorites/favorites_screen.dart';
import '../presentation/gallery/gallery_screen.dart';

/// The app's frame: navigation and the body.
///
/// Owns nothing but `_index`. The [Ticker], [ShaderClock], [LayoutScope],
/// and [RepositoryScope] all live in [AuroraApp] above [MaterialApp] so
/// pushed routes can reach them.
class AuroraShell extends StatefulWidget {
  const AuroraShell({super.key});

  @override
  State<AuroraShell> createState() => _AuroraShellState();
}

class _AuroraShellState extends State<AuroraShell> {
  int _index = 0;

  void _select(int index) {
    if (index == _index) return;
    setState(() => _index = index);
  }

  static const List<NavigationDestination> _barDestinations =
      <NavigationDestination>[
        NavigationDestination(
          icon: Icon(Icons.grid_view_rounded),
          label: 'Gallery',
        ),
        NavigationDestination(
          icon: Icon(Icons.favorite_border),
          label: 'Favorites',
        ),
        NavigationDestination(icon: Icon(Icons.info_outline), label: 'About'),
      ];

  static const List<NavigationRailDestination> _railDestinations =
      <NavigationRailDestination>[
        NavigationRailDestination(
          icon: Icon(Icons.grid_view_rounded),
          label: Text('Gallery'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.favorite_border),
          label: Text('Favorites'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.info_outline),
          label: Text('About'),
        ),
      ];

  Widget _body() => switch (_index) {
    0 => const GalleryScreen(),
    1 => const FavoritesScreen(),
    _ => const AboutScreen(),
  };

  @override
  Widget build(BuildContext context) {
    final layout = LayoutScope.of(context);

    if (layout.isExpanded) {
      return Scaffold(
        body: Row(
          children: <Widget>[
            NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: _select,
              destinations: _railDestinations,
              labelType: MediaQuery.sizeOf(context).width > 1200
                  ? NavigationRailLabelType.all
                  : NavigationRailLabelType.none,
            ),
            const VerticalDivider(width: 1, color: T.divider),
            Expanded(child: _body()),
          ],
        ),
      );
    }

    return Scaffold(
      body: _body(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _select,
        destinations: _barDestinations,
      ),
    );
  }
}
