import os

filepath = 'lib/presentation/unity_ar_screen/unity_ar_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

start_marker = '// --- GRID SELECTION MENU (When experiment is inactive) ---'
end_marker = '          ],\n        ),\n      ),\n    );\n  }\n}\n'

if start_marker in content and end_marker in content:
    start_idx = content.find(start_marker)
    end_idx = content.find(end_marker)
    
    # We want to replace from start_idx up to end_idx with just the end_marker
    if start_idx != -1 and end_idx != -1:
        new_content = content[:start_idx] + end_marker + content[end_idx + len(end_marker):]
        
        # also remove the _ExperimentCard class
        card_start = new_content.find('class _ExperimentCard extends StatelessWidget')
        if card_start != -1:
            new_content = new_content[:card_start]
            
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print('Grid menu removed')
    else:
        print('Indices not found')
else:
    print('Markers not found')

