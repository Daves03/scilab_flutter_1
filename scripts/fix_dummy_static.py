import os

filepath = 'lib/data/dummy_ar_experiments.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace("static const List<Map<String, dynamic>> _experimentMaps", "const List<Map<String, dynamic>> _experimentMaps")

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)

print('Fixed static modifier!')
