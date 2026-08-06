import os
import re

def fix_file(filepath):
    if not os.path.exists(filepath):
        return
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
        
    # Fix import paths
    content = content.replace("import './widgets/ar_experiment_card_widget.dart';", "import '../student_ar_and_video_lesson_screen/widgets/ar_experiment_card_widget.dart';")
    content = content.replace("import './widgets/ar_experiment_detail_widget.dart';", "import '../student_ar_and_video_lesson_screen/widgets/ar_experiment_detail_widget.dart';")
    content = content.replace("import './widgets/category_filter_widget.dart';", "import '../student_ar_and_video_lesson_screen/widgets/category_filter_widget.dart';")
    content = content.replace("import './widgets/video_lesson_section_widget.dart';", "import '../student_ar_and_video_lesson_screen/widgets/video_lesson_section_widget.dart';")

    # Fix _buildPhoneLayout() -> _buildPhoneLayout(experiments)
    content = content.replace("Expanded(flex: 5, child: _buildPhoneLayout()),", "Expanded(flex: 5, child: _buildPhoneLayout(experiments)),")

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

fix_file('lib/presentation/teacher_ar_and_video_lesson_screen/teacher_ar_and_video_lesson_screen.dart')
fix_file('lib/presentation/student_ar_and_video_lesson_screen/student_ar_and_video_lesson_screen.dart')

def add_model_import(filepath):
    if not os.path.exists(filepath):
        return
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
        
    if "ar_experiment_model.dart" not in content:
        content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport '../../../models/ar_experiment_model.dart';")
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)

add_model_import('lib/presentation/student_ar_and_video_lesson_screen/widgets/ar_experiment_card_widget.dart')
add_model_import('lib/presentation/student_ar_and_video_lesson_screen/widgets/ar_experiment_detail_widget.dart')

print('Fixed!')
