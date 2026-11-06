import { useEffect, useMemo, useRef, useState } from 'react';
import { createPortal } from 'react-dom';
import { Timestamp, doc, onSnapshot, updateDoc } from 'firebase/firestore';
import { deleteObject, getDownloadURL, ref, uploadBytes } from 'firebase/storage';
import { useNavigate, useParams } from 'react-router-dom';
import {
  ArrowLeft, BookOpen, CalendarClock, Check, CheckCircle2, Download, FileText, HelpCircle,
  ChevronRight, Edit3, ListChecks, ListOrdered, Loader2, Paperclip, PenLine, Plus, TextCursorInput, ToggleLeft, Trash2, UploadCloud, WandSparkles, X,
} from 'lucide-react';
import { db, storage } from '../firebase';
import { formatDateTime } from '../services/teacherPortalUtils';
import { generateQuizFromModule } from '../services/aiQuizGenerator';

const QUESTION_TYPES = [
  { value: 'multipleChoice', label: 'Multiple Choice' },
  { value: 'trueFalse', label: 'True or False' },
  { value: 'identification', label: 'Identification' },
  { value: 'enumeration', label: 'Enumeration' },
];

const QUESTION_TYPE_DETAILS = {
  multipleChoice: { description: 'Students choose one correct answer from several options.', icon: ListChecks },
  trueFalse: { description: 'Students decide whether each statement is true or false.', icon: ToggleLeft },
  identification: { description: 'Students type a short answer that identifies the correct term.', icon: TextCursorInput },
  enumeration: { description: 'Students provide every item requested by the question.', icon: ListOrdered },
};

const newQuestion = (type = 'multipleChoice') => ({
  id: `${Date.now()}-${Math.random().toString(36).slice(2, 8)}`,
  question: '',
  type,
  options: type === 'trueFalse' ? ['True', 'False'] : type === 'multipleChoice' ? ['', '', '', ''] : [],
  correctIndex: 0,
  correctAnswers: type === 'enumeration' ? ['', ''] : type === 'identification' ? [''] : [],
  explanation: '',
});

const moduleType = (name = '') => {
  const extension = name.split('.').pop()?.toLowerCase();
  if (extension === 'pdf') return 'pdf';
  if (extension === 'ppt' || extension === 'pptx') return 'ppt';
  return 'doc';
};

const toDateTimeLocal = (value) => {
  const date = typeof value?.toDate === 'function' ? value.toDate() : value ? new Date(value) : null;
  if (!date || Number.isNaN(date.getTime())) return '';
  const local = new Date(date.getTime() - date.getTimezoneOffset() * 60000);
  return local.toISOString().slice(0, 16);
};

export default function TeacherCourseDetail({ user, profile }) {
  const { courseId } = useParams();
  const navigate = useNavigate();
  const [course, setCourse] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [activeTab, setActiveTab] = useState('quizzes');
  const [showQuizForm, setShowQuizForm] = useState(false);
  const [showQuizChoice, setShowQuizChoice] = useState(false);
  const [showQuizTypeSelection, setShowQuizTypeSelection] = useState(false);
  const [manualQuestionTypes, setManualQuestionTypes] = useState(['multipleChoice']);
  const [showAiQuizForm, setShowAiQuizForm] = useState(false);
  const [showModuleForm, setShowModuleForm] = useState(false);
  const [editModule, setEditModule] = useState(null);
  const [previewModule, setPreviewModule] = useState(null);
  const [viewQuiz, setViewQuiz] = useState(null);
  const [editQuiz, setEditQuiz] = useState(null);

  useEffect(() => onSnapshot(doc(db, 'courses', courseId), (snapshot) => {
    setCourse(snapshot.exists() ? { id: snapshot.id, ...snapshot.data() } : null);
    setLoading(false);
  }, (snapshotError) => {
    setError(snapshotError.message);
    setLoading(false);
  }), [courseId]);

  const ownsCourse = course?.teacherUid === user?.uid;
  const quizzes = useMemo(() => course?.quizzes || [], [course?.quizzes]);
  const modules = useMemo(() => course?.modules || [], [course?.modules]);

  const removeQuiz = async (quiz) => {
    if (!window.confirm(`Delete “${quiz.title}”? Student access and results view for this quiz will be removed.`)) return;
    try {
      await updateDoc(doc(db, 'courses', course.id), { quizzes: quizzes.filter((item) => item.id !== quiz.id) });
    } catch (deleteError) {
      window.alert(`Could not delete quiz: ${deleteError.message}`);
    }
  };

  const removeModule = async (module) => {
    if (!window.confirm(`Delete module “${module.title}”?`)) return;
    try {
      await updateDoc(doc(db, 'courses', course.id), { modules: modules.filter((item) => item.id !== module.id) });
      if (module.storagePath) await deleteObject(ref(storage, module.storagePath)).catch(() => {});
    } catch (deleteError) {
      window.alert(`Could not delete module: ${deleteError.message}`);
    }
  };

  if (loading) return <div className="teacher-detail-loading"><Loader2 className="animate-spin" /> Loading course...</div>;
  if (error || !course) return <CourseMessage title="Course unavailable" message={error || 'This course no longer exists.'} onBack={() => navigate('/my-courses')} />;
  if (!ownsCourse) return <CourseMessage title="Access denied" message="You can manage only courses created by your teacher account." onBack={() => navigate('/my-courses')} />;

  return (
    <div className="teacher-page animate-fade-in teacher-course-detail">
      <button className="btn btn-secondary teacher-back-button" onClick={() => navigate('/my-courses')}><ArrowLeft size={18} /> Back to Courses</button>
      <div className="teacher-course-detail-header">
        <div className="teacher-content-icon course"><BookOpen size={24} /></div>
        <div><span className="teacher-eyebrow">Teacher-owned course</span><h1>{course.title}</h1><p>{course.subject} · {course.grade} · Sections {(course.sections || []).join(', ')}</p></div>
      </div>

      <div className="teacher-content-tabs">
        <button className={activeTab === 'quizzes' ? 'active' : ''} onClick={() => setActiveTab('quizzes')}><HelpCircle size={18} /> Quizzes <span>{quizzes.length}</span></button>
        <button className={activeTab === 'modules' ? 'active' : ''} onClick={() => setActiveTab('modules')}><FileText size={18} /> Modules <span>{modules.length}</span></button>
      </div>

      <section className="glass-panel teacher-course-content-panel">
        <div className="teacher-section-title">
          <div>{activeTab === 'quizzes' ? <HelpCircle size={21} /> : <Paperclip size={21} />}<h2>{activeTab === 'quizzes' ? 'Course Quizzes' : 'Attached Modules'}</h2></div>
          <button className="btn btn-primary" onClick={() => activeTab === 'quizzes' ? setShowQuizChoice(true) : setShowModuleForm(true)}>
            <Plus size={18} /> {activeTab === 'quizzes' ? 'Create Quiz' : 'Attach Module / File'}
          </button>
        </div>

        {activeTab === 'quizzes' ? (
          <div className="teacher-content-list">
            {quizzes.map((quiz) => <QuizRow key={quiz.id} quiz={quiz} onOpen={() => setViewQuiz(quiz)} onEdit={() => setEditQuiz(quiz)} onDelete={() => removeQuiz(quiz)} />)}
            {quizzes.length === 0 && <ContentEmpty icon={HelpCircle} text="No quizzes yet. Create the first quiz for this course." />}
          </div>
        ) : (
          <div className="teacher-content-list">
            {modules.map((module) => <ModuleRow key={module.id} module={module} onView={() => setPreviewModule(module)} onEdit={() => setEditModule(module)} onDelete={() => removeModule(module)} />)}
            {modules.length === 0 && <ContentEmpty icon={FileText} text="No modules attached yet. Upload a PDF, Word document, or presentation." />}
          </div>
        )}
      </section>

      {showQuizForm && <QuizModal course={course} quizzes={quizzes} questionTypes={manualQuestionTypes} onClose={() => setShowQuizForm(false)} />}
      {showQuizChoice && <QuizCreationChoiceModal hasModules={modules.some((module) => module.url && ['pdf', 'doc', 'ppt'].includes(module.fileType))} onClose={() => setShowQuizChoice(false)} onManual={() => { setShowQuizChoice(false); setShowQuizTypeSelection(true); }} onAi={() => { setShowQuizChoice(false); setShowAiQuizForm(true); }} />}
      {showQuizTypeSelection && <QuizTypeSelectionModal initialTypes={manualQuestionTypes} onClose={() => setShowQuizTypeSelection(false)} onConfirm={(types) => { setManualQuestionTypes(types); setShowQuizTypeSelection(false); setShowQuizForm(true); }} />}
      {showAiQuizForm && <AiQuizModal course={course} quizzes={quizzes} modules={modules} onClose={() => setShowAiQuizForm(false)} onGenerated={(quiz) => { setShowAiQuizForm(false); setViewQuiz(quiz); }} />}
      {editQuiz && <QuizModal course={course} quizzes={quizzes} quiz={editQuiz} onClose={() => setEditQuiz(null)} />}
      {viewQuiz && <QuizPreviewModal quiz={viewQuiz} onClose={() => setViewQuiz(null)} onEdit={() => { setViewQuiz(null); setEditQuiz(viewQuiz); }} />}
      {showModuleForm && <ModuleModal course={course} modules={modules} user={user} profile={profile} onClose={() => setShowModuleForm(false)} />}
      {editModule && <ModuleModal course={course} modules={modules} user={user} profile={profile} module={editModule} onClose={() => setEditModule(null)} />}
      {previewModule && <ModulePreviewModal module={previewModule} onClose={() => setPreviewModule(null)} />}
    </div>
  );
}

function QuizRow({ quiz, onOpen, onEdit, onDelete }) {
  return (
    <article className="teacher-content-row teacher-quiz-row" role="button" tabIndex={0} onClick={onOpen} onKeyDown={(event) => { if (event.key === 'Enter' || event.key === ' ') onOpen(); }}>
      <div className="teacher-content-icon quiz"><HelpCircle size={19} /></div>
      <div><strong>{quiz.title || 'Untitled Quiz'}</strong><span>{(quiz.questions || []).length} questions · Created {formatDateTime(quiz.createdAt)}</span>{quiz.dueDate && <small><CalendarClock size={14} /> Due {formatDateTime(quiz.dueDate)}</small>}</div>
      <div className="teacher-action-row">
        <button className="teacher-icon-btn edit" onClick={(event) => { event.stopPropagation(); onEdit(); }} title="Edit quiz"><Edit3 size={17} /></button>
        <button className="teacher-icon-btn danger" onClick={(event) => { event.stopPropagation(); onDelete(); }} title="Delete quiz"><Trash2 size={17} /></button>
        <ChevronRight className="teacher-row-chevron" size={19} />
      </div>
    </article>
  );
}

function QuizPreviewModal({ quiz, onClose, onEdit }) {
  return <PortalModal title={quiz.title || 'Quiz Details'} subtitle={`${(quiz.questions || []).length} questions · Created ${formatDateTime(quiz.createdAt)}`} onClose={onClose} wide>
    <div className="teacher-quiz-preview-summary">
      <div><span>Directions</span><p>{quiz.directions || 'No directions were added.'}</p></div>
      <div><span>Due Date</span><strong>{quiz.dueDate ? formatDateTime(quiz.dueDate) : 'No due date'}</strong></div>
    </div>
    <div className="teacher-quiz-preview-list">
      {(quiz.questions || []).map((question, index) => {
        const questionType = question.type || 'multipleChoice';
        const typeLabel = QUESTION_TYPES.find((type) => type.value === questionType)?.label || 'Multiple Choice';
        const correctAnswers = questionType === 'multipleChoice' || questionType === 'trueFalse'
          ? [question.options?.[question.correctIndex] || 'Not set']
          : question.correctAnswers || [];
        return <article className="teacher-preview-question" key={question.id || index}>
          <div className="teacher-preview-question-title"><span>{index + 1}</span><div><small>{typeLabel}</small><strong>{question.question || 'Question text not set'}</strong></div></div>
          {(questionType === 'multipleChoice' || questionType === 'trueFalse') && <div className="teacher-preview-options">{(question.options || []).map((option, optionIndex) => <div className={optionIndex === question.correctIndex ? 'correct' : ''} key={optionIndex}>{optionIndex === question.correctIndex && <CheckCircle2 size={15} />}{option}</div>)}</div>}
          {(questionType === 'identification' || questionType === 'enumeration') && <div className="teacher-preview-answer"><span>Correct {correctAnswers.length === 1 ? 'answer' : 'answers'}</span><strong>{correctAnswers.join(', ') || 'Not set'}</strong></div>}
          {question.explanation && <p className="teacher-preview-explanation"><strong>Explanation:</strong> {question.explanation}</p>}
        </article>;
      })}
      {(!quiz.questions || quiz.questions.length === 0) && <ContentEmpty icon={HelpCircle} text="This quiz has no questions." />}
    </div>
    <div className="teacher-modal-actions teacher-preview-actions"><button type="button" className="btn btn-secondary" onClick={onClose}>Close</button><button type="button" className="btn btn-primary" onClick={onEdit}><Edit3 size={17} /> Edit Quiz</button></div>
  </PortalModal>;
}

function QuizCreationChoiceModal({ hasModules, onClose, onManual, onAi }) {
  return <PortalModal title="Create Quiz" subtitle="Choose how you want to build this quiz." onClose={onClose}>
    <div className="teacher-quiz-methods">
      <button type="button" onClick={onManual}>
        <div className="teacher-method-icon manual"><PenLine size={26} /></div>
        <div><strong>Create Manually</strong><span>Write questions and answers yourself using one or more question types.</span></div>
        <ChevronRight size={20} />
      </button>
      <button type="button" onClick={onAi} disabled={!hasModules}>
        <div className="teacher-method-icon ai"><WandSparkles size={26} /></div>
        <div><strong>AI Quiz Generator</strong><span>{hasModules ? 'Let Gemini read an attached module and generate a quiz.' : 'Attach a PDF, Word, or PowerPoint module first.'}</span></div>
        <ChevronRight size={20} />
      </button>
    </div>
  </PortalModal>;
}

function QuizTypeSelectionModal({ initialTypes, onClose, onConfirm }) {
  const [selected, setSelected] = useState(initialTypes || []);
  const toggle = (type) => setSelected((current) => current.includes(type) ? current.filter((item) => item !== type) : [...current, type]);
  return <PortalModal title="Choose Quiz Types" subtitle="Select one or more question types." onClose={onClose}>
    <div className="teacher-quiz-type-selector">
      {QUESTION_TYPES.map((type) => {
        const selectedType = selected.includes(type.value);
        const Icon = QUESTION_TYPE_DETAILS[type.value].icon;
        return <button type="button" className={selectedType ? 'selected' : ''} key={type.value} aria-pressed={selectedType} onClick={() => toggle(type.value)}>
          <div className="teacher-quiz-type-icon"><Icon size={22} /></div>
          <div><strong>{type.label}</strong><span>{QUESTION_TYPE_DETAILS[type.value].description}</span></div>
          <div className="teacher-type-check">{selectedType && <Check size={15} strokeWidth={3} />}</div>
        </button>;
      })}
    </div>
    <div className="teacher-modal-actions teacher-type-actions"><button type="button" className="btn btn-secondary" onClick={onClose}>Cancel</button><button type="button" className="btn btn-primary" disabled={!selected.length} onClick={() => onConfirm(selected)}>{selected.length ? `Continue with ${selected.length} type${selected.length === 1 ? '' : 's'}` : 'Select a type'}</button></div>
  </PortalModal>;
}

function AiQuizModal({ course, quizzes, modules, onClose, onGenerated }) {
  const supportedModules = modules.filter((module) => module.url && ['pdf', 'doc', 'ppt'].includes(module.fileType));
  const [moduleId, setModuleId] = useState(supportedModules[0]?.id || '');
  const [questionCounts, setQuestionCounts] = useState({ multipleChoice: 5, trueFalse: 0, identification: 0, enumeration: 0 });
  const [generating, setGenerating] = useState(false);
  const [status, setStatus] = useState('');
  const [error, setError] = useState('');
  const abortRef = useRef(null);
  useEffect(() => () => abortRef.current?.abort(), []);
  const totalQuestions = Object.values(questionCounts).reduce((total, count) => total + Number(count || 0), 0);

  const toggleType = (type) => setQuestionCounts((current) => {
    if (current[type] > 0) return { ...current, [type]: 0 };
    const currentTotal = Object.values(current).reduce((total, count) => total + Number(count || 0), 0);
    const remaining = 20 - currentTotal;
    return remaining > 0 ? { ...current, [type]: Math.min(5, remaining) } : current;
  });
  const stepCount = (type, direction) => setQuestionCounts((current) => {
    const currentTotal = Object.values(current).reduce((total, count) => total + Number(count || 0), 0);
    const next = direction > 0
      ? currentTotal < 20 ? current[type] + 1 : current[type]
      : Math.max(1, current[type] - 1);
    return { ...current, [type]: next };
  });
  const close = () => {
    abortRef.current?.abort();
    onClose();
  };
  const generate = async (event) => {
    event.preventDefault();
    const selectedModule = supportedModules.find((module) => module.id === moduleId);
    if (!selectedModule) { setError('Select an attached module.'); return; }
    if (totalQuestions < 1 || totalQuestions > 20) { setError('Choose between 1 and 20 total questions.'); return; }
    setGenerating(true);
    setError('');
    setStatus('Downloading and reading the selected module...');
    const controller = new AbortController();
    abortRef.current = controller;
    try {
      const generated = await generateQuizFromModule({ module: selectedModule, questionCounts, signal: controller.signal, onProgress: setStatus });
      controller.signal.throwIfAborted();
      setStatus('Saving the generated quiz...');
      const savedQuiz = { ...generated, id: `ai-quiz-${Date.now()}`, createdAt: Timestamp.now(), dueDate: null };
      await updateDoc(doc(db, 'courses', course.id), { quizzes: [savedQuiz, ...quizzes] });
      onGenerated(savedQuiz);
    } catch (generationError) {
      if (generationError.name !== 'AbortError') setError(generationError.message || 'AI quiz generation failed. Please try again.');
    } finally {
      abortRef.current = null;
      setGenerating(false);
      setStatus('');
    }
  };

  return <PortalModal title="AI Quiz Generator" subtitle="Select a module and customize the generated quiz." onClose={close}>
    <form onSubmit={generate}>
      {error && <div className="teacher-form-error">{error}</div>}
      <Field label="Module"><div className="teacher-ai-module-select"><FileText size={19} /><select value={moduleId} onChange={(event) => setModuleId(event.target.value)} disabled={generating}>{supportedModules.map((module) => <option value={module.id} key={module.id}>{module.title}</option>)}</select></div></Field>

      <div className="teacher-ai-question-types">
        <h3>Question Types</h3>
        {QUESTION_TYPES.map((type) => {
          const selected = questionCounts[type.value] > 0;
          return <button type="button" className={selected ? 'selected' : ''} key={type.value} disabled={generating} onClick={() => toggleType(type.value)}><span>{type.label}</span><span className="teacher-ai-checkbox">{selected && <CheckCircle2 size={18} />}</span></button>;
        })}
      </div>

      <div className="teacher-ai-count-header"><h3>Number of items for each type</h3><strong>{totalQuestions}/20 total</strong></div>
      <div className="teacher-ai-steppers">
        {QUESTION_TYPES.filter((type) => questionCounts[type.value] > 0).map((type) => <div key={type.value}><span>{type.label}</span><div><button type="button" aria-label={`Remove one ${type.label} question`} disabled={generating || questionCounts[type.value] <= 1} onClick={() => stepCount(type.value, -1)}>&minus;</button><strong>{questionCounts[type.value]}</strong><button type="button" aria-label={`Add one ${type.label} question`} disabled={generating || totalQuestions >= 20} onClick={() => stepCount(type.value, 1)}>+</button></div></div>)}
      </div>
      {generating && <div className="teacher-ai-progress"><Loader2 className="animate-spin" size={24} /><div><strong>AI is working...</strong><span>{status}</span></div></div>}
      <div className="teacher-modal-actions teacher-sticky-actions"><button type="button" className="btn btn-secondary" onClick={close}>{generating ? 'Cancel Generation' : 'Cancel'}</button><button className="btn btn-primary" disabled={generating || totalQuestions < 1}>{generating ? <><Loader2 className="animate-spin" size={17} /> Generating...</> : <><WandSparkles size={17} /> Generate Quiz</>}</button></div>
    </form>
  </PortalModal>;
}

function ModuleRow({ module, onView, onEdit, onDelete }) {
  return (
    <article className="teacher-content-row">
      <div className="teacher-content-icon module"><FileText size={19} /></div>
      <div><strong>{module.title || 'Untitled Module'}</strong><span>{String(module.fileType || 'file').toUpperCase()} · Uploaded {formatDateTime(module.uploadedAt)}</span>{module.description && <small>{module.description}</small>}</div>
      <div className="teacher-action-row">{module.url && <button type="button" className="btn btn-secondary" onClick={onView}>View File</button>}<button className="teacher-icon-btn edit" onClick={onEdit} title="Edit module"><Edit3 size={17} /></button><button className="teacher-icon-btn danger" onClick={onDelete} title="Delete module"><Trash2 size={17} /></button></div>
    </article>
  );
}

const moduleFileName = (module) => {
  const storageName = module.storagePath?.split('/').pop()?.replace(/^module-\d+_\d+_/, '');
  if (storageName && storageName.includes('.')) return storageName;
  const title = module.title || 'module';
  return title.includes('.') ? title : `${title}.${module.fileType || 'pdf'}`;
};

async function downloadModuleFile(module) {
  const response = await fetch(module.url);
  if (!response.ok) throw new Error(`Download failed (${response.status}).`);
  const blobUrl = URL.createObjectURL(await response.blob());
  const anchor = document.createElement('a');
  anchor.href = blobUrl;
  anchor.download = moduleFileName(module);
  document.body.appendChild(anchor);
  anchor.click();
  anchor.remove();
  window.setTimeout(() => URL.revokeObjectURL(blobUrl), 1000);
}

function ModulePreviewModal({ module, onClose }) {
  const isPdf = module.fileType === 'pdf';
  const [previewUrl, setPreviewUrl] = useState(isPdf ? '' : `https://docs.google.com/gview?embedded=1&url=${encodeURIComponent(module.url)}`);
  const [loadingPreview, setLoadingPreview] = useState(isPdf);
  const [previewError, setPreviewError] = useState('');

  useEffect(() => {
    if (!isPdf) return undefined;
    let objectUrl = '';
    let cancelled = false;
    setLoadingPreview(true);
    setPreviewError('');
    fetch(module.url)
      .then((response) => {
        if (!response.ok) throw new Error(`Preview failed (${response.status}).`);
        return response.blob();
      })
      .then((blob) => {
        if (cancelled) return;
        objectUrl = URL.createObjectURL(new Blob([blob], { type: 'application/pdf' }));
        setPreviewUrl(objectUrl);
      })
      .catch((error) => { if (!cancelled) setPreviewError(error.message || 'Could not load the preview.'); })
      .finally(() => { if (!cancelled) setLoadingPreview(false); });
    return () => {
      cancelled = true;
      if (objectUrl) URL.revokeObjectURL(objectUrl);
    };
  }, [isPdf, module.url]);

  return <PortalModal title={module.title || 'Module Preview'} subtitle={`${String(module.fileType || 'file').toUpperCase()} module`} onClose={onClose} wide>
    <div className="teacher-module-preview">
      {loadingPreview && <div className="teacher-preview-status"><Loader2 className="animate-spin" size={30} /><span>Loading file preview...</span></div>}
      {previewError && <div className="teacher-preview-status error"><FileText size={32} /><strong>Preview unavailable</strong><span>{previewError}</span></div>}
      {!loadingPreview && !previewError && previewUrl && <iframe src={previewUrl} title={`${module.title || 'Module'} preview`} />}
    </div>
    <div className="teacher-modal-actions teacher-preview-file-actions"><button type="button" className="btn btn-secondary" onClick={onClose}>Close</button><button type="button" className="btn btn-primary" onClick={() => downloadModuleFile(module).catch(() => window.open(module.url, '_blank', 'noopener,noreferrer'))}><Download size={17} /> Download</button></div>
  </PortalModal>;
}

function QuizModal({ course, quizzes, onClose, quiz = null, questionTypes = QUESTION_TYPES.map((type) => type.value) }) {
  const [title, setTitle] = useState(quiz?.title || '');
  const [directions, setDirections] = useState(quiz?.directions || '');
  const [dueDate, setDueDate] = useState(toDateTimeLocal(quiz?.dueDate));
  const [questions, setQuestions] = useState(() => quiz?.questions?.length
    ? quiz.questions.map((question) => {
      const type = question.type || 'multipleChoice';
      return { ...newQuestion(type), ...question, type, options: [...(question.options || [])], correctAnswers: [...(question.correctAnswers || [])] };
    })
    : questionTypes.map((type) => newQuestion(type)));
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');

  const updateQuestion = (index, changes) => setQuestions((items) => items.map((item, itemIndex) => itemIndex === index ? { ...item, ...changes } : item));
  const changeType = (index, type) => setQuestions((items) => items.map((item, itemIndex) => itemIndex === index ? { ...newQuestion(type), id: item.id, question: item.question, explanation: item.explanation } : item));
  const removeQuestion = (index) => setQuestions((items) => items.filter((_, itemIndex) => itemIndex !== index));

  const validate = () => {
    if (!title.trim()) return 'Enter a quiz title.';
    if (!questions.length) return 'Add at least one question.';
    for (let index = 0; index < questions.length; index += 1) {
      const question = questions[index];
      if (!question.question.trim()) return `Enter the text for question ${index + 1}.`;
      if ((question.type === 'multipleChoice' || question.type === 'trueFalse') && question.options.some((option) => !option.trim())) return `Complete every option for question ${index + 1}.`;
      if ((question.type === 'identification' || question.type === 'enumeration') && question.correctAnswers.some((answer) => !answer.trim())) return `Complete every correct answer for question ${index + 1}.`;
    }
    return '';
  };

  const save = async (event) => {
    event.preventDefault();
    const validationError = validate();
    if (validationError) { setError(validationError); return; }
    setSaving(true);
    try {
      const savedQuiz = {
        id: quiz?.id || `quiz-${Date.now()}`,
        title: title.trim(),
        directions: directions.trim(),
        dueDate: dueDate ? Timestamp.fromDate(new Date(dueDate)) : null,
        createdAt: quiz?.createdAt || Timestamp.now(),
        questions: questions.map((question) => ({
          ...question,
          question: question.question.trim(),
          options: question.options.map((option) => option.trim()),
          correctAnswers: question.correctAnswers.map((answer) => answer.trim()),
          explanation: question.explanation.trim(),
        })),
      };
      const updatedQuizzes = quiz
        ? quizzes.map((item) => item.id === quiz.id ? savedQuiz : item)
        : [...quizzes, savedQuiz];
      await updateDoc(doc(db, 'courses', course.id), { quizzes: updatedQuizzes });
      onClose();
    } catch (saveError) {
      setError(`Could not create quiz: ${saveError.message}`);
    } finally { setSaving(false); }
  };

  return <PortalModal title={quiz ? 'Edit Quiz' : 'Create Quiz'} subtitle={quiz ? 'Update this quiz. Changes will sync to assigned students.' : 'Build a mixed-question quiz for your handled students.'} onClose={onClose} wide>
    <form onSubmit={save}>
      {error && <div className="teacher-form-error">{error}</div>}
      <div className="teacher-form-grid"><Field label="Quiz Title"><input className="input-field" value={title} onChange={(event) => setTitle(event.target.value)} placeholder="e.g. Atomic Structure Quiz" /></Field><Field label="Due Date (Optional)"><input className="input-field" type="datetime-local" value={dueDate} onChange={(event) => setDueDate(event.target.value)} /></Field></div>
      <Field label="Directions"><textarea className="input-field teacher-textarea" value={directions} onChange={(event) => setDirections(event.target.value)} placeholder="Enter directions students should read before answering." /></Field>
      <div className="teacher-quiz-builder-heading"><h3>Questions</h3><button type="button" className="btn btn-secondary" onClick={() => setQuestions((items) => [...items, newQuestion(questionTypes[0] || 'multipleChoice')])}><Plus size={16} /> Add Question</button></div>
      <div className="teacher-question-list">{questions.map((question, index) => <QuestionEditor key={question.id} question={question} index={index} allowedTypes={questionTypes} update={(changes) => updateQuestion(index, changes)} changeType={(type) => changeType(index, type)} remove={() => removeQuestion(index)} canRemove={questions.length > 1} />)}</div>
      <ModalActions onClose={onClose} saving={saving} saveText={quiz ? 'Save Changes' : 'Save Quiz'} />
    </form>
  </PortalModal>;
}

function QuestionEditor({ question, index, allowedTypes, update, changeType, remove, canRemove }) {
  const setOption = (optionIndex, value) => update({ options: question.options.map((option, indexValue) => indexValue === optionIndex ? value : option) });
  const setAnswer = (answerIndex, value) => update({ correctAnswers: question.correctAnswers.map((answer, indexValue) => indexValue === answerIndex ? value : answer) });
  return <div className="teacher-question-editor">
    <div className="teacher-question-header"><strong>Question {index + 1}</strong><select className="input-field" value={question.type} onChange={(event) => changeType(event.target.value)}>{QUESTION_TYPES.filter((type) => allowedTypes.includes(type.value)).map((type) => <option value={type.value} key={type.value}>{type.label}</option>)}</select>{canRemove && <button type="button" className="teacher-icon-btn danger" onClick={remove}><Trash2 size={16} /></button>}</div>
    <Field label="Question"><textarea className="input-field teacher-textarea compact" value={question.question} onChange={(event) => update({ question: event.target.value })} placeholder="Enter the question text" /></Field>
    {(question.type === 'multipleChoice' || question.type === 'trueFalse') && <div className="teacher-answer-options"><span className="input-label">Answer Options (select the correct answer)</span>{question.options.map((option, optionIndex) => <label key={optionIndex}><input type="radio" name={`correct-${question.id}`} checked={question.correctIndex === optionIndex} onChange={() => update({ correctIndex: optionIndex })} /><input className="input-field" value={option} readOnly={question.type === 'trueFalse'} onChange={(event) => setOption(optionIndex, event.target.value)} placeholder={`Option ${String.fromCharCode(65 + optionIndex)}`} /></label>)}</div>}
    {(question.type === 'identification' || question.type === 'enumeration') && <div className="teacher-correct-answers"><span className="input-label">Correct {question.type === 'enumeration' ? 'Answers' : 'Answer'}</span>{question.correctAnswers.map((answer, answerIndex) => <div key={answerIndex}><input className="input-field" value={answer} onChange={(event) => setAnswer(answerIndex, event.target.value)} placeholder={`Answer ${answerIndex + 1}`} />{question.type === 'enumeration' && question.correctAnswers.length > 1 && <button type="button" className="teacher-icon-btn danger" onClick={() => update({ correctAnswers: question.correctAnswers.filter((_, itemIndex) => itemIndex !== answerIndex) })}><X size={15} /></button>}</div>)}{question.type === 'enumeration' && <button type="button" className="teacher-add-answer" onClick={() => update({ correctAnswers: [...question.correctAnswers, ''] })}><Plus size={15} /> Add another answer</button>}</div>}
    <Field label="Explanation (Optional)"><textarea className="input-field teacher-textarea compact" value={question.explanation} onChange={(event) => update({ explanation: event.target.value })} placeholder="Explain why the answer is correct" /></Field>
  </div>;
}

function ModuleModal({ course, modules, user, profile, module = null, onClose }) {
  const fileInputRef = useRef(null);
  const [title, setTitle] = useState(module?.title || '');
  const [description, setDescription] = useState(module?.description || '');
  const [file, setFile] = useState(null);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');

  const save = async (event) => {
    event.preventDefault();
    if (module && !file) { setError('Select a replacement file.'); return; }
    if (!module && (!title.trim() || !file)) { setError('Enter a module title and select a supported file.'); return; }
    setSaving(true);
    const id = module?.id || `module-${Date.now()}`;
    try {
      let replacement = null;
      if (file) {
        const safeName = file.name.replace(/[^a-zA-Z0-9._-]/g, '_');
        const storagePath = `course_modules/${course.id}/${id}_${Date.now()}_${safeName}`;
        const storageRef = ref(storage, storagePath);
        await uploadBytes(storageRef, file, { contentType: file.type || undefined });
        replacement = { fileType: moduleType(file.name), fileSizeBytes: file.size, url: await getDownloadURL(storageRef), storagePath };
      }
      const savedModule = {
        ...(module || {}),
        id,
        title: module ? file.name : title.trim(),
        description: module ? (module.description || '') : description.trim(),
        uploadedByUid: module?.uploadedByUid || user.uid,
        uploadedByName: module?.uploadedByName || profile?.name || user.displayName || 'Teacher',
        uploadedAt: module?.uploadedAt || Timestamp.now(),
        ...(replacement || {}),
      };
      const updatedModules = module
        ? modules.map((item) => item.id === module.id ? savedModule : item)
        : [...modules, savedModule];
      await updateDoc(doc(db, 'courses', course.id), { modules: updatedModules });
      if (replacement && module?.storagePath && module.storagePath !== replacement.storagePath) {
        await deleteObject(ref(storage, module.storagePath)).catch(() => {});
      }
      onClose();
    } catch (saveError) {
      setError(`Could not ${module ? 'update' : 'attach'} module: ${saveError.message}`);
    } finally { setSaving(false); }
  };

  return <PortalModal title={module ? 'Replace Module File' : 'Attach Module / File'} subtitle={module ? '' : 'Upload a learning file that students can open in the mobile app.'} onClose={onClose} compact={Boolean(module)}>
    <form onSubmit={save}>
      {error && <div className="teacher-form-error">{error}</div>}
      {!module && <><Field label="Module Title"><input className="input-field" value={title} onChange={(event) => setTitle(event.target.value)} placeholder="e.g. Introduction to Organic Compounds" /></Field><Field label="Description"><textarea className="input-field teacher-textarea" value={description} onChange={(event) => setDescription(event.target.value)} placeholder="Brief description of this module" /></Field></>}
      <button type="button" className={`teacher-file-drop ${file ? 'selected' : ''}`} onClick={() => fileInputRef.current?.click()}><UploadCloud size={34} /><strong>{file ? file.name : module ? 'Tap to select a replacement file' : 'Choose a file'}</strong><span>{module ? 'The file name will be used as the module name.' : 'PDF, DOC, DOCX, PPT, or PPTX'}</span></button>
      <input ref={fileInputRef} type="file" hidden accept=".pdf,.doc,.docx,.ppt,.pptx" onChange={(event) => setFile(event.target.files?.[0] || null)} />
      <ModalActions onClose={onClose} saving={saving} saveText={module ? 'Save' : 'Attach Module'} />
    </form>
  </PortalModal>;
}

function PortalModal({ title, subtitle, onClose, children, wide = false, compact = false }) {
  return createPortal(<div className="teacher-modal-backdrop teacher-status-backdrop" onMouseDown={(event) => event.target === event.currentTarget && onClose()}><div className={`glass-panel teacher-modal teacher-content-modal ${wide ? 'wide' : ''} ${compact ? 'compact' : ''}`}><div className="teacher-modal-header"><div><h2>{title}</h2>{subtitle && <p>{subtitle}</p>}</div><button className="teacher-icon-btn" onClick={onClose}><X size={20} /></button></div>{children}</div></div>, document.body);
}

function Field({ label, children }) { return <label className="input-group"><span className="input-label">{label}</span>{children}</label>; }
function ModalActions({ onClose, saving, saveText }) { return <div className="teacher-modal-actions teacher-sticky-actions"><button type="button" className="btn btn-secondary" onClick={onClose} disabled={saving}>Cancel</button><button className="btn btn-primary" disabled={saving}>{saving ? <><Loader2 className="animate-spin" size={17} /> Saving...</> : <><CheckCircle2 size={17} /> {saveText}</>}</button></div>; }
function ContentEmpty({ icon: Icon, text }) { return <div className="teacher-empty-state"><Icon size={38} /><strong>No content yet</strong><span>{text}</span></div>; }
function CourseMessage({ title, message, onBack }) { return <div className="teacher-empty-state" style={{ minHeight: '70vh' }}><BookOpen size={44} /><strong>{title}</strong><span>{message}</span><button className="btn btn-primary" onClick={onBack}><ArrowLeft size={18} /> Back to Courses</button></div>; }
