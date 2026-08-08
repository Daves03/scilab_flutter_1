import '../../../core/app_export.dart';
import '../../../models/course_model.dart';
import '../../../services/course_service.dart';
import 'package:provider/provider.dart';
import '../teacher_courses_screen.dart';

class CourseQuizManagerWidget extends StatefulWidget {
  final Course course;
  final VoidCallback onUpdated;

  const CourseQuizManagerWidget({
    required this.course,
    required this.onUpdated,
    super.key,
  });

  @override
  State<CourseQuizManagerWidget> createState() =>
      _CourseQuizManagerWidgetState();
}

class _CourseQuizManagerWidgetState extends State<CourseQuizManagerWidget> {
  CourseQuiz? _expandedQuiz;


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
  final CourseQuiz quiz;
  final bool isExpanded;
  final Color accentColor;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  
  const _QuizCard({
    required this.quiz,
    required this.isExpanded,
    required this.accentColor,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
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
                        if (quiz.dueDate != null) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const CustomIconWidget(iconName: 'schedule', color: Color(0xFF00D4FF), size: 10),
                              const SizedBox(width: 4),
                              Text(
                                'Due: ${quiz.dueDate!.month}/${quiz.dueDate!.day} at ${_formatTimeOnly(quiz.dueDate!)}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF00D4FF),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
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
                ],
              ),
            ),
            if (quiz.questions.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
                child: Text(
                  'No questions yet. Edit the quiz to add questions.',
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
  final CourseQuestion question;
  final Color accentColor;
  const _QuestionTile({
    required this.index,
    required this.question,
    required this.accentColor,
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
  DateTime? _selectedDueDate;

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
    _selectedDueDate = widget.existingQuiz?.dueDate;
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
      createdAt: widget.existingQuiz?.createdAt ?? DateTime.now(),
      dueDate: _selectedDueDate,
    );

    widget.onSave(quiz);
    Navigator.pop(context);
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (d == null) return;
    
    if (mounted) {
      final t = await showTimePicker(
        context: context,
        initialTime: _selectedDueDate != null 
          ? TimeOfDay.fromDateTime(_selectedDueDate!) 
          : const TimeOfDay(hour: 23, minute: 59),
      );
      if (t == null) return;
      
      setState(() {
        _selectedDueDate = DateTime(d.year, d.month, d.day, t.hour, t.minute);
      });
    }
  }

  Widget _buildDueDatePicker(BuildContext context) {
    return GestureDetector(
      onTap: _pickDueDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF162544),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.course.accentColor.withAlpha(40),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            CustomIconWidget(iconName: 'calendar_month', color: widget.course.accentColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedDueDate != null 
                  ? 'Due: ${_selectedDueDate!.month}/${_selectedDueDate!.day}/${_selectedDueDate!.year} at ${_formatTimeOnly(_selectedDueDate!)}'
                  : 'Set Due Date (Optional)',
                style: TextStyle(
                  fontSize: 14,
                  color: _selectedDueDate != null ? Colors.white : const Color(0xFF8BA3C0),
                ),
              ),
            ),
            if (_selectedDueDate != null)
              GestureDetector(
                onTap: () {
                  setState(() => _selectedDueDate = null);
                },
                child: const CustomIconWidget(iconName: 'close', color: Color(0xFFFF6B6B), size: 18),
              ),
          ],
        ),
      ),
    );
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
                  const SizedBox(height: 16),
                  _buildDueDatePicker(context),
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

String _formatTimeOnly(DateTime dt) {
  final h = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
  final m = dt.minute.toString().padLeft(2, '0');
  final ampm = dt.hour >= 12 ? 'PM' : 'AM';
  return '$h:$m $ampm';
}
