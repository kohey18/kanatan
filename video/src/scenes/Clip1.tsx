import {AbsoluteFill, interpolate, useCurrentFrame} from 'remotion';
import {BLUE, RED, Caption, ClipFade, Laptop} from '../shared';

const TARGETS = [640, 760, 560, 420];

// Grow between [start, start+dur], then shrink between [del, del+delDur].
const barWidth = (
  frame: number,
  target: number,
  start: number,
  del: number,
  regrow?: number
): number => {
  const grown = interpolate(frame, [start, start + 28], [0, target], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  const shrunk = interpolate(frame, [del, del + 14], [1, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  let w = grown * shrunk;
  if (regrow !== undefined && frame >= regrow) {
    w = interpolate(frame, [regrow, regrow + 40], [0, target * 0.8], {
      extrapolateRight: 'clamp',
    });
  }
  return w;
};

// Uncertain blue/red flicker for the mode indicator.
const FLICKS = [0, 26, 44, 72, 88, 112, 132, 158, 186, 214];
const flickerColor = (frame: number): string => {
  let idx = 0;
  for (let i = 0; i < FLICKS.length; i++) {
    if (frame >= FLICKS[i]) idx = i;
  }
  return idx % 2 === 0 ? BLUE : RED;
};

export const Clip1: React.FC = () => {
  const frame = useCurrentFrame();

  const widths = [
    barWidth(frame, TARGETS[0], 12, 118, 168),
    barWidth(frame, TARGETS[1], 34, 108, 196),
    barWidth(frame, TARGETS[2], 56, 98),
    barWidth(frame, TARGETS[3], 78, 88),
  ];

  const zoom = interpolate(frame, [0, 240], [1, 1.06]);
  // Small shake while deleting.
  const shake = frame >= 88 && frame <= 132 ? Math.sin(frame * 1.7) * 3 : 0;

  return (
    <ClipFade>
      <AbsoluteFill style={{background: '#ffffff', justifyContent: 'center'}}>
        <div style={{transform: `scale(${zoom}) translateX(${shake}px)`, marginTop: -60}}>
          <div style={{position: 'relative'}}>
            <Laptop barWidths={widths} />
            {/* Mode indicator flickering above the laptop */}
            <div
              style={{
                position: 'absolute',
                top: -108,
                left: '50%',
                transform: 'translateX(-50%)',
                width: 64,
                height: 64,
                borderRadius: 18,
                background: flickerColor(frame),
                opacity: 0.55 + 0.45 * Math.abs(Math.sin(frame / 7)),
              }}
            />
          </div>
        </div>
        <Caption text="US配列は好き。でも、切り替えだけがずっと面倒だった。" />
      </AbsoluteFill>
    </ClipFade>
  );
};
