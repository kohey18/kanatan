import {AbsoluteFill, interpolate, useCurrentFrame} from 'remotion';
import {BLUE, FONT, INK, RED, Caption, ClipFade} from '../shared';

type Mode = 'en' | 'jp';
type Seg = {text: string; mode: Mode; newline?: boolean};

// A realistic mixed EN/JP sentence, typed segment by segment.
const SEGS: Seg[] = [
  {text: 'Design Review', mode: 'en'},
  {text: 'の議事録です。', mode: 'jp'},
  {text: 'Kanatan', mode: 'en', newline: true},
  {text: 'なら、もう迷わない。', mode: 'jp'},
];

const START = 20;
const PER_CHAR = 5;
const SEG_GAP = 14;

// Flatten into per-character timestamps.
type Char = {ch: string; mode: Mode; at: number; line: number};
const CHARS: Char[] = (() => {
  const chars: Char[] = [];
  let t = START;
  let line = 0;
  for (const seg of SEGS) {
    if (seg.newline) line++;
    for (const ch of seg.text) {
      chars.push({ch, mode: seg.mode, at: t, line});
      t += PER_CHAR;
    }
    t += SEG_GAP;
  }
  return chars;
})();

const LAST_AT = CHARS[CHARS.length - 1].at;

const ModeSquare: React.FC<{color: string; glyph: string; active: boolean}> = ({color, glyph, active}) => {
  const frame = useCurrentFrame();
  const pulse = active ? 1 + 0.1 * Math.abs(Math.sin(frame / 5)) : 1;
  return (
    <div
      style={{
        width: 84,
        height: 84,
        borderRadius: 22,
        background: color,
        opacity: active ? 1 : 0.35,
        transform: `scale(${pulse})`,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        fontFamily: FONT,
        fontSize: 44,
        fontWeight: 700,
        color: '#ffffff',
      }}
    >
      {glyph}
    </div>
  );
};

export const Clip3: React.FC = () => {
  const frame = useCurrentFrame();

  const visible = CHARS.filter((c) => frame >= c.at);
  const lines: {ch: string; mode: Mode}[][] = [[], []];
  for (const c of visible) {
    lines[c.line].push({ch: c.ch, mode: c.mode});
  }

  // Which mode is being typed right now?
  const current = [...CHARS].reverse().find((c) => frame >= c.at - SEG_GAP);
  const typing = frame <= LAST_AT + 10;
  const mode: Mode = current?.mode ?? 'en';

  const caretLine = visible.length > 0 ? visible[visible.length - 1].line : 0;
  const caretVisible = Math.floor(frame / 14) % 2 === 0;
  const drift = interpolate(frame, [0, 240], [-14, 14]);

  const renderLine = (line: {ch: string; mode: Mode}[], idx: number) => (
    <div key={idx} style={{minHeight: 96, display: 'flex', alignItems: 'center'}}>
      <span>
        {line.map((c, i) => (
          <span key={i} style={{color: c.mode === 'en' ? BLUE : INK}}>
            {c.ch}
          </span>
        ))}
      </span>
      {caretLine === idx && typing && (
        <span
          style={{
            display: 'inline-block',
            width: 7,
            height: 62,
            marginLeft: 6,
            borderRadius: 4,
            background: mode === 'en' ? BLUE : RED,
            opacity: caretVisible ? 1 : 0.15,
          }}
        />
      )}
    </div>
  );

  return (
    <ClipFade>
      <AbsoluteFill style={{background: '#ffffff', justifyContent: 'center'}}>
        <div style={{transform: `translateX(${drift}px)`, marginTop: -40}}>
          <div style={{display: 'flex', gap: 36, justifyContent: 'center', marginBottom: 44}}>
            <ModeSquare color={BLUE} glyph="A" active={typing && mode === 'en'} />
            <ModeSquare color={RED} glyph="あ" active={typing && mode === 'jp'} />
          </div>
          {/* Laptop with real mixed-language text being typed */}
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
                fontSize: 56,
                fontWeight: 600,
                letterSpacing: '0.01em',
              }}
            >
              {lines.map((line, i) => renderLine(line, i))}
            </div>
            <div style={{width: 1100, height: 26, background: INK, borderRadius: '0 0 22px 22px'}} />
          </div>
        </div>
        <Caption text="押すキーで、行き先が決まる。もう迷わない。" />
      </AbsoluteFill>
    </ClipFade>
  );
};
