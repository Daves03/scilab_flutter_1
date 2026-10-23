import { useState, useEffect } from 'react';
import { collection, query, where, onSnapshot, doc, deleteDoc, getDoc, writeBatch, serverTimestamp } from 'firebase/firestore';
import { db } from '../firebase';
import { logAdminActivity } from '../services/adminActivityService';
import { BookOpen, FileText, HelpCircle, Trash2, AlertTriangle, Search, Clock, Archive, RotateCcw, ArrowLeft } from 'lucide-react';

export default function TeacherUploads() {
  const [courses, setCourses] = useState([]);
  const [activeTeacherId, setActiveTeacherId] = useState(null);
  const [deleteConfirm, setDeleteConfirm] = useState(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [teacherProfiles, setTeacherProfiles] = useState({});
  const [archivedUploads, setArchivedUploads] = useState([]);
  const [showArchive, setShowArchive] = useState(false);
  const [permanentDeleteConfirm, setPermanentDeleteConfirm] = useState(null);

  const formatDateTime = (ts) => {
    if (!ts) return null;
    let date = null;
    try {
      if (ts.toDate && typeof ts.toDate === 'function') {
        date = ts.toDate();
      } else if (ts.toMillis && typeof ts.toMillis === 'function') {
        date = new Date(ts.toMillis());
      } else if (ts instanceof Date) {
        date = ts;
      } else {
        date = new Date(ts);
      }
    } catch {
      return null;
    }
    if (!date || isNaN(date.getTime())) return null;
    return date.toLocaleString();
  };

  const getCourseDate = (course) => {
    if (course.createdAt) return formatDateTime(course.createdAt);
    if (course.modules?.length && course.modules[0]?.uploadedAt) return formatDateTime(course.modules[0].uploadedAt);
    if (course.quizzes?.length && course.quizzes[0]?.createdAt) return formatDateTime(course.quizzes[0].createdAt);
    return null;
  };

  const getModuleDate = (module) =>
    formatDateTime(module.uploadedAt || module.createdAt);

  const getQuizDate = (quiz) =>
    formatDateTime(quiz.createdAt || quiz.uploadedAt);

  useEffect(() => {
    const q = query(collection(db, 'users'), where('role', '==', 'teacher'));
    const unsubscribe = onSnapshot(q, (snapshot) => {
      const profiles = {};
      snapshot.forEach(doc => {
        const data = doc.data();
        profiles[doc.id] = {
          name: data.name || data.displayName || '',
          email: data.email || '',
        };
      });
      setTeacherProfiles(profiles);
    });
    return () => unsubscribe();
  }, []);

  useEffect(() => {
    const q = query(collection(db, 'courses'));
    
    const unsubscribe = onSnapshot(q, (snapshot) => {
      const data = [];
      snapshot.forEach(doc => {
        data.push({ id: doc.id, ...doc.data() });
      });
      setCourses(data);
      if (data.length > 0) {
        const uniqueIds = Array.from(new Set(data.map(c => c.teacherUid || c.teacherName)));
        setActiveTeacherId(prev => {
           if (!prev || !uniqueIds.includes(prev)) {
               return uniqueIds[0];
           }
           return prev;
        });
      } else {
        setActiveTeacherId(null);
      }
    });

    return () => unsubscribe();
  }, []);

  useEffect(() => {
    const archiveQuery = query(collection(db, 'teacher_upload_archives'));
    const unsubscribe = onSnapshot(archiveQuery, (snapshot) => {
      const data = snapshot.docs.map(archiveDoc => ({
        id: archiveDoc.id,
        ...archiveDoc.data(),
      }));
      data.sort((first, second) => {
        const firstTime = first.archivedAt?.toMillis?.() || 0;
        const secondTime = second.archivedAt?.toMillis?.() || 0;
        return secondTime - firstTime;
      });
      setArchivedUploads(data);
    }, (error) => {
      console.error('Error loading teacher upload archive:', error);
    });

    return () => unsubscribe();
  }, []);

  // Derived state
  const uniqueTeacherIds = Array.from(new Set(courses.map(c => c.teacherUid || c.teacherName)));
  const teachers = uniqueTeacherIds.map(uid => {
    const teacherCourses = courses.filter(c => (c.teacherUid || c.teacherName) === uid);
    // Find the latest name by sorting by createdAt if possible, or just use the last one in the list
    const sorted = [...teacherCourses].sort((a, b) => {
       const timeA = a.createdAt?.toMillis ? a.createdAt.toMillis() : 0;
       const timeB = b.createdAt?.toMillis ? b.createdAt.toMillis() : 0;
       return timeA - timeB;
    });
    const latestName = teacherProfiles[uid]?.name || sorted[sorted.length - 1]?.teacherName || uid;
    
    return {
      id: uid,
      name: latestName,
      email: teacherProfiles[uid]?.email || '',
      courses: teacherCourses
    };
  }).filter(t => (t.name || '').toLowerCase().includes(searchQuery.toLowerCase()));
  
  const activeTeacherCourses = courses.filter(c => (c.teacherUid || c.teacherName) === activeTeacherId);
  const activeTeacherInfo = teachers.find(t => t.id === activeTeacherId) || {};
  const displayActiveTeacherName = activeTeacherInfo.name || 'Teacher';

  const handleDeleteCourse = (courseId, title) => {
    setDeleteConfirm({ type: 'course', id: courseId, name: title });
  };

  const handleDeleteModule = (courseId, index, title) => {
    setDeleteConfirm({ type: 'module', courseId, index, name: title });
  };

  const handleDeleteQuiz = (courseId, index, title) => {
    setDeleteConfirm({ type: 'quiz', courseId, index, name: title });
  };

  const confirmArchive = async () => {
    if (!deleteConfirm) return;
    const { type, id, courseId, index } = deleteConfirm;
    
    try {
      const archiveRef = doc(collection(db, 'teacher_upload_archives'));
      const batch = writeBatch(db);
      let auditTitle = deleteConfirm.name || `Untitled ${type}`;
      let auditDetails = { uploadType: type };

      if (type === 'course') {
        const course = courses.find(item => item.id === id);
        if (!course) throw new Error('Course no longer exists.');
        auditTitle = course.topic || course.title || auditTitle;
        auditDetails = {
          uploadType: type,
          courseId: course.id,
          teacherName: teacherProfiles[course.teacherUid]?.name || course.teacherName || 'Teacher',
          grade: course.grade || '',
          sections: course.sections || [],
        };
        batch.set(archiveRef, {
          type: 'course',
          teacherUid: course.teacherUid || '',
          teacherName: teacherProfiles[course.teacherUid]?.name || course.teacherName || 'Teacher',
          courseId: course.id,
          courseTitle: course.topic || course.title || 'Untitled course',
          subject: course.subject || '',
          grade: course.grade || '',
          sections: course.sections || [],
          payload: course,
          archivedAt: serverTimestamp(),
        });
        batch.delete(doc(db, 'courses', id));
      } else if (type === 'module') {
        const courseRef = doc(db, 'courses', courseId);
        const course = courses.find(c => c.id === courseId);
        if (!course?.modules?.[index]) throw new Error('Module no longer exists.');
        const updatedModules = [...course.modules];
        const [module] = updatedModules.splice(index, 1);
        auditTitle = module.title || auditTitle;
        auditDetails = {
          uploadType: type,
          courseId: course.id,
          courseTitle: course.topic || course.title || 'Untitled course',
          teacherName: teacherProfiles[course.teacherUid]?.name || course.teacherName || 'Teacher',
        };
        batch.set(archiveRef, {
          type: 'module',
          teacherUid: course.teacherUid || '',
          teacherName: teacherProfiles[course.teacherUid]?.name || course.teacherName || 'Teacher',
          courseId: course.id,
          courseTitle: course.topic || course.title || 'Untitled course',
          subject: course.subject || '',
          grade: course.grade || '',
          sections: course.sections || [],
          originalIndex: index,
          payload: module,
          archivedAt: serverTimestamp(),
        });
        batch.update(courseRef, { modules: updatedModules });
      } else if (type === 'quiz') {
        const courseRef = doc(db, 'courses', courseId);
        const course = courses.find(c => c.id === courseId);
        if (!course?.quizzes?.[index]) throw new Error('Quiz no longer exists.');
        const updatedQuizzes = [...course.quizzes];
        const [quiz] = updatedQuizzes.splice(index, 1);
        auditTitle = quiz.title || auditTitle;
        auditDetails = {
          uploadType: type,
          courseId: course.id,
          courseTitle: course.topic || course.title || 'Untitled course',
          teacherName: teacherProfiles[course.teacherUid]?.name || course.teacherName || 'Teacher',
        };
        batch.set(archiveRef, {
          type: 'quiz',
          teacherUid: course.teacherUid || '',
          teacherName: teacherProfiles[course.teacherUid]?.name || course.teacherName || 'Teacher',
          courseId: course.id,
          courseTitle: course.topic || course.title || 'Untitled course',
          subject: course.subject || '',
          grade: course.grade || '',
          sections: course.sections || [],
          originalIndex: index,
          payload: quiz,
          archivedAt: serverTimestamp(),
        });
        batch.update(courseRef, { quizzes: updatedQuizzes });
      }

      await batch.commit();
      await logAdminActivity({
        type: 'teacher_upload_archived',
        title: `${type[0].toUpperCase()}${type.slice(1)}: ${auditTitle}`,
        details: auditDetails,
      });
      setDeleteConfirm(null);
    } catch (error) {
      console.error(`Error archiving ${type}:`, error);
      alert(`Failed to archive ${type}: ` + (error.message || error));
    }
  };

  const restoreArchivedUpload = async (archive) => {
    try {
      const archiveRef = doc(db, 'teacher_upload_archives', archive.id);
      const courseRef = doc(db, 'courses', archive.courseId);
      const batch = writeBatch(db);

      if (archive.type === 'course') {
        const existingCourse = await getDoc(courseRef);
        if (existingCourse.exists()) {
          alert('A course with this ID already exists. Remove it before restoring this archived course.');
          return;
        }
        const restoredCourse = { ...archive.payload };
        delete restoredCourse.id;
        batch.set(courseRef, restoredCourse);
      } else {
        const courseSnapshot = await getDoc(courseRef);
        if (!courseSnapshot.exists()) {
          alert('Restore the parent course before restoring this item.');
          return;
        }

        const field = archive.type === 'module' ? 'modules' : 'quizzes';
        const items = [...(courseSnapshot.data()[field] || [])];
        const archivedItemId = archive.payload?.id;
        if (archivedItemId && items.some(item => item.id === archivedItemId)) {
          alert(`This ${archive.type} is already present in the course.`);
          return;
        }
        const requestedIndex = Number.isInteger(archive.originalIndex)
          ? archive.originalIndex
          : items.length;
        const restoreIndex = Math.max(0, Math.min(requestedIndex, items.length));
        items.splice(restoreIndex, 0, archive.payload);
        batch.update(courseRef, { [field]: items });
      }

      batch.delete(archiveRef);
      await batch.commit();
      await logAdminActivity({
        type: 'teacher_upload_restored',
        title: `${archive.type[0].toUpperCase()}${archive.type.slice(1)}: ${archive.payload?.title || archive.courseTitle || 'Untitled upload'}`,
        details: {
          uploadType: archive.type,
          courseId: archive.courseId || '',
          courseTitle: archive.courseTitle || '',
          teacherName: archive.teacherName || 'Teacher',
        },
      });
    } catch (error) {
      console.error('Error restoring archived upload:', error);
      alert('Failed to restore the archived upload: ' + (error.message || error));
    }
  };

  const permanentlyDeleteArchivedUpload = async () => {
    if (!permanentDeleteConfirm) return;
    try {
      await deleteDoc(doc(db, 'teacher_upload_archives', permanentDeleteConfirm.id));
      await logAdminActivity({
        type: 'teacher_upload_permanently_deleted',
        title: `${permanentDeleteConfirm.type[0].toUpperCase()}${permanentDeleteConfirm.type.slice(1)}: ${permanentDeleteConfirm.payload?.title || permanentDeleteConfirm.courseTitle || 'Untitled upload'}`,
        details: {
          uploadType: permanentDeleteConfirm.type,
          courseId: permanentDeleteConfirm.courseId || '',
          courseTitle: permanentDeleteConfirm.courseTitle || '',
          teacherName: permanentDeleteConfirm.teacherName || 'Teacher',
        },
      });
      setPermanentDeleteConfirm(null);
    } catch (error) {
      console.error('Error permanently deleting archived upload:', error);
      alert('Failed to permanently delete the archived upload: ' + (error.message || error));
    }
  };

  return (
    <>
      <div className="animate-fade-in flex-mobile-col" style={{ display: 'flex', gap: '24px', height: 'calc(100vh - 100px)' }}>
      <div className="mobile-w-full" style={{ flex: '0 0 350px', display: 'flex', flexDirection: 'column' }}>
        <div className="page-header" style={{ marginBottom: '24px' }}>
          <div>
            <h1>Teacher Uploads</h1>
            <p>Browse modules and quizzes.</p>
          </div>
        </div>

        <div className="glass-panel" style={{ flex: 1, overflowY: 'auto', padding: '16px' }}>
          <h3 style={{ marginBottom: '16px', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <BookOpen size={20} color="var(--accent-orange)" /> Teachers ({teachers.length})
          </h3>
          <div style={{ position: 'relative', marginBottom: '16px' }}>
            <Search size={18} color="var(--text-secondary)" style={{ position: 'absolute', left: '12px', top: '50%', transform: 'translateY(-50%)' }} />
            <input 
              type="text" 
              placeholder="Search teachers..." 
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="input-field"
              style={{ paddingLeft: '38px' }}
            />
          </div>
          {teachers.length === 0 ? (
            <div style={{ textAlign: 'center', color: 'var(--text-secondary)', padding: '20px' }}>
              No teachers found.
            </div>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
              {teachers.map(teacher => (
                <div 
                  key={teacher.id}
                  onClick={() => {
                    setActiveTeacherId(teacher.id);
                    setShowArchive(false);
                  }}
                  style={{
                    padding: '16px',
                    borderRadius: '12px',
                    cursor: 'pointer',
                    background: activeTeacherId === teacher.id ? 'rgba(0, 212, 255, 0.1)' : 'rgba(0,0,0,0.2)',
                    border: '1px solid',
                    borderColor: activeTeacherId === teacher.id ? 'var(--accent-cyan)' : 'var(--border-light)',
                    transition: 'all 0.2s ease'
                  }}
                >
                  <h4 style={{ color: 'var(--text-primary)', marginBottom: '4px', fontSize: '1rem' }}>{teacher.name}</h4>
                  {teacher.email && (
                    <div style={{ fontSize: '0.8rem', color: 'var(--text-secondary)', marginBottom: '4px' }}>
                      {teacher.email}
                    </div>
                  )}
                  <div style={{ fontSize: '0.8rem', color: 'var(--text-secondary)' }}>
                    <span>{teacher.courses.length} {teacher.courses.length === 1 ? 'Topic' : 'Topics'}</span>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>

      <div style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
        <div style={{ display: 'flex', justifyContent: 'flex-end', marginBottom: '12px' }}>
          <button
            className={`btn ${showArchive ? 'btn-secondary' : 'btn-archive'}`}
            onClick={() => setShowArchive(previous => !previous)}
            style={{ display: 'inline-flex', alignItems: 'center', gap: '8px' }}
          >
            {showArchive ? <ArrowLeft size={17} /> : <Archive size={17} />}
            {showArchive ? 'Back to Uploads' : `Archive (${archivedUploads.length})`}
          </button>
        </div>

        {showArchive ? (
          <div className="glass-panel animate-fade-in" style={{ flex: 1, padding: '32px', overflowY: 'auto' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '8px' }}>
              <Archive size={28} color="var(--accent-orange)" />
              <h2 style={{ fontSize: '2rem', margin: 0 }}>Archived Teacher Uploads</h2>
            </div>
            <p style={{ color: 'var(--text-secondary)', marginBottom: '28px' }}>
              Restore archived courses, modules, and quizzes or permanently delete them.
            </p>

            {archivedUploads.length === 0 ? (
              <div style={{ minHeight: '320px', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', color: 'var(--text-secondary)', textAlign: 'center' }}>
                <Archive size={48} color="var(--accent-orange)" style={{ opacity: 0.45, marginBottom: '14px' }} />
                <h3 style={{ color: 'var(--text-primary)', marginBottom: '6px' }}>Archive is empty</h3>
                <p>Archived teacher uploads will appear here.</p>
              </div>
            ) : (
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(285px, 1fr))', gap: '16px' }}>
                {archivedUploads.map(archive => {
                  const itemTitle = archive.payload?.title || archive.courseTitle || 'Untitled upload';
                  const archivedDate = formatDateTime(archive.archivedAt) || 'Archiving...';
                  return (
                    <div key={archive.id} style={{ background: 'rgba(0,0,0,0.2)', border: '1px solid color-mix(in srgb, var(--accent-orange) 30%, var(--border-light))', borderRadius: '14px', padding: '16px', display: 'flex', flexDirection: 'column', gap: '10px' }}>
                      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: '10px' }}>
                        <span className="badge" style={{ color: 'var(--accent-orange)', background: 'color-mix(in srgb, var(--accent-orange) 12%, transparent)', textTransform: 'capitalize' }}>
                          {archive.type}
                        </span>
                        <span style={{ color: 'var(--text-secondary)', fontSize: '0.72rem' }}>{archivedDate}</span>
                      </div>
                      <h3 style={{ color: 'var(--text-primary)', fontSize: '1rem', margin: 0, wordBreak: 'break-word' }}>{itemTitle}</h3>
                      <div style={{ color: 'var(--text-secondary)', fontSize: '0.8rem', lineHeight: 1.5 }}>
                        <div><strong style={{ color: 'var(--text-primary)' }}>Teacher:</strong> {archive.teacherName || 'Teacher'}</div>
                        {archive.type !== 'course' && (
                          <div><strong style={{ color: 'var(--text-primary)' }}>Course/Topic:</strong> {archive.courseTitle || 'Unknown'}</div>
                        )}
                        <div><strong style={{ color: 'var(--text-primary)' }}>Grade:</strong> {archive.grade || 'Not set'}</div>
                        <div><strong style={{ color: 'var(--text-primary)' }}>Sections:</strong> {archive.sections?.join(', ') || 'Not set'}</div>
                      </div>
                      {archive.type === 'module' && archive.payload?.url && (
                        <a href={archive.payload.url} target="_blank" rel="noreferrer" className="btn btn-secondary" style={{ justifyContent: 'center', fontSize: '0.8rem' }}>
                          View File
                        </a>
                      )}
                      <div style={{ display: 'flex', gap: '8px', marginTop: 'auto' }}>
                        <button className="btn btn-success" style={{ flex: 1, justifyContent: 'center' }} onClick={() => restoreArchivedUpload(archive)} title="Restore upload">
                          <RotateCcw size={16} /> Restore
                        </button>
                        <button className="btn btn-danger" style={{ padding: '8px 10px' }} onClick={() => setPermanentDeleteConfirm(archive)} title="Permanently delete">
                          <Trash2 size={16} />
                        </button>
                      </div>
                    </div>
                  );
                })}
              </div>
            )}
          </div>
        ) : activeTeacherId && activeTeacherCourses.length > 0 ? (
          <div className="glass-panel animate-fade-in" style={{ flex: 1, padding: '32px', display: 'flex', flexDirection: 'column', overflowY: 'auto' }}>
            <h2 style={{ fontSize: '2rem', marginBottom: '32px', borderBottom: '1px solid var(--border-light)', paddingBottom: '16px' }}>
              {displayActiveTeacherName}'s Uploads
            </h2>
            
            {activeTeacherCourses.map((course, index) => (
              <div key={course.id} style={{ marginBottom: '48px', paddingBottom: '48px', borderBottom: index !== activeTeacherCourses.length - 1 ? '2px dashed var(--text-secondary)' : 'none' }}>
                <div style={{ display: 'flex', flexWrap: 'wrap', alignItems: 'center', gap: '16px', marginBottom: '24px', color: 'var(--text-secondary)' }}>
                  <span className="badge" style={{ display: 'flex', alignItems: 'center', gap: '12px', background: 'rgba(255,255,255,0.1)', fontSize: '1.1rem', color: 'var(--accent-green)', padding: '6px 12px' }}>
                    Course/Topic: {course.topic || course.title}
                    <button
                      onClick={() => handleDeleteCourse(course.id, course.title)}
                      style={{ background: 'transparent', border: 'none', padding: 0, margin: 0, cursor: 'pointer', display: 'flex', alignItems: 'center', color: 'var(--accent-orange)' }}
                      title="Archive Course"
                    >
                      <Archive size={18} />
                    </button>
                  </span>
                  <span className="badge" style={{ background: 'rgba(255,255,255,0.1)', fontSize: '0.9rem', padding: '6px 12px', color: 'var(--accent-purple)' }}>Subject: {course.subject}</span>
                  <span className="badge" style={{ background: 'rgba(255,255,255,0.1)', fontSize: '0.9rem', padding: '6px 12px', color: 'var(--accent-cyan)' }}>Section: {course.sections?.join(', ')}</span>
                  <span className="badge" style={{ background: 'rgba(255,255,255,0.1)', fontSize: '0.9rem', padding: '6px 12px', color: 'var(--accent-pending)' }}>Grade: {course.grade || 'Not set'}</span>
                  {(() => {
                    const createdDate = getCourseDate(course);
                    return createdDate ? (
                      <span className="badge" style={{ background: 'rgba(255,255,255,0.1)', fontSize: '0.9rem', padding: '6px 12px', color: 'var(--accent-orange)', display: 'inline-flex', alignItems: 'center', gap: '6px' }}>
                        <Clock size={14} />
                        Created: {createdDate}
                      </span>
                    ) : null;
                  })()}
                </div>

                <h3 style={{ marginBottom: '16px', display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <FileText size={20} color="var(--accent-cyan)" /> Modules ({course.modules?.length || 0})
                </h3>
                <div style={{ marginBottom: '32px' }}>
                  {(!course.modules || course.modules.length === 0) ? (
                    <p>No modules uploaded yet.</p>
                  ) : (
                    <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(250px, 1fr))', gap: '16px' }}>
                      {course.modules.map((mod, index) => (
                        <div key={index} style={{ background: 'rgba(0,0,0,0.2)', padding: '16px', borderRadius: '12px', border: '1px solid var(--border-light)' }}>
                          <h4 style={{ color: 'var(--text-primary)', marginBottom: '8px', wordBreak: 'break-all' }}>{mod.title}</h4>
                          <div style={{ display: 'flex', alignItems: 'center', gap: '6px', color: 'var(--text-secondary)', fontSize: '0.75rem', marginBottom: '12px' }}>
                            <Clock size={13} color="var(--accent-orange)" />
                            <span>Uploaded: {getModuleDate(mod) || 'Date not recorded'}</span>
                          </div>
                          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                            <span style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>{mod.fileType?.toUpperCase()}</span>
                            <div style={{ display: 'flex', gap: '8px' }}>
                              <a href={mod.url} target="_blank" rel="noreferrer" className="btn btn-secondary" style={{ padding: '6px 12px', fontSize: '0.8rem' }}>View File</a>
                              <button onClick={() => handleDeleteModule(course.id, index, mod.title)} className="btn btn-archive" style={{ padding: '6px', display: 'flex', alignItems: 'center', justifyContent: 'center' }} title="Archive Module">
                                <Archive size={16} />
                              </button>
                            </div>
                          </div>
                        </div>
                      ))}
                    </div>
                  )}
                </div>

                <h3 style={{ marginBottom: '16px', display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <HelpCircle size={20} color="var(--accent-purple)" /> Quizzes ({course.quizzes?.length || 0})
                </h3>
                <div>
                  {(!course.quizzes || course.quizzes.length === 0) ? (
                    <p>No quizzes created yet.</p>
                  ) : (
                    <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(250px, 1fr))', gap: '16px' }}>
                      {course.quizzes.map((quiz, index) => (
                        <div key={index} style={{ background: 'rgba(0,0,0,0.2)', padding: '16px', borderRadius: '12px', border: '1px solid var(--border-light)' }}>
                          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '8px' }}>
                            <h4 style={{ color: 'var(--text-primary)', wordBreak: 'break-all' }}>{quiz.title}</h4>
                            <button onClick={() => handleDeleteQuiz(course.id, index, quiz.title)} className="btn btn-archive" style={{ padding: '6px', display: 'flex', alignItems: 'center', justifyContent: 'center', marginLeft: '8px' }} title="Archive Quiz">
                              <Archive size={16} />
                            </button>
                          </div>
                          <span style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>
                            {quiz.questions?.length || 0} Questions • {quiz.timeLimitMinutes} mins
                          </span>
                          <div style={{ display: 'flex', alignItems: 'center', gap: '6px', color: 'var(--text-secondary)', fontSize: '0.75rem', marginTop: '10px' }}>
                            <Clock size={13} color="var(--accent-orange)" />
                            <span>Created: {getQuizDate(quiz) || 'Date not recorded'}</span>
                          </div>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              </div>
            ))}
          </div>
        ) : (
          <div className="glass-panel" style={{ flex: 1, display: 'flex', justifyContent: 'center', alignItems: 'center', color: 'var(--text-secondary)' }}>
            <div style={{ textAlign: 'center' }}>
              <BookOpen size={48} color="rgba(255,255,255,0.1)" style={{ marginBottom: '16px' }} />
              <p>Select a teacher to view uploads</p>
            </div>
          </div>
        )}
      </div>
    </div>

      {/* Archive Confirmation Modal */}
      {deleteConfirm && (
        <div style={{
          position: 'fixed', top: 0, left: 0, right: 0, bottom: 0,
          background: 'rgba(0,0,0,0.6)',
          backdropFilter: 'blur(4px)',
          display: 'flex', justifyContent: 'center', alignItems: 'center',
          zIndex: 100
        }}>
          <div className="glass-panel animate-fade-in" style={{ width: '100%', maxWidth: '420px', padding: '32px', textAlign: 'center' }}>
            <div style={{ background: 'color-mix(in srgb, var(--accent-orange) 12%, transparent)', padding: '16px', borderRadius: '50%', display: 'inline-block', marginBottom: '16px' }}>
              <Archive size={32} color="var(--accent-orange)" />
            </div>
            <h2 style={{ marginBottom: '12px', textTransform: 'capitalize' }}>
              Archive {deleteConfirm.type}?
            </h2>
            <p style={{ color: 'var(--text-secondary)', marginBottom: '24px', lineHeight: 1.5 }}>
              Are you sure you want to archive the {deleteConfirm.type} <strong>"{deleteConfirm.name}"</strong>?
              {deleteConfirm.type === 'course' && " Its modules and quizzes will be archived with it."}
              <br/><br/>You can restore it later from Archived Teacher Uploads.
            </p>
            <div style={{ display: 'flex', gap: '12px' }}>
              <button className="btn btn-secondary" style={{ flex: 1 }} onClick={() => setDeleteConfirm(null)}>Cancel</button>
              <button className="btn btn-archive" style={{ flex: 1 }} onClick={confirmArchive}>Yes, Archive</button>
            </div>
          </div>
        </div>
      )}

      {/* Permanent Delete Confirmation Modal */}
      {permanentDeleteConfirm && (
        <div style={{
          position: 'fixed', top: 0, left: 0, right: 0, bottom: 0,
          background: 'rgba(0,0,0,0.7)',
          backdropFilter: 'blur(4px)',
          display: 'flex', justifyContent: 'center', alignItems: 'center',
          zIndex: 100
        }}>
          <div className="glass-panel animate-fade-in" style={{ width: '100%', maxWidth: '420px', padding: '32px', textAlign: 'center', border: '1px solid var(--accent-red)' }}>
            <div style={{ background: 'rgba(255, 71, 87, 0.1)', padding: '16px', borderRadius: '50%', display: 'inline-block', marginBottom: '16px' }}>
              <AlertTriangle size={32} color="var(--accent-red)" />
            </div>
            <h2 style={{ marginBottom: '12px', color: 'var(--accent-red)' }}>Permanently Delete?</h2>
            <p style={{ color: 'var(--text-secondary)', marginBottom: '24px', lineHeight: 1.5 }}>
              Permanently delete the archived {permanentDeleteConfirm.type} <strong>"{permanentDeleteConfirm.payload?.title || permanentDeleteConfirm.courseTitle}"</strong>?
              <br/><br/>This action cannot be undone.
            </p>
            <div style={{ display: 'flex', gap: '12px' }}>
              <button className="btn btn-secondary" style={{ flex: 1 }} onClick={() => setPermanentDeleteConfirm(null)}>Cancel</button>
              <button className="btn btn-danger" style={{ flex: 1 }} onClick={permanentlyDeleteArchivedUpload}>Delete Forever</button>
            </div>
          </div>
        </div>
      )}
    </>
  );
}
