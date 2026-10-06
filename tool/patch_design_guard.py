from pathlib import Path
p = Path(__file__).resolve().parent.parent / "lib" / "design_guard" / "qlyp_design_guard.dart"
t = p.read_text(encoding="utf-8")
t = t.replace(
    "    this.optionalSheetEscapePatternIds = const [],\n  }) : foundationWhitelist",
    "    this.optionalSheetEscapePatternIds = const [],\n    this.optionalAppWidgetPatternIds = const [],\n  }) : foundationWhitelist",
)
t = t.replace(
    "  final List<String> optionalSheetEscapePatternIds;\n",
    "  final List<String> optionalSheetEscapePatternIds;\n  final List<String> optionalAppWidgetPatternIds;\n",
)
old = "    'lib/widgets/qlyp_buttons.dart',\n  ];"
new = "    'lib/config/qlyp_page_transitions.dart',\n    'lib/config/qlyp_page_transition.dart',\n    'lib/motion/qlyp_motion_accessibility.dart',\n  ];"
t = t.replace(old, new)
marker = "  static const defaultOptionalSheetEscapePatternIds"
if "defaultOptionalAppWidgetPatternIds" not in t:
    t = t.replace(marker, "  static const defaultOptionalAppWidgetPatternIds = <String>[\n    'escape_expansion_tile',\n    'escape_list_tile',\n    'escape_switch',\n    'escape_segmented_button',\n    'escape_floating_action_button',\n  ];\n\n" + marker)
block = "    if (optionalSheetEscapePatternIds.isNotEmpty) {\n      yield* optionalSheetEscapePatternIds;\n    }\n  }"
if "optionalAppWidgetPatternIds.isNotEmpty" not in t:
    t = t.replace(block, block.replace("\n  }", "\n    if (optionalAppWidgetPatternIds.isNotEmpty) {\n      yield* optionalAppWidgetPatternIds;\n    }\n  }"))
ins = "      if (optionalAppWidgetPatternIds.contains('escape_expansion_tile') &&\n          line.contains('ExpansionTile')) {\n        add('escape_expansion_tile');\n      }\n"
if "escape_expansion_tile" not in t:
    t = t.replace("      if (line.contains('GoogleFonts.')) add('google_fonts');", ins + "      if (line.contains('GoogleFonts.')) add('google_fonts');")
t = t.replace("  List<String>? optionalSheetEscapePatternIds,\n}) {", "  List<String>? optionalSheetEscapePatternIds,\n  List<String>? optionalAppWidgetPatternIds,\n}) {")
t = t.replace("    optionalSheetEscapePatternIds: optionalSheetEscapePatternIds ?? const [],\n  );", "    optionalSheetEscapePatternIds: optionalSheetEscapePatternIds ?? const [],\n    optionalAppWidgetPatternIds: optionalAppWidgetPatternIds ?? const [],\n  );")
p.write_text(t, encoding="utf-8", newline="\n")
print("ok")