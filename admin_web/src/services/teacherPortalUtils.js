export const STUDENT_ROLES = ['grade9', 'grade10'];

export const gradeLabelForRole = (role) => {
  if (role === 'grade9') return 'Grade 9';
  if (role === 'grade10') return 'Grade 10';
  return '';
};

export const timestampToDate = (value) => {
  if (!value) return null;
  if (typeof value.toDate === 'function') return value.toDate();
  const parsed = new Date(value);
  return Number.isNaN(parsed.getTime()) ? null : parsed;
};

export const formatDateTime = (value) => {
  const date = timestampToDate(value);
  if (!date) return 'Not available';
  return new Intl.DateTimeFormat('en-PH', {
    dateStyle: 'medium',
    timeStyle: 'short',
  }).format(date);
};

export const gradeNumber = (value) => {
  const match = String(value || '').match(/(?:^|\D)(9|10)(?:\D|$)/);
  return match ? Number(match[1]) : null;
};

export const normalizeSection = (value) => String(value || '')
  .trim()
  .toLowerCase()
  .replace(/^(?:section|sec\.?)\s*/, '')
  .replace(/^(?:(?:grade|g)\s*)?(?:9|10)\s*(?:[-:/.]|\s)\s*/, '')
  .replace(/[^a-z0-9]+/g, '');

export const sectionsOverlap = (left = [], right = []) => {
  const keys = new Set(left.map(normalizeSection).filter(Boolean));
  return right.some((section) => keys.has(normalizeSection(section)));
};

export const teacherHandlesStudent = (teacherSections = [], student = {}, sectionCatalog = []) => {
  if (!STUDENT_ROLES.includes(student.role) || !sectionsOverlap(teacherSections, student.sections || [])) {
    return false;
  }

  const studentGrade = gradeNumber(gradeLabelForRole(student.role));
  const matchingTeacherSections = sectionCatalog.filter((section) =>
    teacherSections.some((name) => normalizeSection(name) === normalizeSection(section.name)),
  );
  if (matchingTeacherSections.length === 0) return true;

  return matchingTeacherSections.some((section) => {
    const sectionGrade = gradeNumber(section.grade);
    return sectionGrade == null || sectionGrade === studentGrade;
  });
};

export const teacherGradeLabels = (teacherSections = [], sectionCatalog = []) => {
  const grades = new Set();
  sectionCatalog.forEach((section) => {
    if (teacherSections.some((name) => normalizeSection(name) === normalizeSection(section.name))) {
      const number = gradeNumber(section.grade);
      if (number) grades.add(`Grade ${number}`);
    }
  });
  teacherSections.forEach((section) => {
    const number = gradeNumber(section);
    if (number) grades.add(`Grade ${number}`);
  });
  return [...grades].sort();
};

export const courseMatchesStudent = (course = {}, student = {}) => {
  const studentGrade = gradeNumber(gradeLabelForRole(student.role));
  const courseGrade = gradeNumber(course.grade);
  return studentGrade != null
    && studentGrade === courseGrade
    && sectionsOverlap(course.sections || course.assignedSections || [], student.sections || []);
};

export const latestQuizAttempts = (attempts = []) => {
  const latest = new Map();
  attempts.forEach((attempt) => {
    const key = `${attempt.studentId || ''}:${attempt.quizId || attempt.id || ''}`;
    const current = latest.get(key);
    const candidateTime = timestampToDate(attempt.submittedAt)?.getTime() || 0;
    const currentTime = timestampToDate(current?.submittedAt)?.getTime() || 0;
    if (!current || candidateTime >= currentTime) latest.set(key, attempt);
  });
  return [...latest.values()];
};

export const percentage = (score, total) => total > 0 ? (Number(score || 0) / Number(total)) * 100 : 0;

export const average = (values = []) => values.length
  ? values.reduce((sum, value) => sum + value, 0) / values.length
  : 0;
