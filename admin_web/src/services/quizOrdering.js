export const timestampMillis = (value) => {
  if (!value) return 0;
  let millis;
  if (typeof value.toMillis === 'function') millis = value.toMillis();
  else if (typeof value.toDate === 'function') millis = value.toDate().getTime();
  else if (typeof value.seconds === 'number') millis = value.seconds * 1000 + (value.nanoseconds || 0) / 1000000;
  else if (typeof value._seconds === 'number') millis = value._seconds * 1000 + (value._nanoseconds || 0) / 1000000;
  else millis = value instanceof Date ? value.getTime() : new Date(value).getTime();
  return Number.isFinite(millis) ? millis : 0;
};

export const uploadTimestampMillis = (item) => timestampMillis(item.uploadedAt) || timestampMillis(item.createdAt);

export const newestQuizFirst = (first, second) => uploadTimestampMillis(second) - uploadTimestampMillis(first);

// Keep the stored index so archive actions still select the displayed quiz.
export const quizzesNewestFirst = (quizzes = []) => quizzes
  .map((quiz, index) => ({ quiz, index }))
  .sort((first, second) => newestQuizFirst(first.quiz, second.quiz));

export const modulesNewestFirst = (modules = []) => modules
  .map((module, index) => ({ module, index }))
  .sort((first, second) =>
    (timestampMillis(second.module.uploadedAt) || timestampMillis(second.module.createdAt))
    - (timestampMillis(first.module.uploadedAt) || timestampMillis(first.module.createdAt)));

// Sort individual uploads across every course, keeping their original addresses.
export const teacherUploadTimeline = (courses = []) => courses.flatMap((course) => {
  const modules = (course.modules || []).map((item, index) => ({ type: 'module', item, index, course, timestamp: uploadTimestampMillis(item) }));
  const quizzes = (course.quizzes || [])
    .map((item, index) => ({ type: 'quiz', item, index, course, timestamp: uploadTimestampMillis(item) }))
    .filter(({ item }) => !item.approvalStatus || item.approvalStatus === 'approved');
  return [...modules, ...quizzes];
}).sort((first, second) => second.timestamp - first.timestamp
  || String(first.course.id).localeCompare(String(second.course.id))
  || first.type.localeCompare(second.type)
  || first.index - second.index);

export const formatUploadTime = (millis) => millis ? new Intl.DateTimeFormat('en-PH', {
  timeZone: 'Asia/Manila', year: 'numeric', month: 'short', day: 'numeric',
  hour: 'numeric', minute: '2-digit', second: '2-digit', hour12: true, timeZoneName: 'short',
}).format(new Date(millis)) : 'Date not recorded';

export const teacherUploadGroups = (courses = []) => courses.map((course) => {
  const uploads = teacherUploadTimeline([course]);
  return {
    course,
    modules: uploads.filter((upload) => upload.type === 'module'),
    quizzes: uploads.filter((upload) => upload.type === 'quiz'),
    createdTimestamp: timestampMillis(course.createdAt),
  };
}).sort((first, second) => second.createdTimestamp - first.createdTimestamp
  || String(first.course.id).localeCompare(String(second.course.id)));
