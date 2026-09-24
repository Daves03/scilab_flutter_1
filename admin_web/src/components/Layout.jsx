import { useState, useEffect } from 'react';
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
  X,
  Sun,
  Moon
} from 'lucide-react';

export default function Layout() {
  const navigate = useNavigate();
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const [theme, setTheme] = useState(() => localStorage.getItem('admin-theme') || 'dark');
  const [showSignOutModal, setShowSignOutModal] = useState(false);

  useEffect(() => {
    document.documentElement.setAttribute('data-theme', theme);
    localStorage.setItem('admin-theme', theme);
  }, [theme]);

  const toggleTheme = () => {
    setTheme(prev => prev === 'dark' ? 'light' : 'dark');
  };

  const handleLogoutClick = () => {
    setShowSignOutModal(true);
  };

  const confirmLogout = async () => {
    await auth.signOut();
    navigate('/login');
  };

  const closeMenu = () => {
    setIsMobileMenuOpen(false);
  };

  return (
    <div className="app-container">
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
          
          <div 
            onClick={toggleTheme}
            className="nav-link" 
            style={{ width: '100%', cursor: 'pointer', marginTop: '16px', display: 'flex', alignItems: 'center', gap: '12px' }}
          >
            {theme === 'dark' ? <Moon size={20} /> : <Sun size={20} />} 
            <span style={{ marginRight: '8px' }}>{theme === 'dark' ? 'Dark Mode' : 'Light Mode'}</span>
            <div className={`theme-toggle ${theme}`}>
              <div className="toggle-thumb" />
            </div>
          </div>
        </nav>

        <div style={{ marginTop: 'auto', paddingTop: '24px', borderTop: '1px solid var(--border-light)' }}>
          <button 
            onClick={handleLogoutClick}
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

      {/* Sign Out Confirmation Modal */}
      {showSignOutModal && (
        <div style={{
          position: 'fixed',
          top: 0, left: 0, right: 0, bottom: 0,
          backgroundColor: 'rgba(0, 0, 0, 0.75)',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          zIndex: 1000, padding: '24px'
        }}>
          <div className="card" style={{ 
            maxWidth: '400px', 
            width: '100%', 
            textAlign: 'center',
            backgroundColor: 'var(--bg-main)',
            padding: '32px',
            borderRadius: '16px',
            boxShadow: 'var(--shadow-lg)'
          }}>
            <div style={{ display: 'flex', justifyContent: 'center', marginBottom: '16px' }}>
              <div style={{ background: 'rgba(255, 71, 87, 0.1)', padding: '16px', borderRadius: '50%' }}>
                <LogOut size={32} color="var(--accent-red)" />
              </div>
            </div>
            <h2 style={{ marginBottom: '8px', color: 'var(--text-primary)' }}>Sign Out</h2>
            <p style={{ color: 'var(--text-secondary)', marginBottom: '24px' }}>
              Are you sure you want to sign out?
            </p>
            <div style={{ display: 'flex', gap: '16px' }}>
              <button 
                onClick={() => setShowSignOutModal(false)}
                className="btn btn-secondary" 
                style={{ flex: 1 }}
              >
                Cancel
              </button>
              <button 
                onClick={confirmLogout}
                className="btn btn-danger" 
                style={{ flex: 1 }}
              >
                Sign Out
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
