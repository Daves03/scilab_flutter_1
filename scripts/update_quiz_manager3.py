import re

file_path = "lib/presentation/teacher_courses_screen/widgets/teacher_quiz_manager_widget.dart"

with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

unified_dialog_code = """

// ── Unified Google Forms-Style Quiz Editor ───────────────────────────────────

class _UnifiedQuizEditorDialog extends StatefulWidget {
  final Course course;
  final CourseQuiz? existingQuiz;
  final void Function(CourseQuiz) onSave;

  const _UnifiedQuizEditorDialog({
    required this.course,
    this.existingQuiz,
    required this.onSave,
  });

  @override
  State<_UnifiedQuizEditorDialog> createState() =>
      _UnifiedQuizEditorDialogState();
}

class _UnifiedQuizEditorDialogState extends State<_UnifiedQuizEditorDialog> {
  late TextEditingController _titleCtrl;
  late List<_QuestionDraft> _questions;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.existingQuiz?.title ?? '');
    if (widget.existingQuiz != null) {
      _questions = widget.existingQuiz!.questions
          .map((q) => _QuestionDraft.fromCourseQuestion(q))
          .toList();
    } else {
      _questions = [_QuestionDraft.empty()];
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    for (var q in _questions) {
      q.dispose();
    }
    super.dispose();
  }

  void _addQuestion() {
    setState(() {
      _questions.add(_QuestionDraft.empty());
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions[index].dispose();
      _questions.removeAt(index);
    });
  }

  void _save() {
    if (_titleCtrl.text.trim().isEmpty) return;

    final validQuestions = <CourseQuestion>[];
    for (var draft in _questions) {
      if (draft.questionCtrl.text.trim().isEmpty) continue;
      final opts = draft.optionCtrls
          .map((c) => c.text.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      if (opts.length < 2) continue;

      validQuestions.add(CourseQuestion(
        id: draft.id,
        question: draft.questionCtrl.text.trim(),
        options: opts,
        correctIndex: draft.correctIndex.clamp(0, opts.length - 1),
        explanation: draft.explanationCtrl.text.trim(),
      ));
    }

    final quiz = CourseQuiz(
      id: widget.existingQuiz?.id ?? 'tq_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleCtrl.text.trim(),
      questions: validQuestions,
    );

    widget.onSave(quiz);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1E35),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: widget.course.accentColor.withAlpha(60),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
              decoration: BoxDecoration(
                color: widget.course.accentColor.withAlpha(15),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: widget.course.accentColor.withAlpha(40),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'quiz',
                    color: widget.course.accentColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.existingQuiz == null ? 'Create Quiz' : 'Edit Quiz',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const CustomIconWidget(
                      iconName: 'close',
                      color: Color(0xFF8BA3C0),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _GlassTextField(
                    controller: _titleCtrl,
                    label: 'Quiz Title',
                    hint: 'e.g. Quiz 1: Carbon Bonding',
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Text(
                        'Questions',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: widget.course.accentColor,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_questions.length} question(s)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8BA3C0),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._questions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final draft = entry.value;
                    return _QuestionEditorCard(
                      index: index,
                      draft: draft,
                      accentColor: widget.course.accentColor,
                      onRemove: () => _removeQuestion(index),
                      onCorrectChanged: (newIdx) {
                        setState(() {
                          draft.correctIndex = newIdx;
                        });
                      },
                    );
                  }),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _addQuestion,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: widget.course.accentColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: widget.course.accentColor.withAlpha(70),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'add',
                            color: widget.course.accentColor,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Add Question',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: widget.course.accentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Footer
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFF3A5A7A),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF8BA3C0),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.course.accentColor,
                        foregroundColor: const Color(0xFF0A1628),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Save Quiz',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionDraft {
  final String id;
  final TextEditingController questionCtrl;
  final List<TextEditingController> optionCtrls;
  int correctIndex;
  final TextEditingController explanationCtrl;

  _QuestionDraft({
    required this.id,
    required this.questionCtrl,
    required this.optionCtrls,
    required this.correctIndex,
    required this.explanationCtrl,
  });

  factory _QuestionDraft.empty() {
    return _QuestionDraft(
      id: 'tqq_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}',
      questionCtrl: TextEditingController(),
      optionCtrls: List.generate(4, (_) => TextEditingController()),
      correctIndex: 0,
      explanationCtrl: TextEditingController(),
    );
  }

  factory _QuestionDraft.fromCourseQuestion(CourseQuestion q) {
    return _QuestionDraft(
      id: q.id,
      questionCtrl: TextEditingController(text: q.question),
      optionCtrls: List.generate(
        4,
        (i) => TextEditingController(
          text: i < q.options.length ? q.options[i] : '',
        ),
      ),
      correctIndex: q.correctIndex,
      explanationCtrl: TextEditingController(text: q.explanation),
    );
  }

  void dispose() {
    questionCtrl.dispose();
    for (var c in optionCtrls) {
      c.dispose();
    }
    explanationCtrl.dispose();
  }
}

class _QuestionEditorCard extends StatelessWidget {
  final int index;
  final _QuestionDraft draft;
  final Color accentColor;
  final VoidCallback onRemove;
  final void Function(int) onCorrectChanged;

  const _QuestionEditorCard({
    required this.index,
    required this.draft,
    required this.accentColor,
    required this.onRemove,
    required this.onCorrectChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF142240),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFF1E3A5F), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onRemove,
                child: const CustomIconWidget(
                  iconName: 'delete_outline',
                  color: Color(0xFFFF4757),
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _GlassTextField(
            controller: draft.questionCtrl,
            label: 'Question',
            hint: 'Enter the question text',
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          Text(
            'Answer Options (Mark correct answer)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(4, (i) {
            final isCorrect = draft.correctIndex == i;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => onCorrectChanged(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCorrect ? accentColor : Colors.transparent,
                        border: Border.all(
                          color: isCorrect ? accentColor : const Color(0xFF3A5A7A),
                          width: 2,
                        ),
                      ),
                      child: isCorrect
                          ? const Icon(
                              Icons.check,
                              size: 13,
                              color: Color(0xFF0A1628),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _GlassTextField(
                      controller: draft.optionCtrls[i],
                      label: 'Option ${String.fromCharCode(65 + i)}',
                      hint: 'Enter option ${String.fromCharCode(65 + i)}',
                      compact: true,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          _GlassTextField(
            controller: draft.explanationCtrl,
            label: 'Explanation (optional)',
            hint: 'Explain why the correct answer is right',
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
"""

with open(file_path, "a", encoding="utf-8") as f:
    f.write(unified_dialog_code)

print("Appended dialog code successfully")
