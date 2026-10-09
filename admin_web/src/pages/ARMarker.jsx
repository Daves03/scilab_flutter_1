import React, { useState } from 'react';
import { createPortal } from 'react-dom';
import markerImage from '../assets/scilab_AR_marker.png';
import { Download, Eye, X } from 'lucide-react';

export default function ARMarker() {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const handleDownload = () => {
    const link = document.createElement('a');
    link.href = markerImage;
    link.download = 'SciLab_AR_Marker.png';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  return (
    <div className="animate-fade-in">
      <div className="page-header">
        <div>
          <h1>AR Marker</h1>
          <p>View or download the official AR marker used by the mobile application.</p>
        </div>
      </div>

      <div className="glass-panel" style={{ padding: '32px', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', minHeight: '500px' }}>
        
        <div style={{ background: '#fff', padding: '16px', borderRadius: '16px', boxShadow: '0 4px 24px rgba(0,0,0,0.1)', marginBottom: '32px' }}>
          <img 
            src={markerImage} 
            alt="SciLab AR Marker" 
            style={{ 
              maxWidth: '100%', 
              maxHeight: '400px', 
              objectFit: 'contain',
              display: 'block'
            }} 
          />
        </div>

        <div style={{ display: 'flex', gap: '16px', flexWrap: 'wrap', justifyContent: 'center' }}>
          <button 
            onClick={() => setIsModalOpen(true)}
            className="btn btn-secondary"
            style={{ padding: '16px 32px', fontSize: '16px' }}
          >
            <Eye size={20} />
            View Full Size
          </button>

          <button 
            onClick={handleDownload}
            className="btn btn-primary"
            style={{ padding: '16px 32px', fontSize: '16px' }}
          >
            <Download size={20} />
            Download AR Marker
          </button>
        </div>
      </div>

      {/* Full Screen Modal via Portal */}
      {isModalOpen && createPortal(
        <div style={{
          position: 'fixed', top: 0, left: 0, width: '100vw', height: '100vh',
          backgroundColor: 'rgba(0, 0, 0, 0.85)', zIndex: 9999,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          backdropFilter: 'blur(5px)'
        }}>
          <button 
            onClick={() => setIsModalOpen(false)}
            style={{
              position: 'absolute', top: '24px', right: '32px',
              background: 'rgba(255, 255, 255, 0.1)', border: 'none', borderRadius: '50%',
              width: '48px', height: '48px', display: 'flex', alignItems: 'center', justifyContent: 'center',
              color: '#fff', cursor: 'pointer', transition: 'all 0.2s',
              zIndex: 10000
            }}
            onMouseOver={(e) => e.currentTarget.style.background = 'rgba(255, 255, 255, 0.2)'}
            onMouseOut={(e) => e.currentTarget.style.background = 'rgba(255, 255, 255, 0.1)'}
          >
            <X size={28} />
          </button>
          
          <img 
            src={markerImage} 
            alt="SciLab AR Marker Full" 
            style={{ 
              maxWidth: '90%', maxHeight: '90%', 
              objectFit: 'contain',
              boxShadow: '0 0 40px rgba(0, 212, 255, 0.2)',
              borderRadius: '16px',
              background: '#fff'
            }} 
          />
        </div>,
        document.body
      )}
    </div>
  );
}
