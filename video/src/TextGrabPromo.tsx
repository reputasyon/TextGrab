import {
  AbsoluteFill,
  Sequence,
  useCurrentFrame,
  interpolate,
  spring,
  useVideoConfig,
  Easing,
} from "remotion";
import { Scene1_Intro } from "./scenes/Scene1_Intro";
import { Scene2_Problem } from "./scenes/Scene2_Problem";
import { Scene3_Demo } from "./scenes/Scene3_Demo";
import { Scene4_Features } from "./scenes/Scene4_Features";
import { Scene5_CTA } from "./scenes/Scene5_CTA";

export const TextGrabPromo: React.FC = () => {
  return (
    <AbsoluteFill style={{ backgroundColor: "#0a0a0a" }}>
      {/* Scene 1: Logo + Title (0-4s = frames 0-120) */}
      <Sequence from={0} durationInFrames={120}>
        <Scene1_Intro />
      </Sequence>

      {/* Scene 2: The Problem (4-8s = frames 120-240) */}
      <Sequence from={120} durationInFrames={120}>
        <Scene2_Problem />
      </Sequence>

      {/* Scene 3: Demo Animation (8-14s = frames 240-420) */}
      <Sequence from={240} durationInFrames={180}>
        <Scene3_Demo />
      </Sequence>

      {/* Scene 4: Features (14-17.5s = frames 420-525) */}
      <Sequence from={420} durationInFrames={105}>
        <Scene4_Features />
      </Sequence>

      {/* Scene 5: CTA (17.5-20s = frames 525-600) */}
      <Sequence from={525} durationInFrames={75}>
        <Scene5_CTA />
      </Sequence>
    </AbsoluteFill>
  );
};
