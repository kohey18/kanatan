import {AbsoluteFill, interpolate, spring, useCurrentFrame, useVideoConfig} from 'remotion';
import {BLUE, FONT, INK, RED, Caption, ClipFade} from '../shared';

const KEY = {
  background: '#ffffff',
  border: `4px solid ${INK}`,
  borderRadius: 14,
  height: 88,
} as const;

const Row: React.FC<{widths: number[]}> = ({widths}) => (
  <div style={{display: 'flex', gap: 16, marginBottom: 16}}>
    {widths.map((w, i) => (
      <div key={i} style={{...KEY, width: w}} />
    ))}
  </div>
);

/** A special key that gets tapped: press dip, fill color, white glyph, ripple. */
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
          width: 124,
          background: filled > 0.5 ? color : '#ffffff',
          transform: `scale(${scale})`,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          fontFamily: FONT,
          fontSize: 48,
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

// Typing schedule: tap left cmd -> type "Hello" in English,
// tap right cmd -> continue with こんにちは in Japanese.
const EN_TEXT = 'Hello';
const JP_TEXT = 'こんにちは';
const EN_START = 78;
const EN_PER_CHAR = 8;
const JP_START = 168;
const JP_PER_CHAR = 11;

const visibleCount = (frame: number, start: number, total: number, perChar: number): number =>
  Math.max(0, Math.min(total, Math.floor((frame - start) / perChar) + (frame >= start ? 1 : 0)));

export const Clip2: React.FC = () => {
  const frame = useCurrentFrame();

  const en = EN_TEXT.slice(0, visibleCount(frame, EN_START, EN_TEXT.length, EN_PER_CHAR));
  const jp = JP_TEXT.slice(0, visibleCount(frame, JP_START, JP_TEXT.length, JP_PER_CHAR));
  const caretColor = frame < 150 ? BLUE : RED;
  const caretVisible = Math.floor(frame / 16) % 2 === 0;

  return (
    <ClipFade>
      <AbsoluteFill style={{background: '#ffffff', justifyContent: 'center', alignItems: 'center'}}>
        {/* Input field: actually typing English, then Japanese */}
        <div
          style={{
            width: 1180,
            height: 118,
            border: `5px solid ${INK}`,
            borderRadius: 22,
            marginTop: -40,
            marginBottom: 44,
            display: 'flex',
            alignItems: 'center',
            paddingLeft: 40,
            fontFamily: FONT,
            fontSize: 58,
            fontWeight: 600,
            color: INK,
            letterSpacing: '0.01em',
          }}
        >
          <span>{en}</span>
          <span>{jp}</span>
          <span
            style={{
              width: 8,
              height: 68,
              marginLeft: 8,
              background: caretColor,
              opacity: caretVisible ? 1 : 0.15,
              borderRadius: 4,
            }}
          />
        </div>

        <div
          style={{
            background: '#f7f7f7',
            border: `6px solid ${INK}`,
            borderRadius: 34,
            padding: 38,
            transform: 'scale(0.92)',
          }}
        >
          <Row widths={[112, 112, 112, 112, 112, 112, 112, 112, 112, 112, 112, 112]} />
          <Row widths={[168, 112, 112, 112, 112, 112, 112, 112, 112, 112, 168]} />
          <Row widths={[205, 112, 112, 112, 112, 112, 112, 112, 112, 225]} />
          <Row widths={[262, 112, 112, 112, 112, 112, 112, 112, 280]} />
          <div style={{display: 'flex', gap: 16}}>
            <div style={{...KEY, width: 112}} />
            <div style={{...KEY, width: 112}} />
            <TapKey tapAt={60} color={BLUE} glyph="A" />
            <div style={{...KEY, width: 580}} />
            <TapKey tapAt={150} color={RED} glyph="あ" />
            <div style={{...KEY, width: 112}} />
            <div style={{...KEY, width: 112}} />
          </div>
        </div>
        <Caption text="左⌘をタップで英数、右⌘でかな。" />
      </AbsoluteFill>
    </ClipFade>
  );
};
