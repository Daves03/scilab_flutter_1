import { useState } from 'react';
import { Outlet, NavLink, useNavigate } from 'react-router-dom';
import { auth } from '../firebase';
import { 
  LayoutDashboard, 
  Users, 
  Layers, 
  BookOpen, 
  LogOut, 
  Box,
  Menu,
  X
} from 'lucide-react';

export default function Layout() {
  const navigate = useNavigate();
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  const handleLogout = async () => {
    await auth.signOut();
    navigate('/login');
  };

  const closeMenu = () => {
    setIsMobileMenuOpen(false);
  };

  return (
    <div className="app-container animate-fade-in">
      {/* Mobile Header (Only visible on small screens) */}
      <div className="mobile-header">
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <img src="/favicon.png" alt="Scilab Logo" style={{ width: '32px', height: '32px', objectFit: 'contain' }} />
          <h3 style={{ fontSize: '1.2rem', margin: 0, fontWeight: 700 }}>Scilab Admin</h3>
        </div>
        <button onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)} className="mobile-menu-btn">
          {isMobileMenuOpen ? <X size={28} /> : <Menu size={28} />}
        </button>
      </div>

      <aside className={`sidebar ${isMobileMenuOpen ? 'open' : ''}`}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '48px', padding: '0 8px' }}>
          <img src="/favicon.png" alt="Scilab Logo" style={{ width: '40px', height: '40px', objectFit: 'contain' }} />
          <div>
            <h3 style={{ fontSize: '1.2rem', margin: 0 }}>Scilab Admin</h3>
            <span style={{ fontSize: '0.75rem', color: 'var(--accent-green)', fontWeight: 600 }}>PORTAL ACTIVE</span>
          </div>
        </div>

        <nav style={{ display: 'flex', flexDirection: 'column', flex: 1 }}>
          <NavLink 
            to="/" 
            end
            onClick={closeMenu}
            className={({ isActive }) => isActive ? "nav-link active" : "nav-link"}
          >
            <LayoutDashboard size={20} />
            Overview
          </NavLink>
          
          <NavLink 
            to="/users" 
            onClick={closeMenu}
            className={({ isActive }) => isActive ? "nav-link active" : "nav-link"}
          >
            <Users size={20} />
            Manage Users
          </NavLink>
          
          <NavLink 
            to="/sections" 
            onClick={closeMenu}
            className={({ isActive }) => isActive ? "nav-link active" : "nav-link"}
          >
            <Layers size={20} />
            Manage Sections
          </NavLink>
          
          <NavLink 
            to="/uploads" 
            onClick={closeMenu}
            className={({ isActive }) => isActive ? "nav-link active" : "nav-link"}
          >
            <BookOpen size={20} />
            Teacher Uploads
          </NavLink>
          
          <NavLink 
            to="/ar-labs" 
            onClick={closeMenu}
            className={({ isActive }) => isActive ? "nav-link active" : "nav-link"}
          >
            <Box size={20} />
            AR Labs
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

      {/* Overlay to close sidebar on mobile when clicking outside */}
      {isMobileMenuOpen && (
        <div 
          className="sidebar-overlay"
          onClick={closeMenu}
        />
      )}

      <main className="main-content">
        <Outlet />
      </main>
    </div>
  );
}
