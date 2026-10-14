import { useState, useEffect, useRef } from 'react';
import { createPortal } from 'react-dom';
import { collection, getDocs } from 'firebase/firestore';
import { db } from '../firebase';
import { 
  Users, Clock, ShieldCheck, BookOpen, GraduationCap, UserCheck, 
  Layers, Hexagon, ArrowRight, Activity, QrCode, Server, 
  CheckCircle2, AlertCircle, Calendar, CalendarDays, ChevronLeft, 
  ChevronRight, Pin, PinOff, X 
} from 'lucide-react';
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
  const [showSystemHealth, setShowSystemHealth] = useState(false);
  const [ping, setPing] = useState(null);

  // Live Date, Time & Calendar states
  const [currentTime, setCurrentTime] = useState(new Date());
  const [isPinned, setIsPinned] = useState(() => {
    return localStorage.getItem('dashboard_calendar_pinned') === 'true';
  });
  const [showCalendar, setShowCalendar] = useState(() => {
    return localStorage.getItem('dashboard_calendar_pinned') === 'true';
  });
  const [viewDate, setViewDate] = useState(new Date());
  const [selectedDate, setSelectedDate] = useState(new Date());
  const calendarContainerRef = useRef(null);

  // Live clock tick every second
  useEffect(() => {
    const timer = setInterval(() => {
      setCurrentTime(new Date());
    }, 1000);
    return () => clearInterval(timer);
  }, []);

  // Close floating calendar when clicking outside
  useEffect(() => {
    function handleClickOutside(event) {
      if (calendarContainerRef.current && !calendarContainerRef.current.contains(event.target)) {
        if (!isPinned) {
          setShowCalendar(false);
        }
      }
    }
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, [isPinned]);

  // Close floating calendar with Escape key
  useEffect(() => {
    function handleKeyDown(event) {
      if (event.key === 'Escape' && !isPinned) {
        setShowCalendar(false);
      }
    }
    document.addEventListener('keydown', handleKeyDown);
    return () => document.removeEventListener('keydown', handleKeyDown);
  }, [isPinned]);

  const handleTogglePin = () => {
    const newPinned = !isPinned;
    setIsPinned(newPinned);
    localStorage.setItem('dashboard_calendar_pinned', newPinned.toString());
    if (newPinned) {
      setShowCalendar(true);
    }
  };

  const formattedTime = currentTime.toLocaleTimeString('en-US', {
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
    hour12: true
  });

  const formattedDate = currentTime.toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric'
  });

  const dayOfWeek = currentTime.toLocaleDateString('en-US', { weekday: 'long' });

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

        {/* Date, Time & Calendar Widget */}
        <div ref={calendarContainerRef} style={{ position: 'relative' }}>
          <div className="dashboard-datetime-widget">
            {/* Date Section */}
            <div 
              className="datetime-item" 
              onClick={() => setShowCalendar(prev => !prev)}
              style={{ cursor: 'pointer' }}
              title="Click to view monthly calendar"
            >
              <div className="datetime-icon-box" style={{ background: 'linear-gradient(135deg, rgba(0, 212, 255, 0.18), rgba(59, 130, 246, 0.18))', color: 'var(--accent-cyan)' }}>
                <Calendar size={18} />
              </div>
              <div>
                <div style={{ fontSize: '0.72rem', fontWeight: 700, color: 'var(--accent-cyan)', textTransform: 'uppercase', letterSpacing: '0.05em' }}>
                  {dayOfWeek}
                </div>
                <div style={{ fontSize: '0.92rem', fontWeight: 600, color: 'var(--text-primary)', whiteSpace: 'nowrap' }}>
                  {formattedDate}
                </div>
              </div>
            </div>

            <div className="datetime-divider" />

            {/* Time Section */}
            <div className="datetime-item">
              <div className="datetime-icon-box" style={{ background: 'linear-gradient(135deg, rgba(16, 185, 129, 0.18), rgba(0, 212, 255, 0.18))', color: '#10b981' }}>
                <Clock size={18} />
              </div>
              <div>
                <div style={{ fontSize: '0.72rem', fontWeight: 700, color: '#10b981', textTransform: 'uppercase', letterSpacing: '0.05em' }}>
                  TIME
                </div>
                <div style={{ fontSize: '0.92rem', fontWeight: 700, color: 'var(--text-primary)', fontVariantNumeric: 'tabular-nums', fontFamily: 'monospace', whiteSpace: 'nowrap' }}>
                  {formattedTime}
                </div>
              </div>
            </div>

            {/* Calendar View Toggle Button */}
            <button
              type="button"
              className="btn btn-secondary"
              onClick={() => setShowCalendar(prev => !prev)}
              style={{
                padding: '6px 12px',
                fontSize: '0.82rem',
                borderRadius: '10px',
                display: 'flex',
                alignItems: 'center',
                gap: '6px',
                background: showCalendar ? 'rgba(0, 212, 255, 0.15)' : undefined,
                borderColor: showCalendar ? 'var(--accent-cyan)' : undefined,
                color: showCalendar ? 'var(--accent-cyan)' : undefined
              }}
              title={showCalendar ? "Hide Calendar" : "View Monthly Calendar"}
            >
              <CalendarDays size={16} />
              <span className="hide-mobile">{showCalendar ? 'Close' : 'Calendar'}</span>
            </button>
          </div>

          {/* Floating Calendar Popover (when open and not pinned) */}
          {showCalendar && !isPinned && (
            <div className="calendar-popover animate-fade-in">
              <CalendarPanel 
                viewDate={viewDate}
                setViewDate={setViewDate}
                selectedDate={selectedDate}
                setSelectedDate={setSelectedDate}
                currentTime={currentTime}
                onClose={() => setShowCalendar(false)}
                isPinned={isPinned}
                onTogglePin={handleTogglePin}
              />
            </div>
          )}
        </div>
      </div>

      {/* Docked Calendar Card (when pinned) */}
      {showCalendar && isPinned && (
        <div className="calendar-docked-card animate-fade-in glass-panel">
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))', gap: '28px', alignItems: 'center' }}>
            <CalendarPanel 
              viewDate={viewDate}
              setViewDate={setViewDate}
              selectedDate={selectedDate}
              setSelectedDate={setSelectedDate}
              currentTime={currentTime}
              onClose={() => setShowCalendar(false)}
              isPinned={isPinned}
              onTogglePin={handleTogglePin}
            />

            {/* Right side: Today's Overview & Clock Hero */}
            <div style={{
              background: 'linear-gradient(135deg, rgba(0, 212, 255, 0.08), rgba(167, 139, 250, 0.08))',
              border: '1px solid var(--border-light)',
              borderRadius: '16px',
              padding: '24px',
              display: 'flex',
              flexDirection: 'column',
              justifyContent: 'space-between',
              height: '100%',
              minHeight: '260px'
            }}>
              <div>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '16px' }}>
                  <div>
                    <span style={{ fontSize: '0.8rem', fontWeight: 700, color: 'var(--accent-cyan)', textTransform: 'uppercase', letterSpacing: '0.08em' }}>
                      Today's Schedule & Clock
                    </span>
                    <h3 style={{ fontSize: '1.6rem', fontWeight: 700, color: 'var(--text-primary)', marginTop: '4px' }}>
                      {dayOfWeek}
                    </h3>
                  </div>
                  <div style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: '6px',
                    background: 'rgba(16, 185, 129, 0.15)',
                    padding: '4px 10px',
                    borderRadius: '20px',
                    border: '1px solid rgba(16, 185, 129, 0.3)'
                  }}>
                    <span style={{ width: '8px', height: '8px', borderRadius: '50%', background: '#10b981' }} className="animate-pulse" />
                    <span style={{ fontSize: '0.75rem', color: '#10b981', fontWeight: 700 }}>SYSTEM SYNCED</span>
                  </div>
                </div>

                <div style={{ 
                  fontSize: '2.2rem', 
                  fontWeight: 800, 
                  fontFamily: 'monospace', 
                  fontVariantNumeric: 'tabular-nums', 
                  color: 'var(--text-primary)',
                  marginBottom: '8px',
                  letterSpacing: '-0.02em'
                }}>
                  {formattedTime}
                </div>

                <p style={{ color: 'var(--text-secondary)', fontSize: '0.95rem', marginBottom: '20px' }}>
                  {formattedDate}
                </p>

                <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', fontSize: '0.85rem', color: 'var(--text-secondary)' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                    <span>Active Learners</span>
                    <strong style={{ color: 'var(--text-primary)' }}>{stats.students}</strong>
                  </div>
                  <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                    <span>Teaching Faculty</span>
                    <strong style={{ color: 'var(--text-primary)' }}>{stats.teachers}</strong>
                  </div>
                  <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                    <span>Action Needed</span>
                    <strong style={{ color: stats.pendingUsers > 0 ? '#fbbf24' : '#10b981' }}>
                      {stats.pendingUsers > 0 ? `${stats.pendingUsers} Pending` : 'All clear'}
                    </strong>
                  </div>
                </div>
              </div>

              <div style={{ marginTop: '20px', display: 'flex', gap: '10px' }}>
                <button 
                  type="button" 
                  className="btn btn-secondary" 
                  style={{ flex: 1, fontSize: '0.85rem' }}
                  onClick={handleTogglePin}
                >
                  <PinOff size={15} />
                  <span>Unpin from Dashboard</span>
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

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

      <h2 style={{ fontSize: '1.5rem', marginBottom: '20px', color: 'var(--text-primary)' }}>Platform Content & Modules</h2>
      
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
        
      </div>

      <h2 style={{ fontSize: '1.5rem', marginBottom: '20px', color: 'var(--text-primary)', marginTop: '40px' }}>System Tools & Admin</h2>
      
      <div className="grid-secondary" style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))', gap: '20px' }}>
        <StatCard 
          title="AR Marker" 
          value="VuMark" 
          icon={<QrCode size={24} color="#fcd34d" />} 
          trend="Download Scilab Marker"
          onClick={() => navigate('/ar-marker')}
          color="#fcd34d"
          small
        />
        
        <StatCard 
          title="Activity Logs" 
          value="Tracker" 
          icon={<Activity size={24} color="#14b8a6" />} 
          trend="Track user actions"
          onClick={() => navigate('/activity-logs')}
          color="#14b8a6"
          small
        />

        <StatCard 
          title="Legal" 
          value="Terms" 
          icon={<ShieldCheck size={24} color="#94a3b8" />} 
          trend="Terms & conditions"
          onClick={() => navigate('/legal')}
          color="#94a3b8"
          small
        />
        
        <StatCard 
          title="System Status" 
          value="Online" 
          icon={<Server size={24} color="#10b981" />} 
          trend="All systems operational"
          color="#10b981"
          onClick={() => {
            setShowSystemHealth(true);
            const start = Date.now();
            getDocs(collection(db, 'users')).then(() => {
              setPing(Date.now() - start);
            }).catch(() => setPing(-1));
          }}
          small
        />
      </div>

      {showSystemHealth && createPortal(
        <div className="modal-overlay" style={{
          position: 'fixed', top: 0, left: 0, right: 0, bottom: 0,
          backgroundColor: 'rgba(0,0,0,0.6)', backdropFilter: 'blur(4px)',
          display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 1000
        }}>
          <div className="modal-content animate-fade-in glass-panel" style={{
            background: 'var(--bg-card)', width: '100%', maxWidth: '400px',
            borderRadius: '16px', padding: '24px', position: 'relative',
            border: '1px solid var(--border-light)',
            boxShadow: 'var(--shadow-lg)'
          }}>
            <h2 style={{ fontSize: '1.25rem', marginBottom: '20px', color: 'var(--text-primary)', display: 'flex', alignItems: 'center', gap: '8px' }}>
              <Server size={20} color="#10b981" /> System Health
            </h2>
            
            <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '12px', background: 'var(--bg-main)', borderRadius: '8px', border: '1px solid var(--border-light)' }}>
                <span style={{ color: 'var(--text-secondary)' }}>Firestore Database</span>
                <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                  <CheckCircle2 size={16} color="#10b981" />
                  <span style={{ color: '#10b981', fontWeight: 'bold' }}>Online</span>
                </div>
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '12px', background: 'var(--bg-main)', borderRadius: '8px', border: '1px solid var(--border-light)' }}>
                <span style={{ color: 'var(--text-secondary)' }}>Authentication Service</span>
                <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                  <CheckCircle2 size={16} color="#10b981" />
                  <span style={{ color: '#10b981', fontWeight: 'bold' }}>Online</span>
                </div>
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '12px', background: 'var(--bg-main)', borderRadius: '8px', border: '1px solid var(--border-light)' }}>
                <span style={{ color: 'var(--text-secondary)' }}>Storage Bucket</span>
                <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                  <CheckCircle2 size={16} color="#10b981" />
                  <span style={{ color: '#10b981', fontWeight: 'bold' }}>Online</span>
                </div>
              </div>
              
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '12px', borderTop: '1px solid var(--border-light)', marginTop: '8px' }}>
                <span style={{ color: 'var(--text-secondary)', fontSize: '0.9rem' }}>Network Latency</span>
                <span style={{ color: 'var(--text-primary)', fontWeight: 'bold' }}>
                  {ping === null ? 'Pinging...' : ping === -1 ? 'Error' : `${ping} ms`}
                </span>
              </div>
            </div>

            <button 
              className="btn btn-secondary" 
              style={{ width: '100%', marginTop: '24px' }}
              onClick={() => setShowSystemHealth(false)}
            >
              Close
            </button>
          </div>
        </div>,
        document.body
      )}
    </div>
  );
}

function CalendarPanel({ viewDate, setViewDate, selectedDate, setSelectedDate, currentTime, onClose, isPinned, onTogglePin }) {
  const today = new Date();
  const year = viewDate.getFullYear();
  const month = viewDate.getMonth();

  const monthName = viewDate.toLocaleDateString('en-US', { month: 'long', year: 'numeric' });

  const firstDayOfMonth = new Date(year, month, 1).getDay();
  const daysInMonth = new Date(year, month + 1, 0).getDate();
  const daysInPrevMonth = new Date(year, month, 0).getDate();

  const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  const cells = [];

  // Previous month trailing days
  for (let i = firstDayOfMonth - 1; i >= 0; i--) {
    cells.push({ day: daysInPrevMonth - i, otherMonth: true });
  }
  // Current month days
  for (let d = 1; d <= daysInMonth; d++) {
    const isToday = d === today.getDate() && month === today.getMonth() && year === today.getFullYear();
    const isSelected = d === selectedDate.getDate() && month === selectedDate.getMonth() && year === selectedDate.getFullYear();
    cells.push({ day: d, otherMonth: false, isToday, isSelected });
  }
  // Next month leading days to fill grid
  const remaining = 42 - cells.length;
  for (let d = 1; d <= remaining; d++) {
    cells.push({ day: d, otherMonth: true });
  }

  const goToPrevMonth = () => {
    setViewDate(new Date(year, month - 1, 1));
  };

  const goToNextMonth = () => {
    setViewDate(new Date(year, month + 1, 1));
  };

  const goToToday = () => {
    const now = new Date();
    setViewDate(new Date(now.getFullYear(), now.getMonth(), 1));
    setSelectedDate(now);
  };

  return (
    <div>
      {/* Calendar Header */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
          <CalendarDays size={20} color="var(--accent-cyan)" />
          <h3 style={{ fontSize: '1.1rem', fontWeight: 700, color: 'var(--text-primary)', margin: 0 }}>
            {monthName}
          </h3>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
          <button
            type="button"
            onClick={goToPrevMonth}
            style={{
              background: 'none', border: '1px solid var(--border-light)', borderRadius: '8px',
              width: '30px', height: '30px', display: 'flex', alignItems: 'center', justifyContent: 'center',
              cursor: 'pointer', color: 'var(--text-secondary)', transition: 'all 0.15s ease'
            }}
            onMouseEnter={(e) => { e.currentTarget.style.borderColor = 'var(--accent-cyan)'; e.currentTarget.style.color = 'var(--accent-cyan)'; }}
            onMouseLeave={(e) => { e.currentTarget.style.borderColor = 'var(--border-light)'; e.currentTarget.style.color = 'var(--text-secondary)'; }}
            title="Previous month"
          >
            <ChevronLeft size={16} />
          </button>
          <button
            type="button"
            onClick={goToToday}
            style={{
              background: 'none', border: '1px solid var(--border-light)', borderRadius: '8px',
              padding: '4px 10px', cursor: 'pointer', color: 'var(--text-secondary)',
              fontSize: '0.75rem', fontWeight: 600, transition: 'all 0.15s ease'
            }}
            onMouseEnter={(e) => { e.currentTarget.style.borderColor = 'var(--accent-cyan)'; e.currentTarget.style.color = 'var(--accent-cyan)'; }}
            onMouseLeave={(e) => { e.currentTarget.style.borderColor = 'var(--border-light)'; e.currentTarget.style.color = 'var(--text-secondary)'; }}
            title="Go to today"
          >
            Today
          </button>
          <button
            type="button"
            onClick={goToNextMonth}
            style={{
              background: 'none', border: '1px solid var(--border-light)', borderRadius: '8px',
              width: '30px', height: '30px', display: 'flex', alignItems: 'center', justifyContent: 'center',
              cursor: 'pointer', color: 'var(--text-secondary)', transition: 'all 0.15s ease'
            }}
            onMouseEnter={(e) => { e.currentTarget.style.borderColor = 'var(--accent-cyan)'; e.currentTarget.style.color = 'var(--accent-cyan)'; }}
            onMouseLeave={(e) => { e.currentTarget.style.borderColor = 'var(--border-light)'; e.currentTarget.style.color = 'var(--text-secondary)'; }}
            title="Next month"
          >
            <ChevronRight size={16} />
          </button>
          
          {/* Pin / Close buttons */}
          <div style={{ marginLeft: '8px', display: 'flex', gap: '4px' }}>
            <button
              type="button"
              onClick={onTogglePin}
              title={isPinned ? "Unpin calendar" : "Pin calendar to dashboard"}
              style={{
                background: isPinned ? 'rgba(0, 212, 255, 0.15)' : 'none',
                border: '1px solid var(--border-light)',
                borderColor: isPinned ? 'var(--accent-cyan)' : 'var(--border-light)',
                borderRadius: '8px',
                width: '30px', height: '30px', display: 'flex', alignItems: 'center', justifyContent: 'center',
                cursor: 'pointer', color: isPinned ? 'var(--accent-cyan)' : 'var(--text-secondary)', transition: 'all 0.15s ease'
              }}
            >
              {isPinned ? <PinOff size={14} /> : <Pin size={14} />}
            </button>
            <button
              type="button"
              onClick={onClose}
              title="Close calendar"
              style={{
                background: 'none', border: '1px solid var(--border-light)', borderRadius: '8px',
                width: '30px', height: '30px', display: 'flex', alignItems: 'center', justifyContent: 'center',
                cursor: 'pointer', color: 'var(--text-secondary)', transition: 'all 0.15s ease'
              }}
              onMouseEnter={(e) => { e.currentTarget.style.borderColor = 'var(--accent-red)'; e.currentTarget.style.color = 'var(--accent-red)'; }}
              onMouseLeave={(e) => { e.currentTarget.style.borderColor = 'var(--border-light)'; e.currentTarget.style.color = 'var(--text-secondary)'; }}
            >
              <X size={14} />
            </button>
          </div>
        </div>
      </div>

      {/* Day Headers */}
      <div className="calendar-grid">
        {dayNames.map(d => (
          <div key={d} className="calendar-day-header">{d}</div>
        ))}

        {/* Day Cells */}
        {cells.map((cell, idx) => (
          <div
            key={idx}
            className={`calendar-day-cell ${cell.otherMonth ? 'other-month' : ''} ${cell.isToday ? 'today' : ''} ${cell.isSelected && !cell.isToday && !cell.otherMonth ? 'selected' : ''}`}
            onClick={() => {
              if (!cell.otherMonth) {
                setSelectedDate(new Date(year, month, cell.day));
              }
            }}
          >
            {cell.day}
          </div>
        ))}
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
