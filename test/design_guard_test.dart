import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/design_guard/qlyp_design_guard.dart';

void main() {
  test('design guard matches baseline (D21)', () {
    final packageRoot = Directory.current;
    final baselineFile = File('${packageRoot.path}/test/design_guard_baseline.json');
    expect(baselineFile.existsSync(), isTrue);
    final errors = runDesignGuardCheck(
      packageRoot: packageRoot,
      baselineFile: baselineFile,
    );
    expect(errors, isEmpty, reason: errors.join('\n'));
  });
}