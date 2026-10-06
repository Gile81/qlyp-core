// ignore_for_file: avoid_print
import 'dart:io';
import 'package:qlyp_core/design_guard/qlyp_design_guard.dart';

void main(List<String> args) {
  final packageRoot = Directory.current;
  if (!File('${packageRoot.path}/pubspec.yaml').existsSync()) {
    stderr.writeln('Run from qlyp_core package root.');
    exit(2);
  }

  String? baselinePath;
  var write = false;
  for (var i = 0; i < args.length; i++) {
    final a = args[i];
    if (a == '--write-baseline') {
      write = true;
      if (i + 1 < args.length) baselinePath = args[++i];
    }
  }

  baselinePath ??= 'test/design_guard_baseline.json';
  final baselineFile = File('${packageRoot.path}/$baselinePath');

  final guard = QlypDesignGuard(
    libRoot: Directory('${packageRoot.path}/lib'),
  );
  final counts = guard.scanCounts();

  if (write) {
    QlypDesignGuard.writeBaseline(baselineFile, counts);
    print('Wrote baseline ${baselineFile.path} (${counts.length} files)');
    exit(0);
  }

  if (!baselineFile.existsSync()) {
    stderr.writeln('Missing baseline ${baselineFile.path}');
    exit(1);
  }
  final errors = runDesignGuardCheck(
    packageRoot: packageRoot,
    baselineFile: baselineFile,
  );
  if (errors.isEmpty) {
    print('Design guard OK');
    exit(0);
  }
  for (final e in errors) {
    stderr.writeln(e);
  }
  exit(1);
}