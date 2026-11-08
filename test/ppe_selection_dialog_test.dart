import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scilab_flutter_1/models/ppe_selection.dart';
import 'package:scilab_flutter_1/presentation/unity_ar_screen/widgets/ppe_selection_dialog.dart';

void main() {
  testWidgets(
    'custom PPE labels, correct choices and first-attempt feedback are used',
    (tester) async {
      tester.view.physicalSize = const Size(1000, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      const choices = [
        PpeOption(
          id: 'custom',
          label: 'Teacher PPE',
          icon: Icons.shield,
          reason: 'Teacher feedback',
        ),
        PpeOption(
          id: 'extra',
          label: 'Optional PPE',
          icon: Icons.shield,
          reason: 'Optional feedback',
        ),
      ];
      PpeSelectionResult? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  result = await showDialog<PpeSelectionResult>(
                    context: context,
                    builder: (_) => const PpeSelectionDialog(
                      experimentTitle: 'Teacher experiment',
                      requiredPpe: {'custom'},
                      options: choices,
                    ),
                  );
                },
                child: const Text('Open PPE'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open PPE'));
      await tester.pumpAndSettle();
      expect(find.text('Safety goggles'), findsNothing);
      await tester.tap(find.text('Optional PPE'));
      await tester.tap(find.text('Check PPE'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Teacher feedback'), findsOneWidget);
      expect(result, isNull);
      await tester.tap(find.text('Optional PPE'));
      await tester.tap(find.text('Teacher PPE'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(result?.selected, {'custom'});
      expect(result?.score, 0);
      expect(result?.firstAttemptMissing, {'custom'});
      expect(result?.firstAttemptUnnecessary, {'extra'});
      expect(result?.options.first.label, 'Teacher PPE');
    },
  );
}
