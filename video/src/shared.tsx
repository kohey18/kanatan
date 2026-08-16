import {interpolate, useCurrentFrame} from 'remotion';

export const BLUE = '#0017c1';
export const RED = '#d64550';
export const INK = '#1a1a1a';
export const SUB = '#333333';
export const BAR = '#d9d9d9';
export const FONT = "'Hiragino Sans', 'Noto Sans JP', sans-serif";

/** Bottom-centered caption that fades in and rises slightly. */
export const Caption: React.FC<{text: string; appear?: number}> = ({text, appear = 8}) => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame, [appear, appear + 15], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  const y = interpolate(frame, [appear, appear + 15], [24, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  return (
    <div
      style={{
        position: 'absolute',
        bottom: 96,
        width: '100%',
        textAlign: 'center',
        fontFamily: FONT,
        fontSize: 52,
        fontWeight: 600,
        color: INK,
        opacity,
        transform: `translateY(${y}px)`,
        letterSpacing: '0.02em',
      }}
    >
      {text}
    </div>
  );
};

/** Fade the whole clip in over the first few frames (soft cut). */
export const ClipFade: React.FC<{children: React.ReactNode}> = ({children}) => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame, [0, 8], [0, 1], {
    extrapolateRight: 'clamp',
  });
  return <div style={{position: 'absolute', inset: 0, opacity}}>{children}</div>;
};

/** A laptop with an abstract document of gray bars. barWidths in px (0 = hidden). */
export const Laptop: React.FC<{
  barWidths: number[];
  children?: React.ReactNode;
}> = ({barWidths, children}) => {
  return (
    <div style={{position: 'relative', width: 1100, margin: '0 auto'}}>
      <div
        style={{
          width: 980,
          height: 560,
          margin: '0 auto',
          background: '#ffffff',
          border: `7px solid ${INK}`,
          borderRadius: 28,
          padding: '56px 64px',
          boxSizing: 'border-box',
          position: 'relative',
        }}
      >
        {barWidths.map((w, i) => (
          <div
            key={i}
            style={{
              width: Math.max(0, w),
              height: 30,
              borderRadius: 15,
              background: BAR,
              marginBottom: 34,
            }}
          />
        ))}
        {children}
      </div>
      <div
        style={{
          width: 1100,
          height: 26,
          background: INK,
          borderRadius: '0 0 22px 22px',
          marginTop: 0,
        }}
      />
    </div>
  );
};
