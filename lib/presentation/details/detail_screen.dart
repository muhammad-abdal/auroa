import 'dart:async';

import 'package:aurora/core/layout/repository_scope.dart';
import 'package:aurora/core/rendering/shader_view.dart';
import 'package:aurora/core/services/shader_exporter.dart';
import 'package:aurora/presentation/customize/customize_controller.dart';
import 'package:flutter/material.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/widgets/favorite_toggle.dart';
import '../../core/widgets/glass_pill.dart';
import '../../domain/entities/shader_params.dart';
import '../../domain/entities/shader_spec.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../domain/shader_catalog.dart';
import '../customize/customize_sheet.dart';
import 'playback_indicator.dart';

/// Full-screen view of one shader, swipeable to its neighbors.
///
/// Owns:
///  - the pager and its current index
///  - the current shader's live params (customize edits update the shader
///    behind the sheet in real time)
///  - a per-shader pause set, so pausing Aurora and swiping to Nebula
///    leaves Nebula playing
///
/// The shader is edge-to-edge at every window size. On very wide windows
/// the pager letterboxes to [T.maxShaderAspect]; a 32:9 full-bleed shader
/// is nauseating.
class DetailScreen extends StatefulWidget {
  final String initialId;

  const DetailScreen({super.key, required this.initialId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late final PageController _pager;
  late int _index;

  /// Params for the currently-visible shader. Kept in state so customize
  /// edits repaint without a trip through the repository.
  ShaderParams? _liveParams;

  /// Shaders the user has paused. Per-shader, not global — pausing one
  /// shouldn't stop the others.
  final Set<String> _paused = <String>{};

  Timer? _indicatorTimer;
  bool _indicatorVisible = false;

  ShaderSpec get _spec => kShaderCatalog[_index];

  @override
  void initState() {
    super.initState();
    final initialIndex = kShaderCatalog.indexWhere(
      (s) => s.id == widget.initialId,
    );
    _index = initialIndex < 0 ? 0 : initialIndex;
    _pager = PageController(initialPage: _index);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Resolve params for the initial shader. Deferred to here rather than
    // initState because the repository comes from the tree.
    _liveParams ??= RepositoryScope.of(context).paramsFor(_spec);
  }

  @override
  void dispose() {
    _indicatorTimer?.cancel();
    _pager.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    final repository = RepositoryScope.of(context);
    setState(() {
      _index = index;
      _liveParams = repository.paramsFor(kShaderCatalog[index]);
    });
  }

  bool get _isPaused => _paused.contains(_spec.id);

  void _togglePlayback() {
    setState(() {
      if (_isPaused) {
        _paused.remove(_spec.id);
      } else {
        _paused.add(_spec.id);
      }
      _indicatorVisible = true;
    });
    _indicatorTimer?.cancel();
    _indicatorTimer = Timer(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _indicatorVisible = false);
    });
  }

  Future<void> _openCustomize() async {
    final repository = RepositoryScope.of(context);
    final controller = CustomizeController(repository: repository, spec: _spec);

    // Mirror every slider tick into this screen's state so the shader
    // behind the sheet repaints in real time.
    void sync() => setState(() => _liveParams = controller.params);
    controller.addListener(sync);

    await CustomizeSheet.show(
      context: context,
      spec: _spec,
      controller: controller,
    ).whenComplete(() {
      controller.removeListener(sync);
      // dispose() flushes any pending debounced write, so the box is
      // current by the time we re-read from it.
      controller.dispose();
      if (!mounted) return;
      setState(() => _liveParams = repository.paramsFor(_spec));
    });
  }

  Future<void> _export() async {
    await ShaderExporter.copy(context, _spec, _liveParams ?? _spec.defaults);
  }

  @override
  Widget build(BuildContext context) {
    final repository = RepositoryScope.of(context);
    final params = _liveParams ?? repository.paramsFor(_spec);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final size = MediaQuery.sizeOf(context);

    final containerAspect = size.width / size.height;
    final letterboxed = containerAspect > T.maxShaderAspect;

    return Scaffold(
      backgroundColor: T.bg,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // ── Shader pager ──────────────────────────────────────────
          Center(
            child: letterboxed
                ? AspectRatio(
                    aspectRatio: T.maxShaderAspect,
                    child: _buildPager(repository, params),
                  )
                : _buildPager(repository, params),
          ),

          // ── Tap to toggle playback ───────────────────────────────
          Positioned.fill(
            child: GestureDetector(
              onTap: _togglePlayback,
              behavior: HitTestBehavior.opaque,
            ),
          ),

          // ── Playback confirmation ────────────────────────────────
          Center(
            child: PlaybackIndicator(
              paused: _isPaused,
              visible: _indicatorVisible,
            ),
          ),

          // ── Action pill ──────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomInset + T.s24,
            child: Center(
              child: GlassPill(
                children: <Widget>[
                  FavoriteToggle(shaderId: _spec.id),
                  _PillAction(icon: Icons.tune_rounded, onTap: _openCustomize),
                  _PillAction(icon: Icons.ios_share_rounded, onTap: _export),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPager(FavoritesRepository repository, ShaderParams current) {
    return PageView.builder(
      controller: _pager,
      onPageChanged: _onPageChanged,
      itemCount: kShaderCatalog.length,
      itemBuilder: (context, index) {
        final spec = kShaderCatalog[index];
        final isCurrent = index == _index;
        final params = isCurrent ? current : repository.paramsFor(spec);

        return Hero(
          tag: 'shader-${spec.id}',
          child: ShaderView(
            spec: spec,
            params: params,
            live: !_paused.contains(spec.id),
          ),
        );
      },
    );
  }
}

class _PillAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _PillAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(T.s8),
        child: Icon(icon, size: 22, color: T.textPrimary),
      ),
    );
  }
}
