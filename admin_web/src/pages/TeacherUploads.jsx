import { useState, useEffect } from 'react';
import { collection, query, onSnapshot } from 'firebase/firestore';
import { db } from '../firebase';
import { BookOpen, FileText, HelpCircle } from 'lucide-react';

export default function TeacherUploads() {
  const [courses, setCourses] = useState([]);
  const [activeCourse, setActiveCourse] = useState(null);

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
                    transition: 'all 0.2s ease'
                  }}
                >
                  <h4 style={{ color: 'white', marginBottom: '4px', fontSize: '1rem' }}>{course.title}</h4>
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
                  {activeCourse.modules.map(mod => (
                    <div key={mod.id} style={{ background: 'rgba(0,0,0,0.2)', padding: '16px', borderRadius: '12px', border: '1px solid var(--border-light)' }}>
                      <h4 style={{ color: 'white', marginBottom: '8px', wordBreak: 'break-all' }}>{mod.title}</h4>
                      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                        <span style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>{mod.fileType?.toUpperCase()}</span>
                        <a href={mod.url} target="_blank" rel="noreferrer" className="btn btn-secondary" style={{ padding: '6px 12px', fontSize: '0.8rem' }}>View File</a>
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
                  {activeCourse.quizzes.map(quiz => (
                    <div key={quiz.id} style={{ background: 'rgba(0,0,0,0.2)', padding: '16px', borderRadius: '12px', border: '1px solid var(--border-light)' }}>
                      <h4 style={{ color: 'white', marginBottom: '8px' }}>{quiz.title}</h4>
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
    </div>
  );
}
