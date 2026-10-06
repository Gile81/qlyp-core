import 'dart:io';
import 'package:qlyp_core/design_guard/qlyp_design_guard.dart';

void main() {
  final root = Directory.current;
  final guard = QlypDesignGuard(libRoot: Directory('${root.path}/lib'));
  final counts = guard.scanCounts();
  QlypDesignGuard.writeBaseline(
    File('${root.path}/test/design_guard_baseline.json'),
    counts,
  );
  stdout.writeln('baseline entries: ${counts.length}');
}