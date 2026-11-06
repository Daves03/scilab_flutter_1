import { useEffect, useMemo, useState } from 'react';
import { createPortal } from 'react-dom';
import { collection, onSnapshot, query, where } from 'firebase/firestore';
import { Activity, BarChart3, BookOpen, CheckCircle2, ChevronLeft, ChevronRight, Clock3, FlaskConical, GraduationCap, TrendingUp, Users, X } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { db } from '../firebase';
import TeacherDateTimeCalendar from '../components/TeacherDateTimeCalendar';
import UserAvatar from '../components/UserAvatar';
import {
  average,
  courseMatchesStudent,
  formatDateTime,
  latestQuizAttempts,
  percentage,
  teacherHandlesStudent,
  teacherGradeLabels,
  timestampToDate,
} from '../services/teacherPortalUtils';

export default function TeacherDashboard({ user, profile }) {
  const navigate = useNavigate();
  const [courses, setCourses] = useState([]);
  const [students, setStudents] = useState([]);
  const [sections, setSections] = useState([]);
  const [attempts, setAttempts] = useState([]);
  const [arRecords, setArRecords] = useState([]);
  const [experiments, setExperiments] = useState([]);
  const [participationPopup, setParticipationPopup] = useState(null);
  const [participationPage, setParticipationPage] = useState(1);
  const [showAssignments, setShowAssignments] = useState(false);
  const teacherSections = useMemo(() => profile?.sections || [], [profile?.sections]);
  const teachingGrades = useMemo(() => teacherGradeLabels(teacherSections, sections), [sections, teacherSections]);

  useEffect(() => {
    if (!user?.uid) return undefined;
    const unsubscribers = [
      onSnapshot(query(collection(db, 'courses'), where('teacherUid', '==', user.uid)), (snapshot) => {
        setCourses(snapshot.docs.map((item) => ({ id: item.id, ...item.data() })));
      }),
      onSnapshot(collection(db, 'users'), (snapshot) => {
        setStudents(snapshot.docs.map((item) => ({ id: item.id, ...item.data() })));
      }),
      onSnapshot(collection(db, 'sections'), (snapshot) => {
        setSections(snapshot.docs.map((item) => ({ id: item.id, ...item.data() })));
      }),
      onSnapshot(collection(db, 'quiz_attempts'), (snapshot) => {
        setAttempts(snapshot.docs.map((item) => ({ id: item.id, ...item.data() })));
      }),
      onSnapshot(collection(db, 'ar_experiments'), (snapshot) => {
        setExperiments(snapshot.docs.map((item) => ({ id: item.id, ...item.data() })));
      }),
    ];
    return () => unsubscribers.forEach((unsubscribe) => unsubscribe());
  }, [user?.uid]);

  const handledStudents = useMemo(() => students.filter((student) =>
    student.status === 'approved'
      && teacherHandlesStudent(teacherSections, student, sections)
      && courses.some((course) => courseMatchesStudent(course, student))),
  [courses, sections, students, teacherSections]);

  useEffect(() => {
    if (!handledStudents.length) {
      setArRecords([]);
      return undefined;
    }
    const recordsByStudent = new Map();
    const unsubscribers = handledStudents.map((student) => onSnapshot(
      collection(db, 'users', student.id, 'experiment_activity'),
      (snapshot) => {
        recordsByStudent.set(student.id, snapshot.docs.map((item) => ({ id: item.id, studentId: student.id, ...item.data() })));
        setArRecords(Array.from(recordsByStudent.values()).flat());
      },
      (error) => console.warn(`Could not read AR participation for ${student.id}:`, error),
    ));
    return () => unsubscribers.forEach((unsubscribe) => unsubscribe());
  }, [handledStudents]);

  const pendingStudents = useMemo(() => students.filter((student) =>
    student.status === 'pending' && teacherHandlesStudent(teacherSections, student, sections)),
  [sections, students, teacherSections]);

  const ownedCourseIds = useMemo(() => new Set(courses.map((course) => course.id)), [courses]);
  const handledStudentIds = useMemo(() => new Set(handledStudents.map((student) => student.id)), [handledStudents]);
  const relevantAttempts = useMemo(() => latestQuizAttempts(attempts.filter((attempt) =>
    ownedCourseIds.has(attempt.courseId) && handledStudentIds.has(attempt.studentId))),
  [attempts, handledStudentIds, ownedCourseIds]);
  const classAverage = average(relevantAttempts.map((attempt) => percentage(attempt.score, attempt.totalQuestions)));
  const recentStudentResults = useMemo(() => {
    const experimentNames = new Map(experiments.map((experiment) => [experiment.id, experiment.title]));
    const quizResults = relevantAttempts.map((attempt) => ({
      id: `quiz-${attempt.id}`,
      studentId: attempt.studentId,
      fallbackStudentName: attempt.studentName || 'Student',
      type: 'Quiz',
      title: attempt.quizTitle || 'Quiz',
      date: attempt.submittedAt,
      scoreText: `${Number(attempt.score || 0)}/${Number(attempt.totalQuestions || 0)}`,
      result: percentage(attempt.score, attempt.totalQuestions),
    }));
    const arResults = arRecords.filter((record) => handledStudentIds.has(record.studentId) && record.completedAt).map((record) => {
      const score = Number(record.score ?? record.rubricScore ?? record.rubricScores?.total ?? 100);
      return {
        id: `ar-${record.studentId}-${record.id}`,
        studentId: record.studentId,
        fallbackStudentName: 'Student',
        type: 'AR Lab',
        title: record.experimentTitle || experimentNames.get(record.experimentId || record.id) || 'AR Experiment',
        date: record.completedAt,
        scoreText: `${Math.round(score)}/100`,
        result: score,
      };
    });
    return [...quizResults, ...arResults].sort((a, b) =>
      (timestampToDate(b.date)?.getTime() || 0) - (timestampToDate(a.date)?.getTime() || 0));
  }, [arRecords, experiments, handledStudentIds, relevantAttempts]);
  const participationRows = useMemo(() => handledStudents.map((student) => {
    const quizCount = attempts.filter((attempt) => ownedCourseIds.has(attempt.courseId) && attempt.studentId === student.id).length;
    const arCount = arRecords.filter((record) => record.studentId === student.id && (record.launchedAt || record.completedAt || record.completed)).length;
    return { id: student.id, name: student.name || 'Unnamed Student', avatarUrl: student.avatarUrl || '', section: (student.sections || []).join(', '), quizCount, arCount, total: quizCount + arCount };
  }).sort((a, b) => b.total - a.total || a.name.localeCompare(b.name)), [arRecords, attempts, handledStudents, ownedCourseIds]);
  const maxParticipation = Math.max(1, ...participationRows.map((student) => student.total));
  const quizParticipationTotal = participationRows.reduce((total, student) => total + student.quizCount, 0);
  const arParticipationTotal = participationRows.reduce((total, student) => total + student.arCount, 0);
  const activeStudentCount = participationRows.filter((student) => student.total > 0).length;
  const participationPageCount = Math.max(1, Math.ceil(participationRows.length / 6));
  const visibleParticipationRows = participationRows.slice((participationPage - 1) * 6, participationPage * 6);

  useEffect(() => {
    setParticipationPage((current) => Math.min(current, participationPageCount));
  }, [participationPageCount]);

  const recentContent = useMemo(() => courses.flatMap((course) => [
    ...(course.quizzes || []).map((quiz) => ({
      id: `${course.id}-quiz-${quiz.id}`,
      type: 'Quiz',
      title: quiz.title,
      course: course.title,
      date: quiz.createdAt,
    })),
    ...(course.modules || []).map((module) => ({
      id: `${course.id}-module-${module.id}`,
      type: 'Module',
      title: module.title,
      course: course.title,
      date: module.uploadedAt,
    })),
  ]).sort((a, b) => (b.date?.seconds || 0) - (a.date?.seconds || 0)).slice(0, 5), [courses]);

  return (
    <div className="teacher-page animate-fade-in">
      <div className="page-header teacher-page-header">
        <div>
          <span className="teacher-eyebrow"><GraduationCap size={16} /> Teacher Dashboard</span>
          <h1>Dashboard Overview</h1>
          <p>Welcome, {profile?.name || 'Teacher'}. Here is your current class overview.</p>
        </div>
        <div className="teacher-overview-header-tools">
          <TeacherDateTimeCalendar />
          <button type="button" className="teacher-handled-chip" onClick={() => setShowAssignments(true)} aria-label="View handled grade levels and sections">
            <span>Handled sections</span>
            <strong>{teacherSections.length ? teacherSections.join(', ') : 'Not assigned'}</strong>
            <ChevronRight size={18} />
          </button>
        </div>
      </div>

      <div className="teacher-stat-grid">
        <SummaryCard icon={Users} color="cyan" value={handledStudents.length} label="Handled Students" onClick={() => navigate('/students?status=approved')} />
        <SummaryCard icon={Clock3} color="orange" value={pendingStudents.length} label="Pending Approvals" onClick={() => navigate('/students?status=pending')} />
        <SummaryCard icon={BookOpen} color="green" value={courses.length} label="My Courses" onClick={() => navigate('/my-courses')} />
        <SummaryCard icon={TrendingUp} color="purple" value={`${classAverage.toFixed(0)}%`} label="Class Quiz Average" onClick={() => navigate('/student-progress')} />
      </div>

      <section className="glass-panel teacher-participation-card">
        <div className="teacher-section-title teacher-participation-heading">
          <div><BarChart3 size={21} /><div><h2>Student Participation</h2><p>Quiz submissions and AR Lab activities from your handled students.</p></div></div>
          <button type="button" onClick={() => navigate('/student-progress')}>View student progress</button>
        </div>
        <div className="teacher-participation-summary">
          <button type="button" onClick={() => setParticipationPopup('quiz')} aria-label="View student quiz submissions"><CheckCircle2 size={16} /><strong>{quizParticipationTotal}</strong> Quiz submissions</button>
          <button type="button" onClick={() => setParticipationPopup('ar')} aria-label="View student AR activities"><FlaskConical size={16} /><strong>{arParticipationTotal}</strong> AR activities</button>
          <button type="button" onClick={() => setParticipationPopup('active')} aria-label="View active students"><Activity size={16} /><strong>{activeStudentCount}/{handledStudents.length}</strong> Active students</button>
        </div>
        <div className="teacher-participation-legend"><span className="quiz">Quiz submissions</span><span className="ar">AR Lab activity</span></div>
        <div className="teacher-participation-chart">
          {visibleParticipationRows.map((student) => (
            <div className="teacher-participation-row" key={student.id}>
              <div className="teacher-participation-student"><strong>{student.name}</strong><span>{student.section ? `Section ${student.section}` : 'No section'}</span></div>
              <div className="teacher-participation-track" title={`${student.quizCount} quiz submissions, ${student.arCount} AR activities`}>
                {student.quizCount > 0 && <span className="quiz" style={{ width: `${(student.quizCount / maxParticipation) * 100}%` }} />}
                {student.arCount > 0 && <span className="ar" style={{ width: `${(student.arCount / maxParticipation) * 100}%` }} />}
                {student.total === 0 && <em>No recorded activity</em>}
              </div>
              <strong className="teacher-participation-total">{student.total}</strong>
            </div>
          ))}
          {participationRows.length === 0 && <EmptyLine text="Handled students will appear here after they are assigned to one of your courses." />}
        </div>
        {participationPageCount > 1 && <div className="teacher-participation-pagination">
          <button type="button" disabled={participationPage === 1} onClick={() => setParticipationPage((page) => page - 1)}><ChevronLeft size={16} /> Previous</button>
          <strong>{participationPage} / {participationPageCount}</strong>
          <button type="button" disabled={participationPage === participationPageCount} onClick={() => setParticipationPage((page) => page + 1)}>Next <ChevronRight size={16} /></button>
        </div>}
      </section>

      <div className="teacher-dashboard-columns">
        <section className="glass-panel teacher-section-card">
          <div className="teacher-section-title">
            <div><CheckCircle2 size={20} /><h2>Recent Student Results</h2></div>
            <span>{recentStudentResults.length} completed</span>
          </div>
          <div className="teacher-list">
            {recentStudentResults.slice(0, 6).map((record) => {
              const student = handledStudents.find((item) => item.id === record.studentId);
              return (
                <div className="teacher-list-row" key={record.id}>
                  <UserAvatar user={student || { name: record.fallbackStudentName }} />
                  <div className="teacher-list-copy">
                    <strong>{student?.name || record.fallbackStudentName}</strong>
                    <span>{record.type}: {record.title} · {formatDateTime(record.date)}</span>
                  </div>
                  <strong className={record.result >= 75 ? 'score-good' : 'score-low'}>{record.scoreText}</strong>
                </div>
              );
            })}
            {recentStudentResults.length === 0 && <EmptyLine text="No quiz or completed AR Lab results from your handled students yet." />}
          </div>
        </section>

        <section className="glass-panel teacher-section-card">
          <div className="teacher-section-title">
            <div><BookOpen size={20} /><h2>Recent Course Content</h2></div>
            <span>{courses.length} courses</span>
          </div>
          <div className="teacher-list">
            {recentContent.map((content) => (
              <div className="teacher-list-row" key={content.id}>
                <div className={`teacher-content-icon ${content.type.toLowerCase()}`}><BookOpen size={17} /></div>
                <div className="teacher-list-copy">
                  <strong>{content.title || `Untitled ${content.type}`}</strong>
                  <span>{content.type} in {content.course} · {formatDateTime(content.date)}</span>
                </div>
              </div>
            ))}
            {recentContent.length === 0 && <EmptyLine text="Your newly created modules and quizzes will appear here." />}
          </div>
        </section>
      </div>
      {participationPopup && <ParticipationDetailsModal type={participationPopup} rows={participationRows} onClose={() => setParticipationPopup(null)} />}
      {showAssignments && <TeacherAssignmentsModal grades={teachingGrades} sections={teacherSections} onClose={() => setShowAssignments(false)} />}
    </div>
  );
}

function TeacherAssignmentsModal({ grades, sections, onClose }) {
  return createPortal(<div className="teacher-modal-backdrop teacher-status-backdrop" onMouseDown={(event) => event.target === event.currentTarget && onClose()}>
    <div className="glass-panel teacher-modal teacher-content-modal compact teacher-assignments-modal">
      <div className="teacher-modal-header"><div><h2>Teaching Assignments</h2><p>Your assigned grade levels and handled sections.</p></div><button type="button" className="teacher-icon-btn" onClick={onClose} aria-label="Close teaching assignments"><X size={20} /></button></div>
      <div className="teacher-assignment-group"><span><GraduationCap size={19} /></span><div><small>Grade Level Teaching</small><div>{grades.length ? grades.map((grade) => <b key={grade}>{grade}</b>) : <strong>Not assigned</strong>}</div></div></div>
      <div className="teacher-assignment-group"><span><Users size={19} /></span><div><small>Sections Teaching</small><div>{sections.length ? sections.map((section) => <b key={section}>Section {section}</b>) : <strong>Not assigned</strong>}</div></div></div>
      <div className="teacher-modal-actions teacher-preview-file-actions"><button type="button" className="btn btn-secondary" onClick={onClose}>Close</button></div>
    </div>
  </div>, document.body);
}

function ParticipationDetailsModal({ type, rows, onClose }) {
  const settings = {
    quiz: { title: 'Quiz Submissions', description: 'Submissions made by your handled students.', icon: CheckCircle2, color: 'quiz' },
    ar: { title: 'AR Lab Activities', description: 'AR Lab participation recorded for your handled students.', icon: FlaskConical, color: 'ar' },
    active: { title: 'Active Students', description: 'Students with recorded quiz or AR Lab participation.', icon: Activity, color: 'active' },
  }[type];
  const visibleRows = type === 'quiz'
    ? rows.filter((student) => student.quizCount > 0)
    : type === 'ar'
      ? rows.filter((student) => student.arCount > 0)
      : rows;
  const Icon = settings.icon;
  return createPortal(
    <div className="teacher-modal-backdrop teacher-status-backdrop" onMouseDown={(event) => event.target === event.currentTarget && onClose()}>
      <div className="glass-panel teacher-modal teacher-content-modal compact teacher-participation-modal">
        <div className="teacher-modal-header">
          <div><div className={`teacher-participation-modal-icon ${settings.color}`}><Icon size={21} /></div><h2>{settings.title}</h2><p>{settings.description}</p></div>
          <button type="button" className="teacher-icon-btn" onClick={onClose} aria-label="Close participation details"><X size={20} /></button>
        </div>
        <div className="teacher-participation-modal-list">
          {visibleRows.map((student) => {
            const active = student.total > 0;
            const count = type === 'quiz' ? student.quizCount : type === 'ar' ? student.arCount : student.total;
            return <div className="teacher-participation-modal-row" key={student.id}>
              <UserAvatar user={student} />
              <div><strong>{student.name}</strong><span>{student.section ? `Section ${student.section}` : 'No section'}</span></div>
              {type === 'active'
                ? <em className={active ? 'active' : 'inactive'}>{active ? 'Active' : 'No activity'}</em>
                : <strong className={`teacher-participation-count ${settings.color}`}>{count}</strong>}
            </div>;
          })}
          {visibleRows.length === 0 && <div className="teacher-empty-line">No matching student activity has been recorded yet.</div>}
        </div>
        <div className="teacher-modal-actions teacher-preview-file-actions"><button type="button" className="btn btn-secondary" onClick={onClose}>Close</button></div>
      </div>
    </div>,
    document.body,
  );
}

function SummaryCard({ icon: Icon, color, value, label, onClick }) {
  return (
    <button type="button" className="glass-panel teacher-stat-card teacher-stat-link" onClick={onClick} aria-label={`Open ${label}`}>
      <div className={`teacher-stat-icon ${color}`}><Icon size={23} /></div>
      <strong>{value}</strong>
      <span>{label}</span>
      <small>View details →</small>
    </button>
  );
}

function EmptyLine({ text }) {
  return <div className="teacher-empty-line">{text}</div>;
}
