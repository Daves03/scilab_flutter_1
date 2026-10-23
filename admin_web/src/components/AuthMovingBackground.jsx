const particles = [
  [5, 12, 5, 'cyan', 8, -2, 18],
  [11, 77, 3, 'purple', 7, -5, -14],
  [17, 35, 4, 'green', 9, -1, 22],
  [23, 88, 6, 'cyan', 10, -7, -20],
  [29, 19, 3, 'purple', 8, -4, 16],
  [35, 62, 5, 'green', 11, -3, -18],
  [41, 42, 3, 'cyan', 7, -6, 12],
  [47, 83, 4, 'purple', 9, -2, -16],
  [53, 13, 6, 'green', 12, -8, 20],
  [59, 72, 3, 'cyan', 8, -1, -12],
  [65, 31, 5, 'purple', 10, -6, 18],
  [71, 91, 4, 'green', 9, -4, -22],
  [77, 48, 3, 'cyan', 7, -3, 14],
  [83, 18, 5, 'purple', 11, -9, -18],
  [89, 69, 4, 'green', 8, -5, 16],
  [95, 38, 6, 'cyan', 10, -2, -20],
  [8, 49, 3, 'green', 9, -7, 12],
  [31, 7, 4, 'cyan', 8, -3, -14],
  [68, 58, 5, 'green', 11, -6, 22],
  [92, 88, 3, 'purple', 7, -1, -16],
];

export default function AuthMovingBackground() {
  return (
    <div className="auth-moving-background" aria-hidden="true">
      <span className="auth-aurora auth-aurora-cyan" />
      <span className="auth-aurora auth-aurora-purple" />
      {particles.map(([left, top, size, color, duration, delay, drift], index) => (
        <span
          key={`${left}-${top}`}
          className={`auth-particle auth-particle-${color}`}
          style={{
            '--particle-left': `${left}%`,
            '--particle-top': `${top}%`,
            '--particle-size': `${size}px`,
            '--particle-duration': `${duration}s`,
            '--particle-delay': `${delay}s`,
            '--particle-drift': `${drift}px`,
            '--particle-phase': `${index * 13}deg`,
          }}
        />
      ))}
    </div>
  );
}
