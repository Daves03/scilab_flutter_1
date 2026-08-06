import os

filepath = 'lib/models/course_model.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Add field
content = content.replace(
    'final List<CourseQuiz> quizzes;',
    'final List<CourseQuiz> quizzes;\n  final List<String> assignedSections;'
)

# 2. Add to constructor
content = content.replace(
    'required this.quizzes,',
    'required this.quizzes,\n    this.assignedSections = const [],'
)

# 3. Add to fromMap
content = content.replace(
    'quizzes: ((data[\'quizzes\'] as List<dynamic>?) ?? const [])',
    'assignedSections: List<String>.from(data[\'assignedSections\'] ?? const []),\n      quizzes: ((data[\'quizzes\'] as List<dynamic>?) ?? const [])'
)

# 4. Add to toMap
content = content.replace(
    '\'quizzes\': quizzes.map((q) => q.toMap()).toList(),',
    '\'quizzes\': quizzes.map((q) => q.toMap()).toList(),\n        \'assignedSections\': assignedSections,'
)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
print('Updated course_model.dart')
