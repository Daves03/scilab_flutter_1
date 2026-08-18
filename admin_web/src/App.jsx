import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { useState, useEffect } from 'react';
import { onAuthStateChanged } from 'firebase/auth';
import { doc, getDoc } from 'firebase/firestore';
import { auth, db } from './firebase';

import Login from './pages/Login';
import Layout from './components/Layout';
import Overview from './pages/Overview';
import ManageUsers from './pages/ManageUsers';
import ManageSections from './pages/ManageSections';
import TeacherUploads from './pages/TeacherUploads';

function App() {
  const [user, setUser] = useState(null);
  const [isAdmin, setIsAdmin] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (currentUser) => {
      if (currentUser) {
        setUser(currentUser);
        try {
          const userDoc = await getDoc(doc(db, 'users', currentUser.uid));
          if (userDoc.exists() && userDoc.data().role === 'admin') {
            setIsAdmin(true);
          } else {
            setIsAdmin(false);
            auth.signOut();
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
    });

    return () => unsubscribe();
  }, []);

  if (loading) {
    return (
      <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100vh', color: 'white' }}>
        <h2>Loading...</h2>
      </div>
    );
  }

  return (
    <BrowserRouter>
      <Routes>
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
        </Route>
      </Routes>
    </BrowserRouter>
  );
}

export default App;
