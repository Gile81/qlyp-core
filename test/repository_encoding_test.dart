import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

final RegExp _mojibake = RegExp(r'[\uFFFD]|\u00c3|\u00e2\u20ac|\ubfef');

bool _isCandidate(String path) {
  if (path == 'pubspec.yaml') return true;
  if (path.startsWith('lib/') || path.startsWith('test/')) return true;
  return false;
}

bool _hasPrefix(List<int> bytes, List<int> prefix) {
  if (bytes.length < prefix.length) return false;
  for (var i = 0; i < prefix.length; i++) {
    if (bytes[i] != prefix[i]) return false;
  }
  return true;
}

bool _looksBinary(List<int> bytes) {
  if (bytes.isEmpty) return false;
  if (_hasPrefix(bytes, [0xEF, 0xBB, 0xBF])) return false;
  if (bytes.length >= 2 && (bytes[0] == 0xFF && bytes[1] == 0xFE)) return true;
  if (bytes.length >= 2 && (bytes[0] == 0xFE && bytes[1] == 0xFF)) return true;
  if (bytes.length >= 2 && bytes[1] == 0x00) return true;
  return false;
}

void main() {
  test('tracked repository text files are utf8 without bom or mojibake', () {
    final root = Directory.current;
    final result = Process.runSync(
      'git',
      ['ls-files'],
      runInShell: true,
      workingDirectory: root.path,
    );
    expect(result.exitCode, 0, reason: result.stderr.toString());
    final paths = (result.stdout as String)
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty && _isCandidate(line))
        .toList();

    final failures = <String>[];
    for (final relative in paths) {
      final file = File('${root.path}${Platform.pathSeparator}$relative');
      if (!file.existsSync()) continue;
      final bytes = file.readAsBytesSync();
      if (_hasPrefix(bytes, [0xEF, 0xBB, 0xBF])) {
        failures.add('BOM: $relative');
        continue;
      }
      if (bytes.contains(0)) {
        failures.add('NUL byte: $relative');
        continue;
      }
      if (_looksBinary(bytes)) {
        failures.add('UTF-16 suspected: $relative');
        continue;
      }
      late final String text;
      try {
        text = utf8.decode(bytes, allowMalformed: false);
      } catch (_) {
        failures.add('Invalid UTF-8: $relative');
        continue;
      }
      var lineNo = 0;
      for (final line in LineSplitter.split(text)) {
        lineNo++;
        if (_mojibake.hasMatch(line)) {
          failures.add('Mojibake: $relative at line $lineNo');
        }
      }
    }

    expect(failures, isEmpty, reason: failures.join('\n'));
  });
}