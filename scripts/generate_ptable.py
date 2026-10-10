import urllib.request
import json

url = "https://raw.githubusercontent.com/Bowserinator/Periodic-Table-JSON/master/PeriodicTableJSON.json"
output_file = r"d:\StudioProjects\scilab_flutter_1\lib\data\periodic_table_data.dart"

req = urllib.request.urlopen(url)
data = json.loads(req.read().decode('utf-8'))

dart_code = '''class ElementData {
  final int atomicNumber;
  final String symbol;
  final String name;
  final String category;
  final double atomicMass;
  final String funFact;

  const ElementData({
    required this.atomicNumber,
    required this.symbol,
    required this.name,
    required this.category,
    required this.atomicMass,
    required this.funFact,
  });
}

// A dictionary linking Atomic Number (1-118) to the Element Data!
final Map<String, ElementData> periodicTable = {
'''

for el in data['elements']:
    number = el.get('number', 0)
    symbol = el.get('symbol', '')
    name = el.get('name', '')
    category = el.get('category', '').title()
    mass = el.get('atomic_mass', 0.0)
    summary = el.get('summary', '').replace('"', '\\"').replace('\n', ' ')
    
    dart_code += f'''  "{number}": const ElementData(
    atomicNumber: {number},
    symbol: "{symbol}",
    name: "{name}",
    category: "{category}",
    atomicMass: {mass},
    funFact: "{summary}",
  ),
'''

dart_code += "};\n"

with open(output_file, 'w', encoding='utf-8') as f:
    f.write(dart_code)

print("Generated all 118 elements successfully!")
