import { Outlet, NavLink, useNavigate } from 'react-router-dom';
import { auth } from '../firebase';
import { 
  LayoutDashboard, 
  Users, 
  Layers, 
  BookOpen, 
  LogOut, 
  ShieldAlert
} from 'lucide-react';

export default function Layout() {
  const navigate = useNavigate();

  const handleLogout = async () => {
    await auth.signOut();
    navigate('/login');
  };

  return (
    <div className="app-container animate-fade-in">
      <aside className="sidebar">
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '48px', padding: '0 8px' }}>
          <div style={{ background: 'var(--accent-purple)', padding: '8px', borderRadius: '8px' }}>
            <ShieldAlert size={24} color="white" />
          </div>
          <div>
            <h3 style={{ fontSize: '1.2rem', margin: 0 }}>Scilab Admin</h3>
            <span style={{ fontSize: '0.75rem', color: 'var(--accent-green)', fontWeight: 600 }}>PORTAL ACTIVE</span>
          </div>
        </div>

        <nav style={{ display: 'flex', flexDirection: 'column', flex: 1 }}>
          <NavLink 
            to="/" 
            end
            className={({ isActive }) => isActive ? "nav-link active" : "nav-link"}
          >
            <LayoutDashboard size={20} />
            Overview
          </NavLink>
          
          <NavLink 
            to="/users" 
            className={({ isActive }) => isActive ? "nav-link active" : "nav-link"}
          >
            <Users size={20} />
            Manage Users
          </NavLink>
          
          <NavLink 
            to="/sections" 
            className={({ isActive }) => isActive ? "nav-link active" : "nav-link"}
          >
            <Layers size={20} />
            Manage Sections
          </NavLink>
          
          <NavLink 
            to="/uploads" 
            className={({ isActive }) => isActive ? "nav-link active" : "nav-link"}
          >
            <BookOpen size={20} />
            Teacher Uploads
          </NavLink>
        </nav>

        <div style={{ marginTop: 'auto', paddingTop: '24px', borderTop: '1px solid var(--border-light)' }}>
          <button 
            onClick={handleLogout}
            className="nav-link" 
            style={{ width: '100%', background: 'transparent', border: 'none', cursor: 'pointer' }}
          >
            <LogOut size={20} color="var(--accent-red)" />
            <span style={{ color: 'var(--accent-red)' }}>Sign Out</span>
          </button>
        </div>
      </aside>

      <main className="main-content">
        <Outlet />
      </main>
    </div>
  );
}
