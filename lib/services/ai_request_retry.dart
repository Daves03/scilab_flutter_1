bool isTemporaryAiError(Object error) {
  final message = error.toString().toLowerCase();
  if (message.contains('quota') ||
      message.contains('429') ||
      message.contains('api key') ||
      message.contains('payment')) {
    return false;
  }
  return message.contains('high demand') ||
      message.contains('overloaded') ||
      message.contains('temporarily unavailable') ||
      message.contains('service unavailable') ||
      message.contains('503') ||
      message.contains('502') ||
      message.contains('504');
}

Future<T> retryTemporaryAiRequest<T>(
  Future<T> Function() request, {
  Future<void> Function(Duration)? wait,
  void Function(int retry, Duration delay)? onRetry,
}) async {
  for (var attempt = 0; ; attempt++) {
    try {
      return await request();
    } catch (error) {
      if (attempt >= 2 || !isTemporaryAiError(error)) rethrow;
      final delay = Duration(seconds: 2 << attempt);
      onRetry?.call(attempt + 1, delay);
      await (wait ?? Future<void>.delayed)(delay);
    }
  }
}
