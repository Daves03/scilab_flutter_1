import '../../../core/app_export.dart';
import '../../../models/course_model.dart';
import '../../../services/course_service.dart';
import '../../../services/ai_quiz_generator_service.dart';
import '../../../services/office_document_text_extractor.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

enum _QuizCreationMethod { manual, ai }

class _AiQuizOptions {
  final CourseModule module;
  final Map<CourseQuestionType, int> questionCounts;

  const _AiQuizOptions({required this.module, required this.questionCounts});
}

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

  Future<void> _addQuiz() async {
    final method = await showDialog<_QuizCreationMethod>(
      context: context,
      builder: (context) => _QuizCreationMethodDialog(
        hasModules: widget.course.modules.any(
          (module) =>
              module.url.isNotEmpty &&
              const {'pdf', 'doc', 'ppt'}.contains(module.fileType),
        ),
      ),
    );
    if (!mounted || method == null) return;

    if (method == _QuizCreationMethod.ai) {
      await _generateAiQuiz();
      return;
    }

    final selectedTypes = await showDialog<Set<CourseQuestionType>>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _QuizTypeSelectionDialog(),
    );
    if (!mounted || selectedTypes == null || selectedTypes.isEmpty) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _UnifiedQuizEditorDialog(
        course: widget.course,
        questionTypes: selectedTypes,
        onSave: (CourseQuiz quiz) {
          setState(() {
            widget.course.quizzes.insert(0, quiz);
            _expandedQuiz = quiz;
          });
          widget.onUpdated();
          context.read<CourseService>().updateCourse(widget.course);
        },
      ),
    );
  }

  Future<void> _generateAiQuiz() async {
    final supportedModules = widget.course.modules
        .where(
          (module) =>
              module.url.isNotEmpty &&
              const {'pdf', 'doc', 'ppt'}.contains(module.fileType),
        )
        .toList();
    if (supportedModules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Upload a PDF, Word, or PowerPoint module before using the AI quiz generator.',
          ),
        ),
      );
      return;
    }

    final options = await showDialog<_AiQuizOptions>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _AiQuizGeneratorDialog(modules: supportedModules),
    );
    if (!mounted || options == null) return;

    final courseService = context.read<CourseService>();
    BuildContext? loadingDialogContext;
    void closeLoadingDialog() {
      final dialogContext = loadingDialogContext;
      loadingDialogContext = null;
      if (dialogContext != null && dialogContext.mounted) {
        Navigator.of(dialogContext).pop();
      }
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        loadingDialogContext = dialogContext;
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 18),
                Flexible(child: Text('AI is reading the module...')),
              ],
            ),
          ),
        );
      },
    );

    final aiService = AiQuizGeneratorService();
    var insertedQuizzes = <CourseQuiz>[];
    try {
      final response = await http
          .get(Uri.parse(options.module.url))
          .timeout(const Duration(minutes: 2));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Module download failed (${response.statusCode}).');
      }

      String? extractedText;
      if (options.module.fileType == 'doc' ||
          options.module.fileType == 'ppt') {
        extractedText = OfficeDocumentTextExtractor.extract(
          bytes: response.bodyBytes,
          fileName: options.module.title,
        ).text;
      }
      final quizzes = await aiService.generateQuizzesFromDocument(
        response.bodyBytes,
        options.module.title,
        numQuizzes: 1,
        numQuestions: options.questionCounts.values.fold(0, (a, b) => a + b),
        mimeType: options.module.fileType == 'pdf'
            ? 'application/pdf'
            : 'text/plain',
        extractedDocumentText: extractedText,
        sourceFileName: options.module.title,
        questionTypes: options.questionCounts.keys.toSet(),
        questionTypeCounts: options.questionCounts,
      );
      if (quizzes == null || quizzes.isEmpty) {
        throw Exception(
          aiService.lastErrorMessage ?? 'AI did not return a combined quiz.',
        );
      }
      if (!mounted) return;

      widget.course.quizzes.insertAll(0, quizzes);
      insertedQuizzes = quizzes;
      await courseService.updateCourse(widget.course);
      closeLoadingDialog();
      if (!mounted) return;
      setState(() => _expandedQuiz = quizzes.first);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${quizzes.length} AI quiz${quizzes.length == 1 ? '' : 'zes'} created from ${options.module.title}.',
          ),
        ),
      );
      widget.onUpdated();
    } catch (error) {
      closeLoadingDialog();
      if (insertedQuizzes.isNotEmpty) {
        final insertedIds = insertedQuizzes.map((quiz) => quiz.id).toSet();
        widget.course.quizzes.removeWhere(
          (quiz) => insertedIds.contains(quiz.id),
        );
      }
      if (!mounted) return;
      final message = error.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not generate the quiz: $message')),
      );
    } finally {
      closeLoadingDialog();
    }
  }

  void _editQuiz(CourseQuiz quiz) {
    final questionTypes = quiz.questions.map((q) => q.type).toSet();
    if (questionTypes.isEmpty) {
      questionTypes.add(CourseQuestionType.multipleChoice);
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _UnifiedQuizEditorDialog(
        course: widget.course,
        existingQuiz: quiz,
        questionTypes: questionTypes,
        onSave: (CourseQuiz updatedQuiz) {
          setState(() {
            final idx = widget.course.quizzes.indexWhere(
              (q) => q.id == quiz.id,
            );
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
    final courseService = context.read<CourseService>();
    showDialog(
      context: context,
      builder: (ctx) => _ConfirmDeleteDialog(
        title: 'Delete Quiz',
        message:
            'Are you sure you want to delete "${quiz.title}"? This cannot be undone.',
        onConfirm: () async {
          try {
            await courseService.removeQuiz(widget.course.id, quiz.id);
            if (!mounted) return;

            setState(() {
              widget.course.quizzes.removeWhere((q) => q.id == quiz.id);
              if (_expandedQuiz?.id == quiz.id) _expandedQuiz = null;
            });
            widget.onUpdated();
          } catch (_) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Could not delete the quiz. Please check your connection and try again.',
                ),
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quizzes = widget.course.quizzes;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final accentColor =
        (isLight && widget.course.accentColor == const Color(0xFF00D4FF))
        ? const Color(0xFF1565C0)
        : widget.course.accentColor;

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
              color: accentColor,
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
                  color: accentColor,
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
                      accentColor: accentColor,
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
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF142240)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isExpanded
              ? accentColor.withAlpha(80)
              : (Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1E3A5F)
                    : Colors.grey.shade300),
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
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${quiz.questions.length} question${quiz.questions.length == 1 ? '' : 's'}',
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF8BA3C0)
                                : Colors.grey.shade600,
                          ),
                        ),
                        if (quiz.dueDate != null) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'schedule',
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0xFF00D4FF)
                                    : const Color(0xFF1565C0),
                                size: 10,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Due: ${quiz.dueDateLabel}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color(0xFF00D4FF)
                                      : const Color(0xFF1565C0),
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
                    child: CustomIconWidget(
                      iconName: 'expand_more',
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF8BA3C0)
                          : Colors.grey.shade600,
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
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E3A5F)
                  : Colors.grey.shade300,
            ),
            if (quiz.directions.trim().isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(14, 10, 14, 2),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accentColor.withAlpha(45)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Directions',
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      quiz.directions,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFFB7C9DD)
                            : Colors.grey.shade700,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
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
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF8BA3C0)
                        : Colors.grey.shade600,
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
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF0F1E35)
            : Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E3A5F)
              : Colors.grey.shade300,
          width: 1,
        ),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withAlpha(18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        question.type.label,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      question.question,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (question.type == CourseQuestionType.identification ||
              question.type == CourseQuestionType.enumeration)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF00FF88).withAlpha(12),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: const Color(0xFF00FF88).withAlpha(55),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 16,
                    color: Color(0xFF00FF88),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      'Correct: ${question.correctAnswers.join(', ')}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF00C875),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
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
                              : (Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0xFF8BA3C0)
                                    : Colors.grey.shade600),
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
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!compact) ...[
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isLight ? Colors.grey.shade600 : const Color(0xFF8BA3C0),
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: 13,
            color: isLight ? Colors.black87 : Colors.white,
          ),
          decoration: InputDecoration(
            hintText: compact ? label : hint,
            hintStyle: TextStyle(
              fontSize: 12,
              color: isLight ? Colors.grey.shade500 : const Color(0xFF4A6A8A),
            ),
            filled: true,
            fillColor: isLight ? Colors.white : const Color(0xFF142240),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: compact ? 10 : 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: isLight ? Colors.grey.shade300 : const Color(0xFF1E3A5F),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: isLight ? Colors.grey.shade300 : const Color(0xFF1E3A5F),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: isLight
                    ? const Color(0xFF1565C0)
                    : const Color(0xFF00D4FF),
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
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bgColor = isLight ? Colors.white : const Color(0xFF0F1E35);
    final borderColor = isLight
        ? const Color(0x22FF4757)
        : const Color(0x44FF4757);
    final titleColor = isLight ? const Color(0xFF1E253F) : Colors.white;
    final textColor = isLight
        ? const Color(0xFF6C7B90)
        : const Color(0xFF8BA3C0);
    final btnBorderColor = isLight
        ? Colors.grey.shade300
        : const Color(0xFF3A5A7A);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: isLight
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
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
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(fontSize: 13, color: textColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: btnBorderColor, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: textColor,
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

class _QuizCreationMethodDialog extends StatelessWidget {
  final bool hasModules;

  const _QuizCreationMethodDialog({required this.hasModules});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final accent = isLight ? const Color(0xFF1565C0) : const Color(0xFF00D4FF);

    Widget option({
      required IconData icon,
      required String title,
      required String description,
      required VoidCallback? onTap,
    }) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isLight ? Colors.grey.shade50 : const Color(0xFF142240),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: onTap != null
                ? accent.withAlpha(70)
                : Colors.grey.withAlpha(50),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: onTap != null ? accent : Colors.grey, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: onTap != null
                          ? (isLight ? Colors.black87 : Colors.white)
                          : Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: TextStyle(
                      color: isLight
                          ? Colors.grey.shade600
                          : const Color(0xFF8BA3C0),
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: onTap != null ? accent : Colors.grey,
            ),
          ],
        ),
      ),
    );

    return AlertDialog(
      title: const Text('Create Quiz'),
      content: SizedBox(
        width: 430,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            option(
              icon: Icons.edit_note_rounded,
              title: 'Create Manually',
              description: 'Write and configure each quiz question yourself.',
              onTap: () => Navigator.pop(context, _QuizCreationMethod.manual),
            ),
            const SizedBox(height: 12),
            option(
              icon: Icons.auto_awesome_rounded,
              title: 'AI Quiz Generator',
              description: hasModules
                  ? 'Choose an uploaded module and generate questions from it.'
                  : 'Upload a module first to use the AI quiz generator.',
              onTap: hasModules
                  ? () => Navigator.pop(context, _QuizCreationMethod.ai)
                  : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class _AiQuizGeneratorDialog extends StatefulWidget {
  final List<CourseModule> modules;

  const _AiQuizGeneratorDialog({required this.modules});

  @override
  State<_AiQuizGeneratorDialog> createState() => _AiQuizGeneratorDialogState();
}

class _AiQuizGeneratorDialogState extends State<_AiQuizGeneratorDialog> {
  late CourseModule _module;
  final Set<CourseQuestionType> _types = {CourseQuestionType.multipleChoice};
  final Map<CourseQuestionType, int> _itemCounts = {
    CourseQuestionType.multipleChoice: 5,
  };

  int get _totalItems => _itemCounts.values.fold(0, (a, b) => a + b);

  @override
  void initState() {
    super.initState();
    _module = widget.modules.first;
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final accent = isLight ? const Color(0xFF1565C0) : const Color(0xFF00D4FF);
    final foreground = isLight ? Colors.black87 : Colors.white;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 680),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 12),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, color: accent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'AI Quiz Generator',
                      style: TextStyle(
                        color: foreground,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Module',
                    style: TextStyle(
                      color: foreground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 7),
                  DropdownButtonFormField<CourseModule>(
                    initialValue: _module,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description_outlined),
                    ),
                    items: widget.modules
                        .map(
                          (module) => DropdownMenuItem(
                            value: module,
                            child: Text(
                              module.title,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (module) {
                      if (module != null) setState(() => _module = module);
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Question Types',
                    style: TextStyle(
                      color: foreground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...CourseQuestionType.values.map(
                    (type) => CheckboxListTile(
                      value: _types.contains(type),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      activeColor: accent,
                      title: Text(type.label),
                      onChanged: !_types.contains(type) && _totalItems >= 20
                          ? null
                          : (selected) => setState(() {
                              if (selected == true) {
                                _types.add(type);
                                _itemCounts[type] = 1;
                              } else if (_types.length > 1) {
                                _types.remove(type);
                                _itemCounts.remove(type);
                              }
                            }),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Number of items for each type',
                          style: TextStyle(
                            color: foreground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '$_totalItems/20 total',
                        style: TextStyle(
                          color: accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._types.map(
                    (type) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(child: Text(type.label)),
                          IconButton.outlined(
                            visualDensity: VisualDensity.compact,
                            onPressed: _itemCounts[type] == 1
                                ? null
                                : () => setState(
                                    () => _itemCounts[type] =
                                        _itemCounts[type]! - 1,
                                  ),
                            icon: const Icon(Icons.remove_rounded, size: 18),
                          ),
                          SizedBox(
                            width: 34,
                            child: Text(
                              '${_itemCounts[type]}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton.outlined(
                            visualDensity: VisualDensity.compact,
                            onPressed: _totalItems >= 20
                                ? null
                                : () => setState(
                                    () => _itemCounts[type] =
                                        _itemCounts[type]! + 1,
                                  ),
                            icon: const Icon(Icons.add_rounded, size: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () => Navigator.pop(
                        context,
                        _AiQuizOptions(
                          module: _module,
                          questionCounts: {
                            for (final type in _types) type: _itemCounts[type]!,
                          },
                        ),
                      ),
                      icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('Generate', maxLines: 1, softWrap: false),
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

class _QuizTypeSelectionDialog extends StatefulWidget {
  const _QuizTypeSelectionDialog();

  @override
  State<_QuizTypeSelectionDialog> createState() =>
      _QuizTypeSelectionDialogState();
}

class _QuizTypeSelectionDialogState extends State<_QuizTypeSelectionDialog> {
  final Set<CourseQuestionType> _selectedTypes = {};

  String _description(CourseQuestionType type) => switch (type) {
    CourseQuestionType.multipleChoice =>
      'Students choose one correct answer from several options.',
    CourseQuestionType.trueFalse =>
      'Students decide whether each statement is true or false.',
    CourseQuestionType.identification =>
      'Students type a short answer that identifies the correct term.',
    CourseQuestionType.enumeration =>
      'Students provide every item requested by the question.',
  };

  IconData _icon(CourseQuestionType type) => switch (type) {
    CourseQuestionType.multipleChoice => Icons.checklist_rounded,
    CourseQuestionType.trueFalse => Icons.rule_rounded,
    CourseQuestionType.identification => Icons.short_text_rounded,
    CourseQuestionType.enumeration => Icons.format_list_numbered_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final accentColor = isLight
        ? const Color(0xFF1565C0)
        : const Color(0xFF00D4FF);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 650),
        decoration: BoxDecoration(
          color: isLight ? Colors.white : const Color(0xFF0F1E35),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accentColor.withAlpha(70)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isLight ? 30 : 90),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 14),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: accentColor.withAlpha(22),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(
                      Icons.quiz_outlined,
                      color: accentColor,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choose Quiz Types',
                          style: TextStyle(
                            color: isLight ? Colors.black87 : Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Select one or more question types.',
                          style: TextStyle(
                            color: isLight
                                ? Colors.grey.shade600
                                : const Color(0xFF8BA3C0),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    color: const Color(0xFF8BA3C0),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: isLight ? Colors.grey.shade200 : const Color(0xFF1E3A5F),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(16),
                children: CourseQuestionType.values.map((type) {
                  final selected = _selectedTypes.contains(type);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: () => setState(() {
                        selected
                            ? _selectedTypes.remove(type)
                            : _selectedTypes.add(type);
                      }),
                      borderRadius: BorderRadius.circular(14),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: selected
                              ? accentColor.withAlpha(isLight ? 18 : 25)
                              : (isLight
                                    ? Colors.grey.shade50
                                    : const Color(0xFF142240)),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected
                                ? accentColor
                                : (isLight
                                      ? Colors.grey.shade200
                                      : const Color(0xFF1E3A5F)),
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: accentColor.withAlpha(20),
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: Icon(
                                _icon(type),
                                color: accentColor,
                                size: 21,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    type.label,
                                    style: TextStyle(
                                      color: isLight
                                          ? Colors.black87
                                          : Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    _description(type),
                                    style: TextStyle(
                                      color: isLight
                                          ? Colors.grey.shade600
                                          : const Color(0xFF8BA3C0),
                                      fontSize: 11.5,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              selected
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              color: selected
                                  ? accentColor
                                  : const Color(0xFF5A7190),
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isLight
                            ? Colors.grey.shade700
                            : const Color(0xFFB7C9DD),
                        side: BorderSide(
                          color: isLight
                              ? Colors.grey.shade300
                              : const Color(0xFF3A5A7A),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedTypes.isEmpty
                          ? null
                          : () => Navigator.pop(
                              context,
                              Set<CourseQuestionType>.from(_selectedTypes),
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: isLight
                            ? Colors.grey.shade200
                            : const Color(0xFF1E3A5F),
                        disabledForegroundColor: const Color(0xFF8BA3C0),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _selectedTypes.isEmpty
                            ? 'Select a type'
                            : 'Continue (${_selectedTypes.length})',
                        style: const TextStyle(fontWeight: FontWeight.w700),
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

class _UnifiedQuizEditorDialog extends StatefulWidget {
  final Course course;
  final CourseQuiz? existingQuiz;
  final Set<CourseQuestionType> questionTypes;
  final void Function(CourseQuiz) onSave;

  const _UnifiedQuizEditorDialog({
    required this.course,
    this.existingQuiz,
    required this.questionTypes,
    required this.onSave,
  });

  @override
  State<_UnifiedQuizEditorDialog> createState() =>
      _UnifiedQuizEditorDialogState();
}

class _UnifiedQuizEditorDialogState extends State<_UnifiedQuizEditorDialog> {
  late TextEditingController _titleCtrl;
  late TextEditingController _directionsCtrl;
  late List<_QuestionDraft> _questions;
  DateTime? _selectedDueDate;

  List<CourseQuestionType> get _availableTypes => CourseQuestionType.values
      .where(widget.questionTypes.contains)
      .toList(growable: false);

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.existingQuiz?.title ?? '');
    _directionsCtrl = TextEditingController(
      text: widget.existingQuiz?.directions ?? '',
    );
    if (widget.existingQuiz != null) {
      _questions = widget.existingQuiz!.questions
          .map((q) => _QuestionDraft.fromCourseQuestion(q))
          .toList();
    } else {
      _questions = [_QuestionDraft.empty(_availableTypes.first)];
    }
    _selectedDueDate = widget.existingQuiz?.dueDate;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _directionsCtrl.dispose();
    for (var q in _questions) {
      q.dispose();
    }
    super.dispose();
  }

  void _addQuestion() {
    setState(() {
      _questions.add(_QuestionDraft.empty(_availableTypes.first));
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions[index].dispose();
      _questions.removeAt(index);
    });
  }

  void _save() {
    if (_titleCtrl.text.trim().isEmpty) {
      _showValidationMessage('Enter a quiz title.');
      return;
    }

    final validQuestions = <CourseQuestion>[];
    for (var index = 0; index < _questions.length; index++) {
      final draft = _questions[index];
      final questionText = draft.questionCtrl.text.trim();
      if (questionText.isEmpty) {
        _showValidationMessage('Enter the text for question ${index + 1}.');
        return;
      }

      var options = <String>[];
      var correctIndex = 0;
      var correctAnswers = <String>[];

      switch (draft.type) {
        case CourseQuestionType.multipleChoice:
          final selectedOption = draft.correctIndex < draft.optionCtrls.length
              ? draft.optionCtrls[draft.correctIndex].text.trim()
              : '';
          options = draft.optionCtrls
              .map((controller) => controller.text.trim())
              .where((answer) => answer.isNotEmpty)
              .toList();
          if (options.length < 2 || selectedOption.isEmpty) {
            _showValidationMessage(
              'Question ${index + 1} needs at least two options and a marked correct answer.',
            );
            return;
          }
          correctIndex = options
              .indexOf(selectedOption)
              .clamp(0, options.length - 1);
        case CourseQuestionType.trueFalse:
          options = const ['True', 'False'];
          correctIndex = draft.correctIndex.clamp(0, 1);
        case CourseQuestionType.identification:
          correctAnswers = draft.answerCtrls
              .map((controller) => controller.text.trim())
              .where((answer) => answer.isNotEmpty)
              .toList();
          if (correctAnswers.isEmpty) {
            _showValidationMessage(
              'Enter the correct answer for question ${index + 1}.',
            );
            return;
          }
        case CourseQuestionType.enumeration:
          correctAnswers = draft.answerCtrls
              .map((controller) => controller.text.trim())
              .where((answer) => answer.isNotEmpty)
              .toList();
          if (correctAnswers.length < 2) {
            _showValidationMessage(
              'Enumeration question ${index + 1} needs at least two answers.',
            );
            return;
          }
      }

      validQuestions.add(
        CourseQuestion(
          id: draft.id,
          question: questionText,
          type: draft.type,
          options: options,
          correctIndex: correctIndex,
          correctAnswers: correctAnswers,
          explanation: draft.explanationCtrl.text.trim(),
        ),
      );
    }

    if (validQuestions.isEmpty) {
      _showValidationMessage('Add at least one complete question.');
      return;
    }

    final quiz = CourseQuiz(
      id:
          widget.existingQuiz?.id ??
          'tq_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleCtrl.text.trim(),
      directions: _directionsCtrl.text.trim(),
      questions: validQuestions,
      createdAt: widget.existingQuiz?.createdAt ?? DateTime.now(),
      dueDate: _selectedDueDate,
    );

    widget.onSave(quiz);
    Navigator.pop(context);
  }

  void _showValidationMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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

  Widget _buildDueDatePicker(BuildContext context, Color accentColor) {
    return GestureDetector(
      onTap: _pickDueDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF162544)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accentColor.withAlpha(40), width: 1),
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: 'calendar_month',
              color: accentColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedDueDate != null
                    ? 'Due: ${_selectedDueDate!.month.toString().padLeft(2, '0')}/${_selectedDueDate!.day.toString().padLeft(2, '0')}/${_selectedDueDate!.year.toString().substring(2)} at ${_formatTimeOnly(_selectedDueDate!)}'
                    : 'Set Due Date (Optional)',
                style: TextStyle(
                  fontSize: 14,
                  color: _selectedDueDate != null
                      ? (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black87)
                      : (Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF8BA3C0)
                            : Colors.grey.shade600),
                ),
              ),
            ),
            if (_selectedDueDate != null)
              GestureDetector(
                onTap: () {
                  setState(() => _selectedDueDate = null);
                },
                child: const CustomIconWidget(
                  iconName: 'close',
                  color: Color(0xFFFF6B6B),
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final accentColor =
        (isLight && widget.course.accentColor == const Color(0xFF00D4FF))
        ? const Color(0xFF1565C0)
        : widget.course.accentColor;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        decoration: BoxDecoration(
          color: isLight ? Colors.white : const Color(0xFF0F1E35),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: accentColor.withAlpha(60), width: 1),
        ),
        child: Column(
          children: [
            // Header
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
                    iconName: 'quiz',
                    color: accentColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.existingQuiz == null ? 'Create Quiz' : 'Edit Quiz',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isLight ? Colors.black87 : Colors.white,
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
                  _buildDueDatePicker(context, accentColor),
                  const SizedBox(height: 16),
                  _GlassTextField(
                    controller: _directionsCtrl,
                    label: 'Directions (Optional)',
                    hint:
                        'e.g. Read each question carefully and select the best answer.',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Text(
                        'Questions',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: accentColor,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_questions.length} question(s)',
                        style: TextStyle(
                          fontSize: 12,
                          color: isLight
                              ? Colors.grey.shade600
                              : const Color(0xFF8BA3C0),
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
                      accentColor: accentColor,
                      availableTypes: _availableTypes,
                      onRemove: () => _removeQuestion(index),
                      onTypeChanged: (newType) {
                        setState(() => draft.changeType(newType));
                      },
                      onDraftChanged: () => setState(() {}),
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
                        color: accentColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: accentColor.withAlpha(70),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'add',
                            color: accentColor,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Add Question',
                            style: TextStyle(
                              fontSize: 13,
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
                        backgroundColor: accentColor,
                        foregroundColor: isLight
                            ? Colors.white
                            : const Color(0xFF0A1628),
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
  final List<TextEditingController> answerCtrls;
  CourseQuestionType type;
  int correctIndex;
  final TextEditingController explanationCtrl;

  _QuestionDraft({
    required this.id,
    required this.questionCtrl,
    required this.optionCtrls,
    required this.answerCtrls,
    required this.type,
    required this.correctIndex,
    required this.explanationCtrl,
  });

  factory _QuestionDraft.empty(CourseQuestionType type) {
    return _QuestionDraft(
      id: 'tqq_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}',
      questionCtrl: TextEditingController(),
      optionCtrls: _newOptionControllers(type),
      answerCtrls: _newAnswerControllers(type),
      type: type,
      correctIndex: 0,
      explanationCtrl: TextEditingController(),
    );
  }

  factory _QuestionDraft.fromCourseQuestion(CourseQuestion q) {
    final optionCount = q.options.length > 4 ? q.options.length : 4;
    final answerValues = q.correctAnswers.isNotEmpty
        ? q.correctAnswers
        : const <String>[];
    return _QuestionDraft(
      id: q.id,
      questionCtrl: TextEditingController(text: q.question),
      optionCtrls: List.generate(
        optionCount,
        (i) => TextEditingController(
          text: i < q.options.length ? q.options[i] : '',
        ),
      ),
      answerCtrls: answerValues.isEmpty
          ? _newAnswerControllers(q.type)
          : answerValues
                .map((answer) => TextEditingController(text: answer))
                .toList(),
      type: q.type,
      correctIndex: q.correctIndex,
      explanationCtrl: TextEditingController(text: q.explanation),
    );
  }

  static List<TextEditingController> _newOptionControllers(
    CourseQuestionType type,
  ) {
    if (type == CourseQuestionType.trueFalse) {
      return [
        TextEditingController(text: 'True'),
        TextEditingController(text: 'False'),
      ];
    }
    return List.generate(4, (_) => TextEditingController());
  }

  static List<TextEditingController> _newAnswerControllers(
    CourseQuestionType type,
  ) {
    return switch (type) {
      CourseQuestionType.identification => [TextEditingController()],
      CourseQuestionType.enumeration => List.generate(
        3,
        (_) => TextEditingController(),
      ),
      _ => <TextEditingController>[],
    };
  }

  void changeType(CourseQuestionType newType) {
    if (newType == type) return;
    for (final controller in optionCtrls) {
      controller.dispose();
    }
    for (final controller in answerCtrls) {
      controller.dispose();
    }
    optionCtrls
      ..clear()
      ..addAll(_newOptionControllers(newType));
    answerCtrls
      ..clear()
      ..addAll(_newAnswerControllers(newType));
    type = newType;
    correctIndex = 0;
  }

  void addEnumerationAnswer() {
    answerCtrls.add(TextEditingController());
  }

  void removeEnumerationAnswer(int index) {
    answerCtrls[index].dispose();
    answerCtrls.removeAt(index);
  }

  void dispose() {
    questionCtrl.dispose();
    for (var c in optionCtrls) {
      c.dispose();
    }
    for (var c in answerCtrls) {
      c.dispose();
    }
    explanationCtrl.dispose();
  }
}

class _QuestionEditorCard extends StatelessWidget {
  final int index;
  final _QuestionDraft draft;
  final Color accentColor;
  final List<CourseQuestionType> availableTypes;
  final VoidCallback onRemove;
  final VoidCallback onDraftChanged;
  final ValueChanged<CourseQuestionType> onTypeChanged;
  final void Function(int) onCorrectChanged;

  const _QuestionEditorCard({
    required this.index,
    required this.draft,
    required this.accentColor,
    required this.availableTypes,
    required this.onRemove,
    required this.onDraftChanged,
    required this.onTypeChanged,
    required this.onCorrectChanged,
  });

  Widget _buildChoiceEditor(BuildContext context, bool isLight) {
    final choices = draft.type == CourseQuestionType.trueFalse
        ? const ['True', 'False']
        : null;
    final count = choices?.length ?? draft.optionCtrls.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          draft.type == CourseQuestionType.trueFalse
              ? 'Correct Answer'
              : 'Answer Options (Mark correct answer)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: accentColor,
          ),
        ),
        const SizedBox(height: 8),
        ...List.generate(count, (i) {
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
                        color: isCorrect
                            ? accentColor
                            : const Color(0xFF3A5A7A),
                        width: 2,
                      ),
                    ),
                    child: isCorrect
                        ? Icon(
                            Icons.check,
                            size: 13,
                            color: isLight
                                ? Colors.white
                                : const Color(0xFF0A1628),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: choices != null
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 13,
                          ),
                          decoration: BoxDecoration(
                            color: isLight
                                ? Colors.white
                                : const Color(0xFF162544),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isCorrect
                                  ? accentColor.withAlpha(100)
                                  : const Color(0xFF2A4668),
                            ),
                          ),
                          child: Text(
                            choices[i],
                            style: TextStyle(
                              color: isLight ? Colors.black87 : Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        )
                      : _GlassTextField(
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
      ],
    );
  }

  Widget _buildTextAnswerEditor(BuildContext context) {
    final isEnumeration = draft.type == CourseQuestionType.enumeration;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isEnumeration ? 'Correct Answers' : 'Correct Answer',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: accentColor,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          isEnumeration
              ? 'Students must enter all answers. Answer order will not matter.'
              : 'Capitalization and extra spaces will not affect grading.',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.grey.shade600
                : const Color(0xFF8BA3C0),
            fontSize: 11,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 10),
        ...draft.answerCtrls.asMap().entries.map((entry) {
          final answerIndex = entry.key;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: _GlassTextField(
                    controller: entry.value,
                    label: isEnumeration
                        ? 'Answer ${answerIndex + 1}'
                        : 'Accepted answer',
                    hint: isEnumeration
                        ? 'Enter required answer ${answerIndex + 1}'
                        : 'Enter the correct answer',
                    compact: true,
                  ),
                ),
                if (isEnumeration && draft.answerCtrls.length > 2) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Remove answer',
                    onPressed: () {
                      draft.removeEnumerationAnswer(answerIndex);
                      onDraftChanged();
                    },
                    icon: const Icon(
                      Icons.remove_circle_outline_rounded,
                      color: Color(0xFFFF4757),
                      size: 20,
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
        if (isEnumeration)
          TextButton.icon(
            onPressed: () {
              draft.addEnumerationAnswer();
              onDraftChanged();
            },
            icon: Icon(Icons.add_rounded, color: accentColor, size: 18),
            label: Text(
              'Add another answer',
              style: TextStyle(
                color: accentColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLight ? Colors.grey.shade50 : const Color(0xFF142240),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isLight ? Colors.grey.shade200 : const Color(0xFF1E3A5F),
          width: 1,
        ),
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
          if (availableTypes.length > 1) ...[
            DropdownButtonFormField<CourseQuestionType>(
              initialValue: draft.type,
              isExpanded: true,
              dropdownColor: isLight ? Colors.white : const Color(0xFF162544),
              decoration: InputDecoration(
                labelText: 'Question Type',
                labelStyle: TextStyle(color: accentColor, fontSize: 12),
                filled: true,
                fillColor: isLight ? Colors.white : const Color(0xFF162544),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF2A4668)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF2A4668)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: accentColor),
                ),
              ),
              style: TextStyle(
                color: isLight ? Colors.black87 : Colors.white,
                fontSize: 13,
              ),
              items: availableTypes
                  .map(
                    (type) =>
                        DropdownMenuItem(value: type, child: Text(type.label)),
                  )
                  .toList(),
              onChanged: (type) {
                if (type != null) onTypeChanged(type);
              },
            ),
            const SizedBox(height: 16),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: accentColor.withAlpha(18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: accentColor.withAlpha(60)),
              ),
              child: Text(
                draft.type.label,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          _GlassTextField(
            controller: draft.questionCtrl,
            label: 'Question',
            hint: 'Enter the question text',
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          if (draft.type == CourseQuestionType.multipleChoice ||
              draft.type == CourseQuestionType.trueFalse)
            _buildChoiceEditor(context, isLight)
          else
            _buildTextAnswerEditor(context),
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
