import React, { useState } from 'react';
import { Shield, FileText } from 'lucide-react';

export default function Legal() {
  const [activeTab, setActiveTab] = useState('terms');

  return (
    <div className="animate-fade-in">
      <div className="page-header">
        <div>
          <h1>Legal</h1>
          <p>Manage Terms & Conditions and Privacy Policy.</p>
        </div>
      </div>

      <div className="glass-panel" style={{ padding: 0, display: 'flex', flexDirection: 'column', minHeight: '600px' }}>
        {/* Horizontal Tabs */}
        <div style={{ display: 'flex', borderBottom: '1px solid var(--border-light)', padding: '0 32px' }}>
          <button 
            onClick={() => setActiveTab('terms')}
            style={{ 
              padding: '16px 24px', 
              border: 'none', 
              background: 'transparent',
              color: activeTab === 'terms' ? 'var(--primary-color)' : 'var(--text-secondary)',
              fontWeight: activeTab === 'terms' ? '600' : 'normal', 
              cursor: 'pointer',
              borderBottom: activeTab === 'terms' ? '2px solid var(--primary-color)' : '2px solid transparent',
              transition: 'all 0.2s',
              marginRight: '8px',
              fontSize: '15px'
            }}
          >
            Terms & Conditions
          </button>
          
          <button 
            onClick={() => setActiveTab('privacy')}
            style={{ 
              padding: '16px 24px', 
              border: 'none', 
              background: 'transparent',
              color: activeTab === 'privacy' ? 'var(--primary-color)' : 'var(--text-secondary)',
              fontWeight: activeTab === 'privacy' ? '600' : 'normal', 
              cursor: 'pointer',
              borderBottom: activeTab === 'privacy' ? '2px solid var(--primary-color)' : '2px solid transparent',
              transition: 'all 0.2s',
              fontSize: '15px'
            }}
          >
            Privacy Policy
          </button>
        </div>

        {/* Content Area */}
        <div style={{ flex: 1, padding: '32px', overflowY: 'auto', maxHeight: '700px' }}>
          {activeTab === 'terms' ? (
            <div style={{ color: 'var(--text-color)', lineHeight: '1.6' }}>
              <h2 style={{ fontSize: '24px', fontWeight: 'bold', marginBottom: '24px', color: 'var(--text-color)' }}>Terms and Conditions</h2>
              <p style={{ marginBottom: '24px' }}>Welcome to SciLab AR! By using this application, you agree to the following terms and conditions. Please read them carefully before proceeding.</p>
              
              <h3 style={{ fontSize: '18px', fontWeight: 'bold', marginTop: '32px', marginBottom: '12px', color: 'var(--text-color)' }}>1. Educational Simulation Only</h3>
              <p style={{ marginBottom: '16px' }}>SciLab AR is an Augmented Reality (AR) tool designed solely for educational and visualization purposes. While the simulations aim to be realistic, they are virtual representations and may not perfectly reflect the unpredictability of real-world chemical reactions. This app should be used as a supplementary learning tool and not as a substitute for actual laboratory training.</p>
              
              <h3 style={{ fontSize: '18px', fontWeight: 'bold', marginTop: '32px', marginBottom: '12px', color: 'var(--text-color)' }}>2. Safety Warning (Real-World Experiments)</h3>
              <p style={{ marginBottom: '8px' }}>Chemistry experiments involve real risks. The experiments demonstrated in this app (such as Elephant Toothpaste and Silver Nitrate tests) involve chemicals that can be hazardous if mishandled.</p>
              <ul style={{ paddingLeft: '20px', marginBottom: '16px', listStyleType: 'disc' }}>
                <li style={{ marginBottom: '8px' }}>DO NOT attempt to replicate these experiments in the real world without the direct supervision of a qualified science teacher or professional.</li>
                <li style={{ marginBottom: '8px' }}>The developers and Cavite State University - Bacoor City Campus are not liable for any accidents, injuries, or damages resulting from the unsupervised or improper replication of these simulations.</li>
              </ul>
              
              <h3 style={{ fontSize: '18px', fontWeight: 'bold', marginTop: '32px', marginBottom: '12px', color: 'var(--text-color)' }}>3. Health & Safety (AR Usage)</h3>
              <p style={{ marginBottom: '8px' }}>Extended use of Augmented Reality may cause motion sickness, dizziness, or eye strain for some users.</p>
              <ul style={{ paddingLeft: '20px', marginBottom: '16px', listStyleType: 'disc' }}>
                <li style={{ marginBottom: '8px' }}>Please use the app in a safe environment.</li>
                <li style={{ marginBottom: '8px' }}>Be aware of your surroundings to avoid tripping or bumping into real-world objects while focusing on the screen.</li>
                <li style={{ marginBottom: '8px' }}>If you experience discomfort, discontinue use immediately.</li>
              </ul>
              
              <h3 style={{ fontSize: '18px', fontWeight: 'bold', marginTop: '32px', marginBottom: '12px', color: 'var(--text-color)' }}>4. Device & Environment Requirements</h3>
              <p style={{ marginBottom: '16px' }}>To ensure the app functions correctly, please ensure your device meets the minimum hardware requirements (Android, ARCore/Vuforia compatible). The app requires a well-lit environment to detect markers accurately. Poor lighting or reflective surfaces may affect performance.</p>
              
              <h3 style={{ fontSize: '18px', fontWeight: 'bold', marginTop: '32px', marginBottom: '12px', color: 'var(--text-color)' }}>5. Data Privacy and Storage</h3>
              <p style={{ marginBottom: '8px' }}>SciLab AR utilizes cloud services to sync your progress. Your data, including names, progress logs, and experiment records, are stored securely on our cloud servers.</p>
              <ul style={{ paddingLeft: '20px', marginBottom: '16px', listStyleType: 'disc' }}>
                <li style={{ marginBottom: '8px' }}>We collect and transmit your data to our secure external servers solely for the purpose of providing you with educational content and activity logs across devices.</li>
                <li style={{ marginBottom: '8px' }}>Your progress is saved to your account in the cloud, allowing you to access it securely anytime.</li>
              </ul>
              
              <h3 style={{ fontSize: '18px', fontWeight: 'bold', marginTop: '32px', marginBottom: '12px', color: 'var(--text-color)' }}>6. Intellectual Property & Copyright</h3>
              <p style={{ marginBottom: '8px' }}>All content included in this application, such as text, graphics, logos, 3D models, animations, user interfaces, and software code, is the property of the developers and Cavite State University - Bacoor City Campus or its content suppliers and is protected by copyright laws.</p>
              <ul style={{ paddingLeft: '20px', marginBottom: '16px', listStyleType: 'disc' }}>
                <li style={{ marginBottom: '8px' }}>Third-Party Assets: Certain assets (e.g., Unity engine components, Vuforia SDK) are used under license from their respective owners.</li>
                <li style={{ marginBottom: '8px' }}>Restrictions: You may not copy, reproduce, distribute, reverse engineer, or create derivative works from this application without express written permission from the copyright holders.</li>
              </ul>
              
              <h3 style={{ fontSize: '18px', fontWeight: 'bold', marginTop: '32px', marginBottom: '12px', color: 'var(--text-color)' }}>7. Acceptance of Terms</h3>
              <p style={{ marginBottom: '32px' }}>By clicking "Accept" or continuing to use SciLab AR, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions.</p>
              
              <hr style={{ borderColor: 'var(--border-light)', margin: '32px 0' }} />
              <p style={{ textAlign: 'center', fontSize: '14px', fontWeight: 'bold', color: 'var(--text-secondary)' }}>Copyright © 2026 SciLab AR. All Rights Reserved. Cavite State University - Bacoor City Campus</p>
            </div>
          ) : (
            <div style={{ color: 'var(--text-color)', lineHeight: '1.6' }}>
              <h2 style={{ fontSize: '24px', fontWeight: 'bold', marginBottom: '24px', color: 'var(--text-color)' }}>Privacy Policy</h2>
              
              <h3 style={{ fontSize: '18px', fontWeight: 'bold', marginTop: '32px', marginBottom: '12px', color: 'var(--text-color)' }}>Data Privacy and Storage</h3>
              <p style={{ marginBottom: '8px' }}>SciLab AR utilizes cloud services to sync your progress. Your data, including names, progress logs, and experiment records, are stored securely on our cloud servers.</p>
              <ul style={{ paddingLeft: '20px', marginBottom: '16px', listStyleType: 'disc' }}>
                <li style={{ marginBottom: '8px' }}>We collect and transmit your data to our secure external servers solely for the purpose of providing you with educational content and activity logs across devices.</li>
                <li style={{ marginBottom: '8px' }}>Your progress is saved to your account in the cloud, allowing you to access it securely anytime.</li>
              </ul>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
