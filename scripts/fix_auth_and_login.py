import os
import re

def fix_auth_service(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Change signature of signInWithGoogle
    content = content.replace("Future<bool> signInWithGoogle() async {", "Future<String?> signInWithGoogle() async {")
    
    # Replace the block inside signInWithGoogle
    old_block = """      final docRef = _db.collection('users').doc(fbUser.uid);
      final doc = await docRef.get();
      if (!doc.exists) {
        final newUser = AppUser(
          id: fbUser.uid,
          name: fbUser.displayName ?? '',
          email: fbUser.email ?? '',
          role: null,
          status: VerificationStatus.pending,
        );
        await docRef.set(newUser.toMap());
      }
      return true;"""

    new_block = """      final docRef = _db.collection('users').doc(fbUser.uid);
      final doc = await docRef.get();
      String? userRoleStr;
      if (!doc.exists) {
        final newUser = AppUser(
          id: fbUser.uid,
          name: fbUser.displayName ?? '',
          email: fbUser.email ?? '',
          role: null,
          status: VerificationStatus.pending,
        );
        await docRef.set(newUser.toMap());
        userRoleStr = 'student';
      } else {
        // Update name to match Google account if it exists
        if (fbUser.displayName != null && fbUser.displayName!.isNotEmpty) {
          await docRef.update({'name': fbUser.displayName});
        }
        final data = doc.data();
        if (data != null) {
          userRoleStr = data['role'] == 'teacher' ? 'teacher' : 'student';
        } else {
          userRoleStr = 'student';
        }
      }
      return userRoleStr;"""
    
    content = content.replace(old_block, new_block)
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

fix_auth_service('lib/services/auth_service.dart')

def fix_login_form(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
        
    old_block = """      final success = await context.read<AuthService>().signInWithGoogle();
      if (!mounted) return;
      if (success) {
        widget.onSuccess('student');
      }"""
      
    new_block = """      final role = await context.read<AuthService>().signInWithGoogle();
      if (!mounted) return;
      if (role != null) {
        widget.onSuccess(role);
      }"""
      
    content = content.replace(old_block, new_block)

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

fix_login_form('lib/presentation/sign_up_login_screen/widgets/login_form_widget.dart')

print('Fixed!')
