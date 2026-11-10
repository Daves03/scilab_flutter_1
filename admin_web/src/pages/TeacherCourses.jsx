import { useEffect, useMemo, useState } from 'react';
import { createPortal } from 'react-dom';
import { addDoc, collection, deleteDoc, doc, onSnapshot, query, serverTimestamp, updateDoc, where } from 'firebase/firestore';
import { BookOpen, CalendarClock, Edit3, FileText, LayoutGrid, List, Plus, Search, Trash2, X } from 'lucide-react';
import { Link, useNavigate } from 'react-router-dom';
import { db } from '../firebase';
import { formatDateTime, teacherGradeLabels } from '../services/teacherPortalUtils';

const EMPTY_FORM = { title: '', subject: '', grade: '', sections: [] };

export default function TeacherCourses({ user, profile }) {
  const navigate = useNavigate();
  const [courses, setCourses] = useState([]);
  const [sectionCatalog, setSectionCatalog] = useState([]);
  const [search, setSearch] = useState('');
  const [view, setView] = useState('cards');
  const [form, setForm] = useState(EMPTY_FORM);
  const [editing, setEditing] = useState(null);
  const [showForm, setShowForm] = useState(false);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');
  const teacherSections = useMemo(() => profile?.sections || [], [profile?.sections]);

  useEffect(() => {
    try {
      setView(localStorage.getItem(`teacher-course-view:${user?.uid}`) === 'list' ? 'list' : 'cards');
    } catch {
      setView('cards');
    }
  }, [user?.uid]);

  const changeView = (nextView) => {
    setView(nextView);
    try {
      localStorage.setItem(`teacher-course-view:${user?.uid}`, nextView);
    } catch { /* The view still works when browser storage is unavailable. */ }
  };

  useEffect(() => {
    if (!user?.uid) return undefined;
    const unsubscribeCourses = onSnapshot(query(collection(db, 'courses'), where('teacherUid', '==', user.uid)), (snapshot) => {
      const data = snapshot.docs.map((item) => ({ id: item.id, ...item.data() }));
      data.sort((a, b) => (b.createdAt?.seconds || 0) - (a.createdAt?.seconds || 0));
      setCourses(data);
    });
    const unsubscribeSections = onSnapshot(collection(db, 'sections'), (snapshot) => {
      setSectionCatalog(snapshot.docs.map((item) => ({ id: item.id, ...item.data() })).filter((section) => !section.isTrashed));
    });
    return () => { unsubscribeCourses(); unsubscribeSections(); };
  }, [user?.uid]);

  const grades = useMemo(() => teacherGradeLabels(teacherSections, sectionCatalog), [sectionCatalog, teacherSections]);
  const sectionsForGrade = useMemo(() => {
    const matchingCatalog = sectionCatalog.filter((section) => section.grade === form.grade && teacherSections.includes(section.name));
    return matchingCatalog.length ? matchingCatalog.map((section) => section.name) : teacherSections;
  }, [form.grade, sectionCatalog, teacherSections]);
  const visibleCourses = courses.filter((course) => `${course.title} ${course.subject} ${course.grade}`.toLowerCase().includes(search.toLowerCase()));

  const openCreate = () => {
    const initialGrade = grades[0] || '';
    setEditing(null);
    setForm({ ...EMPTY_FORM, grade: initialGrade });
    setError('');
    setShowForm(true);
  };

  const openEdit = (course) => {
    setEditing(course);
    setForm({
      title: course.title || '',
      subject: course.subject || '',
      grade: course.grade || grades[0] || '',
      sections: [...(course.sections || course.assignedSections || [])],
    });
    setError('');
    setShowForm(true);
  };

  const toggleSection = (section) => setForm((current) => ({
    ...current,
    sections: current.sections.includes(section)
      ? current.sections.filter((item) => item !== section)
      : [...current.sections, section],
  }));

  const saveCourse = async (event) => {
    event.preventDefault();
    setError('');
    if (!form.title.trim() || !form.subject.trim() || !form.grade || form.sections.length === 0) {
      setError('Complete the course/topic, subject, grade, and at least one handled section.');
      return;
    }
    setSaving(true);
    const payload = {
      title: form.title.trim(),
      subject: form.subject.trim(),
      grade: form.grade,
      sections: form.sections,
      teacherUid: user.uid,
      teacherName: profile?.name || user.displayName || 'Teacher',
    };
    try {
      if (editing) {
        await updateDoc(doc(db, 'courses', editing.id), payload);
      } else {
        await addDoc(collection(db, 'courses'), {
          ...payload,
          modules: [],
          quizzes: [],
          iconName: 'science',
          accentColorValue: 0xff00d4ff,
          createdAt: serverTimestamp(),
        });
      }
      setShowForm(false);
    } catch (saveError) {
      console.error('Could not save course:', saveError);
      setError(`Could not save the course: ${saveError.message}`);
    } finally {
      setSaving(false);
    }
  };

  const removeCourse = async (course) => {
    if (!window.confirm(`Delete “${course.title}” and its modules and quizzes? This cannot be undone.`)) return;
    try {
      await deleteDoc(doc(db, 'courses', course.id));
    } catch (deleteError) {
      window.alert(`Could not delete the course: ${deleteError.message}`);
    }
  };

  return (
    <div className="teacher-page animate-fade-in">
      <div className="page-header teacher-page-header">
        <div>
          <span className="teacher-eyebrow"><BookOpen size={16} /> Teacher-owned content</span>
          <h1>Manage Courses</h1>
          <p>Create and edit only your courses for your assigned grade levels and sections.</p>
        </div>
        <button className="btn btn-primary" onClick={openCreate}><Plus size={18} /> New Course</button>
      </div>

      <div className="teacher-course-browser-toolbar">
        <label className="teacher-search"><Search size={18} /><input aria-label="Search your courses" value={search} onChange={(event) => setSearch(event.target.value)} placeholder="Search your courses..." /></label>
        <div className="teacher-course-view-switch" role="group" aria-label="Course view">
          <button type="button" aria-pressed={view === 'cards'} className={view === 'cards' ? 'active' : ''} onClick={() => changeView('cards')}><LayoutGrid size={18} /> Cards</button>
          <button type="button" aria-pressed={view === 'list'} className={view === 'list' ? 'active' : ''} onClick={() => changeView('list')}><List size={18} /> List</button>
        </div>
      </div>

      {view === 'cards' ? (
      <div className="teacher-course-grid">
        {visibleCourses.map((course) => (
          <article
            className="glass-panel teacher-course-card teacher-course-link"
            key={course.id}
            role="link"
            tabIndex={0}
            onClick={() => navigate(`/my-courses/${course.id}`)}
            onKeyDown={(event) => {
              if (event.key === 'Enter' || event.key === ' ') navigate(`/my-courses/${course.id}`);
            }}
          >
            <div className="teacher-course-card-top">
              <div className="teacher-content-icon course"><BookOpen size={21} /></div>
              <div className="teacher-action-row">
                <button className="teacher-icon-btn edit" onClick={(event) => { event.stopPropagation(); openEdit(course); }} title="Edit course"><Edit3 size={17} /></button>
                <button className="teacher-icon-btn danger" onClick={(event) => { event.stopPropagation(); removeCourse(course); }} title="Delete course"><Trash2 size={17} /></button>
              </div>
            </div>
            <h2>{course.title || 'Untitled Course'}</h2>
            <p>{course.subject || 'No subject'}</p>
            <div className="teacher-course-meta"><span>{course.grade || 'Grade not set'}</span><span>Sections {(course.sections || []).join(', ') || 'not set'}</span></div>
            <div className="teacher-course-counts">
              <span><FileText size={15} /> {(course.modules || []).length} Modules</span>
              <span><BookOpen size={15} /> {(course.quizzes || []).length} Quizzes</span>
            </div>
            <div className="teacher-course-created"><CalendarClock size={15} /> Created {formatDateTime(course.createdAt)}</div>
            <span className="teacher-open-course">Open course →</span>
          </article>
        ))}
        {visibleCourses.length === 0 && <div className="glass-panel teacher-empty-state teacher-grid-empty"><BookOpen size={40} /><strong>No courses found</strong><span>Create a course to make it available in the mobile app for your assigned students.</span></div>}
      </div>
      ) : (
        <section className="glass-panel teacher-course-list-panel" aria-label="Courses in list view">
          <div className="teacher-responsive-table">
            <table className="data-table teacher-course-list-table responsive-records-table">
              <thead><tr><th>Course / Topic</th><th>Subject</th><th>Grade & Sections</th><th>Created</th><th>Modules</th><th>Quizzes</th><th>Actions</th></tr></thead>
              <tbody>{visibleCourses.map((course) => <tr key={course.id}>
                <td data-label="Course / Topic"><Link className="teacher-course-list-name" to={`/my-courses/${course.id}`}><span className="teacher-content-icon course"><BookOpen size={19} /></span><strong>{course.title || 'Untitled Course'}</strong></Link></td>
                <td data-label="Subject">{course.subject || 'No subject'}</td>
                <td data-label="Grade & Sections"><div className="teacher-course-list-assignment"><strong>{course.grade || 'Grade not set'}</strong><span>Sections {(course.sections || course.assignedSections || []).join(', ') || 'not set'}</span></div></td>
                <td data-label="Created">{formatDateTime(course.createdAt)}</td>
                <td data-label="Modules">{(course.modules || []).length}</td>
                <td data-label="Quizzes">{(course.quizzes || []).length}</td>
                <td data-label="Actions"><div className="teacher-action-row">
                  <button type="button" className="teacher-icon-btn edit" onClick={() => openEdit(course)} aria-label={`Edit ${course.title || 'course'}`} title="Edit course"><Edit3 size={17} /></button>
                  <button type="button" className="teacher-icon-btn danger" onClick={() => removeCourse(course)} aria-label={`Delete ${course.title || 'course'}`} title="Delete course"><Trash2 size={17} /></button>
                </div></td>
              </tr>)}</tbody>
            </table>
          </div>
          {visibleCourses.length === 0 && <div className="teacher-empty-state"><BookOpen size={40} /><strong>No courses found</strong><span>{search.trim() ? 'Try another search.' : 'Create a course to make it available to your assigned students.'}</span></div>}
        </section>
      )}

      {showForm && createPortal(
        <div className="teacher-modal-backdrop teacher-status-backdrop" onMouseDown={(event) => event.target === event.currentTarget && setShowForm(false)}>
          <form className="glass-panel teacher-modal teacher-course-modal" onSubmit={saveCourse}>
            <div className="teacher-modal-header"><div><h2>{editing ? 'Edit Course' : 'Create Course'}</h2><p>Changes sync immediately with the mobile app.</p></div><button type="button" className="teacher-icon-btn" onClick={() => setShowForm(false)}><X size={20} /></button></div>
            {error && <div className="teacher-form-error">{error}</div>}
            <label className="input-group"><span className="input-label">Subject</span><input className="input-field" value={form.subject} onChange={(event) => setForm({ ...form, subject: event.target.value })} placeholder="e.g. Chemistry" /></label>
            <label className="input-group"><span className="input-label">Topic</span><input className="input-field" value={form.title} onChange={(event) => setForm({ ...form, title: event.target.value })} placeholder="e.g. Acid Base" /></label>
            <label className="input-group"><span className="input-label">Grade Level</span><select className="input-field" value={form.grade} onChange={(event) => setForm({ ...form, grade: event.target.value, sections: [] })}>{grades.length === 0 && <option value="">No assigned grade found</option>}{grades.map((grade) => <option key={grade}>{grade}</option>)}</select></label>
            <label className="input-group teacher-section-select">
              <span className="input-label">Sections</span>
              <select
                className="input-field"
                value=""
                disabled={sectionsForGrade.length === 0 || form.sections.length >= sectionsForGrade.length}
                onChange={(event) => event.target.value && toggleSection(event.target.value)}
              >
                <option value="">{sectionsForGrade.length === 0 ? 'No handled sections available' : form.sections.length >= sectionsForGrade.length ? 'All assigned sections added' : 'Select a handled section'}</option>
                {sectionsForGrade.filter((section) => !form.sections.includes(section)).map((section) => <option key={section} value={section}>Section {section}</option>)}
              </select>
            </label>
            <div className="teacher-assigned-sections">
              <span>Assigned sections</span>
              <div>
                {form.sections.map((section) => (
                  <button type="button" key={section} onClick={() => toggleSection(section)} aria-label={`Remove Section ${section}`}>
                    <b>{section}</b><X size={14} />
                  </button>
                ))}
                {form.sections.length === 0 && <small>No sections assigned yet.</small>}
              </div>
            </div>
            <div className="teacher-modal-actions"><button type="button" className="btn btn-secondary" onClick={() => setShowForm(false)}>Cancel</button><button className="btn btn-primary teacher-course-save" disabled={saving}>{saving ? 'Saving...' : editing ? 'Save' : 'Create Course'}</button></div>
          </form>
        </div>,
        document.body,
      )}
    </div>
  );
}
