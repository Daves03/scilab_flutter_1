import { useState, useEffect } from 'react';
import { collection, query, where, onSnapshot, doc, updateDoc, deleteDoc } from 'firebase/firestore';
import { sendPasswordResetEmail } from 'firebase/auth';
import { db, auth } from '../firebase';
import { CheckCircle, XCircle, Key, RefreshCcw, Trash2, AlertTriangle, Search } from 'lucide-react';

export default function ManageUsers() {
  const [activeTab, setActiveTab] = useState('pending'); // 'pending' | 'approved' | 'rejected'
  const [roleFilter, setRoleFilter] = useState('all');
  const [searchQuery, setSearchQuery] = useState('');
  const [users, setUsers] = useState([]);
  
  const [deleteConfirm, setDeleteConfirm] = useState(null); // User to move to trash
  const [permanentDeleteConfirm, setPermanentDeleteConfirm] = useState(null); // User to permanently delete
  const [recoverConfirm, setRecoverConfirm] = useState(null); // User to recover
  const [resetConfirm, setResetConfirm] = useState(null); // User to reset password

  useEffect(() => {
    const q = query(collection(db, 'users'), where('status', '==', activeTab));
    
    const unsubscribe = onSnapshot(q, (snapshot) => {
      const usersData = [];
      snapshot.forEach(doc => {
        const data = doc.data();
        if (data.role !== 'admin') {
          usersData.push({ id: doc.id, ...data });
        }
      });
      setUsers(usersData);
    });

    return () => unsubscribe();
  }, [activeTab]);

  const handleApprove = async (id, currentRole) => {
    try {
      await updateDoc(doc(db, 'users', id), {
        status: 'approved',
        role: currentRole || 'grade9'
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
      setRecoverConfirm(null);
    } catch (e) {
      console.error(e);
      alert('Error recovering user');
    }
  };

  const handlePermanentDelete = async () => {
    if (!permanentDeleteConfirm) return;
    try {
      await deleteDoc(doc(db, 'users', permanentDeleteConfirm.id));
      setPermanentDeleteConfirm(null);
    } catch (e) {
      console.error(e);
      alert('Error permanently deleting user');
    }
  };

  const handleConfirmReset = async () => {
    if (!resetConfirm) return;
    try {
      await sendPasswordResetEmail(auth, resetConfirm.email);
      alert(`Password reset email sent to ${resetConfirm.email}`);
      setResetConfirm(null);
    } catch (e) {
      console.error(e);
      alert('Error sending reset email');
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
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px', borderBottom: '1px solid var(--border-light)' }}>
          <div className="tabs" style={{ borderBottom: 'none', marginBottom: 0 }}>
            <button 
              className={`tab ${activeTab === 'pending' ? 'active' : ''}`}
              onClick={() => setActiveTab('pending')}
            >
              Pending Approvals ({activeTab === 'pending' ? users.length : '...'})
            </button>
            <button 
              className={`tab ${activeTab === 'approved' ? 'active' : ''}`}
              onClick={() => setActiveTab('approved')}
            >
              Active Users ({activeTab === 'approved' ? users.length : '...'})
            </button>
            <button 
              className={`tab ${activeTab === 'rejected' ? 'active' : ''}`}
              onClick={() => setActiveTab('rejected')}
            >
              Trash ({activeTab === 'rejected' ? users.length : '...'})
            </button>
          </div>
          
          <div style={{ display: 'flex', gap: '12px', alignItems: 'center' }}>
            <div className="input-group" style={{ marginBottom: 0 }}>
              <div style={{ position: 'relative' }}>
                <Search size={18} style={{ position: 'absolute', left: '12px', top: '50%', transform: 'translateY(-50%)', color: 'var(--text-secondary)' }} />
                <input 
                  className="input-field"
                  style={{ padding: '8px 12px 8px 36px', width: '220px', margin: 0 }}
                  placeholder="Search name or email..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                />
              </div>
            </div>
            <select 
              className="input-field" 
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

        {users.length === 0 ? (
          <div style={{ padding: '40px', textAlign: 'center', color: 'var(--text-secondary)' }}>
            {activeTab === 'rejected' ? 'Trash is empty.' : 'No users found in this category.'}
          </div>
        ) : (
          <div style={{ overflowX: 'auto' }}>
            <table className="data-table">
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Email</th>
                  <th>Role</th>
                  <th>Sections</th>
                  <th style={{ textAlign: 'right' }}>Actions</th>
                </tr>
              </thead>
              <tbody>
                {users.filter(u => {
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
                    searchMatch = name.includes(q) || email.includes(q);
                  }
                  
                  return roleMatch && searchMatch;
                }).map(user => (
                  <tr key={user.id} style={{ opacity: activeTab === 'rejected' ? 0.6 : 1 }}>
                    <td>
                      <div style={{ fontWeight: 600, color: 'white', textDecoration: activeTab === 'rejected' ? 'line-through' : 'none' }}>
                        {user.name || 'No Name'}
                      </div>
                    </td>
                    <td style={{ textDecoration: activeTab === 'rejected' ? 'line-through' : 'none' }}>{user.email}</td>
                    <td>
                      <span className="badge badge-role">
                        {user.role || 'Unknown'}
                      </span>
                    </td>
                    <td>{user.sections?.join(', ') || '-'}</td>
                    <td style={{ textAlign: 'right' }}>
                      
                      {activeTab === 'pending' && (
                        <div style={{ display: 'flex', gap: '8px', justifyContent: 'flex-end' }}>
                          <button className="btn btn-success" onClick={() => handleApprove(user.id, user.role)} title="Approve">
                            <CheckCircle size={16} />
                          </button>
                          <button className="btn btn-danger" onClick={() => setDeleteConfirm(user)} title="Move to Trash">
                            <Trash2 size={16} />
                          </button>
                        </div>
                      )}

                      {activeTab === 'approved' && (
                        <div style={{ display: 'flex', gap: '8px', justifyContent: 'flex-end' }}>
                          <button className="btn btn-secondary" onClick={() => setResetConfirm(user)} title="Reset Password">
                            <Key size={16} /> Reset
                          </button>
                          {user.role !== 'admin' && (
                            <button className="btn btn-danger" onClick={() => setDeleteConfirm(user)} title="Move to Trash">
                              <Trash2 size={16} />
                            </button>
                          )}
                        </div>
                      )}

                      {activeTab === 'rejected' && (
                        <div style={{ display: 'flex', gap: '8px', justifyContent: 'flex-end' }}>
                          <button className="btn btn-success" onClick={() => setRecoverConfirm(user)} title="Recover User">
                            <RefreshCcw size={16} />
                          </button>
                          <button className="btn btn-danger" onClick={() => setPermanentDeleteConfirm(user)} title="Permanently Delete">
                            <Trash2 size={16} />
                          </button>
                        </div>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Move to Trash Modal */}
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
            <h2 style={{ marginBottom: '12px' }}>Move to Trash?</h2>
            <p style={{ color: 'var(--text-secondary)', marginBottom: '24px', lineHeight: 1.5 }}>
              Are you sure you want to move <strong>"{deleteConfirm.name}"</strong> to the trash? 
              They will no longer be able to access their account until you recover them.
            </p>
            <div style={{ display: 'flex', gap: '12px', justifyContent: 'center' }}>
              <button className="btn btn-secondary" onClick={() => setDeleteConfirm(null)}>Cancel</button>
              <button className="btn btn-danger" onClick={handleConfirmDelete}>Yes, move to trash</button>
            </div>
          </div>
        </div>
      )}

      {/* Permanent Delete Modal */}
      {permanentDeleteConfirm && (
        <div style={{
          position: 'fixed', top: 0, left: 0, right: 0, bottom: 0,
          background: 'rgba(0,0,0,0.8)',
          backdropFilter: 'blur(6px)',
          display: 'flex', justifyContent: 'center', alignItems: 'center',
          zIndex: 100
        }}>
          <div className="glass-panel animate-fade-in" style={{ width: '100%', maxWidth: '420px', padding: '32px', textAlign: 'center', border: '1px solid var(--accent-red)' }}>
            <div style={{ background: 'rgba(255, 71, 87, 0.2)', padding: '16px', borderRadius: '50%', display: 'inline-block', marginBottom: '16px' }}>
              <AlertTriangle size={32} color="var(--accent-red)" />
            </div>
            <h2 style={{ marginBottom: '12px', color: 'var(--accent-red)' }}>Permanent Delete</h2>
            <p style={{ color: 'var(--text-secondary)', marginBottom: '24px', lineHeight: 1.5 }}>
              Are you sure you want to permanently delete <strong>"{permanentDeleteConfirm.name}"</strong>? 
              <br /><br />
              This action <strong>cannot be undone</strong> and will completely wipe their account from the database.
            </p>
            <div style={{ display: 'flex', gap: '12px', justifyContent: 'center' }}>
              <button className="btn btn-secondary" onClick={() => setPermanentDeleteConfirm(null)}>Cancel</button>
              <button className="btn btn-danger" onClick={handlePermanentDelete}>Permanently Delete</button>
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
            <h2 style={{ marginBottom: '12px', color: 'white' }}>Reset Password?</h2>
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
