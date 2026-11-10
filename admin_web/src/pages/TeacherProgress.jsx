import { useEffect, useMemo, useState } from 'react';
import { createPortal } from 'react-dom';
import { collection, onSnapshot, query, where } from 'firebase/firestore';
import { Activity, BarChart3, BookOpenCheck, ChevronDown, FlaskConical, Info, Search, Trophy, Users, X } from 'lucide-react';
import { db } from '../firebase';
import UserAvatar from '../components/UserAvatar';
import { AR_RUBRIC_CRITERIA, arRecordScore, arPerformanceLevel, normalizeArRubric, isGradedArRecord } from '../services/arProgressAssessment';
import {
  average,
  courseMatchesStudent,
  formatDateTime,
  gradeLabelForRole,
  latestQuizAttempts,
  percentage,
  teacherHandlesStudent,
} from '../services/teacherPortalUtils';

export default function TeacherProgress({ user, profile }) {
  const [students, setStudents] = useState([]);
  const [sections, setSections] = useState([]);
  const [courses, setCourses] = useState([]);
  const [attempts, setAttempts] = useState([]);
  const [arRecords, setArRecords] = useState([]);
  const [experiments, setExperiments] = useState([]);
  const [details, setDetails] = useState(null);
  const [search, setSearch] = useState('');
  const [sectionFilter, setSectionFilter] = useState('all');
  const [progressTab, setProgressTab] = useState('quizzes');
  const teacherSections = useMemo(() => profile?.sections || [], [profile?.sections]);

  useEffect(() => {
    if (!user?.uid) return undefined;
    const unsubscribers = [
      onSnapshot(collection(db, 'users'), (snapshot) => setStudents(snapshot.docs.map((item) => ({ id: item.id, ...item.data() })))),
      onSnapshot(collection(db, 'sections'), (snapshot) => setSections(snapshot.docs.map((item) => ({ id: item.id, ...item.data() })))),
      onSnapshot(query(collection(db, 'courses'), where('teacherUid', '==', user.uid)), (snapshot) => setCourses(snapshot.docs.map((item) => ({ id: item.id, ...item.data() })))),
      onSnapshot(collection(db, 'quiz_attempts'), (snapshot) => setAttempts(snapshot.docs.map((item) => ({ id: item.id, ...item.data() })))),
      onSnapshot(collection(db, 'ar_experiments'), (snapshot) => setExperiments(snapshot.docs.map((item) => ({ id: item.id, ...item.data() })))),
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
      (error) => console.warn(`Could not read AR records for ${student.id}:`, error),
    ));
    return () => unsubscribers.forEach((unsubscribe) => unsubscribe());
  }, [handledStudents]);
  const ownedCourseIds = useMemo(() => new Set(courses.map((course) => course.id)), [courses]);
  const latestAttempts = useMemo(() => latestQuizAttempts(attempts.filter((attempt) => ownedCourseIds.has(attempt.courseId))), [attempts, ownedCourseIds]);

  const summaries = useMemo(() => handledStudents.map((student) => {
    const quizAttempts = latestAttempts.filter((attempt) => attempt.studentId === student.id).sort((a, b) => (b.submittedAt?.seconds || 0) - (a.submittedAt?.seconds || 0));
    const quizAverage = average(quizAttempts.map((attempt) => percentage(attempt.score, attempt.totalQuestions)));
    const studentAr = arRecords.filter((record) => record.studentId === student.id).map((record) => ({
      ...record,
      experimentTitle: record.experimentTitle || experiments.find((experiment) => experiment.id === (record.experimentId || record.id))?.title || 'Unknown Experiment',
    })).sort((a, b) => ((b.completedAt || b.launchedAt)?.seconds || 0) - ((a.completedAt || a.launchedAt)?.seconds || 0));
    const completedAr = studentAr.filter((record) => record.completed === true || record.completedAt);
    const gradedAr = completedAr.filter(isGradedArRecord);
    const arAverage = average(gradedAr.map(arRecordScore));
    const overall = average([quizAverage, arAverage].filter((value, index) => index === 0 ? quizAttempts.length : gradedAr.length));
    return { ...student, quizAttempts, quizAverage, arRecords: studentAr, arAverage, arTries: studentAr.length, completedAr: completedAr.length, overall };
  }), [arRecords, experiments, handledStudents, latestAttempts]);

  const visible = summaries.filter((student) => {
    const text = `${student.name} ${student.studentNumber}`.toLowerCase();
    return text.includes(search.toLowerCase()) && (sectionFilter === 'all' || (student.sections || []).includes(sectionFilter));
  });

  return (
    <div className="teacher-page animate-fade-in">
      <div className="page-header teacher-page-header"><div><span className="teacher-eyebrow"><BarChart3 size={16} /> Live learning data</span><h1>Student Progress</h1><p>Quiz and AR Lab results for students who belong to your courses.</p></div></div>
      <section className="glass-panel teacher-progress-browser">
        <div className="teacher-progress-controls">
          <label className="teacher-progress-filter">
            <Users size={18} />
            <select value={sectionFilter} onChange={(event) => setSectionFilter(event.target.value)}>
              <option value="all">All Sections</option>
              {teacherSections.map((section) => <option value={section} key={section}>Section {section}</option>)}
            </select>
          </label>
          <label className="teacher-search teacher-progress-search"><Search size={18} /><input value={search} onChange={(event) => setSearch(event.target.value)} placeholder="Search by student name or ID" /></label>
          <div className="teacher-progress-tab-switch" role="tablist" aria-label="Student progress record type">
            <button type="button" role="tab" aria-selected={progressTab === 'quizzes'} className={progressTab === 'quizzes' ? 'active' : ''} onClick={() => setProgressTab('quizzes')}><BookOpenCheck size={17} /> Quiz Results</button>
            <button type="button" role="tab" aria-selected={progressTab === 'ar'} className={progressTab === 'ar' ? 'active' : ''} onClick={() => setProgressTab('ar')}><FlaskConical size={17} /> AR Lab Records</button>
          </div>
        </div>

        <div className="teacher-progress-student-list">
          {visible.map((student) => {
            const recordCount = progressTab === 'quizzes' ? student.quizAttempts.length : student.arRecords.length;
            const recordLabel = progressTab === 'quizzes'
              ? `${recordCount} ${recordCount === 1 ? 'Quiz' : 'Quizzes'}`
              : `${recordCount} ${recordCount === 1 ? 'Experiment' : 'Experiments'}`;
            return (
              <button
                type="button"
                className={`teacher-progress-student-row ${progressTab}`}
                key={student.id}
                onClick={() => setDetails({ type: progressTab === 'quizzes' ? 'quizzes' : 'arRecords', student })}
              >
                <UserAvatar user={student} large />
                <span className="teacher-progress-student-copy">
                  <strong>{student.name || 'Unnamed Student'}</strong>
                  <b>{student.studentNumber ? `#${student.studentNumber}` : 'No student number'}</b>
                  <small>{gradeLabelForRole(student.role)} · Section {(student.sections || []).join(', ') || 'Not assigned'}</small>
                </span>
                <span className="teacher-progress-count-badge">{recordLabel}</span>
              </button>
            );
          })}
          {visible.length === 0 && <div className="teacher-empty-state teacher-grid-empty"><Users size={40} /><strong>No student progress found</strong><span>Approved students must match both the grade and section of one of your courses.</span></div>}
        </div>
      </section>
      {details && <StudentProgressDetailsModal type={details.type} student={summaries.find((student) => student.id === details.student.id) || details.student} onClose={() => setDetails(null)} />}
    </div>
  );
}

function StudentProgressDetailsModal({ type, student, onClose }) {
  const [expandedRubrics, setExpandedRubrics] = useState({});
  const settings = {
    quizAverage: { title: 'Quiz Average', label: 'Quiz Average', value: `${student.quizAverage.toFixed(0)}%`, icon: Trophy, tone: 'quiz', note: 'This is the average of the latest score from each completed quiz.', records: [], averageOnly: true },
    quizzes: { title: 'Quiz Results', label: 'Completed Quizzes', value: student.quizAttempts.length, icon: BookOpenCheck, tone: 'quiz-count', note: 'Each result shows the quiz score and its submission date and time.', records: student.quizAttempts },
    arScore: { title: 'AR Scores', label: 'AR Score', value: `${student.arAverage.toFixed(0)}%`, icon: FlaskConical, tone: 'ar', note: 'All AR Lab records are shown newest first. Started activities without a completed score appear as 0.', records: student.arRecords },
    arRecords: { title: 'AR Lab Records', label: 'AR Records', value: student.arRecords.length, icon: FlaskConical, tone: 'ar', note: 'Each AR Lab record shows its score and most recent completion or launch date and time.', records: student.arRecords },
    arTries: { title: 'AR Lab Tries', label: 'AR Tries', value: student.arTries, icon: Activity, tone: 'ar-count', note: 'Each recorded AR Lab attempt is shown with its status, date, and time.', records: student.arRecords },
  }[type];
  const SummaryIcon = settings.icon;
  return createPortal(<div className="teacher-modal-backdrop teacher-status-backdrop" onMouseDown={(event) => event.target === event.currentTarget && onClose()}>
    <div className="glass-panel teacher-modal teacher-content-modal teacher-progress-detail-modal">
      <div className="teacher-modal-header">
        <div><h2>{student.name || 'Student'}&apos;s {settings.title}</h2><p>{gradeLabelForRole(student.role)} · Section {(student.sections || []).join(', ') || 'Not assigned'}</p></div>
        <button type="button" className="teacher-icon-btn" onClick={onClose} aria-label="Close student progress details"><X size={20} /></button>
      </div>
      <div className="teacher-progress-detail-summary single">
        <div className={settings.tone}><SummaryIcon size={21} /><strong>{settings.value}</strong><span>{settings.label}</span></div>
      </div>
      <div className="teacher-progress-detail-note"><Info size={16} /><span>{settings.note}</span></div>
      {!settings.averageOnly && <div className="teacher-progress-record-list">
        {settings.records.map((record) => {
          const quizRecord = type === 'quizzes';
          const tryRecord = type === 'arTries';
          const completed = record.completed === true || Boolean(record.completedAt);
          const graded = quizRecord || isGradedArRecord(record);
          const score = quizRecord ? percentage(record.score, record.totalQuestions) : arRecordScore(record);
          const scoreText = quizRecord ? `${record.score || 0}/${record.totalQuestions || 0}` : !graded ? 'Not graded' : tryRecord ? (completed ? 'Completed' : 'Started') : `${score.toFixed(1)}/100`;
          const title = quizRecord ? (record.quizTitle || 'Quiz') : record.experimentTitle;
          const date = quizRecord ? record.submittedAt : (record.completedAt || record.launchedAt);
          const rubricScores = !quizRecord ? normalizeArRubric(record.rubricScores) : null;
          const hasRubric = graded && rubricScores && Object.keys(rubricScores).length > 0;
          const rubricExpanded = Boolean(expandedRubrics[record.id]);
          const scoreTone = quizRecord ? (score >= 75 ? 'good' : score > 0 ? 'mid' : 'low') : score >= 80 ? 'good' : score >= 70 ? 'mid' : 'low';
          return <article className="teacher-progress-record" key={record.id}>
            <div><strong>{title}</strong><span>{formatDateTime(date)}</span></div>
            <strong className={!graded ? '' : tryRecord ? (completed ? 'score-good' : 'score-mid') : `score-${scoreTone}`}>{scoreText}</strong>
            {graded && !quizRecord && !tryRecord && <span className={`teacher-ar-performance score-${scoreTone}`}>{arPerformanceLevel(score)}</span>}
            {graded && !tryRecord && <div className="teacher-progress-record-bar"><span className={scoreTone} style={{ width: `${Math.min(100, score)}%` }} /></div>}
            {hasRubric && <div className="teacher-rubric-section">
              <button type="button" className={rubricExpanded ? 'expanded' : ''} onClick={() => setExpandedRubrics((current) => ({ ...current, [record.id]: !current[record.id] }))} aria-expanded={rubricExpanded}>
                <span>Rubric Breakdown</span><ChevronDown size={17} />
              </button>
              {rubricExpanded && <div className="teacher-rubric-breakdown">
                <p>Each category is worth 25 points (100 points total).</p>
                {AR_RUBRIC_CRITERIA.map(([key, label, maximum]) => <div key={key}><span>{label}</span><strong>{rubricScores[key] ?? '—'}/{maximum}</strong></div>)}
                <div className="total"><span>Total</span><strong>{score.toFixed(0)}/100</strong></div>
                <p>PPE: required items correctly selected on the first attempt ÷ required items × 25, rounded, minus 1 per unnecessary item (minimum 0).</p>
                <p>Procedure: 25 points minus 5 per sequence error and 2 per equipment error (minimum 0).</p>
                <p>Results: whether the expected scientific outcome was produced.</p>
                <p>Understanding: correct answers ÷ total questions × 25, rounded.</p>
                {rubricScores.legacyConverted === 1
                  ? <p>Historical category scores converted to the current 25-point weights; this is not a new assessment.</p>
                  : <>
                    {('sequenceErrors' in rubricScores || 'equipmentErrors' in rubricScores) && <p>Recorded errors: {rubricScores.sequenceErrors ?? 0} sequence, {rubricScores.equipmentErrors ?? 0} equipment.</p>}
                    {'totalUnderstandingQuestions' in rubricScores && <p>Understanding answers: {rubricScores.correctUnderstandingAnswers ?? 0}/{rubricScores.totalUnderstandingQuestions}.</p>}
                  </>}
              </div>}
            </div>}
          </article>;
        })}
        {settings.records.length === 0 && <div className="teacher-progress-detail-empty"><SummaryIcon size={38} /><span>No {type === 'quizzes' ? 'completed quizzes' : type === 'arScore' || type === 'arRecords' ? 'AR Lab records' : 'AR Lab tries'} yet.</span></div>}
      </div>}
      <div className="teacher-modal-actions teacher-preview-file-actions"><button type="button" className="btn btn-secondary" onClick={onClose}>Close</button></div>
    </div>
  </div>, document.body);
}

