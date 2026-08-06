import os

filepath = 'lib/services/ar_service.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# add import for dummy data
if 'dummy_ar_experiments.dart' not in content:
    content = content.replace("import '../models/ar_experiment_model.dart';", "import '../models/ar_experiment_model.dart';\nimport '../data/dummy_ar_experiments.dart';")

# replace experimentsStream
old_stream = '''  Stream<List<ArExperimentModel>> experimentsStream() {
    return _db.collection(_collection).snapshots().map((snap) =>
        snap.docs.map((d) => ArExperimentModel.fromMap(d.id, d.data())).toList());
  }'''

new_stream = '''  Stream<List<ArExperimentModel>> experimentsStream() async* {
    try {
      await for (final snap in _db.collection(_collection).snapshots()) {
        final exps = snap.docs.map((d) => ArExperimentModel.fromMap(d.id, d.data())).toList();
        if (exps.isNotEmpty) {
          yield exps;
        } else {
          yield dummyArExperiments;
        }
      }
    } catch (e) {
      print('AR Service fallback due to error: \');
      yield dummyArExperiments;
    }
  }'''

content = content.replace(old_stream, new_stream)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)

print('Updated ArService')
