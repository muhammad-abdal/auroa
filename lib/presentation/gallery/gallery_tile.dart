import 'package:aurora/core/layout/repository_scope.dart';
import 'package:aurora/core/rendering/shader_view.dart';
import 'package:aurora/presentation/details/detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/design_tokens.dart';
import '../../domain/entities/shader_spec.dart';

/// One tile in the gallery grid.
///
/// Wraps a live [ShaderView] with the tile's interaction: tap opens detail,
/// long-press toggles favorite, a heart appears bottom-right when favorited.
///
/// The tile listens to `repository.changes` for two reasons — the heart's
/// visibility, and a params write from the customize sheet. When you
/// customize a shader and swipe back to the grid, the tile must reflect the
/// new colors, and the only signal for that is the repository's notifier.
///
/// The [Hero] wraps the shader but not the heart: during the push to
/// detail, the shader flies, the heart stays put and fades with the route.
class GalleryTile extends StatelessWidget {
  final ShaderSpec spec;
  final double resolutionScale;

  const GalleryTile({
    super.key,
    required this.spec,
    required this.resolutionScale,
  });

  void _open(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: T.hero,
        reverseTransitionDuration: T.hero,
        pageBuilder: (_, _, _) => DetailScreen(initialId: spec.id),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  void _toggleFavorite(BuildContext context) {
    HapticFeedback.lightImpact();
    RepositoryScope.of(context).toggle(spec.id);
  }

  @override
  Widget build(BuildContext context) {
    final repository = RepositoryScope.of(context);

    return ListenableBuilder(
      listenable: repository.changes,
      builder: (context, _) {
        final isFavorite = repository.isFavorite(spec.id);
        final params = repository.paramsFor(spec);

        return GestureDetector(
          onTap: () => _open(context),
          onLongPress: () => _toggleFavorite(context),
          behavior: HitTestBehavior.opaque,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(T.rTile),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: 'shader-${spec.id}',
                  child: ShaderView(
                    spec: spec,
                    params: params,
                    resolutionScale: resolutionScale,
                  ),
                ),
                if (isFavorite)
                  const Positioned(
                    right: T.s8,
                    bottom: T.s8,
                    child: Icon(
                      Icons.favorite,
                      size: 16,
                      color: T.textPrimary,
                      shadows: <Shadow>[
                        Shadow(blurRadius: 4, color: Colors.black54),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
