import { useEffect, useRef, useState } from 'react';
import { CheckCircle, Loader2, ShieldCheck, XCircle } from 'lucide-react';
import { approveAdminDeviceRequest } from '../services/adminDeviceVerification';
import scilabLogo from '../assets/scilab_logo.png';
import AuthMovingBackground from '../components/AuthMovingBackground';
import AuthThemeToggle from '../components/AuthThemeToggle';

export default function AdminDeviceApproval() {
  const [status, setStatus] = useState('loading');
  const [message, setMessage] = useState('Confirming the new device request...');
  const started = useRef(false);

  useEffect(() => {
    if (started.current) return;
    started.current = true;

    approveAdminDeviceRequest(window.location.href)
      .then(() => {
        setStatus('success');
        setMessage('The new browser is approved. Return to the waiting login screen—it will open automatically.');
      })
      .catch((error) => {
        console.error('Admin device approval failed:', error);
        setStatus('error');
        setMessage(error.message || 'The device could not be approved.');
      });
  }, []);

  const icon = status === 'loading'
    ? <Loader2 className="animate-spin" size={34} />
    : status === 'success'
      ? <CheckCircle size={34} />
      : <XCircle size={34} />;

  return (
    <div className="animate-fade-in auth-page-shell" style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', minHeight: '100vh', padding: '20px' }}>
      <AuthMovingBackground />
      <AuthThemeToggle />
      <div className="glass-panel auth-login-card" style={{ width: '100%', maxWidth: '430px', padding: '40px', textAlign: 'center' }}>
        <img src={scilabLogo} alt="SciLab AR" style={{ width: '72px', height: '72px', borderRadius: '50%', background: 'white', border: '2px solid var(--accent-cyan)', marginBottom: '18px' }} />
        <div style={{ color: status === 'error' ? 'var(--accent-red)' : status === 'success' ? 'var(--accent-green)' : 'var(--accent-cyan)', marginBottom: '14px' }}>
          {icon}
        </div>
        <h2 style={{ marginBottom: '10px' }}>
          {status === 'loading' ? 'Approving Device' : status === 'success' ? 'Device Approved' : 'Approval Failed'}
        </h2>
        <p style={{ lineHeight: 1.6, marginBottom: '22px' }}>{message}</p>
        {status === 'success' && (
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px', color: 'var(--accent-green)', fontWeight: 600 }}>
            <ShieldCheck size={18} /> Approval confirmed
          </div>
        )}
      </div>
    </div>
  );
}
