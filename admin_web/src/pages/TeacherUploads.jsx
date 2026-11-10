import { useState, useEffect } from 'react';
import { collection, query, where, onSnapshot, doc, deleteDoc, getDoc, writeBatch, runTransaction, serverTimestamp, Timestamp } from 'firebase/firestore';
import { db } from '../firebase';
import { logAdminActivity } from '../services/adminActivityService';
import { newestQuizFirst, teacherUploadGroups, formatUploadTime, uploadTimestampMillis } from '../services/quizOrdering';
import { BookOpen, FileText, HelpCircle, Trash2, AlertTriangle, Search, Clock, Archive, RotateCcw, ArrowLeft, ShieldCheck, CheckCircle2, XCircle, Eye, X } from 'lucide-react';

export default function TeacherUploads() {
  const [courses, setCourses] = useState([]);
  const [activeTeacherId, setActiveTeacherId] = useState(null);
  const [deleteConfirm, setDeleteConfirm] = useState(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [teacherProfiles, setTeacherProfiles] = useState({});
  const [archivedUploads, setArchivedUploads] = useState([]);
  const [showArchive, setShowArchive] = useState(false);
  const [activeView, setActiveView] = useState('uploads');
  const [approvalFilter, setApprovalFilter] = useState('pending');
  const [previewQuiz, setPreviewQuiz] = useState(null);
  const [rejectConfirm, setRejectConfirm] = useState(null);
  const [recoverConfirm, setRecoverConfirm] = useState(null);
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

  const getQuizDate = (quiz) =>
    formatUploadTime(uploadTimestampMillis(quiz));

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
  const activeTeacherUploadGroups = teacherUploadGroups(activeTeacherCourses);
  const activeTeacherInfo = teachers.find(t => t.id === activeTeacherId) || {};
  const displayActiveTeacherName = activeTeacherInfo.name || 'Teacher';
  const pendingQuizzes = courses.flatMap(course => (course.quizzes || [])
    .filter(quiz => quiz.approvalStatus === 'pending')
    .map(quiz => ({
      quiz,
      courseId: course.id,
      courseTitle: course.topic || course.title || 'Untitled course',
      teacherName: teacherProfiles[course.teacherUid]?.name || course.teacherName || 'Teacher',
      grade: course.grade || 'Not set',
      sections: course.sections || [],
    })));
  const rejectedQuizzes = courses.flatMap(course => (course.quizzes || [])
    .filter(quiz => quiz.approvalStatus === 'rejected')
    .map(quiz => ({
      quiz,
      courseId: course.id,
      courseTitle: course.topic || course.title || 'Untitled course',
      teacherName: teacherProfiles[course.teacherUid]?.name || course.teacherName || 'Teacher',
      grade: course.grade || 'Not set',
      sections: course.sections || [],
    })));
  const visibleApprovalQuizzes = [...(approvalFilter === 'rejected' ? rejectedQuizzes : pendingQuizzes)]
    .sort((first, second) => newestQuizFirst(first.quiz, second.quiz));

  const updateQuizApproval = async (pendingQuiz, approvalStatus) => {
    try {
      await runTransaction(db, async transaction => {
        const courseRef = doc(db, 'courses', pendingQuiz.courseId);
        const snapshot = await transaction.get(courseRef);
        if (!snapshot.exists()) throw new Error('The course no longer exists.');
        const currentQuizzes = snapshot.data().quizzes || [];
        let found = false;
        const updatedQuizzes = currentQuizzes.map(quiz => {
          if (quiz.id !== pendingQuiz.quiz.id) return quiz;
          found = true;
          return {
            ...quiz,
            approvalStatus,
            reviewedAt: Timestamp.now(),
          };
        });
        if (!found) throw new Error('The quiz no longer exists.');
        transaction.update(courseRef, { quizzes: updatedQuizzes });
      });
      const activityAction = approvalStatus === 'approved'
        ? { type: 'quiz_approved', label: 'Approved' }
        : approvalStatus === 'rejected'
          ? { type: 'quiz_rejected', label: 'Rejected' }
          : { type: 'quiz_recovered', label: 'Recovered' };
      await logAdminActivity({
        type: activityAction.type,
        title: `${activityAction.label} quiz: ${pendingQuiz.quiz.title || 'Untitled quiz'}`,
        details: {
          courseId: pendingQuiz.courseId,
          courseTitle: pendingQuiz.courseTitle,
          teacherName: pendingQuiz.teacherName,
          grade: pendingQuiz.grade,
          sections: pendingQuiz.sections,
          quizId: pendingQuiz.quiz.id,
        },
      });
      return true;
    } catch (error) {
      console.error(`Could not ${approvalStatus} quiz:`, error);
      const actionLabel = approvalStatus === 'approved' ? 'approve' : approvalStatus === 'rejected' ? 'reject' : 'recover';
      alert(`Could not ${actionLabel} the quiz: ${error.message || error}`);
      return false;
    }
  };

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
      <div className="animate-fade-in flex-mobile-col uploads-layout" style={{ display: 'flex', gap: '24px', height: 'calc(100vh - 100px)' }}>
      <div className="mobile-w-full uploads-teacher-browser" style={{ flex: '0 0 350px', display: 'flex', flexDirection: 'column' }}>
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
                    setActiveView('uploads');
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
        <div className="glass-panel" style={{ display: 'grid', gridTemplateColumns: 'repeat(2, minmax(0, 1fr))', padding: '0 24px', marginBottom: '14px' }}>
          <button
            type="button"
            onClick={() => {
              setActiveView('uploads');
              setShowArchive(false);
            }}
            style={{
              minHeight: '58px', border: 'none', background: 'transparent', cursor: 'pointer', font: 'inherit', fontWeight: 800,
              borderBottom: activeView === 'uploads' ? '3px solid var(--accent-cyan)' : '3px solid transparent',
              color: activeView === 'uploads' ? 'var(--accent-green)' : 'var(--text-secondary)',
            }}
          >
            Teacher Uploads ({courses.length})
          </button>
          <button
            type="button"
            onClick={() => {
              setActiveView('approvals');
              setShowArchive(false);
            }}
            style={{
              minHeight: '58px', border: 'none', background: 'transparent', cursor: 'pointer', font: 'inherit', fontWeight: 800,
              borderBottom: activeView === 'approvals' ? '3px solid var(--accent-cyan)' : '3px solid transparent',
              color: activeView === 'approvals' ? 'var(--accent-orange)' : 'var(--text-secondary)',
            }}
          >
            Quiz Approvals ({pendingQuizzes.length})
          </button>
        </div>

        {activeView === 'uploads' && (
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
        )}

        {activeView === 'approvals' ? (
          <div className="glass-panel animate-fade-in" style={{ flex: 1, padding: '32px', overflowY: 'auto' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '14px', paddingBottom: '20px', marginBottom: '22px', borderBottom: '1px solid var(--border-light)' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                <ShieldCheck size={28} color="var(--accent-orange)" />
                <div>
                  <h2 style={{ margin: 0, color: 'var(--text-primary)' }}>Quiz Approvals</h2>
                  <p style={{ margin: '4px 0 0', color: 'var(--text-secondary)' }}>Review teacher-created quizzes before students can see them.</p>
                </div>
              </div>
              <div style={{ display: 'flex', alignItems: 'center', flexWrap: 'wrap', gap: '10px' }}>
                <button
                  type="button"
                  onClick={() => setApprovalFilter('pending')}
                  aria-pressed={approvalFilter === 'pending'}
                  style={{ display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: '8px', minWidth: '124px', minHeight: '42px', border: '1.5px solid color-mix(in srgb, var(--accent-orange) 70%, var(--border-light))', borderRadius: '11px', color: 'var(--accent-orange)', background: approvalFilter === 'pending' ? 'color-mix(in srgb, var(--accent-orange) 22%, var(--bg-card))' : 'color-mix(in srgb, var(--accent-orange) 8%, var(--bg-card))', boxShadow: approvalFilter === 'pending' ? '0 0 0 3px color-mix(in srgb, var(--accent-orange) 13%, transparent)' : 'none', padding: '9px 14px', font: 'inherit', fontWeight: 800, cursor: 'pointer' }}
                >
                  <Clock size={16} /> {pendingQuizzes.length} Pending
                </button>
                <button
                  type="button"
                  onClick={() => setApprovalFilter('rejected')}
                  aria-pressed={approvalFilter === 'rejected'}
                  style={{ display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: '8px', minWidth: '124px', minHeight: '42px', border: '1.5px solid color-mix(in srgb, var(--accent-red) 70%, var(--border-light))', borderRadius: '11px', color: 'var(--accent-red)', background: approvalFilter === 'rejected' ? 'color-mix(in srgb, var(--accent-red) 22%, var(--bg-card))' : 'color-mix(in srgb, var(--accent-red) 8%, var(--bg-card))', boxShadow: approvalFilter === 'rejected' ? '0 0 0 3px color-mix(in srgb, var(--accent-red) 13%, transparent)' : 'none', padding: '9px 14px', font: 'inherit', fontWeight: 800, cursor: 'pointer' }}
                >
                  <XCircle size={16} /> {rejectedQuizzes.length} Rejected
                </button>
              </div>
            </div>

            {visibleApprovalQuizzes.length === 0 ? (
              <div style={{ minHeight: '330px', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', textAlign: 'center', color: 'var(--text-secondary)' }}>
                {approvalFilter === 'pending'
                  ? <CheckCircle2 size={52} color="var(--accent-green)" style={{ opacity: 0.72, marginBottom: '14px' }} />
                  : <XCircle size={52} color="var(--accent-red)" style={{ opacity: 0.65, marginBottom: '14px' }} />}
                <h3 style={{ color: 'var(--text-primary)', marginBottom: '6px' }}>{approvalFilter === 'pending' ? 'All quizzes reviewed' : 'No rejected quizzes'}</h3>
                <p>{approvalFilter === 'pending' ? 'New teacher-created quizzes will appear here for approval.' : 'Quizzes rejected by an administrator will appear here.'}</p>
              </div>
            ) : (
              <div className="admin-quiz-review-list" role="region" aria-label="Quiz approvals table" tabIndex={0} style={{ border: '1px solid var(--border-light)', borderRadius: '14px' }}>
                <div>
                  <div className="admin-quiz-review-heading" style={{ display: 'grid', gap: '18px', alignItems: 'center', padding: '15px 18px', borderBottom: '1px solid var(--border-light)', color: 'var(--text-secondary)', fontSize: '0.76rem', fontWeight: 800, textTransform: 'uppercase', letterSpacing: '0.03em' }}>
                    <span>Teacher</span>
                    <span>Title</span>
                    <span>Course</span>
                    <span>Class</span>
                    <span>Created</span>
                    <span style={{ textAlign: 'center' }}>Actions</span>
                  </div>
                  {visibleApprovalQuizzes.map(item => (
                    <div
                      key={`${item.courseId}-${item.quiz.id}`}
                      className="admin-quiz-review-row"
                      style={{ display: 'grid', gap: '18px', alignItems: 'center', padding: '18px', borderBottom: '1px solid var(--border-light)', background: 'var(--bg-card)' }}
                    >
                      <strong data-label="Teacher" style={{ color: 'var(--text-primary)', wordBreak: 'break-word' }}>{item.teacherName}</strong>
                      <div data-label="Title" style={{ minWidth: 0 }}>
                        <strong style={{ display: 'block', color: 'var(--text-primary)', wordBreak: 'break-word' }}>{item.quiz.title || 'Untitled quiz'}</strong>
                        <span style={{ display: 'block', marginTop: '4px', color: 'var(--text-secondary)', fontSize: '0.75rem' }}>{item.quiz.questions?.length || 0} Questions</span>
                      </div>
                      <span data-label="Course" style={{ color: 'var(--text-primary)', wordBreak: 'break-word' }}>{item.courseTitle}</span>
                      <span data-label="Class" style={{ color: 'var(--text-secondary)' }}>{item.grade}<br />Sections {item.sections.join(', ') || 'Not set'}</span>
                      <span data-label="Created" style={{ color: 'var(--text-secondary)', fontSize: '0.8rem' }}>{getQuizDate(item.quiz) || 'Date not recorded'}</span>
                      <div className="admin-quiz-review-actions" style={{ display: 'flex', justifyContent: 'center', gap: '8px' }}>
                        <button className="btn btn-secondary" style={{ padding: '8px 11px', justifyContent: 'center' }} onClick={() => setPreviewQuiz(item)} title="View quiz"><Eye size={16} /> View</button>
                        {approvalFilter === 'pending' ? (
                          <>
                            <button className="btn btn-success" style={{ padding: '8px 11px', justifyContent: 'center' }} onClick={() => updateQuizApproval(item, 'approved')} title="Approve quiz"><CheckCircle2 size={16} /> Approve</button>
                            <button className="btn btn-danger" style={{ padding: '8px 11px', justifyContent: 'center' }} onClick={() => setRejectConfirm(item)} title="Reject quiz"><XCircle size={16} /> Reject</button>
                          </>
                        ) : (
                          <button className="btn btn-success" style={{ padding: '8px 11px', justifyContent: 'center' }} onClick={() => setRecoverConfirm(item)} title="Recover quiz to pending"><RotateCcw size={16} /> Recover</button>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
        ) : showArchive ? (
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
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(min(285px, 100%), 1fr))', gap: '16px' }}>
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
            
            {activeTeacherUploadGroups.map(({ course, modules, quizzes, createdTimestamp }, groupIndex) => (
              <section key={course.id} style={{ marginBottom: '36px', paddingBottom: '32px', borderBottom: groupIndex !== activeTeacherUploadGroups.length - 1 ? '2px dashed var(--border-light)' : 'none' }}>
                <div style={{ display: 'flex', flexWrap: 'wrap', alignItems: 'center', gap: '12px', marginBottom: '24px' }}>
                  <span className="badge" style={{ background: 'var(--bg-card-hover)', color: 'var(--accent-green)', fontSize: '1rem', padding: '8px 12px' }}>Course/Topic: {course.topic || course.title || 'Untitled course'}</span>
                  <span className="badge badge-role">{course.subject || 'No subject'}</span>
                  <span className="badge">{course.grade || 'Grade not set'} &middot; Sections {(course.sections || []).join(', ') || 'not set'}</span>
                  <button type="button" className="btn btn-archive" style={{ padding: '7px 10px', fontSize: '.8rem' }} onClick={() => handleDeleteCourse(course.id, course.title)}><Archive size={16} /> Archive Course</button>
                </div>
                <p style={{ marginBottom: '20px', fontSize: '.8rem' }}>Course created: {formatUploadTime(createdTimestamp)}</p>
                <h3 style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '16px' }}><FileText size={20} color="var(--accent-cyan)" /> Modules ({modules.length})</h3>
                {modules.length === 0 ? <p style={{ marginBottom: '24px' }}>No modules uploaded yet.</p> : (
                  <div className="admin-upload-card-grid" style={{ marginBottom: '28px' }}>
                    {modules.map(({ item: mod, index, timestamp }) => (
                      <article key={mod.id || index} className="admin-upload-card">
                        <h4>{mod.title || 'Untitled module'}</h4>
                        <p className="admin-upload-card-date"><Clock size={13} /><span>Uploaded: {formatUploadTime(timestamp)}</span></p>
                        <div className="admin-upload-card-actions"><span>{mod.fileType?.toUpperCase() || 'Module'}</span><div className="teacher-action-row">
                          {mod.url && <a href={mod.url} target="_blank" rel="noreferrer" className="btn btn-secondary" style={{ padding: '7px 10px', fontSize: '.8rem' }}>View File</a>}
                          <button type="button" className="btn btn-archive" style={{ padding: '7px' }} onClick={() => handleDeleteModule(course.id, index, mod.title)} aria-label={`Archive ${mod.title || 'module'}`} title="Archive module"><Archive size={16} /></button>
                        </div></div>
                      </article>
                    ))}
                  </div>
                )}
                <h3 style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '16px' }}><HelpCircle size={20} color="var(--accent-purple)" /> Approved Quizzes ({quizzes.length})</h3>
                {quizzes.length === 0 ? <p>No approved quizzes yet.</p> : (
                  <div className="admin-upload-card-grid">
                    {quizzes.map(({ item: quiz, index, timestamp }) => (
                      <article key={quiz.id || index} className="admin-upload-card">
                        <h4>{quiz.title || 'Untitled quiz'}</h4>
                        <p style={{ fontSize: '.8rem' }}>{quiz.questions?.length || 0} Questions{Number(quiz.timeLimitMinutes) > 0 ? ` / ${Number(quiz.timeLimitMinutes)} mins` : ''}</p>
                        <span className="badge badge-approved" style={{ alignSelf: 'flex-start' }}>Approved</span>
                        <p className="admin-upload-card-date"><Clock size={13} /><span>Created: {formatUploadTime(timestamp)}</span></p>
                        <div className="teacher-action-row" style={{ marginTop: 'auto', flexWrap: 'wrap' }}>
                          <button type="button" className="btn btn-secondary" style={{ padding: '7px 10px', fontSize: '.8rem' }} onClick={() => setPreviewQuiz({ quiz, courseId: course.id, courseTitle: course.topic || course.title, teacherName: displayActiveTeacherName, grade: course.grade, sections: course.sections || [] })}><Eye size={16} /> View Quiz</button>
                          <button type="button" className="btn btn-archive" style={{ padding: '7px' }} onClick={() => handleDeleteQuiz(course.id, index, quiz.title)} aria-label={`Archive ${quiz.title || 'quiz'}`} title="Archive quiz"><Archive size={16} /></button>
                        </div>
                      </article>
                    ))}
                  </div>
                )}
              </section>
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

      {rejectConfirm && (
        <div
          role="dialog"
          aria-modal="true"
          aria-label="Confirm quiz rejection"
          onMouseDown={(event) => {
            if (event.target === event.currentTarget) setRejectConfirm(null);
          }}
          style={{ position: 'fixed', inset: 0, zIndex: 150, display: 'grid', placeItems: 'center', padding: '24px', background: 'rgba(1, 8, 20, 0.78)', backdropFilter: 'blur(7px)' }}
        >
          <div className="glass-panel animate-fade-in" style={{ width: 'min(460px, 100%)', padding: '28px', textAlign: 'center', border: '1px solid color-mix(in srgb, var(--accent-red) 55%, var(--border-light))', position: 'relative' }}>
            <button type="button" className="teacher-icon-btn" onClick={() => setRejectConfirm(null)} title="Close" style={{ position: 'absolute', top: '14px', right: '14px' }}><X size={19} /></button>
            <div style={{ width: '68px', height: '68px', display: 'grid', placeItems: 'center', margin: '2px auto 18px', borderRadius: '50%', color: 'var(--accent-red)', background: 'color-mix(in srgb, var(--accent-red) 11%, transparent)', border: '1px solid color-mix(in srgb, var(--accent-red) 35%, transparent)' }}>
              <AlertTriangle size={32} />
            </div>
            <h2 style={{ margin: '0 0 9px', color: 'var(--text-primary)' }}>Reject Quiz?</h2>
            <p style={{ margin: '0 auto 19px', maxWidth: '360px', color: 'var(--text-secondary)', lineHeight: 1.55 }}>
              This quiz will remain hidden from students. You can recover it later from the Rejected list.
            </p>
            <div style={{ padding: '14px', marginBottom: '20px', border: '1px solid var(--border-light)', borderRadius: '12px', background: 'var(--bg-card)', textAlign: 'left' }}>
              <strong style={{ display: 'block', color: 'var(--text-primary)', wordBreak: 'break-word', marginBottom: '6px' }}>{rejectConfirm.quiz.title || 'Untitled quiz'}</strong>
              <span style={{ display: 'block', color: 'var(--text-secondary)', fontSize: '0.78rem', lineHeight: 1.5 }}>Teacher: {rejectConfirm.teacherName}</span>
              <span style={{ display: 'block', color: 'var(--text-secondary)', fontSize: '0.78rem', lineHeight: 1.5 }}>Course/Topic: {rejectConfirm.courseTitle}</span>
              <span style={{ display: 'block', color: 'var(--text-secondary)', fontSize: '0.78rem', lineHeight: 1.5 }}>{rejectConfirm.grade} · Sections {rejectConfirm.sections.join(', ') || 'Not set'}</span>
            </div>
            <div style={{ display: 'flex', gap: '10px' }}>
              <button type="button" className="btn btn-secondary" style={{ flex: 1, justifyContent: 'center' }} onClick={() => setRejectConfirm(null)}>Cancel</button>
              <button
                type="button"
                className="btn btn-danger"
                style={{ flex: 1, justifyContent: 'center' }}
                onClick={async () => {
                  const rejected = await updateQuizApproval(rejectConfirm, 'rejected');
                  if (rejected) setRejectConfirm(null);
                }}
              >
                <XCircle size={17} /> Reject Quiz
              </button>
            </div>
          </div>
        </div>
      )}

      {recoverConfirm && (
        <div
          role="dialog"
          aria-modal="true"
          aria-label="Confirm quiz recovery"
          onMouseDown={(event) => {
            if (event.target === event.currentTarget) setRecoverConfirm(null);
          }}
          style={{ position: 'fixed', inset: 0, zIndex: 150, display: 'grid', placeItems: 'center', padding: '24px', background: 'rgba(1, 8, 20, 0.78)', backdropFilter: 'blur(7px)' }}
        >
          <div className="glass-panel animate-fade-in" style={{ width: 'min(460px, 100%)', padding: '28px', textAlign: 'center', border: '1px solid color-mix(in srgb, var(--accent-green) 55%, var(--border-light))', position: 'relative' }}>
            <button type="button" className="teacher-icon-btn" onClick={() => setRecoverConfirm(null)} title="Close" style={{ position: 'absolute', top: '14px', right: '14px' }}><X size={19} /></button>
            <div style={{ width: '68px', height: '68px', display: 'grid', placeItems: 'center', margin: '2px auto 18px', borderRadius: '50%', color: 'var(--accent-green)', background: 'color-mix(in srgb, var(--accent-green) 11%, transparent)', border: '1px solid color-mix(in srgb, var(--accent-green) 35%, transparent)' }}>
              <RotateCcw size={32} />
            </div>
            <h2 style={{ margin: '0 0 9px', color: 'var(--text-primary)' }}>Recover Quiz?</h2>
            <p style={{ margin: '0 auto 19px', maxWidth: '370px', color: 'var(--text-secondary)', lineHeight: 1.55 }}>
              This quiz will return to Pending for another admin review. Students still cannot see it until it is approved.
            </p>
            <div style={{ padding: '14px', marginBottom: '20px', border: '1px solid var(--border-light)', borderRadius: '12px', background: 'var(--bg-card)', textAlign: 'left' }}>
              <strong style={{ display: 'block', color: 'var(--text-primary)', wordBreak: 'break-word', marginBottom: '6px' }}>{recoverConfirm.quiz.title || 'Untitled quiz'}</strong>
              <span style={{ display: 'block', color: 'var(--text-secondary)', fontSize: '0.78rem', lineHeight: 1.5 }}>Teacher: {recoverConfirm.teacherName}</span>
              <span style={{ display: 'block', color: 'var(--text-secondary)', fontSize: '0.78rem', lineHeight: 1.5 }}>Course/Topic: {recoverConfirm.courseTitle}</span>
              <span style={{ display: 'block', color: 'var(--text-secondary)', fontSize: '0.78rem', lineHeight: 1.5 }}>{recoverConfirm.grade} · Sections {recoverConfirm.sections.join(', ') || 'Not set'}</span>
            </div>
            <div style={{ display: 'flex', gap: '10px' }}>
              <button type="button" className="btn btn-secondary" style={{ flex: 1, justifyContent: 'center' }} onClick={() => setRecoverConfirm(null)}>Cancel</button>
              <button
                type="button"
                className="btn btn-success"
                style={{ flex: 1, justifyContent: 'center' }}
                onClick={async () => {
                  const recovered = await updateQuizApproval(recoverConfirm, 'pending');
                  if (recovered) setRecoverConfirm(null);
                }}
              >
                <RotateCcw size={17} /> Recover Quiz
              </button>
            </div>
          </div>
        </div>
      )}

      {previewQuiz && (
        <QuizApprovalPreview
          item={previewQuiz}
          createdLabel={getQuizDate(previewQuiz.quiz) || 'Date not recorded'}
          onClose={() => setPreviewQuiz(null)}
        />
      )}

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

function QuizApprovalPreview({ item, createdLabel, onClose }) {
  const quiz = item.quiz;
  const questionTypeLabel = (type) => ({
    multipleChoice: 'Multiple Choice',
    trueFalse: 'True or False',
    identification: 'Identification',
    enumeration: 'Enumeration',
  }[type] || 'Multiple Choice');

  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-label={`Preview ${quiz.title || 'quiz'}`}
      onMouseDown={(event) => {
        if (event.target === event.currentTarget) onClose();
      }}
      style={{ position: 'fixed', inset: 0, zIndex: 140, display: 'grid', placeItems: 'center', padding: '24px', background: 'rgba(1, 8, 20, 0.78)', backdropFilter: 'blur(7px)' }}
    >
      <div className="glass-panel animate-fade-in" style={{ width: 'min(880px, 100%)', maxHeight: '88vh', display: 'flex', flexDirection: 'column', overflow: 'hidden', border: '1px solid var(--border-light)' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: '16px', padding: '22px 24px', borderBottom: '1px solid var(--border-light)' }}>
          <div>
            <span style={{ display: 'block', color: 'var(--accent-cyan)', fontSize: '0.76rem', fontWeight: 800, textTransform: 'uppercase', letterSpacing: '0.04em', marginBottom: '5px' }}>Quiz Preview</span>
            <h2 style={{ margin: 0, color: 'var(--text-primary)', wordBreak: 'break-word' }}>{quiz.title || 'Untitled quiz'}</h2>
            <p style={{ margin: '7px 0 0', color: 'var(--text-secondary)', fontSize: '0.82rem' }}>
              {item.teacherName} · {item.courseTitle} · {item.grade}, Sections {item.sections.join(', ') || 'Not set'}
            </p>
          </div>
          <button type="button" className="teacher-icon-btn" onClick={onClose} title="Close quiz preview"><X size={20} /></button>
        </div>

        <div style={{ overflowY: 'auto', padding: '22px 24px' }}>
          <div style={{ display: 'grid', gridTemplateColumns: 'minmax(0, 1fr) auto', gap: '18px', padding: '16px', marginBottom: '18px', border: '1px solid var(--border-light)', borderRadius: '12px', background: 'var(--bg-card)' }}>
            <div>
              <span style={{ display: 'block', color: 'var(--text-secondary)', fontSize: '0.72rem', fontWeight: 800, marginBottom: '6px' }}>DIRECTIONS</span>
              <p style={{ margin: 0, color: 'var(--text-primary)', lineHeight: 1.55 }}>{quiz.directions || 'No directions were added.'}</p>
            </div>
            <div style={{ textAlign: 'right' }}>
              <span style={{ display: 'block', color: 'var(--text-secondary)', fontSize: '0.72rem', fontWeight: 800, marginBottom: '6px' }}>CREATED</span>
              <strong style={{ color: 'var(--text-primary)', fontSize: '0.8rem' }}>{createdLabel}</strong>
            </div>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
            {(quiz.questions || []).map((question, questionIndex) => {
              const type = question.type || 'multipleChoice';
              const usesOptions = type === 'multipleChoice' || type === 'trueFalse';
              const correctAnswers = usesOptions
                ? [question.options?.[question.correctIndex] || 'Not set']
                : question.correctAnswers || [];
              return (
                <article key={question.id || questionIndex} style={{ padding: '17px', border: '1px solid var(--border-light)', borderRadius: '13px', background: 'var(--bg-card)' }}>
                  <div style={{ display: 'flex', alignItems: 'flex-start', gap: '12px' }}>
                    <span style={{ flex: '0 0 30px', height: '30px', display: 'grid', placeItems: 'center', borderRadius: '50%', color: 'var(--accent-cyan)', background: 'color-mix(in srgb, var(--accent-cyan) 12%, transparent)', fontWeight: 800 }}>{questionIndex + 1}</span>
                    <div style={{ minWidth: 0 }}>
                      <span style={{ display: 'block', color: 'var(--accent-cyan)', fontSize: '0.7rem', fontWeight: 800, marginBottom: '5px' }}>{questionTypeLabel(type)}</span>
                      <strong style={{ color: 'var(--text-primary)', lineHeight: 1.45, wordBreak: 'break-word' }}>{question.question || 'Question text not set'}</strong>
                    </div>
                  </div>

                  {usesOptions && (
                    <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(190px, 1fr))', gap: '8px', marginTop: '14px' }}>
                      {(question.options || []).map((option, optionIndex) => {
                        const isCorrect = optionIndex === question.correctIndex;
                        return (
                          <div key={optionIndex} style={{ display: 'flex', alignItems: 'center', gap: '7px', padding: '10px 12px', borderRadius: '9px', border: `1px solid ${isCorrect ? 'color-mix(in srgb, var(--accent-green) 55%, transparent)' : 'var(--border-light)'}`, color: isCorrect ? 'var(--accent-green)' : 'var(--text-secondary)', background: isCorrect ? 'color-mix(in srgb, var(--accent-green) 8%, transparent)' : 'transparent' }}>
                            {isCorrect && <CheckCircle2 size={15} />}{option || `Option ${optionIndex + 1}`}
                          </div>
                        );
                      })}
                    </div>
                  )}

                  {!usesOptions && (
                    <div style={{ marginTop: '14px', padding: '11px 13px', borderRadius: '9px', color: 'var(--accent-green)', background: 'color-mix(in srgb, var(--accent-green) 8%, transparent)', border: '1px solid color-mix(in srgb, var(--accent-green) 35%, transparent)' }}>
                      <span style={{ display: 'block', color: 'var(--text-secondary)', fontSize: '0.7rem', fontWeight: 800, marginBottom: '4px' }}>CORRECT {correctAnswers.length === 1 ? 'ANSWER' : 'ANSWERS'}</span>
                      <strong>{correctAnswers.join(', ') || 'Not set'}</strong>
                    </div>
                  )}

                  {question.explanation && <p style={{ margin: '12px 0 0', color: 'var(--text-secondary)', fontSize: '0.8rem', lineHeight: 1.5 }}><strong style={{ color: 'var(--text-primary)' }}>Explanation:</strong> {question.explanation}</p>}
                </article>
              );
            })}
            {(!quiz.questions || quiz.questions.length === 0) && <p style={{ padding: '40px', textAlign: 'center', color: 'var(--text-secondary)' }}>This quiz has no questions.</p>}
          </div>
        </div>

        <div style={{ display: 'flex', justifyContent: 'flex-end', padding: '16px 24px', borderTop: '1px solid var(--border-light)' }}>
          <button type="button" className="btn btn-secondary" onClick={onClose}>Close</button>
        </div>
      </div>
    </div>
  );
}
