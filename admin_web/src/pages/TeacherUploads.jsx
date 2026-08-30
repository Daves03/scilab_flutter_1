import { useState, useEffect } from 'react';
import { collection, query, onSnapshot, doc, setDoc, deleteDoc } from 'firebase/firestore';
import { db } from '../firebase';
import { BookOpen, FileText, HelpCircle, Trash2, AlertTriangle } from 'lucide-react';

export default function TeacherUploads() {
  const [courses, setCourses] = useState([]);
  const [activeCourse, setActiveCourse] = useState(null);
  const [deleteConfirm, setDeleteConfirm] = useState(null);

  useEffect(() => {
    const q = query(collection(db, 'courses'));
    
    const unsubscribe = onSnapshot(q, (snapshot) => {
      const data = [];
      snapshot.forEach(doc => {
        data.push({ id: doc.id, ...doc.data() });
      });
      setCourses(data);
      if (data.length > 0 && !activeCourse) {
        setActiveCourse(data[0]);
      } else if (activeCourse) {
        // Update active course if it was modified
        const updatedActive = data.find(c => c.id === activeCourse.id);
        if (updatedActive) setActiveCourse(updatedActive);
      }
    });

    return () => unsubscribe();
  }, []);

  const handleDeleteCourse = (courseId, title, e) => {
    e.stopPropagation();
    setDeleteConfirm({ type: 'course', id: courseId, name: title });
  };

  const handleDeleteModule = (index, title) => {
    setDeleteConfirm({ type: 'module', index, name: title });
  };

  const handleDeleteQuiz = (index, title) => {
    setDeleteConfirm({ type: 'quiz', index, name: title });
  };

  const confirmDelete = async () => {
    if (!deleteConfirm) return;
    const { type, id, index } = deleteConfirm;
    
    try {
      if (type === 'course') {
        await deleteDoc(doc(db, 'courses', id));
        if (activeCourse?.id === id) setActiveCourse(null);
      } else if (type === 'module') {
        const courseRef = doc(db, 'courses', activeCourse.id);
        const updatedModules = [...activeCourse.modules];
        updatedModules.splice(index, 1);
        await setDoc(courseRef, { modules: updatedModules }, { merge: true });
      } else if (type === 'quiz') {
        const courseRef = doc(db, 'courses', activeCourse.id);
        const updatedQuizzes = [...activeCourse.quizzes];
        updatedQuizzes.splice(index, 1);
        await setDoc(courseRef, { quizzes: updatedQuizzes }, { merge: true });
      }
      setDeleteConfirm(null);
    } catch (error) {
      console.error(`Error deleting ${type}:`, error);
      alert(`Failed to delete ${type}: ` + (error.message || error));
    }
  };

  return (
    <div className="animate-fade-in flex-mobile-col" style={{ display: 'flex', gap: '24px', height: 'calc(100vh - 100px)' }}>
      <div className="mobile-w-full" style={{ flex: '0 0 350px', display: 'flex', flexDirection: 'column' }}>
        <div className="page-header" style={{ marginBottom: '24px' }}>
          <div>
            <h1>Teacher Uploads</h1>
            <p>Browse modules and quizzes.</p>
          </div>
        </div>

        <div className="glass-panel" style={{ flex: 1, overflowY: 'auto', padding: '16px' }}>
          {courses.length === 0 ? (
            <div style={{ textAlign: 'center', color: 'var(--text-secondary)', padding: '20px' }}>
              No courses found.
            </div>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
              {courses.map(course => (
                <div 
                  key={course.id}
                  onClick={() => setActiveCourse(course)}
                  style={{
                    padding: '16px',
                    borderRadius: '12px',
                    cursor: 'pointer',
                    background: activeCourse?.id === course.id ? 'rgba(0, 212, 255, 0.1)' : 'rgba(0,0,0,0.2)',
                    border: '1px solid',
                    borderColor: activeCourse?.id === course.id ? 'var(--accent-cyan)' : 'var(--border-light)',
                    transition: 'all 0.2s ease',
                    position: 'relative'
                  }}
                >
                  <button
                    onClick={(e) => handleDeleteCourse(course.id, course.title, e)}
                    className="btn btn-danger"
                    style={{ position: 'absolute', top: '12px', right: '12px', padding: '6px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}
                    title="Delete Course"
                  >
                    <Trash2 size={16} />
                  </button>
                  <h4 style={{ color: 'white', marginBottom: '4px', fontSize: '1rem', paddingRight: '32px' }}>{course.title}</h4>
                  <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.8rem', color: 'var(--text-secondary)' }}>
                    <span>{course.teacherName}</span>
                    <span>{course.grade}</span>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>

      <div style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
        {activeCourse ? (
          <div className="glass-panel animate-fade-in" style={{ flex: 1, padding: '32px', display: 'flex', flexDirection: 'column', overflowY: 'auto' }}>
            <div style={{ marginBottom: '32px' }}>
              <h2 style={{ fontSize: '2rem', marginBottom: '8px' }}>{activeCourse.title}</h2>
              <div style={{ display: 'flex', gap: '16px', color: 'var(--text-secondary)' }}>
                <span className="badge badge-role">{activeCourse.teacherName}</span>
                <span className="badge" style={{ background: 'rgba(255,255,255,0.1)' }}>{activeCourse.subject}</span>
                <span className="badge" style={{ background: 'rgba(255,255,255,0.1)' }}>{activeCourse.sections?.join(', ')}</span>
              </div>
            </div>

            <h3 style={{ marginBottom: '16px', display: 'flex', alignItems: 'center', gap: '8px' }}>
              <FileText size={20} color="var(--accent-cyan)" /> Modules ({activeCourse.modules?.length || 0})
            </h3>
            <div style={{ marginBottom: '32px' }}>
              {(!activeCourse.modules || activeCourse.modules.length === 0) ? (
                <p>No modules uploaded yet.</p>
              ) : (
                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(250px, 1fr))', gap: '16px' }}>
                  {activeCourse.modules.map((mod, index) => (
                    <div key={index} style={{ background: 'rgba(0,0,0,0.2)', padding: '16px', borderRadius: '12px', border: '1px solid var(--border-light)' }}>
                      <h4 style={{ color: 'white', marginBottom: '8px', wordBreak: 'break-all' }}>{mod.title}</h4>
                      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                        <span style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>{mod.fileType?.toUpperCase()}</span>
                        <div style={{ display: 'flex', gap: '8px' }}>
                          <a href={mod.url} target="_blank" rel="noreferrer" className="btn btn-secondary" style={{ padding: '6px 12px', fontSize: '0.8rem' }}>View File</a>
                          <button onClick={() => handleDeleteModule(index, mod.title)} className="btn btn-danger" style={{ padding: '6px', display: 'flex', alignItems: 'center', justifyContent: 'center' }} title="Delete Module">
                            <Trash2 size={16} />
                          </button>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>

            <h3 style={{ marginBottom: '16px', display: 'flex', alignItems: 'center', gap: '8px' }}>
              <HelpCircle size={20} color="var(--accent-purple)" /> Quizzes ({activeCourse.quizzes?.length || 0})
            </h3>
            <div>
              {(!activeCourse.quizzes || activeCourse.quizzes.length === 0) ? (
                <p>No quizzes created yet.</p>
              ) : (
                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(250px, 1fr))', gap: '16px' }}>
                  {activeCourse.quizzes.map((quiz, index) => (
                    <div key={index} style={{ background: 'rgba(0,0,0,0.2)', padding: '16px', borderRadius: '12px', border: '1px solid var(--border-light)' }}>
                      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '8px' }}>
                        <h4 style={{ color: 'white', wordBreak: 'break-all' }}>{quiz.title}</h4>
                        <button onClick={() => handleDeleteQuiz(index, quiz.title)} className="btn btn-danger" style={{ padding: '6px', display: 'flex', alignItems: 'center', justifyContent: 'center', marginLeft: '8px' }} title="Delete Quiz">
                          <Trash2 size={16} />
                        </button>
                      </div>
                      <span style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>
                        {quiz.questions?.length || 0} Questions • {quiz.timeLimitMinutes} mins
                      </span>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        ) : (
          <div className="glass-panel" style={{ flex: 1, display: 'flex', justifyContent: 'center', alignItems: 'center', color: 'var(--text-secondary)' }}>
            <div style={{ textAlign: 'center' }}>
              <BookOpen size={48} color="rgba(255,255,255,0.1)" style={{ marginBottom: '16px' }} />
              <p>Select a course to view uploads</p>
            </div>
          </div>
        )}
      </div>

      {/* Delete Confirmation Modal */}
      {deleteConfirm && (
        <div style={{
          position: 'fixed', top: 0, left: 0, right: 0, bottom: 0,
          background: 'rgba(0,0,0,0.6)',
          backdropFilter: 'blur(4px)',
          display: 'flex', justifyContent: 'center', alignItems: 'center',
          zIndex: 100
        }}>
          <div className="glass-panel animate-fade-in" style={{ width: '100%', maxWidth: '420px', padding: '32px', textAlign: 'center' }}>
            <div style={{ background: 'rgba(255, 71, 87, 0.1)', padding: '16px', borderRadius: '50%', display: 'inline-block', marginBottom: '16px' }}>
              <AlertTriangle size={32} color="var(--accent-red)" />
            </div>
            <h2 style={{ marginBottom: '12px', textTransform: 'capitalize' }}>
              Delete {deleteConfirm.type}?
            </h2>
            <p style={{ color: 'var(--text-secondary)', marginBottom: '24px', lineHeight: 1.5 }}>
              Are you sure you want to delete the {deleteConfirm.type} <strong>"{deleteConfirm.name}"</strong>? 
              {deleteConfirm.type === 'course' && " This will also delete all its modules and quizzes."}
              <br/><br/>This action cannot be undone.
            </p>
            <div style={{ display: 'flex', gap: '12px' }}>
              <button className="btn btn-secondary" style={{ flex: 1 }} onClick={() => setDeleteConfirm(null)}>Cancel</button>
              <button className="btn btn-danger" style={{ flex: 1 }} onClick={confirmDelete}>Yes, Delete</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
