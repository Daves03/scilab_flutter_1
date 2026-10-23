import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { useState, useEffect } from 'react';
import { onAuthStateChanged } from 'firebase/auth';
import { doc, getDoc } from 'firebase/firestore';
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

function App() {
  const [user, setUser] = useState(null);
  const [isAdmin, setIsAdmin] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const evaluateUser = async (currentUser) => {
      if (currentUser) {
        setUser(currentUser);
        try {
          const userDoc = await getDoc(doc(db, 'users', currentUser.uid));
          const isHardcodedAdmin = currentUser.email === 'scilabar@gmail.com';
          const hasAdminRole = isHardcodedAdmin || (userDoc.exists() && userDoc.data().role === 'admin');
          if (hasAdminRole && isTrustedAdminDevice(currentUser)) {
            setIsAdmin(true);
          } else {
            setIsAdmin(false);
            if (!hasAdminRole) auth.signOut();
          }
        } catch (error) {
          console.error("Error checking admin status:", error);
          setIsAdmin(false);
        }
      } else {
        setUser(null);
        setIsAdmin(false);
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
          element={!user || !isAdmin ? <Login /> : <Navigate to="/" />}
        />

        <Route
          path="/"
          element={user && isAdmin ? <Layout /> : <Navigate to="/login" />}
        >
          <Route index element={<Overview />} />
          <Route path="users" element={<ManageUsers />} />
          <Route path="sections" element={<ManageSections />} />
          <Route path="uploads" element={<TeacherUploads />} />
          <Route path="ar-labs" element={<ARLabManager />} />
          <Route path="ar-marker" element={<ARMarker />} />
          <Route path="activity-logs" element={<ActivityLogs />} />
          <Route path="legal" element={<Legal />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}

export default App;
