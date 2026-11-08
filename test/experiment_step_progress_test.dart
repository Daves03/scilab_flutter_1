import 'package:flutter_test/flutter_test.dart';
import 'package:scilab_flutter_1/services/experiment_step_progress.dart';

void main() {
  test('yeast can lead the admin order without completing the experiment', () {
    final progress = ExperimentStepProgress(['Yeast', 'Surf', 'Activator']);
    progress.complete('Yeast');
    expect(progress.nextIndex, 1);
    expect(progress.finished, isFalse);
    progress.complete('Activator');
    expect(progress.finished, isFalse);
    progress.complete('Surf');
    expect(progress.finished, isTrue);
  });

  test(
    'compound actions retain progress independently across reordered steps',
    () {
      final progress = ExperimentStepProgress(['Rod1,Rod2', 'Salt-Bottle']);
      progress.complete('Rod1');
      expect(progress.pendingTag(0), 'rod2');
      progress.complete('Salt-Bottle');
      expect(progress.nextIndex, 0);
      expect(progress.complete('Rod1'), StepCompletion.duplicate);
      progress.complete('Rod2');
      expect(progress.finished, isTrue);
    },
  );

  test('explicit aliases need one action and similar names stay distinct', () {
    final progress = ExperimentStepProgress([
      'RedWire,ElectrodeA',
      'blackWire',
    ]);
    progress.complete('ElectrodeA');
    expect(progress.nextIndex, 1);
    expect(experimentTagsMatch('blackWire', '2way-BlackWire'), isFalse);
    expect(experimentTagsMatch('DropperFill', 'DropperDrop'), isFalse);
    expect(experimentTagsMatch('Yeast', 'CustomYeast'), isFalse);
    expect(experimentTagsMatch('Chemical-Bottle', 'chemical_bottle'), isTrue);
    expect(experimentTagsMatch('', ''), isFalse);
    expect(progress.complete('MissingModel'), StepCompletion.unknown);
  });

  test('multi-action progress records every configured action', () {
    final progress = ExperimentStepProgress(['water', 'lemon', 'Litmus']);
    progress.complete('water');
    progress.complete('lemon');
    expect(progress.finished, isFalse);
    progress.complete('Litmus');
    expect(progress.finished, isTrue);
  });
}
