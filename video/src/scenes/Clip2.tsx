import {AbsoluteFill, interpolate, spring, useCurrentFrame, useVideoConfig} from 'remotion';
import {BLUE, FONT, INK, RED, Caption, ClipFade} from '../shared';

const KEY = {
  background: '#ffffff',
  border: `4px solid ${INK}`,
  borderRadius: 14,
  height: 96,
} as const;

const Row: React.FC<{widths: number[]; children?: React.ReactNode}> = ({widths}) => (
  <div style={{display: 'flex', gap: 18, marginBottom: 18}}>
    {widths.map((w, i) => (
      <div key={i} style={{...KEY, width: w}} />
    ))}
  </div>
);

/** A special key that gets tapped: press dip, fill color, glyph, ripple. */
const TapKey: React.FC<{tapAt: number; color: string; glyph: string}> = ({tapAt, color, glyph}) => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();

  const press = spring({frame: frame - tapAt, fps, config: {damping: 12, stiffness: 200}});
  const scale = frame < tapAt ? 1 : 1 - 0.1 * Math.sin(Math.min(press, 1) * Math.PI);
  const filled = interpolate(frame, [tapAt, tapAt + 6], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  const rippleR = interpolate(frame, [tapAt, tapAt + 26], [40, 260], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  const rippleO = interpolate(frame, [tapAt, tapAt + 26], [0.7, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  return (
    <div style={{position: 'relative'}}>
      <div
        style={{
          ...KEY,
          width: 130,
          background: filled > 0.5 ? color : '#ffffff',
          transform: `scale(${scale})`,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          fontFamily: FONT,
          fontSize: 52,
          fontWeight: 700,
          color: '#ffffff',
        }}
      >
        <span style={{opacity: filled}}>{glyph}</span>
      </div>
      {frame >= tapAt && (
        <div
          style={{
            position: 'absolute',
            top: '50%',
            left: '50%',
            width: rippleR * 2,
            height: rippleR * 2,
            marginLeft: -rippleR,
            marginTop: -rippleR,
            borderRadius: '50%',
            border: `6px solid ${color}`,
            opacity: rippleO,
            pointerEvents: 'none',
          }}
        />
      )}
    </div>
  );
};

export const Clip2: React.FC = () => {
  return (
    <ClipFade>
      <AbsoluteFill style={{background: '#ffffff', justifyContent: 'center', alignItems: 'center'}}>
        <div
          style={{
            background: '#f7f7f7',
            border: `6px solid ${INK}`,
            borderRadius: 36,
            padding: 44,
            marginTop: -50,
          }}
        >
          <Row widths={[120, 120, 120, 120, 120, 120, 120, 120, 120, 120, 120, 120]} />
          <Row widths={[180, 120, 120, 120, 120, 120, 120, 120, 120, 120, 180]} />
          <Row widths={[220, 120, 120, 120, 120, 120, 120, 120, 120, 240]} />
          <Row widths={[280, 120, 120, 120, 120, 120, 120, 120, 300]} />
          {/* Bottom row with the two Command keys */}
          <div style={{display: 'flex', gap: 18}}>
            <div style={{...KEY, width: 120}} />
            <div style={{...KEY, width: 120}} />
            <TapKey tapAt={60} color={BLUE} glyph="A" />
            <div style={{...KEY, width: 620}} />
            <TapKey tapAt={150} color={RED} glyph="あ" />
            <div style={{...KEY, width: 120}} />
            <div style={{...KEY, width: 120}} />
          </div>
        </div>
        <Caption text="左⌘をタップで英数、右⌘でかな。" />
      </AbsoluteFill>
    </ClipFade>
  );
};
