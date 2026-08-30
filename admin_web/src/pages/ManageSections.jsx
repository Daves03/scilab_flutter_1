import { useState, useEffect } from 'react';
import { collection, query, onSnapshot, addDoc, doc, updateDoc, deleteDoc } from 'firebase/firestore';
import { db } from '../firebase';
import { Layers, Plus, Trash2, RefreshCcw, AlertTriangle } from 'lucide-react';

export default function ManageSections() {
  const [activeTab, setActiveTab] = useState('active');
  const [gradeFilter, setGradeFilter] = useState('all');
  const [sections, setSections] = useState([]);
  const [trashedSections, setTrashedSections] = useState([]);
  
  const [showAddModal, setShowAddModal] = useState(false);
  const [newSectionName, setNewSectionName] = useState('');
  const [newSectionGrade, setNewSectionGrade] = useState('Grade 9');

  const [deleteConfirm, setDeleteConfirm] = useState(null); // stores section to delete
  const [permanentDeleteConfirm, setPermanentDeleteConfirm] = useState(null); // stores section to permanently delete
  const [recoverConfirm, setRecoverConfirm] = useState(null); // stores section to recover

  useEffect(() => {
    const q = query(collection(db, 'sections'));
    const unsubscribe = onSnapshot(q, (snapshot) => {
      const activeData = [];
      const trashData = [];
      snapshot.forEach(doc => {
        const data = doc.data();
        if (data.isTrashed) {
          trashData.push({ id: doc.id, ...data });
        } else {
          activeData.push({ id: doc.id, ...data });
        }
      });
      
      const sortFn = (a, b) => {
        if (a.grade !== b.grade) return (a.grade || '').localeCompare(b.grade || '');
        return (a.name || '').localeCompare(b.name || '');
      };
      
      activeData.sort(sortFn);
      trashData.sort(sortFn);
      
      setSections(activeData);
      setTrashedSections(trashData);
    });

    return () => unsubscribe();
  }, []);

  const handleAddSection = async (e) => {
    e.preventDefault();
    if (!newSectionName.trim()) return;
    
    try {
      await addDoc(collection(db, 'sections'), {
        name: newSectionName.trim(),
        grade: newSectionGrade,
        isTrashed: false
      });
      setNewSectionName('');
      setShowAddModal(false);
    } catch (e) {
      console.error(e);
      alert('Error adding section');
    }
  };

  const handleConfirmDelete = async () => {
    if (!deleteConfirm) return;
    
    try {
      await updateDoc(doc(db, 'sections', deleteConfirm.id), {
        isTrashed: true,
        deletedAt: new Date().toISOString()
      });
      setDeleteConfirm(null);
    } catch (e) {
      console.error(e);
      alert('Error moving to trash: ' + e.message);
    }
  };

  const handleConfirmRecover = async () => {
    if (!recoverConfirm) return;
    try {
      await updateDoc(doc(db, 'sections', recoverConfirm.id), {
        isTrashed: false,
        deletedAt: null
      });
      setRecoverConfirm(null);
    } catch (e) {
      console.error(e);
      alert('Error recovering section: ' + e.message);
    }
  };

  const handlePermanentDelete = async () => {
    if (!permanentDeleteConfirm) return;
    try {
      await deleteDoc(doc(db, 'sections', permanentDeleteConfirm.id));
      setPermanentDeleteConfirm(null);
    } catch (e) {
      console.error(e);
      alert('Error permanently deleting section: ' + e.message);
    }
  };

  const currentList = activeTab === 'active' ? sections : trashedSections;

  return (
    <div className="animate-fade-in">
      <div className="page-header">
        <div>
          <h1>Manage Sections</h1>
          <p>Create and remove school sections.</p>
        </div>
        {activeTab === 'active' && (
          <button className="btn btn-primary" onClick={() => setShowAddModal(true)}>
            <Plus size={20} /> Add Section
          </button>
        )}
      </div>

      <div className="glass-panel" style={{ padding: '24px' }}>
        <div className="flex-mobile-col" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px', borderBottom: '1px solid var(--border-light)', gap: '16px' }}>
          <div className="tabs mobile-tabs" style={{ borderBottom: 'none', marginBottom: 0 }}>
            <button 
              className={`tab ${activeTab === 'active' ? 'active' : ''}`}
              onClick={() => setActiveTab('active')}
            >
              Active Sections ({sections.length})
            </button>
            <button 
              className={`tab ${activeTab === 'trash' ? 'active' : ''}`}
              onClick={() => setActiveTab('trash')}
            >
              Trash ({trashedSections.length})
            </button>
          </div>
          
          <select 
            className="input-field mobile-w-full" 
            style={{ width: '200px', padding: '8px 12px' }}
            value={gradeFilter}
            onChange={(e) => setGradeFilter(e.target.value)}
          >
            <option value="all">All Grades</option>
            <option value="Grade 9">Grade 9</option>
            <option value="Grade 10">Grade 10</option>
          </select>
        </div>

        {currentList.filter(s => gradeFilter === 'all' || s.grade === gradeFilter).length === 0 ? (
          <div style={{ padding: '40px', textAlign: 'center', color: 'var(--text-secondary)' }}>
            {activeTab === 'active' ? 'No sections created yet in this view.' : 'Trash is empty.'}
          </div>
        ) : (
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))', gap: '16px' }}>
            {currentList.filter(s => gradeFilter === 'all' || s.grade === gradeFilter).map(section => (
              <div key={section.id} style={{ 
                background: 'rgba(0,0,0,0.2)', 
                border: '1px solid var(--border-light)',
                borderRadius: '12px',
                padding: '20px',
                display: 'flex',
                justifyContent: 'space-between',
                alignItems: 'center',
                opacity: activeTab === 'trash' ? 0.7 : 1
              }}>
                <div style={{ display: 'flex', gap: '16px', alignItems: 'center' }}>
                  <div style={{ background: activeTab === 'trash' ? 'rgba(255,255,255,0.1)' : 'var(--accent-purple)', padding: '10px', borderRadius: '10px' }}>
                    <Layers size={20} color="white" />
                  </div>
                  <div>
                    <h4 style={{ margin: 0, fontSize: '1.1rem', color: 'white', textDecoration: activeTab === 'trash' ? 'line-through' : 'none' }}>
                      {section.name}
                    </h4>
                    <span style={{ fontSize: '0.85rem', color: 'var(--text-secondary)' }}>{section.grade}</span>
                  </div>
                </div>
                
                {activeTab === 'active' ? (
                  <button 
                    className="btn btn-danger" 
                    style={{ padding: '8px' }}
                    onClick={() => setDeleteConfirm(section)}
                    title="Move to Trash"
                  >
                    <Trash2 size={16} />
                  </button>
                ) : (
                  <div style={{ display: 'flex', gap: '8px' }}>
                    <button 
                      className="btn btn-success" 
                      style={{ padding: '8px' }}
                      onClick={() => setRecoverConfirm(section)}
                      title="Recover Section"
                    >
                      <RefreshCcw size={16} />
                    </button>
                    <button 
                      className="btn btn-danger" 
                      style={{ padding: '8px' }}
                      onClick={() => setPermanentDeleteConfirm(section)}
                      title="Permanently Delete Section"
                    >
                      <Trash2 size={16} />
                    </button>
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Add Section Modal */}
      {showAddModal && (
        <div style={{
          position: 'fixed', top: 0, left: 0, right: 0, bottom: 0,
          background: 'rgba(0,0,0,0.5)',
          backdropFilter: 'blur(4px)',
          display: 'flex', justifyContent: 'center', alignItems: 'center',
          zIndex: 100
        }}>
          <div className="glass-panel animate-fade-in" style={{ width: '100%', maxWidth: '400px', padding: '32px' }}>
            <h2 style={{ marginBottom: '24px' }}>Add New Section</h2>
            <form onSubmit={handleAddSection}>
              <div className="input-group">
                <label className="input-label">Section Name</label>
                <input 
                  className="input-field"
                  value={newSectionName}
                  onChange={(e) => setNewSectionName(e.target.value)}
                  placeholder="e.g. 9-Rizal"
                  autoFocus
                  required
                />
              </div>
              <div className="input-group" style={{ marginBottom: '32px' }}>
                <label className="input-label">Grade Level</label>
                <select 
                  className="input-field" 
                  value={newSectionGrade}
                  onChange={(e) => setNewSectionGrade(e.target.value)}
                >
                  <option value="Grade 9">Grade 9</option>
                  <option value="Grade 10">Grade 10</option>
                </select>
              </div>
              <div style={{ display: 'flex', gap: '12px', justifyContent: 'flex-end' }}>
                <button type="button" className="btn btn-secondary" onClick={() => setShowAddModal(false)}>Cancel</button>
                <button type="submit" className="btn btn-primary">Create Section</button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Delete Confirmation Modal */}
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
              Are you sure you want to delete the section <strong>"{deleteConfirm.name}"</strong>? 
              Users assigned to this section won't be deleted, but they will lose this section tag. You can recover it from the trash later.
            </p>
            <div style={{ display: 'flex', gap: '12px', justifyContent: 'center' }}>
              <button className="btn btn-secondary" onClick={() => setDeleteConfirm(null)}>Cancel</button>
              <button className="btn btn-danger" onClick={handleConfirmDelete}>Yes, move to trash</button>
            </div>
          </div>
        </div>
      )}

      {/* Permanent Delete Confirmation Modal */}
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
              Are you sure you want to permanently delete the section <strong>"{permanentDeleteConfirm.name}"</strong>? 
              <br /><br />
              This action <strong>cannot be undone</strong>.
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
            <h2 style={{ marginBottom: '12px', color: 'var(--accent-green)' }}>Recover Section?</h2>
            <p style={{ color: 'var(--text-secondary)', marginBottom: '24px', lineHeight: 1.5 }}>
              Are you sure you want to recover <strong>"{recoverConfirm.name}"</strong>? 
              <br /><br />
              It will be moved back to the <strong>Active Sections</strong> list.
            </p>
            <div style={{ display: 'flex', gap: '12px', justifyContent: 'center' }}>
              <button className="btn btn-secondary" onClick={() => setRecoverConfirm(null)}>Cancel</button>
              <button className="btn btn-success" onClick={handleConfirmRecover}>Yes, Recover</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
