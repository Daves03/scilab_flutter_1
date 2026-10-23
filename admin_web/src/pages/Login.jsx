import { useEffect, useState } from 'react';
import { reload, sendEmailVerification, signInWithEmailAndPassword, signOut } from 'firebase/auth';
import { auth } from '../firebase';
import { ADMIN_EMAIL, clearPendingAdminDeviceVerification, hasPendingAdminDeviceVerification, isTrustedAdminDevice, sendAdminDeviceVerification, watchAdminDeviceApproval } from '../services/adminDeviceVerification';
import { logAdminActivity } from '../services/adminActivityService';
import { Loader2, Eye, EyeOff, MailCheck, RefreshCw, ShieldCheck } from 'lucide-react';
import scilabLogo from '../assets/scilab_logo.png';
import AuthMovingBackground from '../components/AuthMovingBackground';
import AuthThemeToggle from '../components/AuthThemeToggle';

const getSignInErrorMessage = (error) => {
  switch (error?.code) {
    case 'auth/invalid-credential':
    case 'auth/invalid-login-credentials':
    case 'auth/wrong-password':
    case 'auth/user-not-found':
      return 'Incorrect email or password. Please try again.';
    case 'auth/too-many-requests':
      return 'Too many failed login attempts. Please wait a few minutes before trying again.';
    case 'auth/network-request-failed':
      return 'Network error. Check your internet connection and try again.';
    case 'auth/user-disabled':
      return 'This administrator account has been disabled.';
    case 'auth/operation-not-allowed':
      return 'Admin email and password login is not enabled in Firebase Authentication.';
    default:
      return 'Could not sign in. Please check your credentials and try again.';
  }
};

const getVerificationErrorMessage = (error) => {
  switch (error?.code) {
    case 'auth/unauthorized-continue-uri':
      return 'This admin website domain is not authorized in Firebase Authentication.';
    case 'auth/operation-not-allowed':
      return 'Firebase Email Link authentication is not enabled.';
    case 'auth/too-many-requests':
      return 'Too many verification emails were requested. Please wait before trying again.';
    case 'auth/network-request-failed':
      return 'Network error while sending verification. Check your connection and try again.';
    default:
      return 'Login succeeded, but the device verification email could not be sent. Please try again.';
  }
};

export default function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [verificationSent, setVerificationSent] = useState(hasPendingAdminDeviceVerification());
  const [accountVerificationSent, setAccountVerificationSent] = useState(false);

  useEffect(() => {
    if (!verificationSent || !auth.currentUser) return undefined;
    return watchAdminDeviceApproval(
      auth.currentUser,
      async () => {
        await logAdminActivity({
          type: 'admin_device_verified',
          title: 'New admin browser verified',
          details: { browser: window.navigator.userAgent },
        });
      },
      (verificationError) => {
        setVerificationSent(false);
        setError(verificationError.message || 'Could not verify this device.');
      },
    );
  }, [verificationSent]);

  const handleLogin = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    let passwordAuthenticated = false;
    
    try {
      if (email.trim().toLowerCase() !== ADMIN_EMAIL) {
        throw new Error('Incorrect email or password. Please try again.');
      }

      const credential = await signInWithEmailAndPassword(auth, ADMIN_EMAIL, password);
      passwordAuthenticated = true;
      if (!isTrustedAdminDevice(credential.user)) {
        if (!credential.user.emailVerified) {
          await sendEmailVerification(credential.user);
          setAccountVerificationSent(true);
        } else {
          await sendAdminDeviceVerification(credential.user);
          setVerificationSent(true);
        }
      }
      setLoading(false);
    } catch (err) {
      console.error('Admin sign-in failed:', err);
      const isWrongAdminEmail = err.message === 'Incorrect email or password. Please try again.';
      setError(isWrongAdminEmail
        ? err.message
        : passwordAuthenticated
          ? getVerificationErrorMessage(err)
          : getSignInErrorMessage(err));
      if (!passwordAuthenticated) setPassword('');
      setLoading(false);
      await signOut(auth).catch(() => {});
    }
  };

  const handleResendVerification = async () => {
    if (!auth.currentUser) {
      clearPendingAdminDeviceVerification();
      setVerificationSent(false);
      setError('Your login session expired. Please sign in again.');
      return;
    }

    setLoading(true);
    setError('');
    try {
      await sendAdminDeviceVerification(auth.currentUser);
      setVerificationSent(true);
    } catch (resendError) {
      console.error('Could not resend device verification:', resendError);
      setError('Could not resend the verification email. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleAccountEmailVerified = async () => {
    const user = auth.currentUser;
    if (!user) {
      setAccountVerificationSent(false);
      setError('Your login session expired. Please sign in again.');
      return;
    }

    setLoading(true);
    setError('');
    try {
      await reload(user);
      if (!user.emailVerified) {
        setError('The email is not verified yet. Open the Firebase email first, then try again.');
        return;
      }
      await sendAdminDeviceVerification(user);
      setAccountVerificationSent(false);
      setVerificationSent(true);
    } catch (verificationError) {
      console.error('Could not check administrator email:', verificationError);
      setError('Could not confirm the administrator email. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleResendAccountVerification = async () => {
    if (!auth.currentUser) {
      setAccountVerificationSent(false);
      setError('Your login session expired. Please sign in again.');
      return;
    }
    setLoading(true);
    setError('');
    try {
      await sendEmailVerification(auth.currentUser);
    } catch (verificationError) {
      console.error('Could not resend administrator email verification:', verificationError);
      setError('Could not resend the email. Wait a moment and try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleCancelVerification = async () => {
    clearPendingAdminDeviceVerification();
    await signOut(auth);
    setVerificationSent(false);
    setAccountVerificationSent(false);
    setPassword('');
    setError('');
  };

  return (
    <div className="animate-fade-in auth-page-shell" style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', minHeight: '100vh', padding: '20px' }}>
      <AuthMovingBackground />
      <AuthThemeToggle />
      <div className="glass-panel auth-login-card" style={{ width: '100%', maxWidth: '400px', padding: '40px' }}>
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

        {accountVerificationSent ? (
          <div style={{ textAlign: 'center' }}>
            <div style={{ width: '58px', height: '58px', borderRadius: '16px', background: 'rgba(0, 214, 255, 0.12)', color: 'var(--accent-cyan)', display: 'inline-flex', alignItems: 'center', justifyContent: 'center', marginBottom: '16px' }}>
              <MailCheck size={30} />
            </div>
            <h3 style={{ marginBottom: '10px' }}>Verify the admin email first</h3>
            <p style={{ fontSize: '0.9rem', lineHeight: 1.6, marginBottom: '20px' }}>
              Firebase sent an account verification email to <strong style={{ color: 'var(--text-primary)' }}>{ADMIN_EMAIL}</strong>. Verify it, return here, then continue to approve this browser.
            </p>
            <button type="button" className="btn btn-primary" style={{ width: '100%', marginBottom: '10px' }} onClick={handleAccountEmailVerified} disabled={loading}>
              {loading ? <Loader2 className="animate-spin" size={18} /> : <><ShieldCheck size={18} /> I verified my email</>}
            </button>
            <button type="button" className="btn btn-secondary" style={{ width: '100%', marginBottom: '10px' }} onClick={handleResendAccountVerification} disabled={loading}>
              <RefreshCw size={18} /> Resend email
            </button>
            <button type="button" className="btn btn-secondary" style={{ width: '100%' }} onClick={handleCancelVerification}>
              Cancel and return to login
            </button>
          </div>
        ) : verificationSent ? (
          <div style={{ textAlign: 'center' }}>
            <div style={{ width: '58px', height: '58px', borderRadius: '16px', background: 'rgba(0, 214, 255, 0.12)', color: 'var(--accent-cyan)', display: 'inline-flex', alignItems: 'center', justifyContent: 'center', marginBottom: '16px' }}>
              <MailCheck size={30} />
            </div>
            <h3 style={{ marginBottom: '10px' }}>Verify this new device</h3>
            <p style={{ fontSize: '0.9rem', lineHeight: 1.6, marginBottom: '20px' }}>
              A confirmation link was sent to <strong style={{ color: 'var(--text-primary)' }}>{ADMIN_EMAIL}</strong>. You may open it in your SciLab account browser. This waiting screen will log in automatically after approval.
            </p>
            <div style={{ display: 'flex', justifyContent: 'center', marginBottom: '18px', color: 'var(--accent-cyan)' }}>
              <Loader2 className="animate-spin" size={22} />
            </div>
            <button type="button" className="btn btn-primary" style={{ width: '100%', marginBottom: '10px' }} onClick={handleResendVerification} disabled={loading}>
              {loading ? <Loader2 className="animate-spin" size={18} /> : <><RefreshCw size={18} /> Resend verification</>}
            </button>
            <button type="button" className="btn btn-secondary" style={{ width: '100%' }} onClick={handleCancelVerification}>
              Cancel and return to login
            </button>
          </div>
        ) : (
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
            {loading ? <Loader2 className="animate-spin" size={20} /> : <><ShieldCheck size={18} /> Login</>}
          </button>
        </form>
        )}
      </div>
    </div>
  );
}
