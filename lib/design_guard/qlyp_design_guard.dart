import 'dart:convert';
import 'dart:io';

class QlypDesignGuard {
  QlypDesignGuard({
    required this.libRoot,
    List<String>? foundationWhitelist,
    this.deprecatedCoreTokens = defaultDeprecatedCoreTokens,
    this.optionalSheetEscapePatternIds = const [],
    this.optionalAppWidgetPatternIds = const [],
  }) : foundationWhitelist = foundationWhitelist ?? defaultFoundationWhitelist;

  final Directory libRoot;
  final List<String> foundationWhitelist;
  final List<String> deprecatedCoreTokens;

  final List<String> optionalSheetEscapePatternIds;
  final List<String> optionalAppWidgetPatternIds;

  static const defaultOptionalAppWidgetPatternIds = <String>[
    'escape_expansion_tile',
    'escape_list_tile',
    'escape_switch',
    'escape_segmented_button',
    'escape_floating_action_button',
  ];

  static const defaultOptionalSheetEscapePatternIds = <String>[
    'escape_modal_bottom_sheet',
    'escape_get_bottom_sheet',
    'escape_show_bottom_sheet',
  ];

  static const defaultFoundationWhitelist = <String>[
    'lib/constants/qlyp_colors.dart',
    'lib/constants/qlyp_motion.dart',
    'lib/constants/qlyp_animations.dart',
    'lib/config/typography.dart',
    'lib/config/qlyp_theme.dart',
    'lib/config/qlyp_page_transitions.dart',
    'lib/config/qlyp_page_transition.dart',
    'lib/motion/qlyp_motion_accessibility.dart',
  ];

  static const defaultDeprecatedCoreTokens = <String>[
    'kDurS', 'kDurXS', 'kDurProgress', 'kDurL', 'kDurXL',
    'QlypColors.qlypPrimaryFreshGreen', 'QlypColors.qlypSecondaryWarmSand',
    'QlypColors.qlypPrimarySunYellow', 'QlypColors.qlypOffWhite',
    'QlypColors.qlypCharcoal', 'QlypColors.qlypMint', 'QlypColors.qlypCoolGray',
    'QlypColors.qlypSlate', 'QlypColors.qlypRed', 'QlypColors.grey50',
    'QlypColors.grey100', 'QlypColors.grey200', 'QlypColors.grey300',
    'QlypColors.grey400', 'QlypColors.grey500', 'QlypColors.grey600',
    'QlypColors.grey700', 'QlypColors.grey800', 'QlypColors.grey900',
    'QlypColors.danger200',
  ];

  static const patternIds = <String>[
    'color_hex', 'colors_material', 'font_size', 'font_weight', 'duration',
    'curves', 'circular_progress', 'linear_progress', 'ink_well',
    'elevated_button', 'text_button', 'app_colors', 'deprecated_core', 'google_fonts',
  ];

  Iterable<String> get _allPatternIds sync* {
    yield* patternIds;
    if (optionalSheetEscapePatternIds.isNotEmpty) {
      yield* optionalSheetEscapePatternIds;
    }
    if (optionalAppWidgetPatternIds.isNotEmpty) {
      yield* optionalAppWidgetPatternIds;
    }
  }

  Map<String, Map<String, int>> scanCounts() {
    final packageRoot = libRoot.parent;
    final out = <String, Map<String, int>>{};
    for (final entity in libRoot.listSync(recursive: true, followLinks: false)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final rel = _relativePath(packageRoot, entity);
      if (foundationWhitelist.contains(rel)) continue;
      final counts = _countFile(packageRoot, entity);
      if (counts.values.any((c) => c > 0)) out[rel] = counts;
    }
    return out;
  }

  List<DesignGuardHit> scanHits() {
    final packageRoot = libRoot.parent;
    final hits = <DesignGuardHit>[];
    for (final entity in libRoot.listSync(recursive: true, followLinks: false)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final rel = _relativePath(packageRoot, entity);
      if (foundationWhitelist.contains(rel)) continue;
      hits.addAll(_hitsInFile(rel, entity));
    }
    return hits;
  }

  List<String> compareToBaseline(
    Map<String, Map<String, int>> actual,
    Map<String, dynamic> baselineRoot,
  ) {
    final errors = <String>[];
    final files = baselineRoot['files'];
    final baselineFiles = files is Map ? files : <String, dynamic>{};
    for (final entry in actual.entries) {
      final file = entry.key;
      final counts = entry.value;
      final rawBase = baselineFiles[file];
      if (rawBase == null) {
        for (final p in _allPatternIds) {
          final n = counts[p] ?? 0;
          if (n > 0) errors.add('NEW_FILE $file: $p ($n)');
        }
        continue;
      }
      final base = (rawBase as Map).map(
        (k, v) => MapEntry(k.toString(), (v as num).toInt()),
      );
      for (final p in _allPatternIds) {
        final n = counts[p] ?? 0;
        final b = base[p] ?? 0;
        if (n > b) errors.add('$file: $p count $n > baseline $b');
        if (n < b) {
          errors.add('$file: $p count $n < baseline $b (update baseline)');
        }
      }
    }
    return errors;
  }

  static Map<String, dynamic> loadBaseline(File file) {
    final decoded = jsonDecode(file.readAsStringSync(encoding: utf8));
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('invalid baseline root');
    }
    return decoded;
  }

  static void writeBaseline(
    File file,
    Map<String, Map<String, int>> counts, {
    List<String> extraPatternIds = const [],
  }) {
    final sorted = Map<String, Map<String, int>>.fromEntries(
      counts.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    final ids = [...patternIds, ...extraPatternIds];
    final payload = <String, dynamic>{
      'version': 1,
      'files': sorted.map(
        (path, patternCounts) => MapEntry(
          path,
          Map<String, int>.fromEntries(
            ids.map((p) => MapEntry(p, patternCounts[p] ?? 0)),
          ),
        ),
      ),
    };
    file.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(payload),
      encoding: utf8,
    );
  }

  Map<String, int> _countFile(Directory packageRoot, File file) {
    final counts = {for (final p in _allPatternIds) p: 0};
    final rel = _relativePath(packageRoot, file);
    for (final hit in _hitsInFile(rel, file)) {
      counts[hit.patternId] = (counts[hit.patternId] ?? 0) + 1;
    }
    return counts;
  }

  List<DesignGuardHit> _hitsInFile(String relPath, File file) {
    final lines = file.readAsLinesSync(encoding: utf8);
    final hits = <DesignGuardHit>[];
    final colorsRe = RegExp(r'Colors\.(?!transparent\b)');
    final appColorsRe = RegExp(r'\bAppColors\b');
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lineNo = i + 1;
      void add(String patternId) {
        hits.add(DesignGuardHit(
          file: relPath, line: lineNo, patternId: patternId, text: line.trim(),
        ));
      }
      if (line.contains('Color(0x')) add('color_hex');
      if (colorsRe.hasMatch(line)) add('colors_material');
      if (line.contains('fontSize:')) add('font_size');
      if (line.contains('fontWeight:')) add('font_weight');
      if (line.contains('Duration(')) add('duration');
      if (line.contains('Curves.')) add('curves');
      if (line.contains('CircularProgressIndicator')) add('circular_progress');
      if (line.contains('LinearProgressIndicator')) add('linear_progress');
      if (line.contains('InkWell')) add('ink_well');
      if (line.contains('ElevatedButton')) add('elevated_button');
      if (line.contains('TextButton')) add('text_button');
      if (appColorsRe.hasMatch(line)) add('app_colors');
      for (final token in deprecatedCoreTokens) {
        if (line.contains(token)) add('deprecated_core');
      }
      if (optionalSheetEscapePatternIds.contains('escape_modal_bottom_sheet') &&
          line.contains('showModalBottomSheet')) {
        add('escape_modal_bottom_sheet');
      }
      if (optionalSheetEscapePatternIds.contains('escape_get_bottom_sheet') &&
          line.contains('Get.bottomSheet')) {
        add('escape_get_bottom_sheet');
      }
      if (optionalSheetEscapePatternIds.contains('escape_show_bottom_sheet') &&
          line.contains('showBottomSheet')) {
        add('escape_show_bottom_sheet');
      }
      if (line.contains('GoogleFonts.')) add('google_fonts');
    }
    return hits;
  }

  String _relativePath(Directory packageRoot, File file) {
    final full = file.path.replaceAll('\\', '/');
    final root = packageRoot.path.replaceAll('\\', '/');
    if (!full.startsWith(root)) return full;
    var rel = full.substring(root.length);
    if (rel.startsWith('/')) rel = rel.substring(1);
    return rel;
  }
}

class DesignGuardHit {
  const DesignGuardHit({
    required this.file,
    required this.line,
    required this.patternId,
    required this.text,
  });
  final String file;
  final int line;
  final String patternId;
  final String text;
}

List<String> runDesignGuardCheck({
  required Directory packageRoot,
  required File baselineFile,
  List<String>? foundationWhitelist,
  List<String>? deprecatedCoreTokens,
  List<String>? optionalSheetEscapePatternIds,
  List<String>? optionalAppWidgetPatternIds,
}) {
  final guard = QlypDesignGuard(
    libRoot: Directory('${packageRoot.path}/lib'),
    foundationWhitelist: foundationWhitelist,
    deprecatedCoreTokens: deprecatedCoreTokens ?? QlypDesignGuard.defaultDeprecatedCoreTokens,
    optionalSheetEscapePatternIds: optionalSheetEscapePatternIds ?? const [],
    optionalAppWidgetPatternIds: optionalAppWidgetPatternIds ?? const [],
  );
  final baseline = QlypDesignGuard.loadBaseline(baselineFile);
  final actual = guard.scanCounts();
  final errors = guard.compareToBaseline(actual, baseline);
  if (errors.isEmpty) return errors;
  final hits = guard.scanHits();
  final enriched = <String>[...errors];
  for (final err in errors) {
    if (!err.contains('> baseline') && !err.contains('NEW_FILE')) continue;
    final file = err.split(':').first.replaceFirst('NEW_FILE ', '');
    for (final h in hits.where((x) => x.file == file).take(5)) {
      enriched.add('  at ${h.file}:${h.line} [${h.patternId}] ${h.text}');
    }
  }
  return enriched;
}