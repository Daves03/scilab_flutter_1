import {
  EmailAuthProvider,
  isSignInWithEmailLink,
  reauthenticateWithCredential,
  sendSignInLinkToEmail,
  signInWithEmailLink,
} from 'firebase/auth';
import {
  collection,
  deleteDoc,
  doc,
  getDoc,
  onSnapshot,
  serverTimestamp,
  setDoc,
  Timestamp,
  updateDoc,
} from 'firebase/firestore';
import { auth, db } from '../firebase';

export const ADMIN_EMAIL = 'scilabar@gmail.com';
export const ADMIN_DEVICE_VERIFIED_EVENT = 'scilab-admin-device-verified';

const TRUSTED_DEVICE_PREFIX = 'scilab_admin_trusted_device_v2_';
const PENDING_REQUEST_KEY = 'scilab_admin_pending_device_request';
const REQUEST_LIFETIME_MS = 15 * 60 * 1000;

const trustedDeviceKey = (uid) => `${TRUSTED_DEVICE_PREFIX}${uid}`;

export function isTrustedAdminDevice(user) {
  if (!user || user.email?.toLowerCase() !== ADMIN_EMAIL) return false;
  return window.localStorage.getItem(trustedDeviceKey(user.uid)) === 'trusted';
}

export function hasPendingAdminDeviceVerification() {
  return Boolean(window.localStorage.getItem(PENDING_REQUEST_KEY));
}

export function clearPendingAdminDeviceVerification() {
  window.localStorage.removeItem(PENDING_REQUEST_KEY);
}

function trustCurrentBrowser(user) {
  window.localStorage.setItem(trustedDeviceKey(user.uid), 'trusted');
  clearPendingAdminDeviceVerification();
  window.dispatchEvent(new Event(ADMIN_DEVICE_VERIFIED_EVENT));
}

export async function sendAdminDeviceVerification(user) {
  if (!user || user.email?.toLowerCase() !== ADMIN_EMAIL) {
    throw new Error('Only the SciLab AR administrator can verify this device.');
  }
  if (!user.emailVerified) {
    throw new Error('Verify the administrator email address before approving a device.');
  }

  const requestRef = doc(collection(db, 'admin_device_requests'));
  const expiresAt = Timestamp.fromMillis(Date.now() + REQUEST_LIFETIME_MS);
  await setDoc(requestRef, {
    requesterUid: user.uid,
    requesterEmail: ADMIN_EMAIL,
    status: 'pending',
    createdAt: serverTimestamp(),
    expiresAt,
  });

  const continueUrl = new URL('/device-approval', window.location.origin);
  continueUrl.searchParams.set('requestId', requestRef.id);

  try {
    await sendSignInLinkToEmail(auth, ADMIN_EMAIL, {
      url: continueUrl.toString(),
      handleCodeInApp: true,
    });
    window.localStorage.setItem(PENDING_REQUEST_KEY, requestRef.id);
  } catch (error) {
    await deleteDoc(requestRef).catch(() => {});
    throw error;
  }
}

export function watchAdminDeviceApproval(user, onApproved, onError) {
  const requestId = window.localStorage.getItem(PENDING_REQUEST_KEY);
  if (!requestId || !user) return () => {};

  let handled = false;
  return onSnapshot(
    doc(db, 'admin_device_requests', requestId),
    async (snapshot) => {
      if (handled || !snapshot.exists()) return;
      const request = snapshot.data();
      const expiresAt = request.expiresAt?.toMillis?.() || 0;

      if (request.requesterUid !== user.uid) {
        handled = true;
        clearPendingAdminDeviceVerification();
        onError?.(new Error('This approval request belongs to a different administrator.'));
        return;
      }
      if (expiresAt && expiresAt < Date.now()) {
        handled = true;
        clearPendingAdminDeviceVerification();
        onError?.(new Error('The device approval request expired. Please sign in again.'));
        return;
      }
      if (request.status === 'approved') {
        handled = true;
        trustCurrentBrowser(user);
        onApproved?.();
      }
    },
    onError,
  );
}

export async function approveAdminDeviceRequest(emailLink) {
  if (!isSignInWithEmailLink(auth, emailLink)) {
    throw new Error('This approval link is invalid or has expired.');
  }

  const requestId = new URL(emailLink).searchParams.get('requestId');
  if (!requestId) throw new Error('The approval request ID is missing.');

  const emailCredential = EmailAuthProvider.credentialWithLink(ADMIN_EMAIL, emailLink);
  let user = auth.currentUser;
  if (user?.email?.toLowerCase() === ADMIN_EMAIL) {
    await reauthenticateWithCredential(user, emailCredential);
  } else {
    const result = await signInWithEmailLink(auth, ADMIN_EMAIL, emailLink);
    user = result.user;
  }

  if (user.email?.toLowerCase() !== ADMIN_EMAIL) {
    throw new Error('Only the SciLab AR administrator can approve this request.');
  }

  const requestRef = doc(db, 'admin_device_requests', requestId);
  const requestSnapshot = await getDoc(requestRef);
  if (!requestSnapshot.exists()) throw new Error('This device request no longer exists.');

  const request = requestSnapshot.data();
  const expiresAt = request.expiresAt?.toMillis?.() || 0;
  if (request.requesterUid !== user.uid) throw new Error('This request belongs to a different administrator.');
  if (request.status !== 'pending') throw new Error('This device request was already used.');
  if (expiresAt && expiresAt < Date.now()) throw new Error('This device approval request has expired.');

  await updateDoc(requestRef, {
    status: 'approved',
    approvedAt: serverTimestamp(),
    approvedByUid: user.uid,
  });

  return requestId;
}
