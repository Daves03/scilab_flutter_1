import re

def update_course_model():
    filepath = 'd:/StudioProjects/scilab_flutter_1/lib/models/course_model.dart'
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    if "final DateTime? createdAt;" not in content:
        # Add property
        content = re.sub(r"(final List<CourseQuiz> quizzes;\n)", r"\1\n  final DateTime? createdAt;\n", content)
        
        # Add to constructor
        content = re.sub(r"(required this\.quizzes,)", r"\1\n    this.createdAt,", content)
        
        # Add to fromMap
        content = re.sub(r"factory Course\.fromMap\(String id, Map<String, dynamic> data\) \{", 
                         "factory Course.fromMap(String id, Map<String, dynamic> data) {\n    final ts = data['createdAt'];", 
                         content)
        content = re.sub(r"(quizzes: \(\(data\['quizzes'\].*?\.toList\(\),)", 
                         r"\1\n      createdAt: ts is Timestamp ? ts.toDate() : null,", 
                         content, flags=re.DOTALL)
        
        # Add to toMap
        content = re.sub(r"('quizzes': quizzes\.map\(\(q\) => q\.toMap\(\)\)\.toList\(\),)", 
                         r"\1\n        'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,", 
                         content)
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print("Updated course_model.dart")

def update_student_home():
    filepath = 'd:/StudioProjects/scilab_flutter_1/lib/presentation/student_home_screen/student_home_screen.dart'
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
        
    course_notification = """
        // Course Created
        if (course.createdAt != null) {
           notifications.add({
             'title': 'New Course Added',
             'desc': '${course.teacherName} created the course ${course.title}.',
             'icon': 'school',
             'color': const Color(0xFF7C3AED),
             'timeStr': _formatNotificationTime(course.createdAt),
             'timestamp': course.createdAt!,
           });
        }
"""
    if "New Course Added" not in content:
        content = re.sub(r"(final course = Course\.fromMap\(doc\.id, doc\.data\(\)\);)", r"\1\n" + course_notification, content)
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print("Updated student_home_screen.dart")

if __name__ == '__main__':
    update_course_model()
    update_student_home()
