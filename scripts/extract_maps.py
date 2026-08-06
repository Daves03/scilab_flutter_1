import re

with open('temp_maps.txt', 'r', encoding='utf-8') as f:
    text = f.read()

# find where _experimentMaps starts and ends
start_idx = text.find('static const List<Map<String, dynamic>> _experimentMaps = [')
# find the ending ]; before the next widget
end_idx = text.find('];', start_idx) + 2

maps_str = text[start_idx:end_idx]

output_dart = f'''import '../models/ar_experiment_model.dart';

{maps_str}

final List<ArExperimentModel> dummyArExperiments = _experimentMaps
    .map((data) => ArExperimentModel.fromMap(data['id'], data))
    .toList();
'''

os.makedirs('lib/data', exist_ok=True)
with open('lib/data/dummy_ar_experiments.dart', 'w', encoding='utf-8') as f:
    f.write(output_dart)

print('Generated dummy_ar_experiments.dart')
