import {
  AbsoluteFill,
  useCurrentFrame,
  interpolate,
  spring,
  useVideoConfig,
} from "remotion";

const features = [
  { icon: "🎯", title: "Vision OCR", desc: "Apple Vision framework" },
  { icon: "🌍", title: "Multi-Language", desc: "TR, EN, DE, FR" },
  { icon: "⌨️", title: "Global Hotkey", desc: "⌃⌥T ile anında yakala" },
  { icon: "📋", title: "Auto Clipboard", desc: "Hemen yapıştır" },
];

export const Scene4_Features: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const enterOpacity = interpolate(frame, [0, 10], [0, 1], {
    extrapolateRight: "clamp",
  });

  const exitOpacity = interpolate(frame, [85, 105], [1, 0], {
    extrapolateRight: "clamp",
  });

  return (
    <AbsoluteFill
      style={{
        justifyContent: "center",
        alignItems: "center",
        background: "linear-gradient(135deg, #0a0a0a 0%, #1a1a2e 50%, #0a0a0a 100%)",
        opacity: enterOpacity * exitOpacity,
      }}
    >
      <div
        style={{
          display: "flex",
          gap: 40,
          justifyContent: "center",
          alignItems: "center",
        }}
      >
        {features.map((feat, i) => {
          const delay = 5 + i * 12;
          const s = spring({
            frame: frame - delay,
            fps,
            config: { damping: 12, mass: 0.6 },
          });

          return (
            <div
              key={i}
              style={{
                width: 220,
                height: 240,
                background: "rgba(255,255,255,0.03)",
                border: "1px solid rgba(255,255,255,0.08)",
                borderRadius: 20,
                display: "flex",
                flexDirection: "column",
                justifyContent: "center",
                alignItems: "center",
                gap: 16,
                transform: `scale(${s}) translateY(${interpolate(s, [0, 1], [30, 0])}px)`,
                opacity: s,
                backdropFilter: "blur(10px)",
              }}
            >
              <div style={{ fontSize: 48 }}>{feat.icon}</div>
              <div
                style={{
                  color: "white",
                  fontSize: 22,
                  fontWeight: 700,
                  fontFamily: "SF Pro Display, -apple-system, sans-serif",
                }}
              >
                {feat.title}
              </div>
              <div
                style={{
                  color: "rgba(255,255,255,0.5)",
                  fontSize: 15,
                  fontFamily: "SF Pro Display, -apple-system, sans-serif",
                  textAlign: "center",
                  padding: "0 16px",
                }}
              >
                {feat.desc}
              </div>
            </div>
          );
        })}
      </div>
    </AbsoluteFill>
  );
};
