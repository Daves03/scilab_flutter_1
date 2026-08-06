import re

def update_teacher_progress():
    filepath = 'd:/StudioProjects/scilab_flutter_1/lib/presentation/teacher_progress_screen/teacher_progress_screen.dart'
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Add imports
    imports_to_add = """import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../models/course_model.dart';
import '../../models/ar_experiment_model.dart';
import '../../models/activity_model.dart';
"""
    if "import 'package:cloud_firestore/cloud_firestore.dart';" not in content:
        content = re.sub(r"(import 'package:shared_preferences/shared_preferences\.dart';)", r"\1\n" + imports_to_add, content)

    # Remove the mock data
    mock_data_pattern = re.compile(r"// ── Mock data ──.*?(?=// ── Screen ──)", re.DOTALL)
    content = mock_data_pattern.sub("", content)

    # Replace _loadData
    load_data_pattern = re.compile(r"  Future<void> _loadData\(\) async \{.*?\n  \}", re.DOTALL)
    new_load_data = """  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    String pad(int n) => n.toString().padLeft(2, '0');
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} at ${pad(hour)}:${pad(dt.minute)} $ampm';
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final sections = prefs.getStringList('teacher_sections') ?? [];
    setState(() {
      _teacherSections = sections;
      _loading = true;
    });

    try {
      final db = FirebaseFirestore.instance;

      // 1. Fetch real students
      final studentsSnap = await db
          .collection('users')
          .where('role', whereIn: [UserRole.grade9.id, UserRole.grade10.id])
          .where('status', isEqualTo: VerificationStatus.approved.id)
          .get();
          
      final users = studentsSnap.docs.map((d) => AppUser.fromMap(d.id, d.data())).toList();

      // 2. Fetch all quiz attempts
      final attemptsSnap = await db.collection('quiz_attempts').get();
      final allAttempts = attemptsSnap.docs.map((d) => QuizAttempt.fromMap(d.id, d.data())).toList();

      // 3. Fetch AR experiments to map IDs to titles
      final arSnap = await db.collection('ar_experiments').get();
      final arExps = arSnap.docs.map((d) => ArExperimentModel.fromMap(d.id, d.data())).toList();
      final arExpMap = { for (var e in arExps) e.id : e.title };

      // 4. Build StudentProgress objects
      List<StudentProgress> dynamicStudents = [];
      for (var u in users) {
         // get quiz results for u.id
         final uAttempts = allAttempts.where((a) => a.studentId == u.id).toList();
         final quizResults = uAttempts.map((a) => QuizResult(
           quizTitle: a.quizTitle,
           score: a.score,
           total: a.totalQuestions,
           date: _formatDate(a.submittedAt),
         )).toList();

         // get AR records for u.id
         final uArSnap = await db.collection('users').doc(u.id).collection('experiment_activity').get();
         final uArRecords = uArSnap.docs.map((d) {
           final expId = d.id;
           final act = ExperimentActivity.fromMap(expId, d.data());
           return ArLabRecord(
             experimentName: arExpMap[expId] ?? 'Unknown Experiment',
             attempts: 1, 
             rubricScore: act.completed ? 100.0 : 0.0,
             lastAttemptDate: _formatDate(act.completedAt ?? act.launchedAt),
           );
         }).toList();

         final section = u.sections.isNotEmpty ? u.sections.first : 'No Section';

         dynamicStudents.add(StudentProgress(
           name: u.name,
           section: section,
           quizResults: quizResults,
           arLabRecords: uArRecords,
         ));
      }

      setState(() {
        _allStudents = dynamicStudents;
        _loading = false;
      });
    } catch (e) {
      print('Error loading dynamic progress: $e');
      setState(() { _loading = false; });
    }
  }"""
    content = load_data_pattern.sub(new_load_data, content)

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print("Updated teacher_progress_screen.dart")

if __name__ == '__main__':
    update_teacher_progress()
