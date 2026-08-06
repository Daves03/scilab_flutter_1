import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';

/// Approve/reject accounts waiting on review. Role is normally already
/// set (people pick it at registration) — approving just flips status.
/// The role dropdown is only for the rare case for a null-role account
/// (e.g. first-time Google sign-in).
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin · Verify accounts')),
      body: StreamBuilder<List<AppUser>>(
        stream: auth.pendingApprovalsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final pending = snapshot.data ?? [];
          if (pending.isEmpty) {
            return const Center(child: Text('No accounts waiting for verification.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: pending.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final user = pending[i];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(child: Text(user.role?.symbol ?? '?')),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.name, style: theme.textTheme.titleMedium),
                              Text(user.email, style: theme.textTheme.bodySmall),
                              Text(
                                user.role?.label ?? 'No role selected',
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(color: theme.colorScheme.primary),
                              ),
                              if (user.sections.isNotEmpty)
                                Text('Sections: ${user.sections.join(', ')}',
                                    style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (user.role == null) ...[
                          for (final role in UserRole.values)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: OutlinedButton(
                                onPressed: () => auth.assignRoleAndApprove(user, role),
                                child: Text('Approve as ${role.label}'),
                              ),
                            ),
                        ] else ...[
                          TextButton(
                            onPressed: () => auth.reject(user),
                            child: Text('Reject', style: TextStyle(color: theme.colorScheme.error)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => auth.approve(user),
                            child: const Text('Approve'),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
