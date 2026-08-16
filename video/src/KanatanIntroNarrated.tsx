import {Audio, Sequence, staticFile} from 'remotion';
import {KanatanIntro} from './KanatanIntro';

// Provided narration, one file per scene (public/audio/clip1-4.m4a).
// clip4 starts slightly before the visual cut (J-cut) so its 6.8s line
// finishes inside the 30s composition.
const LINES: {file: string; from: number}[] = [
  {file: 'audio/clip1.m4a', from: 15}, // クリップ1: US配列は好き…
  {file: 'audio/clip2.m4a', from: 249}, // クリップ2: Kanatanなら…
  {file: 'audio/clip3.m4a', from: 489}, // クリップ3: ショートカットはいつも通り…
  {file: 'audio/clip4.m4a', from: 694}, // クリップ4: 考えるのは文章だけ…
];

export const KanatanIntroNarrated: React.FC = () => {
  return (
    <>
      <KanatanIntro />
      {LINES.map((line) => (
        <Sequence key={line.file} from={line.from}>
          <Audio src={staticFile(line.file)} />
        </Sequence>
      ))}
    </>
  );
};
