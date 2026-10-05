import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qlyp_core/widgets/qlyp_chip.dart';

import 'design_test_helpers.dart';

void main() {
  testWidgets('QlypChip selected FR/EN labels', (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(
        child: QlypChip(label: 'Option', selected: true, onSelected: (_) {}),
      ),
    );
    expect(find.text('Option'), findsOneWidget);

    await tester.pumpWidget(
      wrapDesignTest(
        locale: const Locale('en', 'CA'),
        child: QlypChip(label: 'Choice', selected: false, onSelected: (_) {}),
      ),
    );
    expect(find.text('Choice'), findsOneWidget);
  });

  testWidgets('QlypChip toggles on tap', (tester) async {
    var selected = false;
    await tester.pumpWidget(
      wrapDesignTest(
        child: StatefulBuilder(
          builder: (context, setState) {
            return QlypChip(
              label: 'Toggle',
              selected: selected,
              onSelected: (v) => setState(() => selected = v),
            );
          },
        ),
      ),
    );
    await pressCenter(tester, find.text('Toggle'));
    expect(selected, isTrue);
  });

  testWidgets('QlypChip reduce motion', (tester) async {
    await tester.pumpWidget(
      wrapDesignTest(
        disableAnimations: true,
        child: QlypChip(label: 'Chip', selected: false, onSelected: (_) {}),
      ),
    );
    expect(find.text('Chip'), findsOneWidget);
  });
}