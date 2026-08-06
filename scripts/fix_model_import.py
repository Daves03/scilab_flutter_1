import os

def add_model_import(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
        
    if "ar_experiment_model.dart" not in content:
        content = content.replace("import '../../../core/app_export.dart';", "import '../../../core/app_export.dart';\nimport '../../../models/ar_experiment_model.dart';")
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)

add_model_import('lib/presentation/student_ar_and_video_lesson_screen/widgets/ar_experiment_card_widget.dart')
add_model_import('lib/presentation/student_ar_and_video_lesson_screen/widgets/ar_experiment_detail_widget.dart')

print('Fixed imports!')
