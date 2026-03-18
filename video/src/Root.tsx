import { Composition } from "remotion";
import { TextGrabPromo } from "./TextGrabPromo";
import "./style.css";

export const RemotionRoot: React.FC = () => {
  return (
    <Composition
      id="TextGrabPromo"
      component={TextGrabPromo}
      durationInFrames={600} // 20 seconds at 30fps
      fps={30}
      width={1920}
      height={1080}
    />
  );
};
