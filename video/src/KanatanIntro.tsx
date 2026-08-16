import {AbsoluteFill, Sequence} from 'remotion';
import {Clip1} from './scenes/Clip1';
import {Clip2} from './scenes/Clip2';
import {Clip3} from './scenes/Clip3';
import {Clip4} from './scenes/Clip4';

export const KanatanIntro: React.FC = () => {
  return (
    <AbsoluteFill style={{background: '#ffffff'}}>
      <Sequence durationInFrames={240}>
        <Clip1 />
      </Sequence>
      <Sequence from={240} durationInFrames={240}>
        <Clip2 />
      </Sequence>
      <Sequence from={480} durationInFrames={240}>
        <Clip3 />
      </Sequence>
      <Sequence from={720} durationInFrames={180}>
        <Clip4 />
      </Sequence>
    </AbsoluteFill>
  );
};
