import 'dart:ui' as ui;

import 'package:aurora/core/layout/repository_scope.dart';
import 'package:aurora/core/rendering/thumbnail_cache.dart';
import 'package:aurora/presentation/details/detail_screen.dart';
import 'package:flutter/material.dart';

import '../../core/layout/layout_scope.dart';
import '../../core/theme/breakpoints.dart';
import '../../core/theme/design_tokens.dart';
import '../../domain/entities/shader_spec.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../domain/shader_catalog.dart';

/// The Favorites tab.
///
/// Thumbnails are **static** — one offscreen render per shader, cached for
/// the app's lifetime. A live list of six shaders on top of whatever the
/// gallery is doing would double the app's raster load for a screen nobody
/// stares at.
///
/// Two layouts by breakpoint: a dense list on phones, a card grid on wide
/// windows. A single column of six items on a 27" monitor is a lot of empty
/// space for no reason.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = RepositoryScope.of(context);

    return ListenableBuilder(
      listenable: repository.changes,
      builder: (context, _) {
        final specs = _resolve(repository);

        if (specs.isEmpty) return const _EmptyState();

        final layout = LayoutScope.of(context);
        return SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: T.maxContentWidth),
              child: layout.isCompact
                  ? _ListView(specs: specs, repository: repository)
                  : _GridView(specs: specs, repository: repository),
            ),
          ),
        );
      },
    );
  }

  /// Preserves the catalog's display order rather than insertion order.
  /// Favoriting Nebula before Aurora shouldn't reorder the list when you
  /// come back — the grid establishes an order, and Favorites should match
  /// the grid.
  static List<ShaderSpec> _resolve(FavoritesRepository repository) {
    final ids = repository.ids.toSet();
    return kShaderCatalog.where((s) => ids.contains(s.id)).toList();
  }
}

class _ListView extends StatelessWidget {
  final List<ShaderSpec> specs;
  final FavoritesRepository repository;

  const _ListView({required this.specs, required this.repository});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: T.s16),
      itemCount: specs.length,
      itemBuilder: (context, index) {
        final spec = specs[index];
        return _FavoriteRow(spec: spec, repository: repository);
      },
    );
  }
}

class _GridView extends StatelessWidget {
  final List<ShaderSpec> specs;
  final FavoritesRepository repository;

  const _GridView({required this.specs, required this.repository});

  @override
  Widget build(BuildContext context) {
    final gutter = LayoutScope.of(context).gridGutter;

    return GridView.builder(
      padding: EdgeInsets.all(gutter),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: LayoutScope.of(context).gridColumns,
        mainAxisSpacing: gutter,
        crossAxisSpacing: gutter,
        childAspectRatio: 1.2,
      ),
      itemCount: specs.length,
      itemBuilder: (context, index) {
        final spec = specs[index];
        return _FavoriteRow(spec: spec, repository: repository);
      },
    );
  }
}

/// One favorites entry. Renders a cached thumbnail rather than a live
/// shader, and dispatches to detail on tap.
class _FavoriteRow extends StatelessWidget {
  final ShaderSpec spec;
  final FavoritesRepository repository;

  const _FavoriteRow({required this.spec, required this.repository});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => DetailScreen(initialId: spec.id),
        ),
      ),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: T.s24, vertical: T.s8),
        child: Row(
          children: <Widget>[
            _Thumbnail(spec: spec, repository: repository),
            const SizedBox(width: T.s16),
            Expanded(
              child: Text(
                spec.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: T.textPrimary,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: T.textSecondary),
              onPressed: () => repository.toggle(spec.id),
            ),
          ],
        ),
      ),
    );
  }
}

/// Renders one thumbnail offscreen and caches it.
///
/// Async because `Picture.toImage` is. The placeholder is a static radial
/// gradient in the shader's default colors, so the row never flashes an
/// empty box — it's already wearing the right palette while the real
/// thumbnail renders.
class _Thumbnail extends StatefulWidget {
  final ShaderSpec spec;
  final FavoritesRepository repository;

  const _Thumbnail({required this.spec, required this.repository});

  @override
  State<_Thumbnail> createState() => _ThumbnailState();
}

class _ThumbnailState extends State<_Thumbnail> {
  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    _image = ThumbnailCache.peek(widget.spec.id);
    if (_image == null) _render();
  }

  Future<void> _render() async {
    final image = await ThumbnailCache.render(
      spec: widget.spec,
      params: widget.repository.paramsFor(widget.spec),
      size: 160,
    );
    if (!mounted) return;
    setState(() => _image = image);
  }

  @override
  Widget build(BuildContext context) {
    final params = widget.repository.paramsFor(widget.spec);

    return ClipRRect(
      borderRadius: BorderRadius.circular(T.rTile),
      child: SizedBox(
        width: 56,
        height: 56,
        child: _image == null
            ? DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: <Color>[params.colorA, params.colorB],
                  ),
                ),
              )
            : RawImage(image: _image, fit: BoxFit.cover),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(T.s24),
        child: Text(
          'No favorites yet.',
          style: TextStyle(fontSize: 15, color: T.textSecondary),
        ),
      ),
    );
  }
}
