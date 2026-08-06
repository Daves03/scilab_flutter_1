import '../../../core/app_export.dart';
import '../../../services/course_service.dart';
import '../teacher_courses_screen.dart';

class TeacherQuizManagerWidget extends StatefulWidget {
  final TeacherCourse course;
  final VoidCallback onUpdated;

  const TeacherQuizManagerWidget({
    required this.course,
    required this.onUpdated,
    super.key,
  });

  @override
  State<TeacherQuizManagerWidget> createState() =>
      _TeacherQuizManagerWidgetState();
}

class _TeacherQuizManagerWidgetState extends State<TeacherQuizManagerWidget> {
  TeacherQuiz? _expandedQuiz;

  void _addQuiz() {
    _showQuizDialog(null);
  }

  void _editQuiz(TeacherQuiz quiz) {
    _showQuizDialog(quiz);
  }

  void _deleteQuiz(TeacherQuiz quiz) {
    showDialog(
      context: context,
      builder: (ctx) => _ConfirmDeleteDialog(
        title: 'Delete Quiz',
        message:
            'Are you sure you want to delete "${quiz.title}"? This cannot be undone.',
        onConfirm: () {
          setState(() {
            widget.course.quizzes.removeWhere((q) => q.id == quiz.id);
            if (_expandedQuiz?.id == quiz.id) { _expandedQuiz = null; }
          });
          CourseService().removeQuiz(widget.course.id, quiz.id);
          widget.onUpdated();
        },
      ),
    );
  }

  void _addQuestion(TeacherQuiz quiz) {
    _showQuestionDialog(quiz, null);
  }

  void _editQuestion(TeacherQuiz quiz, TeacherQuestion question) {
    _showQuestionDialog(quiz, question);
  }

  void _deleteQuestion(TeacherQuiz quiz, TeacherQuestion question) {
    showDialog(
      context: context,
      builder: (ctx) => _ConfirmDeleteDialog(
        title: 'Delete Question',
        message: 'Remove this question from the quiz?',
        onConfirm: () {
          setState(() {
            quiz.questions.removeWhere((q) => q.id == question.id);
          });
          CourseService().updateQuiz(widget.course.id, quiz.toCourseQuizModel());
          widget.onUpdated();
        },
      ),
    );
  }

  void _showQuizDialog(TeacherQuiz? existing) {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    showDialog(
      context: context,
      builder: (ctx) => _GlassDialog(
        title: existing == null ? 'Create Quiz' : 'Edit Quiz',
        accentColor: widget.course.accentColor,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GlassTextField(
              controller: titleCtrl,
              label: 'Quiz Title',
              hint: 'e.g. Quiz 1: Carbon Bonding',
            ),
          ],
        ),
        onSave: () {
          if (titleCtrl.text.trim().isEmpty) return;
          late final TeacherQuiz savedQuiz;
          setState(() {
            if (existing == null) {
              savedQuiz = TeacherQuiz(
                id: 'tq_${DateTime.now().millisecondsSinceEpoch}',
                title: titleCtrl.text.trim(),
                questions: [],
              );
              widget.course.quizzes.add(savedQuiz);
            } else {
              existing.title = titleCtrl.text.trim();
              savedQuiz = existing;
            }
          });
          if (existing == null) {
            CourseService().addQuiz(widget.course.id, savedQuiz.toCourseQuizModel());
          } else {
            CourseService().updateQuiz(widget.course.id, savedQuiz.toCourseQuizModel());
          }
          widget.onUpdated();
          Navigator.pop(ctx);
        },
        onCancel: () => Navigator.pop(ctx),
      ),
    );
  }

  void _showQuestionDialog(TeacherQuiz quiz, TeacherQuestion? existing) {
    final questionCtrl = TextEditingController(text: existing?.question ?? '');
    final explanationCtrl = TextEditingController(
      text: existing?.explanation ?? '',
    );
    final optionCtrls = List.generate(
      4,
      (i) => TextEditingController(
        text: (existing != null && i < existing.options.length)
            ? existing.options[i]
            : '',
      ),
    );
    int selectedCorrect = existing?.correctIndex ?? 0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setDialogState) => _GlassDialog(
          title: existing == null ? 'Add Question' : 'Edit Question',
          accentColor: widget.course.accentColor,
          scrollable: true,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GlassTextField(
                controller: questionCtrl,
                label: 'Question',
                hint: 'Enter the question text',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Text(
                'Answer Options',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: widget.course.accentColor,
                ),
              ),
              const SizedBox(height: 8),
              ...List.generate(4, (i) {
                final isCorrect = selectedCorrect == i;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => setDialogState(() => selectedCorrect = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCorrect
                                ? widget.course.accentColor
                                : Colors.transparent,
                            border: Border.all(
                              color: isCorrect
                                  ? widget.course.accentColor
                                  : const Color(0xFF3A5A7A),
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
                          controller: optionCtrls[i],
                          label: 'Option ${String.fromCharCode(65 + i)}',
                          hint: 'Enter option ${String.fromCharCode(65 + i)}',
                          compact: true,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
              Text(
                'Tap the circle to mark the correct answer',
                style: const TextStyle(fontSize: 11, color: Color(0xFF8BA3C0)),
              ),
              const SizedBox(height: 16),
              _GlassTextField(
                controller: explanationCtrl,
                label: 'Explanation (optional)',
                hint: 'Explain why the correct answer is right',
                maxLines: 2,
              ),
            ],
          ),
          onSave: () {
            if (questionCtrl.text.trim().isEmpty) return;
            final opts = optionCtrls
                .map((c) => c.text.trim())
                .where((s) => s.isNotEmpty)
                .toList();
            if (opts.length < 2) { return; }
            setState(() {
              if (existing == null) {
                quiz.questions.add(
                  TeacherQuestion(
                    id: 'tqq_${DateTime.now().millisecondsSinceEpoch}',
                    question: questionCtrl.text.trim(),
                    options: opts,
                    correctIndex: selectedCorrect.clamp(0, opts.length - 1),
                    explanation: explanationCtrl.text.trim(),
                  ),
                );
              } else {
                existing.question = questionCtrl.text.trim();
                existing.options = opts;
                existing.correctIndex = selectedCorrect.clamp(
                  0,
                  opts.length - 1,
                );
                existing.explanation = explanationCtrl.text.trim();
              }
            });
            CourseService().updateQuiz(widget.course.id, quiz.toCourseQuizModel());
            widget.onUpdated();
            Navigator.pop(ctx2);
          },
          onCancel: () => Navigator.pop(ctx2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quizzes = widget.course.quizzes;
    return Column(
      children: [
        // Add quiz button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: SizedBox(
            width: double.infinity,
            child: _AddButton(
              label: 'Create New Quiz',
              icon: 'add_circle_outline',
              color: widget.course.accentColor,
              onTap: _addQuiz,
            ),
          ),
        ),
        // Quiz list
        Expanded(
          child: quizzes.isEmpty
              ? _EmptyState(
                  icon: 'quiz',
                  message:
                      'No quizzes yet.\nTap "Create New Quiz" to get started.',
                  color: widget.course.accentColor,
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: quizzes.length,
                  itemBuilder: (context, index) {
                    final quiz = quizzes[index];
                    final isExpanded = _expandedQuiz?.id == quiz.id;
                    return _QuizCard(
                      quiz: quiz,
                      isExpanded: isExpanded,
                      accentColor: widget.course.accentColor,
                      onToggle: () => setState(() {
                        _expandedQuiz = isExpanded ? null : quiz;
                      }),
                      onEdit: () => _editQuiz(quiz),
                      onDelete: () => _deleteQuiz(quiz),
                      onAddQuestion: () => _addQuestion(quiz),
                      onEditQuestion: (q) => _editQuestion(quiz, q),
                      onDeleteQuestion: (q) => _deleteQuestion(quiz, q),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ── Quiz card with expandable questions ──────────────────────────────────────

class _QuizCard extends StatelessWidget {
  final TeacherQuiz quiz;
  final bool isExpanded;
  final Color accentColor;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddQuestion;
  final void Function(TeacherQuestion) onEditQuestion;
  final void Function(TeacherQuestion) onDeleteQuestion;

  const _QuizCard({
    required this.quiz,
    required this.isExpanded,
    required this.accentColor,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.onAddQuestion,
    required this.onEditQuestion,
    required this.onDeleteQuestion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF142240),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isExpanded
              ? accentColor.withAlpha(80)
              : const Color(0xFF1E3A5F),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Quiz header
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: accentColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: 'quiz',
                        color: accentColor,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quiz.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${quiz.questions.length} question${quiz.questions.length == 1 ? '' : 's'}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF8BA3C0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Edit / Delete actions
                  _ActionIconBtn(
                    icon: 'edit',
                    color: const Color(0xFFFFB800),
                    onTap: onEdit,
                  ),
                  const SizedBox(width: 4),
                  _ActionIconBtn(
                    icon: 'delete_outline',
                    color: const Color(0xFFFF4757),
                    onTap: onDelete,
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const CustomIconWidget(
                      iconName: 'expand_more',
                      color: Color(0xFF8BA3C0),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expanded questions
          if (isExpanded) ...[
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 14),
              color: const Color(0xFF1E3A5F),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Questions',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: onAddQuestion,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(50.0),
                        border: Border.all(
                          color: accentColor.withAlpha(60),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomIconWidget(
                            iconName: 'add',
                            color: accentColor,
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Add Question',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: accentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (quiz.questions.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
                child: Text(
                  'No questions yet. Tap "Add Question" to begin.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8BA3C0),
                  ),
                ),
              )
            else
              ...quiz.questions.asMap().entries.map((entry) {
                final i = entry.key;
                final q = entry.value;
                return _QuestionTile(
                  index: i,
                  question: q,
                  accentColor: accentColor,
                  onEdit: () => onEditQuestion(q),
                  onDelete: () => onDeleteQuestion(q),
                );
              }),
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}

class _QuestionTile extends StatelessWidget {
  final int index;
  final TeacherQuestion question;
  final Color accentColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _QuestionTile({
    required this.index,
    required this.question,
    required this.accentColor,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E35),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFF1E3A5F), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  question.question,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              _ActionIconBtn(
                icon: 'edit',
                color: const Color(0xFFFFB800),
                onTap: onEdit,
              ),
              const SizedBox(width: 2),
              _ActionIconBtn(
                icon: 'delete_outline',
                color: const Color(0xFFFF4757),
                onTap: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...question.options.asMap().entries.map((entry) {
            final i = entry.key;
            final opt = entry.value;
            final isCorrect = i == question.correctIndex;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCorrect
                          ? const Color(0xFF00FF88).withAlpha(30)
                          : Colors.transparent,
                      border: Border.all(
                        color: isCorrect
                            ? const Color(0xFF00FF88)
                            : const Color(0xFF3A5A7A),
                        width: 1.5,
                      ),
                    ),
                    child: isCorrect
                        ? const Icon(
                            Icons.check,
                            size: 10,
                            color: Color(0xFF00FF88),
                          )
                        : null,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      opt,
                      style: TextStyle(
                        fontSize: 12,
                        color: isCorrect
                            ? const Color(0xFF00FF88)
                            : const Color(0xFF8BA3C0),
                        fontWeight: isCorrect
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Shared dialog & field components ─────────────────────────────────────────

class _GlassDialog extends StatelessWidget {
  final String title;
  final Color accentColor;
  final Widget content;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final bool scrollable;

  const _GlassDialog({
    required this.title,
    required this.accentColor,
    required this.content,
    required this.onSave,
    required this.onCancel,
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1E35),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: accentColor.withAlpha(60), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title bar
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
              decoration: BoxDecoration(
                color: accentColor.withAlpha(15),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: accentColor.withAlpha(40),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'edit_note',
                    color: accentColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onCancel,
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
            scrollable
                ? ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.55,
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: content,
                    ),
                  )
                : Padding(padding: const EdgeInsets.all(20), child: content),
            // Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
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
                      onPressed: onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: const Color(0xFF0A1628),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Save',
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

class _GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;
  final bool compact;

  const _GlassTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!compact) ...[
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8BA3C0),
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 13, color: Colors.white),
          decoration: InputDecoration(
            hintText: compact ? label : hint,
            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF4A6A8A)),
            filled: true,
            fillColor: const Color(0xFF142240),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: compact ? 10 : 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(color: Color(0xFF1E3A5F), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(color: Color(0xFF1E3A5F), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(
                color: Color(0xFF00D4FF),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ConfirmDeleteDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onConfirm;

  const _ConfirmDeleteDialog({
    required this.title,
    required this.message,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1E35),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: const Color(0x44FF4757), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CustomIconWidget(
              iconName: 'warning_amber',
              color: Color(0xFFFF4757),
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 13, color: Color(0xFF8BA3C0)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
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
                    onPressed: () {
                      Navigator.pop(context);
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4757),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Delete',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionIconBtn extends StatelessWidget {
  final String icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionIconBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: CustomIconWidget(iconName: icon, color: color, size: 15),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String icon;
  final String message;
  final Color color;

  const _EmptyState({
    required this.icon,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: icon,
            color: color.withAlpha(80),
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(fontSize: 13, color: Color(0xFF8BA3C0)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final String label;
  final String icon;
  final Color color;
  final VoidCallback onTap;

  const _AddButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(color: color.withAlpha(70), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(iconName: icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


