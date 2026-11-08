"""Regenerate the web editor's initial assessments from the Flutter defaults."""
import ast
import json
import re
from pathlib import Path

root = Path(__file__).resolve().parent.parent
quoted = r"""(?:'(?:\\.|[^'\\])*'|"(?:\\.|[^"\\])*")"""
ppe_source = (root / 'lib/models/ppe_selection.dart').read_text(encoding='utf-8')
options = []
for block in re.findall(r'PpeOption\(\s*id:.*?\n  \)', ppe_source, re.S):
    options.append({
        field: ast.literal_eval(re.search(rf'{field}:\s*({quoted})', block).group(1))
        for field in ('id', 'label', 'reason')
    })
required_source = ppe_source.split('requiredPpeByExperiment = {', 1)[1].split('\n};', 1)[0]
required = {
    key: [ast.literal_eval(value) for value in re.findall(quoted, values)]
    for key, values in re.findall(r"'(\d+)':\s*(?:<String>)?\{([^}]+|)\}", required_source)
}
question_source = (root / 'lib/data/experiment_assessment_data.dart').read_text(encoding='utf-8')
questions = {}
for key, block in re.findall(r"^  '(\d+)': \[(.*?)^  \],", question_source, re.S | re.M):
    questions[key] = []
    for item in re.findall(r'ExperimentQuestion\((.*?)\n    \),', block, re.S):
        prompt = ast.literal_eval(re.search(rf'prompt:\s*({quoted})', item).group(1))
        answers = re.search(r'options:\s*\[(.*?)\]', item, re.S).group(1)
        questions[key].append({
            'prompt': prompt,
            'options': [ast.literal_eval(value) for value in re.findall(quoted, answers)],
            'correctOption': int(re.search(r'correctOption:\s*(\d+)', item).group(1)),
        })
assert len(options) == 8 and len(required) == 8 and len(questions) == 8
assert all(5 <= len(items) <= 10 and all(len(item['options']) == 4 for item in items) for items in questions.values())
target = root / 'admin_web/src/data/experimentAssessmentDefaults.json'
target.parent.mkdir(parents=True, exist_ok=True)
target.write_text(json.dumps({
    'ppeOptions': options,
    'requiredPpeByExperiment': required,
    'questionsByExperiment': questions,
}, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
print(f'Exported PPE defaults and {sum(map(len, questions.values()))} questions to {target}')
