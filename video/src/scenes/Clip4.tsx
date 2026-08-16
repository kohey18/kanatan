import {AbsoluteFill, Img, interpolate, spring, staticFile, useCurrentFrame, useVideoConfig} from 'remotion';
import {FONT, INK, SUB, ClipFade} from '../shared';

const FadeRise: React.FC<{at: number; children: React.ReactNode; style?: React.CSSProperties}> = ({
  at,
  children,
  style,
}) => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame, [at, at + 14], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  const y = interpolate(frame, [at, at + 14], [20, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  return <div style={{opacity, transform: `translateY(${y}px)`, ...style}}>{children}</div>;
};

export const Clip4: React.FC = () => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();

  const enter = spring({frame, fps, config: {damping: 11, stiffness: 120}});
  // One gentle pulse after settling.
  const pulse =
    frame > 70 && frame < 100 ? 1 + 0.05 * Math.sin(((frame - 70) / 30) * Math.PI) : 1;
  const glowScale = interpolate(frame, [10, 60], [0.8, 1.7], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  const glowOpacity = interpolate(frame, [10, 40, 90], [0, 0.45, 0.25], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  return (
    <ClipFade>
      <AbsoluteFill
        style={{background: '#ffffff', justifyContent: 'center', alignItems: 'center', fontFamily: FONT}}
      >
        <div style={{position: 'relative', width: 340, height: 340, marginTop: -120}}>
          <div
            style={{
              position: 'absolute',
              inset: -120,
              borderRadius: '50%',
              background:
                'radial-gradient(circle, rgba(0,23,193,0.20) 0%, rgba(214,69,80,0.10) 45%, rgba(255,255,255,0) 70%)',
              transform: `scale(${glowScale})`,
              opacity: glowOpacity,
            }}
          />
          <Img
            src={staticFile('app-icon.png')}
            style={{
              width: 340,
              height: 340,
              transform: `scale(${enter * pulse})`,
            }}
          />
        </div>
        <FadeRise at={40}>
          <div style={{fontSize: 104, fontWeight: 700, color: INK, marginTop: 36, letterSpacing: '0.01em'}}>
            Kanatan
          </div>
        </FadeRise>
        <FadeRise at={62}>
          <div style={{fontSize: 44, fontWeight: 600, color: SUB, marginTop: 10}}>
            もう、入力モードで迷わない。
          </div>
        </FadeRise>
        <FadeRise at={92}>
          <div style={{fontSize: 30, color: '#666666', marginTop: 34}}>
            無料・オープンソース ／ macOS 13+ ／ github.com/kohey18/kanatan
          </div>
        </FadeRise>
      </AbsoluteFill>
    </ClipFade>
  );
};
