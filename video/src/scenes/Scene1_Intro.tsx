import {
  AbsoluteFill,
  useCurrentFrame,
  useVideoConfig,
  spring,
  interpolate,
} from "remotion";

export const Scene1_Intro: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Icon drops in with spring
  const iconScale = spring({ frame, fps, config: { damping: 12, mass: 0.8 } });
  const iconRotate = spring({
    frame: frame - 5,
    fps,
    config: { damping: 15 },
  });

  // Title slides up
  const titleY = spring({
    frame: frame - 15,
    fps,
    config: { damping: 14, mass: 0.6 },
  });
  const titleOpacity = interpolate(frame, [15, 30], [0, 1], {
    extrapolateRight: "clamp",
  });

  // Subtitle fades in
  const subtitleOpacity = interpolate(frame, [35, 55], [0, 1], {
    extrapolateRight: "clamp",
  });
  const subtitleY = interpolate(frame, [35, 55], [20, 0], {
    extrapolateRight: "clamp",
  });

  // Glow pulse
  const glowOpacity = interpolate(
    frame,
    [40, 70, 100, 120],
    [0, 0.6, 0.4, 0],
    { extrapolateRight: "clamp" }
  );

  // Exit fade
  const exitOpacity = interpolate(frame, [100, 120], [1, 0], {
    extrapolateRight: "clamp",
  });

  return (
    <AbsoluteFill
      style={{
        justifyContent: "center",
        alignItems: "center",
        background: "linear-gradient(135deg, #0a0a0a 0%, #1a1a2e 50%, #0a0a0a 100%)",
        opacity: exitOpacity,
      }}
    >
      {/* Background glow */}
      <div
        style={{
          position: "absolute",
          width: 600,
          height: 600,
          borderRadius: "50%",
          background: "radial-gradient(circle, rgba(59,130,246,0.3) 0%, transparent 70%)",
          opacity: glowOpacity,
          filter: "blur(60px)",
        }}
      />

      {/* Icon */}
      <div
        style={{
          fontSize: 120,
          transform: `scale(${iconScale}) rotate(${interpolate(iconRotate, [0, 1], [-180, 0])}deg)`,
          marginBottom: 30,
          filter: "drop-shadow(0 0 40px rgba(59,130,246,0.5))",
        }}
      >
        🔍
      </div>

      {/* Title */}
      <div
        style={{
          fontSize: 90,
          fontWeight: 800,
          color: "white",
          fontFamily: "SF Pro Display, -apple-system, sans-serif",
          letterSpacing: -2,
          opacity: titleOpacity,
          transform: `translateY(${interpolate(titleY, [0, 1], [40, 0])}px)`,
        }}
      >
        Text
        <span
          style={{
            background: "linear-gradient(90deg, #3b82f6, #8b5cf6)",
            WebkitBackgroundClip: "text",
            WebkitTextFillColor: "transparent",
          }}
        >
          Grab
        </span>
      </div>

      {/* Subtitle */}
      <div
        style={{
          fontSize: 32,
          color: "rgba(255,255,255,0.6)",
          fontFamily: "SF Pro Display, -apple-system, sans-serif",
          fontWeight: 400,
          marginTop: 16,
          opacity: subtitleOpacity,
          transform: `translateY(${subtitleY}px)`,
          letterSpacing: 1,
        }}
      >
        Screen OCR for macOS
      </div>
    </AbsoluteFill>
  );
};
