import { STUDENT_ROLES, gradeLabelForRole, gradeNumber, normalizeSection } from './teacherPortalUtils.js';

const matchesSection = (name, section) => {
  const embeddedGrade = gradeNumber(name);
  return normalizeSection(name) === normalizeSection(section.name)
    && (embeddedGrade == null || section.gradeNumber == null || embeddedGrade === section.gradeNumber);
};

export function teacherSectionSummaries(assignments = [], catalog = [], users = []) {
  const assigned = new Map();
  assignments.forEach((name) => {
    if (!normalizeSection(name)) return;
    const matches = catalog.filter((section) => matchesSection(name, {
      ...section, gradeNumber: gradeNumber(section.grade),
    }));
    const sections = matches.length ? matches.filter((section) => !section.isTrashed) : [{ name }];
    sections.forEach((section) => {
      const number = gradeNumber(section.grade) ?? gradeNumber(name);
      const key = `${number || ''}:${normalizeSection(section.name)}`;
      assigned.set(key, { key, name: section.name, gradeNumber: number, grade: number ? `Grade ${number}` : 'Grade not set' });
    });
  });

  return [...assigned.values()].map((section) => {
    const students = users.filter((user) => STUDENT_ROLES.includes(user.role)
      && (section.gradeNumber == null || gradeNumber(gradeLabelForRole(user.role)) === section.gradeNumber)
      && (user.sections || []).some((name) => matchesSection(name, section)));
    return {
      ...section,
      students,
      total: students.length,
      approved: students.filter((student) => student.status === 'approved').length,
      pending: students.filter((student) => student.status === 'pending').length,
      rejected: students.filter((student) => student.status === 'rejected').length,
    };
  }).sort((a, b) => (a.gradeNumber || 0) - (b.gradeNumber || 0)
    || a.name.localeCompare(b.name, undefined, { numeric: true }));
}
