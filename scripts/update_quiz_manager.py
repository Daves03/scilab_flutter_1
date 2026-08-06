import os

filepath = 'lib/presentation/teacher_courses_screen/widgets/teacher_quiz_manager_widget.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Update _showQuizDialog onSave
quiz_save_target = '''        onSave: () {
          if (titleCtrl.text.trim().isEmpty) return;
          setState(() {
            if (existing == null) {
              widget.course.quizzes.add(
                CourseQuiz(
                  id: 'tq_',
                  title: titleCtrl.text.trim(),
                  questions: [],
                ),
              );
            } else {
              final idx = widget.course.quizzes.indexWhere((q) => q.id == existing.id);
              if (idx != -1) {
                widget.course.quizzes[idx] = CourseQuiz(
                  id: existing.id,
                  title: titleCtrl.text.trim(),
                  questions: existing.questions,
                );
              }
            }
          });
          widget.onUpdated();
      context.read<CourseService>().updateCourse(widget.course);
          Navigator.pop(ctx);
        },'''
quiz_save_repl = '''        onSave: () {
          if (titleCtrl.text.trim().isEmpty) return;
          
          if (existing == null) {
            Navigator.pop(ctx);
            // Don't publish yet. Force adding at least one question.
            final tempQuiz = CourseQuiz(
              id: 'tq_',
              title: titleCtrl.text.trim(),
              questions: [],
            );
            _showQuestionDialog(tempQuiz, null, isNewQuiz: true);
          } else {
            setState(() {
              final idx = widget.course.quizzes.indexWhere((q) => q.id == existing.id);
              if (idx != -1) {
                widget.course.quizzes[idx] = CourseQuiz(
                  id: existing.id,
                  title: titleCtrl.text.trim(),
                  questions: existing.questions,
                );
              }
            });
            widget.onUpdated();
            context.read<CourseService>().updateCourse(widget.course);
            Navigator.pop(ctx);
          }
        },'''
content = content.replace(quiz_save_target, quiz_save_repl)

# 2. Update _showQuestionDialog signature
q_sig_target = '  void _showQuestionDialog(CourseQuiz quiz, CourseQuestion? existing) {'
q_sig_repl = '  void _showQuestionDialog(CourseQuiz quiz, CourseQuestion? existing, {bool isNewQuiz = false}) {'
content = content.replace(q_sig_target, q_sig_repl)

# 3. Update _showQuestionDialog onSave
q_save_target = '''            setState(() {
              if (existing == null) {
                quiz.questions.add(
                  CourseQuestion(
                    id: 'tqq_',
                    question: questionCtrl.text.trim(),
                    options: opts,
                    correctIndex: selectedCorrect.clamp(0, opts.length - 1),
                    explanation: explanationCtrl.text.trim(),
                  ),
                );
              } else {
                final qIdx = quiz.questions.indexWhere((q) => q.id == existing.id);
                if (qIdx != -1) {
                  quiz.questions[qIdx] = CourseQuestion(
                    id: existing.id,
                    question: questionCtrl.text.trim(),
                    options: opts,
                    correctIndex: selectedCorrect.clamp(0, opts.length - 1),
                    explanation: explanationCtrl.text.trim(),
                  );
                }
              }
            });
            widget.onUpdated();
      context.read<CourseService>().updateCourse(widget.course);
            Navigator.pop(ctx2);
          },'''
q_save_repl = '''            setState(() {
              if (existing == null) {
                quiz.questions.add(
                  CourseQuestion(
                    id: 'tqq_',
                    question: questionCtrl.text.trim(),
                    options: opts,
                    correctIndex: selectedCorrect.clamp(0, opts.length - 1),
                    explanation: explanationCtrl.text.trim(),
                  ),
                );
              } else {
                final qIdx = quiz.questions.indexWhere((q) => q.id == existing.id);
                if (qIdx != -1) {
                  quiz.questions[qIdx] = CourseQuestion(
                    id: existing.id,
                    question: questionCtrl.text.trim(),
                    options: opts,
                    correctIndex: selectedCorrect.clamp(0, opts.length - 1),
                    explanation: explanationCtrl.text.trim(),
                  );
                }
              }
              
              if (isNewQuiz) {
                widget.course.quizzes.add(quiz);
              }
            });
            widget.onUpdated();
            context.read<CourseService>().updateCourse(widget.course);
            Navigator.pop(ctx2);
          },'''
content = content.replace(q_save_target, q_save_repl)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
print('Updated teacher_quiz_manager_widget.dart')
