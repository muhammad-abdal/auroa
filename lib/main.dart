import 'package:aurora/core/rendering/shader_program_cache.dart';
import 'package:aurora/core/storage/favorites_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'app/aurora_app.dart';
import 'domain/shader_catalog.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  final repository = await HiveFavoritesRepository.open();
  await ShaderProgramCache.warmUp(kShaderCatalog);

  runApp(AuroraApp(repository: repository));
}
