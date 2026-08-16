import {Composition} from 'remotion';
import {KanatanIntro} from './KanatanIntro';

export const RemotionRoot: React.FC = () => {
  return (
    <Composition
      id="KanatanIntro"
      component={KanatanIntro}
      durationInFrames={900}
      fps={30}
      width={1920}
      height={1080}
    />
  );
};
