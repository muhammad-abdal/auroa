import 'package:aurora/core/layout/repository_scope.dart';
import 'package:flutter/material.dart';

import '../../domain/repositories/favorites_repository.dart';
import '../theme/design_tokens.dart';

/// A heart that reads and writes a favorite for [shaderId].
///
/// Listens to `repository.changes` so the gallery heart and the detail
/// heart stay in sync without either knowing the other exists — toggle
/// from the detail screen and the grid tile updates on the next frame.
///
/// The pop animation is a [ScaleTransition] driven by a controller that
/// fires once on toggle. It animates the icon, not the widget, so the
/// tap target never moves.
class FavoriteToggle extends StatefulWidget {
  final String shaderId;
  final double size;

  const FavoriteToggle({super.key, required this.shaderId, this.size = 22});

  @override
  State<FavoriteToggle> createState() => _FavoriteToggleState();
}

class _FavoriteToggleState extends State<FavoriteToggle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pop;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _pop, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  Future<void> _toggle(FavoritesRepository repo) async {
    await repo.toggle(widget.shaderId);
    if (!mounted) return;
    _pop.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final repo = RepositoryScope.of(context);

    return ListenableBuilder(
      listenable: repo.changes,
      builder: (context, _) {
        final isFavorite = repo.isFavorite(widget.shaderId);
        return GestureDetector(
          onTap: () => _toggle(repo),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.all(T.s8),
            child: ScaleTransition(
              scale: _scale,
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                size: widget.size,
                color: isFavorite ? T.textPrimary : T.textSecondary,
              ),
            ),
          ),
        );
      },
    );
  }
}
