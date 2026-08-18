import { useState, useEffect } from 'react';
import { collection, query, where, getDocs } from 'firebase/firestore';
import { db } from '../firebase';
import { Users, Clock, ShieldCheck, BookOpen } from 'lucide-react';

export default function Overview() {
  const [stats, setStats] = useState({
    activeUsers: 0,
    pendingUsers: 0,
    totalCourses: 0
  });

  useEffect(() => {
    async function fetchStats() {
      try {
        const usersSnap = await getDocs(collection(db, 'users'));
        let active = 0;
        let pending = 0;
        
        usersSnap.forEach(doc => {
          const data = doc.data();
          if (data.status === 'approved') active++;
          if (data.status === 'pending') pending++;
        });

        const coursesSnap = await getDocs(collection(db, 'courses'));
        
        setStats({
          activeUsers: active,
          pendingUsers: pending,
          totalCourses: coursesSnap.size
        });
      } catch (e) {
        console.error("Error fetching stats:", e);
      }
    }
    fetchStats();
  }, []);

  return (
    <div className="animate-fade-in">
      <div className="page-header">
        <div>
          <h1>Dashboard Overview</h1>
          <p>Welcome back, Admin. Here is what's happening today.</p>
        </div>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))', gap: '24px', marginBottom: '40px' }}>
        <StatCard 
          title="Active Users" 
          value={stats.activeUsers} 
          icon={<Users size={24} color="var(--accent-cyan)" />} 
          trend="+12% this week"
        />
        <StatCard 
          title="Pending Approvals" 
          value={stats.pendingUsers} 
          icon={<Clock size={24} color="var(--accent-orange)" />} 
          trend="Requires attention"
          alert={stats.pendingUsers > 0}
        />
        <StatCard 
          title="Total Courses" 
          value={stats.totalCourses} 
          icon={<BookOpen size={24} color="var(--accent-purple)" />} 
          trend="Across all sections"
        />
        <StatCard 
          title="System Status" 
          value="Online" 
          icon={<ShieldCheck size={24} color="var(--accent-green)" />} 
          trend="All services operational"
        />
      </div>
    </div>
  );
}

function StatCard({ title, value, icon, trend, alert }) {
  return (
    <div className="glass-panel" style={{ padding: '24px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '16px' }}>
        <div style={{ background: 'rgba(255,255,255,0.05)', padding: '12px', borderRadius: '12px' }}>
          {icon}
        </div>
        {alert && <span style={{ width: '10px', height: '10px', borderRadius: '50%', background: 'var(--accent-orange)' }}></span>}
      </div>
      <h3 style={{ fontSize: '2rem', marginBottom: '4px' }}>{value}</h3>
      <p style={{ color: 'white', fontWeight: 500, marginBottom: '8px' }}>{title}</p>
      <p style={{ fontSize: '0.8rem', color: 'var(--text-secondary)' }}>{trend}</p>
    </div>
  );
}
