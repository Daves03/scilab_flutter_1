import { useState } from 'react';
import { signInWithEmailAndPassword } from 'firebase/auth';
import { auth } from '../firebase';
import { ShieldCheck, Loader2 } from 'lucide-react';

export default function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleLogin = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    
    try {
      await signInWithEmailAndPassword(auth, email, password);
      // App.jsx handles the redirect and role checking
    } catch (err) {
      setError('Invalid email or password, or you are not an admin.');
      setLoading(false);
      auth.signOut();
    }
  };

  return (
    <div className="animate-fade-in" style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100vh', padding: '20px' }}>
      <div className="glass-panel" style={{ width: '100%', maxWidth: '400px', padding: '40px' }}>
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', marginBottom: '32px' }}>
          <div style={{ 
            background: 'linear-gradient(135deg, rgba(124, 58, 237, 0.2), rgba(0, 212, 255, 0.2))',
            padding: '16px',
            borderRadius: '50%',
            marginBottom: '16px',
            border: '1px solid var(--border-light)'
          }}>
            <ShieldCheck size={40} color="var(--accent-cyan)" />
          </div>
          <h2 style={{ marginBottom: '8px' }}>Admin Portal</h2>
          <p style={{ textAlign: 'center', fontSize: '0.9rem' }}>Sign in with your administrator account to continue.</p>
        </div>

        {error && (
          <div style={{ 
            background: 'rgba(255, 71, 87, 0.1)', 
            border: '1px solid rgba(255, 71, 87, 0.3)',
            color: 'var(--accent-red)',
            padding: '12px',
            borderRadius: '8px',
            marginBottom: '20px',
            fontSize: '0.9rem',
            textAlign: 'center'
          }}>
            {error}
          </div>
        )}

        <form onSubmit={handleLogin}>
          <div className="input-group">
            <label className="input-label">Email Address</label>
            <input 
              type="email" 
              className="input-field" 
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required 
              placeholder="admin@school.edu"
            />
          </div>
          
          <div className="input-group" style={{ marginBottom: '32px' }}>
            <label className="input-label">Password</label>
            <input 
              type="password" 
              className="input-field"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required 
              placeholder="••••••••"
            />
          </div>

          <button 
            type="submit" 
            className="btn btn-primary" 
            style={{ width: '100%', padding: '14px' }}
            disabled={loading}
          >
            {loading ? <Loader2 className="animate-spin" size={20} /> : 'Secure Login'}
          </button>
        </form>
      </div>
    </div>
  );
}
