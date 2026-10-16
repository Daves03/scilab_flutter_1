import { useState, useEffect } from 'react';
import { collection, collectionGroup, getDocs, onSnapshot } from 'firebase/firestore';
import { db } from '../firebase';
import { Activity, Clock, Box, BookOpen, Search, PlusCircle, FilePlus, HelpCircle, CheckCircle, ChevronLeft, ChevronRight } from 'lucide-react';

export default function ActivityLogs() {
  const [logs, setLogs] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [filterType, setFilterType] = useState('all');
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 15;

  useEffect(() => {
    setCurrentPage(1);
  }, [searchQuery, filterType]);

  useEffect(() => {
    let disposed = false;
    let requestVersion = 0;

    async function fetchActivities(usersMap, version) {
      try {
        // Fetch activity records and resolve every display name by stable uid.
        const activities = [];
        try {
          const expSnap = await getDocs(collectionGroup(db, 'experiment_activity'));
          expSnap.forEach(doc => {
            const data = doc.data();
            const uid = doc.ref.parent.parent?.id;
            const user = uid ? usersMap[uid] : null;
            
            if (data.launchedAt) {
              activities.push({
                id: `${doc.id}-launch`,
                uid,
                userName: user?.name || user?.displayName || 'Unknown User',
                userRole: user?.role === 'teacher' ? 'teacher' : (user?.role || 'student'),
                type: 'experiment_launch',
                title: doc.id,
                timestamp: data.launchedAt?.toDate ? data.launchedAt.toDate() : (data.launchedAt ? new Date(data.launchedAt) : new Date()),
              });
            }
            if (data.completedAt) {
              activities.push({
                id: `${doc.id}-complete`,
                uid,
                userName: user?.name || user?.displayName || 'Unknown User',
                userRole: user?.role === 'teacher' ? 'teacher' : (user?.role || 'student'),
                type: 'experiment_complete',
                title: doc.id,
                timestamp: data.completedAt?.toDate ? data.completedAt.toDate() : (data.completedAt ? new Date(data.completedAt) : new Date()),
              });
            }
          });
        } catch (e) {
          console.warn("Could not fetch experiment_activity (might need index):", e);
        }

        // 3. Fetch all module activities
        try {
          const modSnap = await getDocs(collectionGroup(db, 'module_activity'));
          modSnap.forEach(doc => {
            const data = doc.data();
            const uid = doc.ref.parent.parent?.id;
            const user = uid ? usersMap[uid] : null;
            
            if (data.openedAt) {
              activities.push({
                id: `${doc.id}-open`,
                uid,
                userName: user?.name || user?.displayName || 'Unknown User',
                userRole: user?.role === 'teacher' ? 'teacher' : (user?.role || 'student'),
                type: 'module_open',
                title: data.moduleTitle || doc.id,
                timestamp: data.openedAt?.toDate ? data.openedAt.toDate() : (data.openedAt ? new Date(data.openedAt) : new Date()),
              });
            }
          });
        } catch (e) {
          console.warn("Could not fetch module_activity (might need index):", e);
        }

        // 4. Fetch all courses (for teacher activities: course/module/quiz creation)
        try {
          const coursesSnap = await getDocs(collection(db, 'courses'));
          coursesSnap.forEach(doc => {
            const course = doc.data();
            const uid = course.teacherUid;
            const user = uid ? usersMap[uid] : null;
            
            if (course.createdAt) {
              activities.push({
                id: `${doc.id}-course-create`,
                uid,
                userName: user?.name || course.teacherName || 'Unknown Teacher',
                userRole: user?.role || 'teacher',
                type: 'course_created',
                title: course.title || 'Untitled Course',
                timestamp: course.createdAt?.toDate ? course.createdAt.toDate() : (course.createdAt ? new Date(course.createdAt) : new Date()),
              });
            }

            if (course.modules && Array.isArray(course.modules)) {
              course.modules.forEach(mod => {
                if (mod.uploadedAt) {
                  activities.push({
                    id: `${doc.id}-module-${mod.id || mod.title}`,
                    uid,
                    userName: user?.name || course.teacherName || 'Unknown Teacher',
                    userRole: user?.role || 'teacher',
                    type: 'module_added',
                    title: mod.title || 'Untitled Module',
                    timestamp: mod.uploadedAt?.toDate ? mod.uploadedAt.toDate() : (mod.uploadedAt ? new Date(mod.uploadedAt) : new Date()),
                  });
                }
              });
            }

            if (course.quizzes && Array.isArray(course.quizzes)) {
              course.quizzes.forEach(quiz => {
                if (quiz.createdAt) {
                  activities.push({
                    id: `${doc.id}-quiz-${quiz.id || quiz.title}`,
                    uid,
                    userName: user?.name || course.teacherName || 'Unknown Teacher',
                    userRole: user?.role || 'teacher',
                    type: 'quiz_added',
                    title: quiz.title || 'Untitled Quiz',
                    timestamp: quiz.createdAt?.toDate ? quiz.createdAt.toDate() : (quiz.createdAt ? new Date(quiz.createdAt) : new Date()),
                  });
                }
              });
            }
          });
        } catch (e) {
          console.warn("Could not fetch courses:", e);
        }

        // 5. Fetch all quiz attempts (student quiz submissions)
        try {
          const attemptsSnap = await getDocs(collection(db, 'quiz_attempts'));
          attemptsSnap.forEach(doc => {
            const data = doc.data();
            const uid = data.studentId;
            const user = uid ? usersMap[uid] : null;

            const scoreText = (data.score !== undefined && data.totalQuestions !== undefined && data.totalQuestions > 0)
              ? ` (${data.score}/${data.totalQuestions})`
              : '';

            activities.push({
              id: `${doc.id}-attempt`,
              uid,
              userName: user?.name || user?.displayName || data.studentName || user?.email || 'Unknown Student',
              userRole: user?.role === 'teacher' ? 'teacher' : (user?.role || 'student'),
              type: 'quiz_submitted',
              title: `${data.quizTitle || 'Quiz'}${scoreText}`,
              timestamp: data.submittedAt?.toDate ? data.submittedAt.toDate() : (data.submittedAt ? new Date(data.submittedAt) : new Date()),
            });
          });
        } catch (e) {
          console.warn("Could not fetch quiz_attempts:", e);
        }

        // Sort descending by timestamp
        activities.sort((a, b) => b.timestamp - a.timestamp);
        
        if (!disposed && version === requestVersion) {
          setLogs(activities);
        }
      } catch (e) {
        console.error("Error fetching activities:", e);
      } finally {
        if (!disposed && version === requestVersion) {
          setLoading(false);
        }
      }
    }

    const unsubscribe = onSnapshot(
      collection(db, 'users'),
      (usersSnap) => {
        const usersMap = {};
        usersSnap.forEach(doc => {
          usersMap[doc.id] = doc.data();
        });
        const version = ++requestVersion;
        fetchActivities(usersMap, version);
      },
      (error) => {
        console.error('Could not watch user names:', error);
        setLoading(false);
      },
    );

    return () => {
      disposed = true;
      unsubscribe();
    };
  }, []);

  const getActionInfo = (type) => {
    switch(type) {
      case 'experiment_launch':
        return { text: 'Launched AR Experiment', color: '#60a5fa', icon: <Box size={16} /> };
      case 'experiment_complete':
        return { text: 'Completed AR Experiment', color: '#34d399', icon: <Box size={16} /> };
      case 'module_open':
        return { text: 'Opened Module', color: '#a78bfa', icon: <BookOpen size={16} /> };
      case 'course_created':
        return { text: 'Created Course', color: '#f59e0b', icon: <PlusCircle size={16} /> };
      case 'module_added':
        return { text: 'Added Module', color: '#ec4899', icon: <FilePlus size={16} /> };
      case 'quiz_added':
        return { text: 'Added Quiz', color: '#8b5cf6', icon: <HelpCircle size={16} /> };
      case 'quiz_submitted':
        return { text: 'Answered Quiz', color: '#10b981', icon: <CheckCircle size={16} /> };
      default:
        return { text: 'Unknown Action', color: '#888', icon: <Activity size={16} /> };
    }
  };

  const filteredLogs = logs.filter(log => {
    const actionInfo = getActionInfo(log.type);

    // Filter by search query
    let searchMatch = true;
    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase();
      searchMatch = 
        log.userName.toLowerCase().includes(q) || 
        log.title.toLowerCase().includes(q) ||
        log.userRole.toLowerCase().includes(q) ||
        actionInfo.text.toLowerCase().includes(q);
    }
    
    // Filter by type
    let typeMatch = true;
    if (filterType === 'experiments') {
      typeMatch = log.type.startsWith('experiment');
    } else if (filterType === 'modules') {
      typeMatch = log.type === 'module_open' || log.type === 'module_added';
    } else if (filterType === 'courses') {
      typeMatch = log.type === 'course_created';
    } else if (filterType === 'added_quizzes' || filterType === 'quizzes') {
      typeMatch = log.type === 'quiz_added';
    } else if (filterType === 'student_quizzes') {
      typeMatch = log.type === 'quiz_submitted';
    }

    return searchMatch && typeMatch;
  });

  const totalPages = Math.max(1, Math.ceil(filteredLogs.length / itemsPerPage));
  const startIndex = (currentPage - 1) * itemsPerPage;
  const paginatedLogs = filteredLogs.slice(startIndex, startIndex + itemsPerPage);

  return (
    <div className="animate-fade-in">
      <div className="page-header">
        <div>
          <h1>Activity Logs</h1>
          <p>Monitor user activity across AR experiments, modules, and quizzes.</p>
        </div>
      </div>

      <div className="glass-panel" style={{ padding: '24px' }}>
        <div className="flex-mobile-col" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px', gap: '16px' }}>
          
          <div className="flex-mobile-col mobile-w-full" style={{ display: 'flex', gap: '12px', alignItems: 'center', width: '100%' }}>
            <div className="input-group mobile-w-full" style={{ marginBottom: 0, flex: 1, maxWidth: '400px' }}>
              <div style={{ position: 'relative' }}>
                <Search size={18} style={{ position: 'absolute', left: '12px', top: '50%', transform: 'translateY(-50%)', color: 'var(--text-secondary)' }} />
                <input 
                  className="input-field mobile-w-full"
                  style={{ padding: '8px 12px 8px 36px', margin: 0, width: '100%' }}
                  placeholder="Search user, role or activity..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                />
              </div>
            </div>
            
            <select 
              className="input-field mobile-w-full" 
              style={{ width: '180px', padding: '8px 12px', margin: 0 }}
              value={filterType}
              onChange={(e) => setFilterType(e.target.value)}
            >
              <option value="all">All Activities</option>
              <option value="experiments">AR Experiments</option>
              <option value="modules">Modules</option>
              <option value="courses">Courses</option>
              <option value="added_quizzes">Added Quizzes</option>
              <option value="student_quizzes">Answered Quizzes</option>
            </select>
          </div>
        </div>

        {loading ? (
          <div style={{ padding: '40px', textAlign: 'center', color: 'var(--text-secondary)' }}>
            Loading activity logs...
          </div>
        ) : filteredLogs.length === 0 ? (
          <div style={{ padding: '40px', textAlign: 'center', color: 'var(--text-secondary)' }}>
            No activity logs found.
          </div>
        ) : (
          <>
            <div style={{ overflowX: 'auto' }}>
              <table className="data-table">
                <thead>
                  <tr>
                    <th>User</th>
                    <th>Role</th>
                    <th>Action</th>
                    <th>Activity Details</th>
                    <th style={{ textAlign: 'right' }}>Time</th>
                  </tr>
                </thead>
                <tbody>
                  {paginatedLogs.map(log => {
                    const actionInfo = getActionInfo(log.type);
                    return (
                      <tr key={log.id}>
                        <td>
                          <div style={{ fontWeight: 600, color: 'var(--text-primary)' }}>
                            {log.userName}
                          </div>
                        </td>
                        <td>
                          <span className="badge badge-role">
                            {log.userRole}
                          </span>
                        </td>
                        <td>
                          <div style={{ display: 'flex', alignItems: 'center', gap: '8px', color: actionInfo.color }}>
                            {actionInfo.icon}
                            <span style={{ fontSize: '0.9rem', fontWeight: 500 }}>{actionInfo.text}</span>
                          </div>
                        </td>
                        <td style={{ color: 'var(--text-primary)' }}>
                          {log.title}
                        </td>
                        <td style={{ textAlign: 'right', color: 'var(--text-secondary)', fontSize: '0.9rem' }}>
                          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'flex-end', gap: '6px' }}>
                            <Clock size={14} />
                            {log.timestamp.toLocaleString()}
                          </div>
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>

            {filteredLogs.length > 0 && (
              <div style={{
                display: 'flex',
                justifyContent: 'space-between',
                alignItems: 'center',
                marginTop: '20px',
                paddingTop: '16px',
                borderTop: '1px solid var(--border-light)',
                flexWrap: 'wrap',
                gap: '12px',
              }}>
                <div style={{ color: 'var(--text-secondary)', fontSize: '0.9rem' }}>
                  Showing <span style={{ color: 'var(--text-primary)', fontWeight: 600 }}>{startIndex + 1}</span> to <span style={{ color: 'var(--text-primary)', fontWeight: 600 }}>{Math.min(startIndex + itemsPerPage, filteredLogs.length)}</span> of <span style={{ color: 'var(--text-primary)', fontWeight: 600 }}>{filteredLogs.length}</span> activities
                </div>

                <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <button
                    className="btn btn-secondary"
                    style={{
                      padding: '8px 16px',
                      fontSize: '0.85rem',
                      opacity: currentPage === 1 ? 0.4 : 1,
                      cursor: currentPage === 1 ? 'not-allowed' : 'pointer',
                    }}
                    onClick={() => setCurrentPage(prev => Math.max(prev - 1, 1))}
                    disabled={currentPage === 1}
                  >
                    <ChevronLeft size={16} />
                    Previous
                  </button>

                  <span style={{ color: 'var(--text-primary)', fontSize: '0.9rem', fontWeight: 500, padding: '0 8px' }}>
                    Page {currentPage} of {totalPages}
                  </span>

                  <button
                    className="btn btn-secondary"
                    style={{
                      padding: '8px 16px',
                      fontSize: '0.85rem',
                      opacity: currentPage >= totalPages ? 0.4 : 1,
                      cursor: currentPage >= totalPages ? 'not-allowed' : 'pointer',
                    }}
                    onClick={() => setCurrentPage(prev => Math.min(prev + 1, totalPages))}
                    disabled={currentPage >= totalPages}
                  >
                    Next
                    <ChevronRight size={16} />
                  </button>
                </div>
              </div>
            )}
          </>
        )}
      </div>
    </div>
  );
}
