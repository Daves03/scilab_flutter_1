import { useState, useEffect } from 'react';
import { collection, getDocs } from 'firebase/firestore';
import { db } from '../firebase';
import { Users, Clock, ShieldCheck, BookOpen, GraduationCap, UserCheck, Layers, Hexagon, ArrowRight, Activity } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

export default function Overview() {
  const navigate = useNavigate();
  const [stats, setStats] = useState({
    students: 0,
    teachers: 0,
    pendingUsers: 0,
    totalCourses: 0,
    totalSections: 0,
    totalArLabs: 0
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function fetchStats() {
      try {
        const usersSnap = await getDocs(collection(db, 'users'));
        let students = 0;
        let teachers = 0;
        let pending = 0;
        
        usersSnap.forEach(doc => {
          const data = doc.data();
          if (data.status === 'pending') {
            pending++;
          } else if (data.status === 'approved') {
            if (data.role === 'teacher') {
              teachers++;
            } else if (data.role !== 'admin') {
              // If not admin and not teacher, consider it a student role (e.g. grade9)
              students++;
            }
          }
        });

        const coursesSnap = await getDocs(collection(db, 'courses'));
        const sectionsSnap = await getDocs(collection(db, 'sections'));
        const arLabsSnap = await getDocs(collection(db, 'ar_experiments'));
        
        setStats({
          students,
          teachers,
          pendingUsers: pending,
          totalCourses: coursesSnap.size,
          totalSections: sectionsSnap.size,
          totalArLabs: arLabsSnap.size
        });
      } catch (e) {
        console.error("Error fetching stats:", e);
      } finally {
        setLoading(false);
      }
    }
    fetchStats();
  }, []);

  return (
    <div className="animate-fade-in" style={{ paddingBottom: '40px' }}>
      <div className="page-header" style={{ marginBottom: '32px' }}>
        <div>
          <h1 className="overview-title">
            Dashboard Overview
          </h1>
          <p style={{ color: 'var(--text-secondary)', fontSize: '1.1rem' }}>Welcome back, Admin. Here is what's happening today in your LMS.</p>
        </div>
      </div>

      {/* Main KPI Grid */}
      <div className="grid-main" style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', gap: '24px', marginBottom: '40px' }}>
        
        <StatCard 
          title="Active Students" 
          value={loading ? "..." : stats.students} 
          icon={<GraduationCap size={28} color="#60a5fa" />} 
          trend="Registered learners"
          onClick={() => navigate('/users')}
          color="#60a5fa"
        />
        
        <StatCard 
          title="Active Teachers" 
          value={loading ? "..." : stats.teachers} 
          icon={<UserCheck size={28} color="#34d399" />} 
          trend="Educators on platform"
          onClick={() => navigate('/users')}
          color="#34d399"
        />
        
        <StatCard 
          title="Pending Approvals" 
          value={loading ? "..." : stats.pendingUsers} 
          icon={<Clock size={28} color="#fbbf24" />} 
          trend={stats.pendingUsers > 0 ? "Requires your attention" : "All caught up"}
          alert={stats.pendingUsers > 0}
          onClick={() => navigate('/users')}
          color="#fbbf24"
        />
        
      </div>

      <h2 style={{ fontSize: '1.5rem', marginBottom: '20px', color: 'white' }}>Platform Content & Modules</h2>
      
      {/* Secondary KPI Grid */}
      <div className="grid-secondary" style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))', gap: '20px', marginBottom: '40px' }}>
        
        <StatCard 
          title="Class Sections" 
          value={loading ? "..." : stats.totalSections} 
          icon={<Layers size={24} color="#a78bfa" />} 
          trend="Manage curriculum"
          onClick={() => navigate('/sections')}
          color="#a78bfa"
          small
        />
        
        <StatCard 
          title="AR Experiments" 
          value={loading ? "..." : stats.totalArLabs} 
          icon={<Hexagon size={24} color="#f472b6" />} 
          trend="Immersive learning labs"
          onClick={() => navigate('/ar-labs')}
          color="#f472b6"
          small
        />

        <StatCard 
          title="Teacher Uploads" 
          value={loading ? "..." : stats.totalCourses} 
          icon={<BookOpen size={24} color="#38bdf8" />} 
          trend="Uploaded course materials"
          onClick={() => navigate('/uploads')}
          color="#38bdf8"
          small
        />
        
        <StatCard 
          title="System Status" 
          value="Online" 
          icon={<Activity size={24} color="#10b981" />} 
          trend="All systems operational"
          color="#10b981"
          small
        />
      </div>
    </div>
  );
}

function StatCard({ title, value, icon, trend, alert, onClick, color, small }) {
  return (
    <div 
      className={`glass-panel stat-card-padding ${small ? 'small' : ''}`} 
      onClick={onClick}
      style={{ 
        cursor: onClick ? 'pointer' : 'default',
        position: 'relative',
        overflow: 'hidden',
        transition: 'all 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
        border: '1px solid rgba(255,255,255,0.05)',
        display: 'flex',
        flexDirection: 'column',
        height: '100%',
        boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)'
      }}
      onMouseEnter={(e) => {
        if(onClick) {
          e.currentTarget.style.transform = 'translateY(-5px) scale(1.02)';
          e.currentTarget.style.borderColor = color ? `${color}55` : 'rgba(255,255,255,0.2)';
          e.currentTarget.style.boxShadow = `0 20px 25px -5px rgba(0,0,0,0.5), 0 8px 10px -6px ${color ? color+'40' : 'rgba(0,0,0,0.5)'}`;
          const arrow = e.currentTarget.querySelector('.arrow-icon');
          if (arrow) arrow.style.transform = 'translateX(5px)';
        }
      }}
      onMouseLeave={(e) => {
        if(onClick) {
          e.currentTarget.style.transform = 'translateY(0) scale(1)';
          e.currentTarget.style.borderColor = 'rgba(255,255,255,0.05)';
          e.currentTarget.style.boxShadow = '0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)';
          const arrow = e.currentTarget.querySelector('.arrow-icon');
          if (arrow) arrow.style.transform = 'translateX(0)';
        }
      }}
    >
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: small ? '12px' : '20px' }}>
        <div className="icon-wrapper" style={{ 
          background: `linear-gradient(135deg, rgba(255,255,255,0.1), rgba(255,255,255,0.02))`, 
          padding: small ? '10px' : '14px', 
          borderRadius: '14px',
          boxShadow: 'inset 0 1px 1px rgba(255,255,255,0.1)'
        }}>
          {icon}
        </div>
        
        {alert && (
          <div style={{ display: 'flex', alignItems: 'center', gap: '6px', background: 'rgba(251, 191, 36, 0.1)', padding: '4px 10px', borderRadius: '20px', border: '1px solid rgba(251, 191, 36, 0.2)' }}>
            <span style={{ fontSize: '0.75rem', color: color, fontWeight: 'bold', textTransform: 'uppercase', letterSpacing: '0.05em' }}>Action Needed</span>
            <span style={{ width: '8px', height: '8px', borderRadius: '50%', background: color, boxShadow: `0 0 8px ${color}` }} className="animate-pulse"></span>
          </div>
        )}
        
        {onClick && !alert && (
          <div className="arrow-icon" style={{ transition: 'transform 0.3s ease', display: 'flex', alignItems: 'center', justifyContent: 'center', width: '32px', height: '32px', borderRadius: '50%', background: 'rgba(255,255,255,0.03)' }}>
            <ArrowRight size={18} color={color || "rgba(255,255,255,0.4)"} />
          </div>
        )}
      </div>
      
      <h3 className={`stat-value ${small ? 'small' : ''}`}>{value}</h3>
      <p className={`stat-title ${small ? 'small' : ''}`}>{title}</p>
      
      <div style={{ marginTop: 'auto', display: 'flex', alignItems: 'center', gap: '8px' }}>
        <p style={{ fontSize: '0.85rem', color: 'var(--text-secondary)' }}>{trend}</p>
      </div>
    </div>
  );
}
