import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/layout/layout_scope.dart';
import '../../core/theme/breakpoints.dart';
import '../../core/theme/design_tokens.dart';
import '../../domain/shader_catalog.dart';
import 'gallery_tile.dart';

/// The Home tab: a grid of every live shader.
///
/// Layout values come from [LayoutScope], measured once by the shell. This
/// screen never calls `MediaQuery`.
///
/// The stagger animation is deliberately short (40ms per tile, 200ms each)
/// so all six tiles settle within ~440ms. Longer and the grid feels slow
/// on every tab switch; shorter and the eye can't track the entrance.
class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final layout = LayoutScope.of(context);
    final gutter = layout.gridGutter;

    return SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: T.maxContentWidth),
          child: CustomScrollView(
            slivers: <Widget>[
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(T.s24, T.s24, T.s24, T.s16),
                  child: Text(
                    'AURORA',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 0.4,
                      fontWeight: FontWeight.w500,
                      color: T.textSecondary,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(gutter, 0, gutter, gutter + T.s24),
                sliver: SliverGrid.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: layout.gridColumns,
                    mainAxisSpacing: gutter,
                    crossAxisSpacing: gutter,
                    childAspectRatio: 1,
                  ),
                  itemCount: kShaderCatalog.length,
                  itemBuilder: (context, index) {
                    final spec = kShaderCatalog[index];
                    return GalleryTile(
                          spec: spec,
                          resolutionScale: layout.tileResolution,
                        )
                        .animate(delay: (index * 40).ms)
                        .fadeIn(duration: T.fast, curve: T.ease)
                        .moveY(begin: 8, end: 0, duration: T.fast);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
