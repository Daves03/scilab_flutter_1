import 'package:flutter_test/flutter_test.dart';
import 'package:scilab_flutter_1/services/ai_request_retry.dart';

void main() {
  test(
    'recognizes the raw provider high-demand message without a status code',
    () {
      expect(
        isTemporaryAiError(
          Exception(
            'This model is currently experiencing high demand. Spikes in demand are usually temporary. Please try again later.',
          ),
        ),
        isTrue,
      );
      expect(isTemporaryAiError(Exception('503 UNAVAILABLE')), isTrue);
      expect(isTemporaryAiError(Exception('429 quota reached')), isFalse);
      expect(isTemporaryAiError(Exception('Invalid API key')), isFalse);
    },
  );
  test(
    'retries temporary failures with increasing delays then succeeds',
    () async {
      var calls = 0;
      final delays = <Duration>[];
      final result = await retryTemporaryAiRequest(
        () async {
          if (++calls < 3) throw Exception('high demand');
          return 'quiz';
        },
        wait: (delay) async {
          delays.add(delay);
        },
      );
      expect(result, 'quiz');
      expect(calls, 3);
      expect(delays, [const Duration(seconds: 2), const Duration(seconds: 4)]);
    },
  );
  test('stops after two retries when overload continues', () async {
    var calls = 0;
    await expectLater(
      retryTemporaryAiRequest(() async {
        calls++;
        throw Exception('high demand');
      }, wait: (_) async {}),
      throwsException,
    );
    expect(calls, 3);
  });
  test('does not retry quota failures', () async {
    var calls = 0;
    await expectLater(
      retryTemporaryAiRequest(() async {
        calls++;
        throw Exception('429 quota reached');
      }, wait: (_) async {}),
      throwsException,
    );
    expect(calls, 1);
  });
}
