import re

file_path = "lib/presentation/teacher_courses_screen/widgets/teacher_quiz_manager_widget.dart"

with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

# Replace _addQuiz, _editQuiz, _deleteQuiz with new versions and remove old question handlers
replacement_methods = """
  void _addQuiz() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _UnifiedQuizEditorDialog(
        course: widget.course,
        onSave: (CourseQuiz quiz) {
          setState(() {
            widget.course.quizzes.add(quiz);
            _expandedQuiz = quiz;
          });
          widget.onUpdated();
          context.read<CourseService>().updateCourse(widget.course);
        },
      ),
    );
  }

  void _editQuiz(CourseQuiz quiz) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _UnifiedQuizEditorDialog(
        course: widget.course,
        existingQuiz: quiz,
        onSave: (CourseQuiz updatedQuiz) {
          setState(() {
            final idx = widget.course.quizzes.indexWhere((q) => q.id == quiz.id);
            if (idx != -1) {
              widget.course.quizzes[idx] = updatedQuiz;
              if (_expandedQuiz?.id == quiz.id) _expandedQuiz = updatedQuiz;
            }
          });
          widget.onUpdated();
          context.read<CourseService>().updateCourse(widget.course);
        },
      ),
    );
  }

  void _deleteQuiz(CourseQuiz quiz) {
    showDialog(
      context: context,
      builder: (ctx) => _ConfirmDeleteDialog(
        title: 'Delete Quiz',
        message:
            'Are you sure you want to delete "${quiz.title}"? This cannot be undone.',
        onConfirm: () {
          setState(() {
            widget.course.quizzes.removeWhere((q) => q.id == quiz.id);
            if (_expandedQuiz?.id == quiz.id) _expandedQuiz = null;
          });
          widget.onUpdated();
          context.read<CourseService>().updateCourse(widget.course);
        },
      ),
    );
  }
"""

content = re.sub(r'  void _addQuiz\(\).*?void _showQuizDialog\(CourseQuiz\? existing\) {', replacement_methods + '\n\n  void _showQuizDialog(CourseQuiz? existing) {', content, flags=re.DOTALL | re.MULTILINE)

# Now remove _showQuizDialog and _showQuestionDialog
content = re.sub(r'  void _showQuizDialog\(CourseQuiz\? existing\).*?^  @override\n  Widget build\(BuildContext context\) \{' , '  @override\n  Widget build(BuildContext context) {', content, flags=re.DOTALL | re.MULTILINE)

# Now, we need to remove onAddQuestion, onEditQuestion, onDeleteQuestion from _QuizCard calls in CourseQuizManagerWidget
content = re.sub(r'                      onAddQuestion: \(\) => _addQuestion\(quiz\),\n', '', content)
content = re.sub(r'                      onEditQuestion: \(q\) => _editQuestion\(quiz, q\),\n', '', content)
content = re.sub(r'                      onDeleteQuestion: \(q\) => _deleteQuestion\(quiz, q\),\n', '', content)

# And remove them from _QuizCard constructor and class properties
content = re.sub(r'  final VoidCallback onAddQuestion;\n  final void Function\(CourseQuestion\) onEditQuestion;\n  final void Function\(CourseQuestion\) onDeleteQuestion;\n\n', '', content)
content = re.sub(r'    required this\.onAddQuestion,\n    required this\.onEditQuestion,\n    required this\.onDeleteQuestion,\n', '', content)

# And remove the callbacks from _QuizCard build method (lines 458-494)
# We will just leave "Questions" header and the questions themselves without the "Add Question" button and edit/delete icons on the questions.
# Or better, just remove the edit/delete buttons from _QuestionTile, and the Add Question button from _QuizCard.

content = re.sub(r'                  GestureDetector\(\n                    onTap: onAddQuestion,\n.*?                  \),\n', '', content, flags=re.DOTALL | re.MULTILINE)
content = re.sub(r'                  onEdit: \(\) => onEditQuestion\(q\),\n                  onDelete: \(\) => onDeleteQuestion\(q\),\n', '', content)
content = re.sub(r'  final VoidCallback onEdit;\n  final VoidCallback onDelete;\n\n', '', content)
content = re.sub(r'    required this\.onEdit,\n    required this\.onDelete,\n', '', content)
content = re.sub(r'              _ActionIconBtn\(\n                icon: \'edit\',\n                color: const Color\(0xFFFFB800\),\n                onTap: onEdit,\n              \),\n              const SizedBox\(width: 2\),\n              _ActionIconBtn\(\n                icon: \'delete_outline\',\n                color: const Color\(0xFFFF4757\),\n                onTap: onDelete,\n              \),', '', content, flags=re.DOTALL | re.MULTILINE)

with open(file_path, "w", encoding="utf-8") as f:
    f.write(content)
print("Updated successfully")
