import 'package:aurora/core/layout/repository_scope.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../core/layout/layout_scope.dart';
import '../core/rendering/shader_clock.dart';
import '../core/theme/aurora_theme.dart';
import '../core/theme/breakpoints.dart';
import '../domain/repositories/favorites_repository.dart';
import 'aurora_shell.dart';

class AuroraApp extends StatefulWidget {
  final FavoritesRepository repository;

  const AuroraApp({super.key, required this.repository});

  @override
  State<AuroraApp> createState() => _AuroraAppState();
}

class _AuroraAppState extends State<AuroraApp>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<double> _time = ValueNotifier<double>(0);
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      _time.value = elapsed.inMicroseconds / 1e6;
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryScope(
      repository: widget.repository,
      child: ShaderClock(
        time: _time,
        child: Listener(
          onPointerDown: (event) {
            if (event.buttons == kSecondaryMouseButton ||
                event.buttons == kMiddleMouseButton) {
              return;
            }
          },
          child: MaterialApp(
            title: 'Aurora',
            debugShowCheckedModeBanner: false,
            theme: AuroraTheme.dark,
            home: LayoutBuilder(
              builder: (context, constraints) {
                return LayoutScope(
                  layout: layoutFor(constraints.biggest),
                  child: const AuroraShell(),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
