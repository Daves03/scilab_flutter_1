import { gradeLabelForRole, gradeNumber, normalizeSection, teacherGradeLabels } from './teacherPortalUtils.js';

export function activityUserSections(user, grade, catalog) {
  const sections = Array.isArray(user.sections) ? user.sections : [];
  if (grade === 'all' || user.role !== 'teacher') return sections;
  return sections.filter(name => {
    const matches = catalog.filter(section => normalizeSection(section.name) === normalizeSection(name));
    return matches.some(section => gradeNumber(section.grade) === gradeNumber(grade))
      || (matches.length === 0 && gradeNumber(name) === gradeNumber(grade));
  });
}

export function matchesActivityUser(user, { role = 'all', grade = 'all', section = 'all' }, catalog = []) {
  const userRole = ['grade9', 'grade10', 'student'].includes(user.role) ? 'student' : user.role;
  if (role !== 'all' && userRole !== role) return false;
  const grades = user.role === 'teacher'
    ? teacherGradeLabels(user.sections || [], catalog)
    : [gradeLabelForRole(user.role)];
  if (grade !== 'all' && !grades.includes(grade)) return false;
  return section === 'all' || activityUserSections(user, grade, catalog).includes(section);
}
