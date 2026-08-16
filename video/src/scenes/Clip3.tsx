import {AbsoluteFill, interpolate, useCurrentFrame} from 'remotion';
import {BLUE, RED, Caption, ClipFade, Laptop} from '../shared';

const TARGETS = [700, 620, 740, 560, 660];

export const Clip3: React.FC = () => {
  const frame = useCurrentFrame();

  // Bars fill steadily, one after another — no deleting this time.
  const widths = TARGETS.map((t, i) =>
    interpolate(frame, [i * 38, i * 38 + 34], [0, t], {
      extrapolateLeft: 'clamp',
      extrapolateRight: 'clamp',
    })
  );

  const drift = interpolate(frame, [0, 240], [-18, 18]);
  // Alternating gentle pulse, like a metronome.
  const pulse = Math.sin(frame / 8);
  const blueScale = 1 + 0.1 * Math.max(0, pulse);
  const redScale = 1 + 0.1 * Math.max(0, -pulse);

  const square = (color: string, scale: number): React.CSSProperties => ({
    width: 72,
    height: 72,
    borderRadius: 20,
    background: color,
    transform: `scale(${scale})`,
  });

  return (
    <ClipFade>
      <AbsoluteFill style={{background: '#ffffff', justifyContent: 'center'}}>
        <div style={{transform: `translateX(${drift}px)`, marginTop: -40}}>
          <div style={{display: 'flex', gap: 40, justifyContent: 'center', marginBottom: 48}}>
            <div style={square(BLUE, blueScale)} />
            <div style={square(RED, redScale)} />
          </div>
          <Laptop barWidths={widths} />
        </div>
        <Caption text="押すキーで、行き先が決まる。もう迷わない。" />
      </AbsoluteFill>
    </ClipFade>
  );
};
