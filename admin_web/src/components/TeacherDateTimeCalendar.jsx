import { useEffect, useRef, useState } from 'react';
import { Calendar, CalendarDays, ChevronLeft, ChevronRight, Clock3, X } from 'lucide-react';

export default function TeacherDateTimeCalendar() {
  const [now, setNow] = useState(new Date());
  const [open, setOpen] = useState(false);
  const [viewDate, setViewDate] = useState(new Date());
  const [selectedDate, setSelectedDate] = useState(new Date());
  const containerRef = useRef(null);

  useEffect(() => {
    const timer = window.setInterval(() => setNow(new Date()), 1000);
    return () => window.clearInterval(timer);
  }, []);

  useEffect(() => {
    const closeOutside = (event) => {
      if (containerRef.current && !containerRef.current.contains(event.target)) setOpen(false);
    };
    const closeOnEscape = (event) => {
      if (event.key === 'Escape') setOpen(false);
    };
    document.addEventListener('mousedown', closeOutside);
    document.addEventListener('keydown', closeOnEscape);
    return () => {
      document.removeEventListener('mousedown', closeOutside);
      document.removeEventListener('keydown', closeOnEscape);
    };
  }, []);

  const day = now.toLocaleDateString('en-PH', { weekday: 'long' });
  const date = now.toLocaleDateString('en-PH', { month: 'short', day: 'numeric', year: 'numeric' });
  const time = now.toLocaleTimeString('en-PH', { hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: true });

  return (
    <div className="teacher-datetime-wrap" ref={containerRef}>
      <div className="dashboard-datetime-widget teacher-datetime-widget">
        <button type="button" className="datetime-item teacher-datetime-trigger" onClick={() => setOpen((value) => !value)} title="Open calendar">
          <div className="datetime-icon-box teacher-date-icon"><Calendar size={18} /></div>
          <div><span className="teacher-datetime-label date">{day}</span><strong>{date}</strong></div>
        </button>
        <div className="datetime-divider" />
        <div className="datetime-item">
          <div className="datetime-icon-box teacher-time-icon"><Clock3 size={18} /></div>
          <div><span className="teacher-datetime-label time">Time</span><strong className="teacher-live-time">{time}</strong></div>
        </div>
        <button type="button" className={`btn btn-secondary teacher-calendar-button ${open ? 'active' : ''}`} onClick={() => setOpen((value) => !value)}>
          <CalendarDays size={16} /> {open ? 'Close' : 'Calendar'}
        </button>
      </div>
      {open && (
        <div className="calendar-popover animate-fade-in">
          <TeacherCalendar viewDate={viewDate} setViewDate={setViewDate} selectedDate={selectedDate} setSelectedDate={setSelectedDate} onClose={() => setOpen(false)} />
        </div>
      )}
    </div>
  );
}

function TeacherCalendar({ viewDate, setViewDate, selectedDate, setSelectedDate, onClose }) {
  const today = new Date();
  const year = viewDate.getFullYear();
  const month = viewDate.getMonth();
  const firstDay = new Date(year, month, 1).getDay();
  const daysInMonth = new Date(year, month + 1, 0).getDate();
  const daysInPreviousMonth = new Date(year, month, 0).getDate();
  const cells = [];

  for (let index = firstDay - 1; index >= 0; index -= 1) {
    cells.push({ day: daysInPreviousMonth - index, otherMonth: true, key: `previous-${index}` });
  }
  for (let day = 1; day <= daysInMonth; day += 1) {
    cells.push({
      day,
      otherMonth: false,
      key: `current-${day}`,
      isToday: day === today.getDate() && month === today.getMonth() && year === today.getFullYear(),
      isSelected: day === selectedDate.getDate() && month === selectedDate.getMonth() && year === selectedDate.getFullYear(),
    });
  }
  for (let day = 1; cells.length < 42; day += 1) cells.push({ day, otherMonth: true, key: `next-${day}` });

  const goToday = () => {
    const current = new Date();
    setViewDate(new Date(current.getFullYear(), current.getMonth(), 1));
    setSelectedDate(current);
  };

  return (
    <div>
      <div className="teacher-calendar-header">
        <div><CalendarDays size={20} /><h3>{viewDate.toLocaleDateString('en-PH', { month: 'long', year: 'numeric' })}</h3></div>
        <button type="button" className="teacher-icon-btn" onClick={onClose} aria-label="Close calendar"><X size={16} /></button>
      </div>
      <div className="teacher-calendar-navigation">
        <button type="button" onClick={() => setViewDate(new Date(year, month - 1, 1))}><ChevronLeft size={17} /> Previous</button>
        <button type="button" onClick={goToday}>Today</button>
        <button type="button" onClick={() => setViewDate(new Date(year, month + 1, 1))}>Next <ChevronRight size={17} /></button>
      </div>
      <div className="calendar-grid">
        {['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((name) => <div className="calendar-day-header" key={name}>{name}</div>)}
        {cells.map((cell) => (
          <button
            type="button"
            key={cell.key}
            disabled={cell.otherMonth}
            className={`calendar-day-cell ${cell.otherMonth ? 'other-month' : ''} ${cell.isToday ? 'today' : ''} ${cell.isSelected && !cell.isToday ? 'selected' : ''}`}
            onClick={() => setSelectedDate(new Date(year, month, cell.day))}
          >{cell.day}</button>
        ))}
      </div>
      <div className="teacher-calendar-selected">Selected: <strong>{selectedDate.toLocaleDateString('en-PH', { weekday: 'long', month: 'long', day: 'numeric', year: 'numeric' })}</strong></div>
    </div>
  );
}
