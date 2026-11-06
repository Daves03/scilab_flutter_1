import { useEffect, useState } from 'react';

export default function UserAvatar({ user, large = false }) {
  const avatarUrl = user?.avatarUrl?.trim() || '';
  const name = user?.name || 'Student';
  const [failed, setFailed] = useState(false);

  useEffect(() => setFailed(false), [avatarUrl]);

  return <div className={`teacher-avatar ${large ? 'large' : ''} ${avatarUrl && !failed ? 'has-image' : ''}`}>
    {avatarUrl && !failed
      ? <img src={avatarUrl} alt={`${name} profile`} onError={() => setFailed(true)} referrerPolicy="no-referrer" />
      : name.charAt(0).toUpperCase()}
  </div>;
}
