import {Composition} from 'remotion';
import {KanatanIntro} from './KanatanIntro';
import {KanatanIntroNarrated} from './KanatanIntroNarrated';

export const RemotionRoot: React.FC = () => {
  return (
    <>
      <Composition
        id="KanatanIntro"
        component={KanatanIntro}
        durationInFrames={900}
        fps={30}
        width={1920}
        height={1080}
      />
      <Composition
        id="KanatanIntroNarrated"
        component={KanatanIntroNarrated}
        durationInFrames={900}
        fps={30}
        width={1920}
        height={1080}
      />
    </>
  );
};
