import os

files = [
    'lib/presentation/student_ar_and_video_lesson_screen/student_ar_and_video_lesson_screen.dart',
    'lib/presentation/teacher_ar_and_video_lesson_screen/teacher_ar_and_video_lesson_screen.dart'
]

for filepath in files:
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    old_code = "if (snapshot.hasError) {"
    new_code = "if (snapshot.hasError) {\n              print('AR Stream Error: \');\n              print('AR Stream StackTrace: \');"
    
    content = content.replace(old_code, new_code)
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

print('Added error print!')
