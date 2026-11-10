import { useEffect, useMemo, useState } from 'react';
import { collection, onSnapshot } from 'firebase/firestore';
import { ArrowLeft, Layers, Search, Users } from 'lucide-react';
import { db } from '../firebase';
import { teacherSectionSummaries } from '../services/teacherSectionSummaries';

export default function TeacherSections({ profile }) {
  const [users, setUsers] = useState([]);
  const [catalog, setCatalog] = useState([]);
  const [usersLoaded, setUsersLoaded] = useState(false);
  const [sectionsLoaded, setSectionsLoaded] = useState(false);
  const [error, setError] = useState('');
  const [search, setSearch] = useState('');
  const [grade, setGrade] = useState('all');
  const [selectedKey, setSelectedKey] = useState(null);

  useEffect(() => {
    const onError = (cause) => {
      console.error('Could not load teacher sections:', cause);
      setError('Could not load your sections and student counts. Please refresh to try again.');
    };
    const unsubscribeUsers = onSnapshot(collection(db, 'users'), (snapshot) => {
      setUsers(snapshot.docs.map((item) => ({ id: item.id, ...item.data() })));
      setUsersLoaded(true);
    }, onError);
    const unsubscribeSections = onSnapshot(collection(db, 'sections'), (snapshot) => {
      setCatalog(snapshot.docs.map((item) => ({ id: item.id, ...item.data() })));
      setSectionsLoaded(true);
    }, onError);
    return () => { unsubscribeUsers(); unsubscribeSections(); };
  }, []);

  const sections = useMemo(() => teacherSectionSummaries(profile?.sections || [], catalog, users), [profile?.sections, catalog, users]);
  const grades = [...new Set(sections.map((section) => section.grade).filter((label) => label !== 'Grade not set'))]
    .sort((first, second) => first.localeCompare(second, undefined, { numeric: true }));
  const selectedGrade = grades.includes(grade) ? grade : 'all';
  const visible = sections.filter((section) => (selectedGrade === 'all' || section.grade === selectedGrade)
    && `${section.name} ${section.grade}`.toLowerCase().includes(search.trim().toLowerCase()));
  const loading = !usersLoaded || !sectionsLoaded;
  const activeSection = sections.find((section) => section.key === selectedKey);

  return (
    <div className="teacher-page animate-fade-in">
      <div className="page-header teacher-page-header">
        <div>
          <span className="teacher-eyebrow"><Layers size={16} /> Your Sections</span>
          <h1>{activeSection ? `Section ${activeSection.name}` : 'Manage Sections'}</h1>
          <p>{activeSection ? `${activeSection.grade} · ${activeSection.total} students` : 'View student totals for each section assigned to you.'}</p>
        </div>
      </div>

      {error && <div className="teacher-form-error" role="alert">{error}</div>}
      <section className="glass-panel teacher-table-panel" aria-busy={loading}>
        {activeSection ? <>
          <button type="button" className="btn btn-secondary" style={{ marginBottom: '24px' }} onClick={() => setSelectedKey(null)}><ArrowLeft size={18} /> Back to Sections</button>
          {!error && <>
            <div className="teacher-section-status-summary">
              <span>Total students: <strong>{activeSection.total}</strong></span>
              <span className="teacher-student-status approved">Active: {activeSection.approved}</span>
              <span className="teacher-student-status pending">Pending: {activeSection.pending}</span>
              <span className="teacher-student-status rejected">Rejected: {activeSection.rejected}</span>
            </div>
            <div className="teacher-responsive-table">
              <table className="data-table">
                <thead><tr><th>Name</th><th>Student Number</th><th>Email</th><th>Status</th></tr></thead>
                <tbody>{activeSection.students.map((student) => <tr key={student.id}>
                  <td><strong>{student.name || 'No Name'}</strong></td>
                  <td>{student.studentNumber ? `#${student.studentNumber}` : '-'}</td>
                  <td>{student.email || '-'}</td>
                  <td><span className={`teacher-student-status ${['approved', 'pending', 'rejected'].includes(student.status) ? student.status : 'unknown'}`}>{student.status === 'approved' ? 'Active' : student.status === 'pending' ? 'Pending' : student.status === 'rejected' ? 'Rejected' : 'Not set'}</span></td>
                </tr>)}</tbody>
              </table>
            </div>
            {activeSection.total === 0 && <div className="teacher-empty-state"><Users size={34} /><strong>No students found in this section</strong></div>}
          </>}
        </> : <>
        <div className="teacher-toolbar teacher-assigned-sections-toolbar">
          <div className="tabs" style={{ borderBottom: 'none', marginBottom: 0, flex: 1 }}>
            <span className="tab active" style={{ display: 'block', textAlign: 'center', color: 'var(--accent-green)' }}>Assigned Sections ({loading || error ? '…' : visible.length})</span>
          </div>
          <label className="teacher-search"><Search size={18} /><input aria-label="Search sections" placeholder="Search sections..." value={search} onChange={(event) => setSearch(event.target.value)} /></label>
          <select className="input-field mobile-w-full" style={{ width: '180px', maxWidth: '100%', margin: 0 }} aria-label="Filter by grade level" value={selectedGrade} onChange={(event) => setGrade(event.target.value)}>
            <option value="all">All Grade Levels</option>
            {grades.map((label) => <option key={label} value={label}>{label}</option>)}
          </select>
        </div>
        {error ? null : loading ? <div className="teacher-empty-state" role="status">Loading sections and student counts...</div> : <>
          <div className="teacher-assigned-sections-grid">
            {visible.map((section) => <button type="button" className="teacher-assigned-section-card" key={section.key} onClick={() => setSelectedKey(section.key)} aria-label={`View Section ${section.name}, ${section.grade}, ${section.total} students`}>
              <span className="teacher-assigned-section-icon"><Layers size={20} /></span>
              <span className="teacher-assigned-section-copy"><strong>{section.name}</strong><span>{section.grade}</span></span>
              <span className="teacher-assigned-section-count"><strong>{section.total}</strong><span>Students</span></span>
            </button>)}
          </div>
          {visible.length === 0 && <div className="teacher-empty-state"><Users size={34} /><strong>{sections.length ? 'No sections match your filters' : 'No sections assigned'}</strong><span>{sections.length ? 'Try another grade level or search.' : 'Your assigned sections and student counts will appear here.'}</span></div>}
          <p role="status" style={{ marginTop: '16px', color: 'var(--text-secondary)' }}>Showing {visible.length} of {sections.length} assigned sections</p>
          <p style={{ marginTop: '8px', color: 'var(--text-secondary)', fontSize: '.8rem' }}>Student totals include active, pending, and rejected accounts. Select a section to view its students.</p>
        </>}
        </>}
      </section>
    </div>
  );
}
