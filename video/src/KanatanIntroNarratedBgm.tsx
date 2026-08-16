import {Audio, interpolate, staticFile} from 'remotion';
import {KanatanIntroNarrated} from './KanatanIntroNarrated';

// Narration windows in frames (start, end) — BGM ducks while a line plays.
const NARRATION_WINDOWS: [number, number][] = [
  [15, 197],
  [249, 406],
  [489, 683],
  [694, 898],
];

const BASE = 0.3;
const DUCKED = 0.1;
const RAMP = 12;

const bgmVolume = (frame: number): number => {
  // Duck factor: approach DUCKED inside any narration window, with ramps.
  let volume = BASE;
  for (const [start, end] of NARRATION_WINDOWS) {
    const inWindow = interpolate(
      frame,
      [start - RAMP, start, end, end + RAMP],
      [0, 1, 1, 0],
      {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'}
    );
    volume = Math.min(volume, BASE - (BASE - DUCKED) * inWindow);
  }

  // Global fade-in and fade-out.
  const envelope = interpolate(frame, [0, 30, 840, 898], [0, 1, 1, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  return volume * envelope;
};

export const KanatanIntroNarratedBgm: React.FC = () => {
  return (
    <>
      <KanatanIntroNarrated />
      <Audio src={staticFile('audio/bgm.m4a')} volume={bgmVolume} />
    </>
  );
};
