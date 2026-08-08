import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../routes/app_routes.dart';
import 'widgets/auth_hero_widget.dart';

class GoogleCompleteProfileScreen extends StatefulWidget {
  const GoogleCompleteProfileScreen({Key? key}) : super(key: key);

  @override
  State<GoogleCompleteProfileScreen> createState() => _GoogleCompleteProfileScreenState();
}

class _GoogleCompleteProfileScreenState extends State<GoogleCompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  
  String _selectedGrade = 'grade9';
  String? _selectedSection;
  bool _isLoading = false;
  
  List<Map<String, dynamic>> _allSections = [];
  bool _isLoadingSections = true;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthService>();
    final user = auth.currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _fetchSections();
  }

  Future<void> _fetchSections() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('sections').get();
      if (mounted) {
        setState(() {
          _allSections = snapshot.docs.map((d) => d.data()).toList();
          _isLoadingSections = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching sections: $e');
      if (mounted) {
        setState(() => _isLoadingSections = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSection == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a section')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = context.read<AuthService>();
      await auth.completeGoogleProfile(
        name: _nameController.text.trim(),
        role: _selectedGrade,
        sections: [_selectedSection!],
      );
      // The auth state change will trigger GoRouter redirect automatically.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: isTablet ? _buildTabletLayout() : _buildPhoneLayout(),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? const Color(0xFF0D2E3F).withOpacity(0.6) 
                      : Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF00D4FF).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87, size: 20),
                  onPressed: () {
                    context.read<AuthService>().logout();
                    context.go(AppRoutes.overviewScreen);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneLayout() {
    return SingleChildScrollView(
      child: Column(children: [const AuthHeroWidget(), _buildFormCard()]),
    );
  }

  Widget _buildTabletLayout() {
    return Center(
      child: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [const AuthHeroWidget(compact: true), _buildFormCard()],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1E35) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Complete Profile',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Please provide your grade and section to continue',
                style: TextStyle(fontSize: 14, color: isDark ? const Color(0xFF8BA3C0) : Colors.grey.shade700),
              ),
              const SizedBox(height: 24),
              
              _buildGlassField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Your name',
                icon: 'person_outline',
                validator: (v) => (v == null || v.isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 14),
              
              _buildGlassField(
                controller: _emailController,
                label: 'Email (from Google)',
                hint: 'Your email',
                icon: 'email_outlined',
                readOnly: true,
              ),
              const SizedBox(height: 16),
              
              Text(
                'Grade Level',
                style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF8BA3C0) : Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              _buildGradeSelector(),
              
              const SizedBox(height: 14),
              Text(
                'School Section',
                style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF8BA3C0) : Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              _buildSectionSelector(),
              
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D4FF),
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black87, strokeWidth: 2))
                      : const Text('Complete Sign Up', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradeSelector() {
    return Row(
      children: [
        _buildGradeChip('grade9', 'Grade 9'),
        const SizedBox(width: 12),
        _buildGradeChip('grade10', 'Grade 10'),
      ],
    );
  }

  Widget _buildGradeChip(String gradeValue, String label) {
    final isSelected = _selectedGrade == gradeValue;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedGrade = gradeValue;
            _selectedSection = null; // reset section when grade changes
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0x2200D4FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF00D4FF) : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F) : Colors.grey.shade300),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected 
                  ? const Color(0xFF00D4FF) 
                  : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionSelector() {
    if (_isLoadingSections) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0A1628) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F) : Colors.grey.shade300),
        ),
        child: const Row(
          children: [
            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 12),
            Text('Loading sections...'),
          ],
        ),
      );
    }

    final targetGrade = _selectedGrade == 'grade9' ? 'Grade 9' : 'Grade 10';
    List<String> validSections = [];
    for (var section in _allSections) {
      final name = section['name'] as String?;
      final grade = section['grade'] as String?;
      if (name != null && grade == targetGrade) {
        validSections.add(name);
      }
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0A1628) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F) : Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSection,
          hint: Text(
            validSections.isEmpty ? 'No sections available' : 'Select section',
            style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade500),
          ),
          isExpanded: true,
          dropdownColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0F1E35) : Colors.white,
          icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade500),
          items: validSections.map((s) {
            return DropdownMenuItem(
              value: s,
              child: Text(s, style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87)),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              _selectedSection = val;
            });
          },
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
    bool readOnly = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF8BA3C0) : Colors.grey.shade700),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          readOnly: readOnly,
          style: TextStyle(
            color: readOnly ? Colors.grey : (isDark ? Colors.white : Colors.black87),
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: isDark ? const Color(0xFF3B5676) : Colors.grey.shade400),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: CustomIconWidget(iconName: icon, color: isDark ? const Color(0xFF3B5676) : Colors.grey.shade500, size: 20),
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: isDark ? const Color(0xFF0A1628) : Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: isDark ? const Color(0xFF1E3A5F) : Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00D4FF), width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }
}
