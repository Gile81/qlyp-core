import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// Inter (pubspec test/fixtures) + optional Phosphor for client-style pill goldens.
Future<void> loadPillGoldenFonts({bool phosphor = false}) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  Future<void> loadPackageFont(String family, String assetPath) async {
    final loader = FontLoader(family)
      ..addFont(rootBundle.load(assetPath));
    await loader.load();
  }

  if (phosphor) {
    await loadPackageFont(
      'PhosphorRegular',
      'packages/phosphor_icons/lib/fonts/Phosphor.ttf',
    );
    await loadPackageFont(
      'PhosphorFill',
      'packages/phosphor_icons/lib/fonts/Phosphor-Fill.ttf',
    );
  }

  const interAssets = [
    'test/fixtures/fonts/Inter-Regular.ttf',
    'test/fixtures/fonts/Inter-Medium.ttf',
    'test/fixtures/fonts/Inter-SemiBold.ttf',
    'test/fixtures/fonts/Inter-Bold.ttf',
    'test/fixtures/fonts/Inter-ExtraBold.ttf',
  ];
  final interLoader = FontLoader('Inter');
  for (final path in interAssets) {
    interLoader.addFont(rootBundle.load(path));
  }
  await interLoader.load();

  const materialPaths = [
    'packages/flutter/lib/fonts/MaterialIcons-Regular.otf',
    'fonts/MaterialIcons-Regular.otf',
  ];
  for (final path in materialPaths) {
    try {
      final materialLoader = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load(path));
      await materialLoader.load();
      break;
    } catch (_) {
      // Try next layout.
    }
  }
}
