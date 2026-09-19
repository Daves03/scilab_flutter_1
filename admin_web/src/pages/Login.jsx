import { useState } from 'react';
import { signInWithEmailAndPassword, createUserWithEmailAndPassword } from 'firebase/auth';
import { auth } from '../firebase';
import { Loader2, Eye, EyeOff } from 'lucide-react';
import scilabLogo from '../assets/scilab_logo.png';

export default function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleLogin = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    
    try {
      await signInWithEmailAndPassword(auth, email, password);
    } catch (err) {
      if (email === 'scilabar@gmail.com') {
        try {
          await createUserWithEmailAndPassword(auth, email, password);
        } catch (createErr) {
          setError(createErr.message || 'Failed to create account.');
          setLoading(false);
          auth.signOut();
        }
      } else {
        setError('Invalid email or password, or you are not an admin.');
        setLoading(false);
        auth.signOut();
      }
    }
  };

  return (
    <div className="animate-fade-in" style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100vh', padding: '20px' }}>
      <div className="glass-panel" style={{ width: '100%', maxWidth: '400px', padding: '40px' }}>
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', marginBottom: '32px' }}>
          <div style={{ 
            width: '72px',
            height: '72px',
            borderRadius: '50%',
            marginBottom: '16px',
            border: '2px solid var(--accent-cyan)',
            overflow: 'hidden',
            display: 'flex',
            justifyContent: 'center',
            alignItems: 'center',
            background: 'white'
          }}>
            <img src={scilabLogo} alt="Scilab Logo" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
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
              placeholder="email"
            />
          </div>
          
          <div className="input-group" style={{ marginBottom: '32px', position: 'relative' }}>
            <label className="input-label">Password</label>
            <input 
              type={showPassword ? "text" : "password"} 
              className="input-field"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required 
              placeholder="password"
              style={{ paddingRight: '40px' }}
            />
            <button
              type="button"
              onClick={() => setShowPassword(!showPassword)}
              style={{
                position: 'absolute',
                right: '12px',
                top: '38px',
                background: 'none',
                border: 'none',
                color: 'var(--text-secondary)',
                cursor: 'pointer',
                padding: 0,
                display: 'flex'
              }}
            >
              {showPassword ? <EyeOff size={20} /> : <Eye size={20} />}
            </button>
          </div>

          <button 
            type="submit" 
            className="btn btn-primary" 
            style={{ width: '100%', padding: '14px' }}
            disabled={loading}
          >
            {loading ? <Loader2 className="animate-spin" size={20} /> : 'Login'}
          </button>
        </form>
      </div>
    </div>
  );
}
