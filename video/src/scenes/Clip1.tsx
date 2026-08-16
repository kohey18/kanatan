import {AbsoluteFill, interpolate, useCurrentFrame} from 'remotion';
import {BLUE, FONT, INK, RED, Caption, ClipFade, ModeSquare} from '../shared';

// The classic mishap: intending こんにちは but the IME is still in English
// mode, so "konnnichiha" comes out. Delete it all... and hesitate, because
// which mode is it in now?
const TYPO = 'konnnichiha';
const RETRY = 'konn';

const TYPE_START = 15;
const TYPE_PER_CHAR = 5; // ends around frame 70
const DELETE_START = 100;
const DELETE_PER_CHAR = 4; // ends around frame 144
const RETRY_START = 168;
const RETRY_PER_CHAR = 7; // ends around frame 196

const typedCount = (frame: number): number => {
  const grown = Math.max(
    0,
    Math.min(TYPO.length, Math.floor((frame - TYPE_START) / TYPE_PER_CHAR) + (frame >= TYPE_START ? 1 : 0))
  );
  if (frame < DELETE_START) return grown;
  const deleted = Math.floor((frame - DELETE_START) / DELETE_PER_CHAR) + 1;
  return Math.max(0, TYPO.length - deleted);
};

const retryCount = (frame: number): number =>
  Math.max(
    0,
    Math.min(RETRY.length, Math.floor((frame - RETRY_START) / RETRY_PER_CHAR) + (frame >= RETRY_START ? 1 : 0))
  );

// Which indicator looks active: English at first; flickers uncertainly
// right after deleting, and again while hesitating at the end.
const uncertainAt = (frame: number, period: number): boolean => Math.floor(frame / period) % 2 === 0;
const activeMode = (frame: number): 'en' | 'jp' | 'flicker' => {
  if (frame >= 146 && frame < 168) return 'flicker';
  if (frame >= 200) return 'flicker';
  return 'en';
};

export const Clip1: React.FC = () => {
  const frame = useCurrentFrame();

  const text = frame < RETRY_START ? TYPO.slice(0, typedCount(frame)) : RETRY.slice(0, retryCount(frame));
  const mode = activeMode(frame);
  const enActive = mode === 'en' || (mode === 'flicker' && uncertainAt(frame, 6));
  const jpActive = mode === 'flicker' && !uncertainAt(frame, 6);

  const caretVisible = Math.floor(frame / 14) % 2 === 0;
  // Small shake when realizing the mistake, and while hesitating.
  const shake =
    (frame >= 74 && frame <= 96) || (frame >= 200 && frame <= 222) ? Math.sin(frame * 1.9) * 3 : 0;
  const zoom = interpolate(frame, [0, 240], [1, 1.05]);

  // A "?!" that pops up when the mistake is noticed, and at the end.
  const confusionOpacity =
    interpolate(frame, [74, 82, 96, 104], [0, 1, 1, 0], {
      extrapolateLeft: 'clamp',
      extrapolateRight: 'clamp',
    }) +
    interpolate(frame, [202, 210, 236, 240], [0, 1, 1, 1], {
      extrapolateLeft: 'clamp',
      extrapolateRight: 'clamp',
    });

  return (
    <ClipFade>
      <AbsoluteFill style={{background: '#ffffff', justifyContent: 'center'}}>
        <div style={{transform: `scale(${zoom}) translateX(${shake}px)`, marginTop: -40}}>
          <div style={{display: 'flex', gap: 36, justifyContent: 'center', marginBottom: 44}}>
            <ModeSquare color={BLUE} glyph="A" active={enActive} />
            <ModeSquare color={RED} glyph="あ" active={jpActive} />
          </div>
          {/* Laptop: こんにちは のつもりが konnnichiha */}
          <div style={{position: 'relative', width: 1100, margin: '0 auto'}}>
            <div
              style={{
                width: 980,
                height: 470,
                margin: '0 auto',
                background: '#ffffff',
                border: `7px solid ${INK}`,
                borderRadius: 28,
                padding: '52px 64px',
                boxSizing: 'border-box',
                fontFamily: FONT,
                fontSize: 60,
                fontWeight: 600,
                letterSpacing: '0.01em',
                position: 'relative',
              }}
            >
              <div style={{display: 'flex', alignItems: 'center'}}>
                <span style={{color: BLUE}}>{text}</span>
                <span
                  style={{
                    width: 7,
                    height: 66,
                    marginLeft: 6,
                    borderRadius: 4,
                    background: BLUE,
                    opacity: caretVisible ? 1 : 0.15,
                  }}
                />
              </div>
              <div
                style={{
                  position: 'absolute',
                  top: 40,
                  right: 56,
                  fontSize: 76,
                  fontWeight: 700,
                  color: RED,
                  opacity: Math.min(1, confusionOpacity),
                  transform: 'rotate(8deg)',
                }}
              >
                ?!
              </div>
            </div>
            <div style={{width: 1100, height: 26, background: INK, borderRadius: '0 0 22px 22px'}} />
          </div>
        </div>
        <Caption text="US配列は好き。でも、日本語切り替えだけがずっと面倒だった。" />
      </AbsoluteFill>
    </ClipFade>
  );
};
