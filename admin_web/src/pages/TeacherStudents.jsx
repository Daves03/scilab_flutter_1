import { useEffect, useMemo, useState } from 'react';
import { createPortal } from 'react-dom';
import { collection, doc, onSnapshot, updateDoc } from 'firebase/firestore';
import { AlertTriangle, CheckCircle2, RefreshCcw, Search, UserCheck, UserX, Users, X } from 'lucide-react';
import { useSearchParams } from 'react-router-dom';
import { db } from '../firebase';
import { gradeLabelForRole, teacherHandlesStudent } from '../services/teacherPortalUtils';

const TABS = [
  { id: 'pending', label: 'Pending Approvals', icon: UserCheck },
  { id: 'approved', label: 'Active Students', icon: CheckCircle2 },
  { id: 'rejected', label: 'Rejected Students', icon: UserX },
];

export default function TeacherStudents({ profile }) {
  const [searchParams, setSearchParams] = useSearchParams();
  const [students, setStudents] = useState([]);
  const [sections, setSections] = useState([]);
  const requestedStatus = searchParams.get('status');
  const [activeTab, setActiveTab] = useState(TABS.some((tab) => tab.id === requestedStatus) ? requestedStatus : 'pending');
  const [search, setSearch] = useState('');
  const [busyId, setBusyId] = useState('');
  const [message, setMessage] = useState('');
  const [confirmation, setConfirmation] = useState(null);
  const teacherSections = useMemo(() => profile?.sections || [], [profile?.sections]);

  useEffect(() => {
    if (TABS.some((tab) => tab.id === requestedStatus)) setActiveTab(requestedStatus);
  }, [requestedStatus]);

  const selectTab = (status) => {
    setActiveTab(status);
    setSearchParams({ status });
  };

  useEffect(() => {
    const unsubscribeUsers = onSnapshot(collection(db, 'users'), (snapshot) => {
      setStudents(snapshot.docs.map((item) => ({ id: item.id, ...item.data() })));
    });
    const unsubscribeSections = onSnapshot(collection(db, 'sections'), (snapshot) => {
      setSections(snapshot.docs.map((item) => ({ id: item.id, ...item.data() })));
    });
    return () => {
      unsubscribeUsers();
      unsubscribeSections();
    };
  }, []);

  const handled = useMemo(() => students.filter((student) =>
    teacherHandlesStudent(teacherSections, student, sections)), [sections, students, teacherSections]);
  const counts = useMemo(() => Object.fromEntries(TABS.map((tab) => [
    tab.id,
    handled.filter((student) => student.status === tab.id).length,
  ])), [handled]);
  const visible = useMemo(() => handled.filter((student) => {
    const queryText = search.trim().toLowerCase();
    return student.status === activeTab && (!queryText || [student.name, student.email, student.studentNumber]
      .some((value) => String(value || '').toLowerCase().includes(queryText)));
  }), [activeTab, handled, search]);

  const changeStatus = async (student, status) => {
    setBusyId(student.id);
    setMessage('');
    try {
      await updateDoc(doc(db, 'users', student.id), { status });
      setMessage(`${student.name || 'Student'} was ${status}.`);
      setConfirmation(null);
    } catch (error) {
      console.error('Could not update student status:', error);
      setMessage(`Could not update this student: ${error.message}`);
    } finally {
      setBusyId('');
    }
  };

  return (
    <div className="teacher-page animate-fade-in">
      <div className="page-header teacher-page-header">
        <div>
          <span className="teacher-eyebrow"><Users size={16} /> Your Students</span>
          <h1>Manage Students</h1>
          <p>Approve and manage only students from your handled grade levels and sections.</p>
        </div>
      </div>

      {message && <div className="teacher-inline-message">{message}</div>}
      <section className="glass-panel teacher-table-panel">
        <div className="teacher-toolbar">
          <div className="teacher-tabs">
            {TABS.map(({ id, label, icon: Icon }) => (
              <button key={id} className={activeTab === id ? 'active' : ''} onClick={() => selectTab(id)}>
                <Icon size={17} /> {label} <span>{counts[id] || 0}</span>
              </button>
            ))}
          </div>
          <label className="teacher-search"><Search size={18} /><input value={search} onChange={(event) => setSearch(event.target.value)} placeholder="Search students..." /></label>
        </div>

        <div className="teacher-responsive-table teacher-students-table-wrap">
          <table className="data-table teacher-students-table">
            <thead><tr><th>Student</th><th>Student Number</th><th>Grade & Section</th><th>Email</th><th>Actions</th></tr></thead>
            <tbody>
              {visible.map((student) => (
                <tr key={student.id}>
                  <td data-label="Student"><div className="teacher-student-cell"><div className="teacher-avatar">{(student.name || 'S')[0]}</div><strong>{student.name || 'Unnamed Student'}</strong></div></td>
                  <td data-label="Student Number">{student.studentNumber ? `#${student.studentNumber}` : 'Not set'}</td>
                  <td data-label="Grade & Section">{gradeLabelForRole(student.role)} · Section {(student.sections || []).join(', ') || 'Not set'}</td>
                  <td data-label="Email">{student.email || 'Not set'}</td>
                  <td data-label="Actions" className="teacher-student-actions-cell">
                    <div className="teacher-action-row">
                      {activeTab !== 'approved' && <button className="btn btn-success" disabled={busyId === student.id} onClick={() => setConfirmation({ student, status: 'approved' })}><CheckCircle2 size={16} /> Approve</button>}
                      {activeTab !== 'rejected' && <button className="btn btn-danger" disabled={busyId === student.id} onClick={() => setConfirmation({ student, status: 'rejected', revoke: activeTab === 'approved' })}><UserX size={16} /> {activeTab === 'approved' ? 'Revoke' : 'Reject'}</button>}
                      {activeTab === 'rejected' && <button className="btn btn-secondary" disabled={busyId === student.id} onClick={() => setConfirmation({ student, status: 'pending' })}><RefreshCcw size={16} /> Return to pending</button>}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          {visible.length === 0 && <div className="teacher-empty-state"><Users size={34} /><strong>No {activeTab} students</strong><span>Students assigned to your handled sections will appear here.</span></div>}
        </div>
      </section>

      {confirmation && (
        <StudentStatusModal
          student={confirmation.student}
          status={confirmation.status}
          revoke={confirmation.revoke}
          busy={busyId === confirmation.student.id}
          onCancel={() => !busyId && setConfirmation(null)}
          onConfirm={() => changeStatus(confirmation.student, confirmation.status)}
        />
      )}
    </div>
  );
}

function StudentStatusModal({ student, status, revoke, busy, onCancel, onConfirm }) {
  const approving = status === 'approved';
  const returning = status === 'pending';
  const title = approving ? 'Approve Student?' : returning ? 'Return to Pending?' : revoke ? 'Revoke Student?' : 'Reject Student?';
  const action = approving ? 'Approve Student' : returning ? 'Return to Pending' : revoke ? 'Revoke Student' : 'Reject Student';
  const description = approving
    ? 'This student will receive access to the courses assigned to their grade level and section.'
    : returning
      ? 'This student will be moved back to the pending list for another review.'
      : revoke
        ? 'This student’s access will be revoked until they are approved again.'
        : 'This student will not be able to access the app until they are approved later.';

  return createPortal(
    <div className="teacher-modal-backdrop teacher-status-backdrop" role="presentation" onMouseDown={(event) => event.target === event.currentTarget && onCancel()}>
      <div className={`glass-panel teacher-status-modal ${approving ? 'approve' : returning ? 'pending' : 'reject'}`} role="dialog" aria-modal="true" aria-labelledby="student-status-title">
        <button type="button" className="teacher-icon-btn teacher-status-close" onClick={onCancel} disabled={busy} aria-label="Close confirmation"><X size={19} /></button>
        <div className="teacher-status-icon">{approving ? <CheckCircle2 size={32} /> : returning ? <RefreshCcw size={30} /> : <AlertTriangle size={32} />}</div>
        <h2 id="student-status-title">{title}</h2>
        <p>{description}</p>

        <div className="teacher-status-student">
          <div className="teacher-avatar large">{(student.name || 'S')[0]}</div>
          <div>
            <strong>{student.name || 'Unnamed Student'}</strong>
            <span>{gradeLabelForRole(student.role)} · Section {(student.sections || []).join(', ') || 'Not set'}</span>
            <small>{student.studentNumber ? `#${student.studentNumber}` : student.email || 'No student number'}</small>
          </div>
        </div>

        <div className="teacher-status-actions">
          <button type="button" className="btn btn-secondary" onClick={onCancel} disabled={busy}>Cancel</button>
          <button type="button" className={`btn ${approving ? 'btn-success' : returning ? 'btn-secondary' : 'btn-danger'}`} onClick={onConfirm} disabled={busy}>
            {busy ? 'Updating...' : action}
          </button>
        </div>
      </div>
    </div>,
    document.body,
  );
}
