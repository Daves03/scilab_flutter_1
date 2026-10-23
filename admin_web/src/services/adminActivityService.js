import { addDoc, collection, serverTimestamp } from 'firebase/firestore';
import { auth, db } from '../firebase';

export async function logAdminActivity({ type, title, details = {} }) {
  const admin = auth.currentUser;

  if (!admin) {
    console.warn('Admin activity was not recorded because no administrator is signed in.');
    return false;
  }

  try {
    await addDoc(collection(db, 'admin_activity_logs'), {
      type,
      title,
      details,
      adminUid: admin.uid,
      adminName: admin.displayName || admin.email || 'Administrator',
      adminEmail: admin.email || '',
      createdAt: serverTimestamp(),
    });
    return true;
  } catch (error) {
    // The main admin action has already succeeded. Keep it successful even if
    // audit logging is temporarily unavailable (for example, before rules publish).
    console.error('Could not record admin activity:', error);
    return false;
  }
}
