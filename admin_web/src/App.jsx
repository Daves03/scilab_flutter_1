import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { useState, useEffect } from 'react';
import { onAuthStateChanged } from 'firebase/auth';
import { doc, getDoc, onSnapshot } from 'firebase/firestore';
import { auth, db } from './firebase';
import { ADMIN_DEVICE_VERIFIED_EVENT, isTrustedAdminDevice } from './services/adminDeviceVerification';

import Login from './pages/Login';
import AdminDeviceApproval from './pages/AdminDeviceApproval';
import Layout from './components/Layout';
import Overview from './pages/Overview';
import ManageUsers from './pages/ManageUsers';
import ManageSections from './pages/ManageSections';
import TeacherUploads from './pages/TeacherUploads';
import ARLabManager from './pages/ARLabManager';
import ARMarker from './pages/ARMarker';
import ActivityLogs from './pages/ActivityLogs';
import Legal from './pages/Legal';
import TeacherDashboard from './pages/TeacherDashboard';
import TeacherStudents from './pages/TeacherStudents';
import TeacherCourses from './pages/TeacherCourses';
import TeacherProgress from './pages/TeacherProgress';
import TeacherCourseDetail from './pages/TeacherCourseDetail';

function App() {
  const [user, setUser] = useState(null);
  const [role, setRole] = useState(null);
  const [profile, setProfile] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const evaluateUser = async (currentUser) => {
      if (currentUser) {
        setUser(currentUser);
        try {
          const userDoc = await getDoc(doc(db, 'users', currentUser.uid));
          const profileData = userDoc.exists() ? { id: userDoc.id, ...userDoc.data() } : null;
          const isHardcodedAdmin = currentUser.email?.toLowerCase() === 'scilabar@gmail.com';
          const resolvedRole = isHardcodedAdmin ? 'admin' : profileData?.role;
          const isApprovedTeacher = resolvedRole === 'teacher' && profileData?.status === 'approved';
          const isVerifiedAdmin = resolvedRole === 'admin' && isTrustedAdminDevice(currentUser);

          if (isVerifiedAdmin || isApprovedTeacher) {
            setRole(resolvedRole);
            setProfile(profileData || {
              id: currentUser.uid,
              name: 'Administrator',
              email: currentUser.email,
              role: 'admin',
              sections: [],
            });
          } else {
            setRole(null);
            setProfile(null);
            if (resolvedRole !== 'admin') auth.signOut();
          }
        } catch (error) {
          console.error("Error checking admin status:", error);
          setRole(null);
          setProfile(null);
        }
      } else {
        setUser(null);
        setRole(null);
        setProfile(null);
      }
      setLoading(false);
    };

    const unsubscribe = onAuthStateChanged(auth, evaluateUser);
    const handleDeviceVerified = () => evaluateUser(auth.currentUser);
    window.addEventListener(ADMIN_DEVICE_VERIFIED_EVENT, handleDeviceVerified);

    return () => {
      unsubscribe();
      window.removeEventListener(ADMIN_DEVICE_VERIFIED_EVENT, handleDeviceVerified);
    };
  }, []);

  useEffect(() => {
    if (!user?.uid || !role) return undefined;
    return onSnapshot(doc(db, 'users', user.uid), (snapshot) => {
      if (snapshot.exists()) setProfile({ id: snapshot.id, ...snapshot.data() });
    }, (error) => console.warn('Could not refresh signed-in profile:', error));
  }, [role, user?.uid]);

  if (loading) {
    return (
      <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100vh', color: 'var(--text-primary)' }}>
        <h2>Loading...</h2>
      </div>
    );
  }

  return (
    <BrowserRouter>
      <Routes>
        <Route path="/device-approval" element={<AdminDeviceApproval />} />
        <Route
          path="/login"
          element={!user || !role ? <Login /> : <Navigate to="/" />}
        />

        <Route
          path="/"
          element={user && role ? <Layout role={role} profile={profile} /> : <Navigate to="/login" />}
        >
          <Route index element={role === 'admin' ? <Overview /> : <TeacherDashboard user={user} profile={profile} />} />
          <Route path="users" element={role === 'admin' ? <ManageUsers /> : <Navigate to="/" replace />} />
          <Route path="sections" element={role === 'admin' ? <ManageSections /> : <Navigate to="/" replace />} />
          <Route path="uploads" element={role === 'admin' ? <TeacherUploads /> : <Navigate to="/" replace />} />
          <Route path="ar-labs" element={<ARLabManager teacherProfile={role === 'teacher' ? profile : null} />} />
          <Route path="ar-marker" element={role === 'admin' ? <ARMarker /> : <Navigate to="/" replace />} />
          <Route path="activity-logs" element={role === 'admin' ? <ActivityLogs /> : <Navigate to="/" replace />} />
          <Route path="legal" element={role === 'admin' ? <Legal /> : <Navigate to="/" replace />} />
          <Route path="students" element={role === 'teacher' ? <TeacherStudents profile={profile} /> : <Navigate to="/" replace />} />
          <Route path="my-courses" element={role === 'teacher' ? <TeacherCourses user={user} profile={profile} /> : <Navigate to="/" replace />} />
          <Route path="my-courses/:courseId" element={role === 'teacher' ? <TeacherCourseDetail user={user} profile={profile} /> : <Navigate to="/" replace />} />
          <Route path="student-progress" element={role === 'teacher' ? <TeacherProgress user={user} profile={profile} /> : <Navigate to="/" replace />} />
          <Route path="*" element={<Navigate to="/" replace />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}

export default App;
