import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/app_export.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import 'package:provider/provider.dart';

class RegisterFormWidget extends StatefulWidget {
  final VoidCallback onSuccess;
  const RegisterFormWidget({required this.onSuccess, super.key});

  @override
  State<RegisterFormWidget> createState() => _RegisterFormWidgetState();
}

class _RegisterFormWidgetState extends State<RegisterFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _sectionController = TextEditingController();
  final _sectionCountController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _selectedRole = 'student';
  String _selectedGrade = 'Grade 9';
  int _teacherSectionCount = 0;
  List<TextEditingController> _teacherSectionControllers = [];

  static const _grades = ['Grade 9', 'Grade 10'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _sectionController.dispose();
    _sectionCountController.dispose();
    for (final c in _teacherSectionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _updateSectionCount(String value) {
    final count = int.tryParse(value) ?? 0;
    final clamped = count.clamp(0, 10);
    if (clamped == _teacherSectionCount) return;

    // Dispose extra controllers if shrinking
    if (clamped < _teacherSectionControllers.length) {
      for (int i = clamped; i < _teacherSectionControllers.length; i++) {
        _teacherSectionControllers[i].dispose();
      }
      _teacherSectionControllers = _teacherSectionControllers.sublist(
        0,
        clamped,
      );
    } else {
      // Add new controllers if growing
      while (_teacherSectionControllers.length < clamped) {
        _teacherSectionControllers.add(TextEditingController());
      }
    }

    setState(() {
      _teacherSectionCount = clamped;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      UserRole? finalRole;
      List<String> finalSections = [];

      if (_selectedRole == 'student') {
        finalRole = _selectedGrade == 'Grade 9' ? UserRole.grade9 : UserRole.grade10;
        final gradeNum = _selectedGrade.replaceAll('Grade ', '');
        finalSections = ['$gradeNum-${_sectionController.text.trim()}'];
      } else {
        finalRole = UserRole.teacher;
        finalSections = _teacherSectionControllers
            .map((c) => c.text.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }

      await context.read<AuthService>().signUp(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            role: finalRole,
            sections: finalSections,
          );
      
      if (!mounted) return;
      
      // Persist student/teacher data for profile screen
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', _nameController.text.trim());
      await prefs.setString('user_role', _selectedRole);
      if (_selectedRole == 'student') {
        await prefs.setString('student_name', _nameController.text.trim());
        await prefs.setString('student_grade', _selectedGrade);
        await prefs.setString('student_section', _sectionController.text.trim());
      } else {
        await prefs.setString('teacher_name', _nameController.text.trim());
        await prefs.setString('teacher_email', _emailController.text.trim());
        await prefs.setStringList('teacher_sections', finalSections);
        await prefs.setInt('teacher_section_count', _teacherSectionCount);
      }

      widget.onSuccess();
    } on AuthFailure catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration failed.'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create Account',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Submit your details for admin approval',
            style: TextStyle(fontSize: 14, color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade700),
          ),
          const SizedBox(height: 24),
          _buildGlassField(
            controller: _nameController,
            label: 'Full Name',
            hint: 'e.g. Priya Sharma',
            icon: 'person_outline',
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Name is required' : null,
          ),
          const SizedBox(height: 14),
          _buildGlassField(
            controller: _emailController,
            label: 'School Email',
            hint: 'you@school.edu',
            icon: 'email_outlined',
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email is required';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 14),
          _buildGlassField(
            controller: _passwordController,
            label: 'Password',
            hint: '••••••••',
            icon: 'lock_outlined',
            obscureText: _obscurePassword,
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _obscurePassword = !_obscurePassword),
              child: CustomIconWidget(
                iconName: _obscurePassword
                    ? 'visibility_off_outlined'
                    : 'visibility_outlined',
                color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600,
                size: 20,
              ),
            ),
            validator: (v) {
              if (v == null || v.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Role selector
          Text(
            'Register as',
            style: TextStyle(fontSize: 13, color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildRoleChip('student', 'Student', 'school_outlined'),
              const SizedBox(width: 12),
              _buildRoleChip('teacher', 'Teacher', 'person_pin_outlined'),
            ],
          ),
          if (_selectedRole == 'student') ...[
            const SizedBox(height: 16),
            Text(
              'Grade Level',
              style: TextStyle(fontSize: 13, color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            _buildGradeSelector(),
            const SizedBox(height: 14),
            Text(
              'School Section',
              style: TextStyle(fontSize: 13, color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            _buildGlassField(
              controller: _sectionController,
              label: 'Section',
              hint: 'e.g. Section A, Rizal, Einstein',
              icon: 'group_outlined',
            ),
          ],
          if (_selectedRole == 'teacher') ...[
            const SizedBox(height: 16),
            Text(
              'How Many Sections Are You Teaching?',
              style: TextStyle(fontSize: 13, color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade700),
            ),
            const SizedBox(height: 4),
            Text(
              'Enter number of sections (max 10)',
              style: TextStyle(fontSize: 11, color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF5A7A9A) : Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            _buildGlassField(
              controller: _sectionCountController,
              label: 'Number of Sections',
              hint: 'e.g. 3',
              icon: 'format_list_numbered',
              keyboardType: TextInputType.number,
              onChanged: _updateSectionCount,
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Please enter number of sections';
                }
                final n = int.tryParse(v);
                if (n == null || n < 1) return 'Enter a valid number (min 1)';
                if (n > 10) return 'Maximum 10 sections allowed';
                return null;
              },
            ),
            if (_teacherSectionCount > 0) ...[
              const SizedBox(height: 16),
              Text(
                'Grade & Section',
                style: TextStyle(fontSize: 13, color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade700),
              ),
              const SizedBox(height: 4),
              Text(
                'Enter grade and section name (e.g. 9-Rizal, 10-Bonifacio)',
                style: TextStyle(fontSize: 11, color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF5A7A9A) : Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              ...List.generate(
                _teacherSectionCount,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildGlassField(
                    controller: _teacherSectionControllers[index],
                    label: 'Section ${index + 1}',
                    hint: 'e.g. 9-Rizal, 10-Bonifacio',
                    icon: 'group_outlined',
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Grade & section is required'
                        : null,
                  ),
                ),
              ),
            ],
          ],
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D4FF),
                foregroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0A1628) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0A1628) : Colors.white,
                      ),
                    )
                  : const Text(
                      'Submit for Approval',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleChip(String value, String label, String icon) {
    final isSelected = _selectedRole == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0x2200D4FF)
                : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF142240) : Colors.grey.shade200),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF00D4FF)
                  : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F) : Colors.grey.shade400),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: icon,
                color: isSelected
                    ? const Color(0xFF00D4FF)
                    : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600),
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? const Color(0xFF00D4FF)
                      : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0x1400D4FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x2900D4FF), width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedGrade,
          isExpanded: true,
          dropdownColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0F1E35) : Colors.white,
          icon: CustomIconWidget(
            iconName: 'expand_more',
            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600,
            size: 20,
          ),
          style: TextStyle(fontSize: 14, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87),
          items: _grades
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
          onChanged: (v) => setState(() => _selectedGrade = v!),
        ),
      ),
    );
  }

  Widget _buildGlassField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87, fontSize: 14),
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            hintStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black38, fontSize: 14),
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: CustomIconWidget(
                iconName: icon,
                color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600,
                size: 20,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
            suffixIcon: suffixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: suffixIcon,
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
            ),
          ),
        ),
      ),
    );
  }
}
