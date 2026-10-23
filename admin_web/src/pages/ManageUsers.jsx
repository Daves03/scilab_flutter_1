import { useState, useEffect } from 'react';
import { collection, onSnapshot, doc, updateDoc, getDocs } from 'firebase/firestore';
import { sendPasswordResetEmail } from 'firebase/auth';
import { db, auth } from '../firebase';
import { logAdminActivity } from '../services/adminActivityService';
import { CheckCircle, XCircle, Key, RefreshCcw, AlertTriangle, Search, Edit, ChevronLeft, ChevronRight } from 'lucide-react';

const timestampToMillis = (value) => {
  if (!value) return 0;
  if (typeof value.toMillis === 'function') return value.toMillis();
  if (typeof value.toDate === 'function') return value.toDate().getTime();
  if (typeof value === 'number') return value;
  if (typeof value === 'string') {
    const parsed = Date.parse(value);
    return Number.isNaN(parsed) ? 0 : parsed;
  }
  if (typeof value.seconds === 'number') {
    return (value.seconds * 1000) + Math.floor((value.nanoseconds || 0) / 1000000);
  }
  return 0;
};

const newestRegistrationFirst = (first, second) => {
  const firstCreatedAt = timestampToMillis(
    first.createdAt || first.registeredAt || first.registrationDate
  );
  const secondCreatedAt = timestampToMillis(
    second.createdAt || second.registeredAt || second.registrationDate
  );

  if (firstCreatedAt !== secondCreatedAt) {
    return secondCreatedAt - firstCreatedAt;
  }
  return 0;
};

export default function ManageUsers() {
  const [activeTab, setActiveTab] = useState('pending'); // 'pending' | 'approved' | 'rejected'
  const [roleFilter, setRoleFilter] = useState('all');
  const [searchQuery, setSearchQuery] = useState('');
  const [allUsers, setAllUsers] = useState([]);
  const [sectionsMap, setSectionsMap] = useState({});
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 15;

  useEffect(() => {
    setCurrentPage(1);
  }, [activeTab, roleFilter, searchQuery]);
  
  const [deleteConfirm, setDeleteConfirm] = useState(null); // User to reject
  const [recoverConfirm, setRecoverConfirm] = useState(null); // User to recover
  const [resetConfirm, setResetConfirm] = useState(null); // User to reset password
  
  const [editUser, setEditUser] = useState(null); // User to edit
  const [editName, setEditName] = useState('');
  const [editStudentNumber, setEditStudentNumber] = useState('');

  useEffect(() => {
    const unsubscribe = onSnapshot(collection(db, 'users'), (snapshot) => {
      const usersData = [];
      snapshot.forEach(doc => {
        const data = doc.data();
        if (data.role !== 'admin') {
          usersData.push({ id: doc.id, ...data });
        }
      });
      setAllUsers(usersData);
    });

    return () => unsubscribe();
  }, []);

  const users = allUsers
    .filter(user => user.status === activeTab)
    .sort(newestRegistrationFirst);
  const userCounts = allUsers.reduce((counts, user) => {
    if (Object.hasOwn(counts, user.status)) {
      counts[user.status] += 1;
    }
    return counts;
  }, { pending: 0, approved: 0, rejected: 0 });

  useEffect(() => {
    const fetchSections = async () => {
      try {
        const snapshot = await getDocs(collection(db, 'sections'));
        const map = {};
        snapshot.forEach(doc => {
          const data = doc.data();
          if (data.name && data.grade) {
            map[data.name] = data.grade;
          }
        });
        setSectionsMap(map);
      } catch (e) {
        console.error('Error fetching sections map:', e);
      }
    };
    fetchSections();
  }, []);

  const handleApprove = async (id, currentRole) => {
    try {
      const targetUser = allUsers.find(user => user.id === id);
      await updateDoc(doc(db, 'users', id), {
        status: 'approved',
        role: currentRole || 'grade9'
      });
      await logAdminActivity({
        type: 'user_approved',
        title: targetUser?.name || targetUser?.email || 'User',
        details: { userId: id, email: targetUser?.email || '', role: currentRole || 'grade9' },
      });
    } catch (e) {
      console.error(e);
      alert('Error approving user');
    }
  };

  const handleConfirmDelete = async () => {
    if (!deleteConfirm) return;
    try {
      await updateDoc(doc(db, 'users', deleteConfirm.id), {
        status: 'rejected', // This acts as our Trash
        previousStatus: deleteConfirm.status || 'approved'
      });
      const wasApproved = deleteConfirm.status === 'approved';
      await logAdminActivity({
        type: wasApproved ? 'user_revoked' : 'user_rejected',
        title: deleteConfirm.name || deleteConfirm.email || 'User',
        details: { userId: deleteConfirm.id, email: deleteConfirm.email || '', role: deleteConfirm.role || '' },
      });
      setDeleteConfirm(null);
    } catch (e) {
      console.error(e);
      alert('Error moving user to trash');
    }
  };

  const handleConfirmRecover = async () => {
    if (!recoverConfirm) return;
    try {
      await updateDoc(doc(db, 'users', recoverConfirm.id), {
        status: recoverConfirm.previousStatus || 'approved'
      });
      await logAdminActivity({
        type: 'user_recovered',
        title: recoverConfirm.name || recoverConfirm.email || 'User',
        details: { userId: recoverConfirm.id, email: recoverConfirm.email || '', restoredStatus: recoverConfirm.previousStatus || 'approved' },
      });
      setRecoverConfirm(null);
    } catch (e) {
      console.error(e);
      alert('Error recovering user');
    }
  };

  const handleConfirmReset = async () => {
    if (!resetConfirm) return;
    try {
      await sendPasswordResetEmail(auth, resetConfirm.email);
      await logAdminActivity({
        type: 'user_password_reset',
        title: resetConfirm.name || resetConfirm.email,
        details: { userId: resetConfirm.id, email: resetConfirm.email },
      });
      alert(`Password reset email sent to ${resetConfirm.email}`);
      setResetConfirm(null);
    } catch (e) {
      console.error(e);
      alert('Error sending reset email');
    }
  };

  const handleOpenEdit = (user) => {
    setEditUser(user);
    setEditName(user.name || '');
    setEditStudentNumber(user.studentNumber || '');
  };

  const handleConfirmEdit = async (e) => {
    e.preventDefault();
    if (!editUser) return;
    try {
      await updateDoc(doc(db, 'users', editUser.id), {
        name: editName,
        studentNumber: editStudentNumber
      });
      await logAdminActivity({
        type: 'user_edited',
        title: editName || editUser.email || 'User',
        details: { userId: editUser.id, email: editUser.email || '', role: editUser.role || '' },
      });
      setEditUser(null);
    } catch (err) {
      console.error(err);
      alert('Error updating user');
    }
  };

  return (
    <div className="animate-fade-in">
      <div className="page-header">
        <div>
          <h1>Manage Users</h1>
          <p>Approve new registrations and manage active accounts.</p>
        </div>
      </div>

      <div className="glass-panel" style={{ padding: '24px' }}>
        <div className="flex-mobile-col" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px', borderBottom: '1px solid var(--border-light)', gap: '16px' }}>
          <div className="tabs" style={{ borderBottom: 'none', marginBottom: 0, display: 'flex', justifyContent: 'center', width: '100%', paddingBottom: '4px' }}>
            <button 
              className={`tab ${activeTab === 'pending' ? 'active' : ''}`}
              onClick={() => setActiveTab('pending')}
              style={{ flex: 1, textAlign: 'center', padding: '12px 4px', fontSize: '0.85rem' }}
            >
              <span style={{ color: 'var(--accent-pending)' }}>Pending Approvals ({userCounts.pending})</span>
            </button>
            <button 
              className={`tab ${activeTab === 'approved' ? 'active' : ''}`}
              onClick={() => setActiveTab('approved')}
              style={{ flex: 1, textAlign: 'center', padding: '12px 4px', fontSize: '0.85rem' }}
            >
              <span style={{ color: 'var(--accent-green)' }}>Active Users ({userCounts.approved})</span>
            </button>
            <button 
              className={`tab ${activeTab === 'rejected' ? 'active' : ''}`}
              onClick={() => setActiveTab('rejected')}
              style={{ flex: 1, textAlign: 'center', padding: '12px 4px', fontSize: '0.85rem' }}
            >
              <span style={{ color: 'var(--accent-red)' }}>Rejected Users ({userCounts.rejected})</span>
            </button>
          </div>
          
          <div className="flex-mobile-col mobile-w-full" style={{ display: 'flex', gap: '12px', alignItems: 'center' }}>
            <div className="input-group mobile-w-full" style={{ marginBottom: 0 }}>
              <div style={{ position: 'relative' }}>
                <Search size={18} style={{ position: 'absolute', left: '12px', top: '50%', transform: 'translateY(-50%)', color: 'var(--text-secondary)' }} />
                <input 
                  className="input-field mobile-w-full"
                  style={{ padding: '8px 12px 8px 36px', width: '220px', margin: 0 }}
                  placeholder="Search name, email, or student no..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                />
              </div>
            </div>
            <select 
              className="input-field mobile-w-full" 
              style={{ width: '160px', padding: '8px 12px', margin: 0 }}
              value={roleFilter}
              onChange={(e) => setRoleFilter(e.target.value)}
            >
              <option value="all">All Roles</option>
              <option value="student">Students</option>
              <option value="teacher">Teachers</option>
            </select>
          </div>
        </div>

        {(() => {
          const filteredUsers = users.filter(u => {
            // Filter by role
            let roleMatch = true;
            if (roleFilter === 'teacher') roleMatch = u.role === 'teacher';
            else if (roleFilter === 'student') roleMatch = u.role !== 'teacher' && u.role !== 'admin';
            
            // Filter by search query
            let searchMatch = true;
            if (searchQuery.trim()) {
              const q = searchQuery.toLowerCase();
              const name = (u.name || '').toLowerCase();
              const email = (u.email || '').toLowerCase();
              const studentNum = (u.studentNumber || '').toLowerCase();
              searchMatch = name.includes(q) || email.includes(q) || studentNum.includes(q);
            }
            
            return roleMatch && searchMatch;
          });

          const totalPages = Math.max(1, Math.ceil(filteredUsers.length / itemsPerPage));
          const startIndex = (currentPage - 1) * itemsPerPage;
          const paginatedUsers = filteredUsers.slice(startIndex, startIndex + itemsPerPage);

          if (users.length === 0) {
            return (
              <div style={{ padding: '40px', textAlign: 'center', color: 'var(--text-secondary)' }}>
                {activeTab === 'rejected' ? 'No rejected users.' : 'No users found in this category.'}
              </div>
            );
          }

          if (filteredUsers.length === 0) {
            return (
              <div style={{ padding: '40px', textAlign: 'center', color: 'var(--text-secondary)' }}>
                No users match your filters.
              </div>
            );
          }

          return (
            <>
              <div style={{ overflowX: 'auto' }}>
                <table className="data-table">
                  <thead>
                    <tr>
                      <th>Name</th>
                      <th>Student Number</th>
                      <th>Email</th>
                      <th>Role</th>
                      <th>Grade Level</th>
                      <th>Sections</th>
                      <th style={{ textAlign: 'right' }}>Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    {paginatedUsers.map(user => (
                      <tr key={user.id} style={{ opacity: activeTab === 'rejected' ? 0.6 : 1 }}>
                        <td>
                          <div style={{ fontWeight: 600, color: 'var(--text-primary)', textDecoration: activeTab === 'rejected' ? 'line-through' : 'none' }}>
                            {user.name || 'No Name'}
                          </div>
                        </td>
                        <td style={{ textDecoration: activeTab === 'rejected' ? 'line-through' : 'none', color: 'var(--text-secondary)' }}>
                          {user.studentNumber ? `#${user.studentNumber}` : '-'}
                        </td>
                        <td style={{ textDecoration: activeTab === 'rejected' ? 'line-through' : 'none' }}>{user.email}</td>
                        <td>
                          <span className="badge badge-role">
                            {user.role === 'teacher' ? 'Teacher' : 'Student'}
                          </span>
                        </td>
                        <td>
                          <span style={{ color: 'var(--text-secondary)' }}>
                            {user.role === 'grade9' ? 'Grade 9' 
                              : user.role === 'grade10' ? 'Grade 10' 
                              : user.role === 'teacher' && user.sections?.length > 0
                                ? [...new Set(user.sections.map(s => sectionsMap[s]))].filter(Boolean).join(', ') || '-'
                              : '-'}
                          </span>
                        </td>
                        <td>{user.sections?.join(', ') || '-'}</td>
                        <td style={{ textAlign: 'right' }}>
                          
                          {activeTab === 'pending' && (
                            <div style={{ display: 'flex', gap: '8px', justifyContent: 'flex-end' }}>
                              <button className="btn btn-success" onClick={() => handleApprove(user.id, user.role)} title="Approve">
                                <CheckCircle size={16} />
                              </button>
                              <button className="btn btn-danger" onClick={() => setDeleteConfirm(user)} title="Reject">
                                <XCircle size={16} />
                              </button>
                            </div>
                          )}

                          {activeTab === 'approved' && (
                            <div style={{ display: 'flex', gap: '8px', justifyContent: 'flex-end' }}>
                              <button className="btn btn-secondary" onClick={() => handleOpenEdit(user)} title="Edit User">
                                <Edit size={16} /> Edit
                              </button>
                              <button className="btn btn-secondary" onClick={() => setResetConfirm(user)} title="Reset Password">
                                <Key size={16} /> Reset
                              </button>
                              {user.role !== 'admin' && (
                                <button className="btn btn-danger" onClick={() => setDeleteConfirm(user)} title="Revoke">
                                  <XCircle size={16} />
                                </button>
                              )}
                            </div>
                          )}

                          {activeTab === 'rejected' && (
                            <div style={{ display: 'flex', gap: '8px', justifyContent: 'flex-end' }}>
                              <button className="btn btn-success" onClick={() => setRecoverConfirm(user)} title="Recover User">
                                <RefreshCcw size={16} />
                              </button>
                            </div>
                          )}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>

              {filteredUsers.length > 0 && (
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
                    Showing <span style={{ color: 'var(--text-primary)', fontWeight: 600 }}>{startIndex + 1}</span> to <span style={{ color: 'var(--text-primary)', fontWeight: 600 }}>{Math.min(startIndex + itemsPerPage, filteredUsers.length)}</span> of <span style={{ color: 'var(--text-primary)', fontWeight: 600 }}>{filteredUsers.length}</span> users
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
          );
        })()}
      </div>

      {/* Edit User Modal */}
      {editUser && (
        <div style={{
          position: 'fixed', top: 0, left: 0, right: 0, bottom: 0,
          background: 'rgba(0,0,0,0.6)',
          backdropFilter: 'blur(4px)',
          display: 'flex', justifyContent: 'center', alignItems: 'center',
          zIndex: 100
        }}>
          <div className="glass-panel animate-fade-in" style={{ width: '100%', maxWidth: '420px', padding: '32px' }}>
            <h2 style={{ marginBottom: '24px', textAlign: 'center' }}>Edit User</h2>
            <form onSubmit={handleConfirmEdit}>
              <div style={{ marginBottom: '16px' }}>
                <label style={{ display: 'block', marginBottom: '8px', color: 'var(--text-secondary)', fontSize: '13px' }}>Full Name</label>
                <input
                  type="text"
                  className="input-field"
                  value={editName}
                  onChange={(e) => setEditName(e.target.value)}
                  style={{ width: '100%' }}
                  required
                />
              </div>
              {editUser.role !== 'teacher' && (
                <div style={{ marginBottom: '24px' }}>
                  <label style={{ display: 'block', marginBottom: '8px', color: 'var(--text-secondary)', fontSize: '13px' }}>Student Number</label>
                  <input
                    type="text"
                    className="input-field"
                    value={editStudentNumber}
                    onChange={(e) => setEditStudentNumber(e.target.value)}
                    style={{ width: '100%' }}
                  />
                </div>
              )}
              <div style={{ display: 'flex', gap: '12px', justifyContent: 'center' }}>
                <button type="button" className="btn btn-secondary" onClick={() => setEditUser(null)}>Cancel</button>
                <button type="submit" className="btn btn-primary" style={{ paddingLeft: '24px', paddingRight: '24px' }}>Save Changes</button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Reject Modal */}
      {deleteConfirm && (
        <div style={{
          position: 'fixed', top: 0, left: 0, right: 0, bottom: 0,
          background: 'rgba(0,0,0,0.6)',
          backdropFilter: 'blur(4px)',
          display: 'flex', justifyContent: 'center', alignItems: 'center',
          zIndex: 100
        }}>
          <div className="glass-panel animate-fade-in" style={{ width: '100%', maxWidth: '420px', padding: '32px', textAlign: 'center' }}>
            <div style={{ background: 'rgba(255, 71, 87, 0.1)', padding: '16px', borderRadius: '50%', display: 'inline-block', marginBottom: '16px' }}>
              <AlertTriangle size={32} color="var(--accent-red)" />
            </div>
            <h2 style={{ marginBottom: '12px' }}>
              {deleteConfirm.status === 'approved' ? 'Revoke User Access?' : 'Reject User?'}
            </h2>
            <p style={{ color: 'var(--text-secondary)', marginBottom: '24px', lineHeight: 1.5 }}>
              Are you sure you want to {deleteConfirm.status === 'approved' ? 'revoke access for' : 'reject'} <strong>"{deleteConfirm.name}"</strong>? 
              They will be moved to the Rejected list and will not be able to access the app.
            </p>
            <div style={{ display: 'flex', gap: '12px', justifyContent: 'center' }}>
              <button className="btn btn-secondary" onClick={() => setDeleteConfirm(null)}>Cancel</button>
              <button className="btn btn-danger" onClick={handleConfirmDelete}>
                {deleteConfirm.status === 'approved' ? 'Yes, revoke access' : 'Yes, reject user'}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Recover Confirmation Modal */}
      {recoverConfirm && (
        <div style={{
          position: 'fixed', top: 0, left: 0, right: 0, bottom: 0,
          background: 'rgba(0,0,0,0.6)',
          backdropFilter: 'blur(4px)',
          display: 'flex', justifyContent: 'center', alignItems: 'center',
          zIndex: 100
        }}>
          <div className="glass-panel animate-fade-in" style={{ width: '100%', maxWidth: '420px', padding: '32px', textAlign: 'center', border: '1px solid var(--accent-green)' }}>
            <div style={{ background: 'rgba(0, 255, 136, 0.2)', padding: '16px', borderRadius: '50%', display: 'inline-block', marginBottom: '16px' }}>
              <RefreshCcw size={32} color="var(--accent-green)" />
            </div>
            <h2 style={{ marginBottom: '12px', color: 'var(--accent-green)' }}>Recover User?</h2>
            <p style={{ color: 'var(--text-secondary)', marginBottom: '24px', lineHeight: 1.5 }}>
              Are you sure you want to recover <strong>"{recoverConfirm.name}"</strong>? 
              <br /><br />
              They will be moved back to the <strong>{recoverConfirm.previousStatus === 'pending' ? 'Pending' : 'Active'}</strong> list.
            </p>
            <div style={{ display: 'flex', gap: '12px', justifyContent: 'center' }}>
              <button className="btn btn-secondary" onClick={() => setRecoverConfirm(null)}>Cancel</button>
              <button className="btn btn-success" onClick={handleConfirmRecover}>Yes, Recover</button>
            </div>
          </div>
        </div>
      )}

      {/* Reset Password Confirmation Modal */}
      {resetConfirm && (
        <div style={{
          position: 'fixed', top: 0, left: 0, right: 0, bottom: 0,
          background: 'rgba(0,0,0,0.6)',
          backdropFilter: 'blur(4px)',
          display: 'flex', justifyContent: 'center', alignItems: 'center',
          zIndex: 100
        }}>
          <div className="glass-panel animate-fade-in" style={{ width: '100%', maxWidth: '420px', padding: '32px', textAlign: 'center', border: '1px solid var(--border-light)' }}>
            <div style={{ background: 'rgba(255, 255, 255, 0.1)', padding: '16px', borderRadius: '50%', display: 'inline-block', marginBottom: '16px' }}>
              <Key size={32} color="white" />
            </div>
            <h2 style={{ marginBottom: '12px', color: 'var(--text-primary)' }}>Reset Password?</h2>
            <p style={{ color: 'var(--text-secondary)', marginBottom: '24px', lineHeight: 1.5 }}>
              Are you sure you want to send a password reset email to <strong>"{resetConfirm.name}"</strong>? 
              <br /><br />
              An email will be sent to <strong>{resetConfirm.email}</strong> with instructions to reset their password.
            </p>
            <div style={{ display: 'flex', gap: '12px', justifyContent: 'center' }}>
              <button className="btn btn-secondary" onClick={() => setResetConfirm(null)}>Cancel</button>
              <button className="btn btn-primary" onClick={handleConfirmReset}>Yes, Send Email</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
