import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/user_model.dart';
import '../../../widgets/custom_icon_widget.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';
class StudentApprovalDialog extends StatefulWidget {
  const StudentApprovalDialog({super.key});

  @override
  State<StudentApprovalDialog> createState() => _StudentApprovalDialogState();
}

class _StudentApprovalDialogState extends State<StudentApprovalDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<AppUser> _pendingStudents = [];
  List<AppUser> _rejectedStudents = [];
  List<AppUser> _approvedStudents = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStudents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    setState(() => _loading = true);
    try {
      final teacherSections = context.read<AuthService>().currentUser?.sections ?? [];
      
      final db = FirebaseFirestore.instance;
      // Fetch both pending, rejected, and approved students
      final snap = await db.collection('users')
          .where('role', whereIn: [UserRole.grade9.id, UserRole.grade10.id])
          .where('status', whereIn: [
            VerificationStatus.pending.id,
            VerificationStatus.rejected.id,
            VerificationStatus.approved.id
          ])
          .get();
          
      final List<AppUser> pending = [];
      final List<AppUser> rejected = [];
      final List<AppUser> approved = [];

      for (var doc in snap.docs) {
        final user = AppUser.fromMap(doc.id, doc.data());
        // Check if student belongs to one of the teacher's sections
        bool belongsToTeacher = user.sections.any((s) => teacherSections.contains(s));
        if (belongsToTeacher) {
          if (user.status == VerificationStatus.pending) {
            pending.add(user);
          } else if (user.status == VerificationStatus.rejected) {
            rejected.add(user);
          } else if (user.status == VerificationStatus.approved) {
            approved.add(user);
          }
        }
      }

      if (mounted) {
        setState(() {
          _pendingStudents = pending;
          _rejectedStudents = rejected;
          _approvedStudents = approved;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading students for approval: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _updateStatus(AppUser student, VerificationStatus newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(student.id).update({
        'status': newStatus.id,
      });
      // Reload after update
      _loadStudents();
    } catch (e) {
      debugPrint('Error updating student status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update student status'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _confirmAndExecute({
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
    required AppUser student,
    required VerificationStatus newStatus,
  }) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF142240) : Colors.white,
        title: Text(title, style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
        content: Text(message, style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey : Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _updateStatus(student, newStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: 450,
        height: 600,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF142240) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F) : Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: _loading 
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D4FF)))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildStudentList(_pendingStudents, VerificationStatus.pending),
                        _buildStudentList(_approvedStudents, VerificationStatus.approved),
                        _buildStudentList(_rejectedStudents, VerificationStatus.rejected),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D4FF).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const CustomIconWidget(iconName: 'group_add', color: Color(0xFF00D4FF), size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                'Student Approvals',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context, true), // Pass true to indicate potential changes
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0A1628) : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(iconName: 'close', color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0A1628) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        padding: const EdgeInsets.all(4),
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F) : Colors.white,
          boxShadow: [
            if (Theme.of(context).brightness == Brightness.light)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        labelColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF0A1628),
        unselectedLabelColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade500,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        tabs: const [
          Tab(text: 'Pending'),
          Tab(text: 'Approved'),
          Tab(text: 'Rejected'),
        ],
      ),
    );
  }

  Widget _buildStudentList(List<AppUser> students, VerificationStatus status) {
    if (students.isEmpty) {
      String iconName;
      String title;
      String subtitle;
      
      switch (status) {
        case VerificationStatus.pending:
          iconName = 'task_alt';
          title = 'All Caught Up!';
          subtitle = 'No pending student approvals at the moment.';
          break;
        case VerificationStatus.approved:
          iconName = 'check_circle_outline';
          title = 'No Approvals Yet';
          subtitle = 'You haven\'t approved any students.';
          break;
        case VerificationStatus.rejected:
          iconName = 'delete_outline';
          title = 'Trash is Empty';
          subtitle = 'No rejected students found.';
          break;
        default:
          iconName = 'info_outline';
          title = 'Nothing here';
          subtitle = 'No students found.';
      }

      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F).withOpacity(0.3) : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: iconName,
                color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF3A5070) : Colors.grey.shade400,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        final section = student.sections.isNotEmpty ? student.sections.first : 'Unknown';
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0A1628) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F) : Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: status == VerificationStatus.pending 
                      ? const Color(0xFF7C3AED).withOpacity(0.15)
                      : (status == VerificationStatus.approved 
                          ? const Color(0xFF00D4FF).withOpacity(0.15)
                          : const Color(0xFFFF6B6B).withOpacity(0.15)),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: status == VerificationStatus.pending 
                          ? const Color(0xFF7C3AED) 
                          : (status == VerificationStatus.approved 
                              ? const Color(0xFF00D4FF)
                              : const Color(0xFFFF6B6B)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Section: $section',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8BA3C0),
                      ),
                    ),
                  ],
                ),
              ),
              if (status == VerificationStatus.pending) ...[
                _buildActionButton(
                  icon: 'close',
                  color: const Color(0xFFFF6B6B),
                  onTap: () => _confirmAndExecute(
                    title: 'Reject Student',
                    message: 'Are you sure you want to reject ${student.name}?',
                    confirmText: 'Reject',
                    confirmColor: const Color(0xFFFF6B6B),
                    student: student,
                    newStatus: VerificationStatus.rejected,
                  ),
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  icon: 'check',
                  color: const Color(0xFF00D4FF),
                  onTap: () => _confirmAndExecute(
                    title: 'Approve Student',
                    message: 'Are you sure you want to approve ${student.name}?',
                    confirmText: 'Approve',
                    confirmColor: const Color(0xFF00D4FF),
                    student: student,
                    newStatus: VerificationStatus.approved,
                  ),
                ),
              ] else if (status == VerificationStatus.rejected) ...[
                _buildActionButton(
                  icon: 'restore',
                  color: const Color(0xFF00D4FF),
                  onTap: () => _confirmAndExecute(
                    title: 'Restore & Approve',
                    message: 'Are you sure you want to restore and approve ${student.name}?',
                    confirmText: 'Restore',
                    confirmColor: const Color(0xFF00D4FF),
                    student: student,
                    newStatus: VerificationStatus.approved,
                  ),
                  tooltip: 'Approve & Restore',
                ),
              ] else if (status == VerificationStatus.approved) ...[
                _buildActionButton(
                  icon: 'close',
                  color: const Color(0xFFFF6B6B),
                  onTap: () => _confirmAndExecute(
                    title: 'Revoke Approval',
                    message: 'Are you sure you want to revoke approval for ${student.name}? They will be moved to the Rejected list.',
                    confirmText: 'Revoke',
                    confirmColor: const Color(0xFFFF6B6B),
                    student: student,
                    newStatus: VerificationStatus.rejected,
                  ),
                  tooltip: 'Revoke & Reject',
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton({required String icon, required Color color, required VoidCallback onTap, String? tooltip}) {
    Widget button = GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: CustomIconWidget(iconName: icon, color: color, size: 20),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip, child: button);
    }
    return button;
  }
}
