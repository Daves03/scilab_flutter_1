/// Matches model identifiers, including comma-separated actions and aliases.
String canonicalExperimentTag(String value) {
  final tag = value.replaceAll(RegExp(r'[-_\s]'), '').toLowerCase();
  return switch (tag) {
    'electrode' || 'electrodea' || 'redwire' => 'redwire',
    'twowayblackwire' => '2wayblackwire',
    _ => tag,
  };
}

Set<String> experimentTagTokens(String value) => value
    .split(',')
    .map(canonicalExperimentTag)
    .where((tag) => tag.isNotEmpty)
    .toSet();

bool experimentTagsMatch(String first, String second) => experimentTagTokens(
  first,
).intersection(experimentTagTokens(second)).isNotEmpty;

enum StepCompletion { accepted, duplicate, unknown }

/// Tracks the configured actions without assuming a particular final model.
class ExperimentStepProgress {
  ExperimentStepProgress(Iterable<String> tags)
    : requirements = tags.map(experimentTagTokens).toList();

  final List<Set<String>> requirements;
  final Map<int, Set<String>> _done = {};

  String pendingTag(int index) => requirements[index]
      .difference(_done[index] ?? const <String>{})
      .join(',');

  bool isStepComplete(int index) =>
      requirements[index].isNotEmpty &&
      (_done[index]?.containsAll(requirements[index]) ?? false);

  bool get finished =>
      requirements.isNotEmpty &&
      List.generate(
        requirements.length,
        (index) => index,
      ).every(isStepComplete);

  int get nextIndex {
    for (var index = 0; index < requirements.length; index++) {
      if (!isStepComplete(index)) return index;
    }
    return requirements.isEmpty ? 0 : requirements.length - 1;
  }

  StepCompletion complete(String modelTag) {
    if (requirements.isEmpty) return StepCompletion.unknown;
    final tokens = experimentTagTokens(modelTag);
    // Prefer the current unfinished action when a model occurs more than once.
    final current = nextIndex;
    final indices = [
      current,
      for (var index = 0; index < requirements.length; index++)
        if (index != current) index,
    ];
    var known = false;
    for (final index in indices) {
      final matches = requirements[index].intersection(tokens);
      if (matches.isEmpty) continue;
      known = true;
      final done = _done.putIfAbsent(index, () => <String>{});
      final pending = matches.difference(done);
      if (pending.isEmpty) continue;
      done.addAll(pending);
      return StepCompletion.accepted;
    }
    return known ? StepCompletion.duplicate : StepCompletion.unknown;
  }
}
