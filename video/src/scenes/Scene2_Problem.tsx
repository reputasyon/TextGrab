import {
  AbsoluteFill,
  useCurrentFrame,
  interpolate,
  spring,
  useVideoConfig,
} from "remotion";

export const Scene2_Problem: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Enter fade
  const enterOpacity = interpolate(frame, [0, 15], [0, 1], {
    extrapolateRight: "clamp",
  });

  // Mock screen with unselectable text (image/PDF scenario)
  const screenScale = spring({
    frame: frame - 5,
    fps,
    config: { damping: 14 },
  });

  // Cursor trying to select (frustration animation)
  const cursorX = interpolate(
    frame,
    [20, 35, 40, 55, 60, 70],
    [400, 700, 700, 500, 500, 600],
    { extrapolateRight: "clamp" }
  );
  const cursorY = interpolate(
    frame,
    [20, 35, 40, 55, 60, 70],
    [350, 350, 380, 380, 350, 370],
    { extrapolateRight: "clamp" }
  );
  const cursorOpacity = interpolate(frame, [15, 20], [0, 1], {
    extrapolateRight: "clamp",
  });

  // Red X / frustration
  const xScale = spring({
    frame: frame - 70,
    fps,
    config: { damping: 8, mass: 0.5 },
  });

  // Problem text
  const textOpacity = interpolate(frame, [75, 90], [0, 1], {
    extrapolateRight: "clamp",
  });

  // Exit
  const exitOpacity = interpolate(frame, [105, 120], [1, 0], {
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
      {/* Mock screen/window */}
      <div
        style={{
          width: 800,
          height: 400,
          background: "linear-gradient(180deg, #2a2a3a 0%, #1a1a2a 100%)",
          borderRadius: 16,
          border: "1px solid rgba(255,255,255,0.1)",
          transform: `scale(${screenScale})`,
          position: "relative",
          overflow: "hidden",
          boxShadow: "0 25px 80px rgba(0,0,0,0.5)",
        }}
      >
        {/* Title bar */}
        <div
          style={{
            height: 40,
            background: "rgba(255,255,255,0.05)",
            display: "flex",
            alignItems: "center",
            padding: "0 16px",
            gap: 8,
          }}
        >
          <div style={{ width: 12, height: 12, borderRadius: "50%", background: "#ff5f57" }} />
          <div style={{ width: 12, height: 12, borderRadius: "50%", background: "#febc2e" }} />
          <div style={{ width: 12, height: 12, borderRadius: "50%", background: "#28c840" }} />
          <div
            style={{
              color: "rgba(255,255,255,0.4)",
              fontSize: 13,
              marginLeft: 12,
              fontFamily: "SF Pro Display, sans-serif",
            }}
          >
            Invoice_2024.pdf
          </div>
        </div>

        {/* Fake document content */}
        <div style={{ padding: "30px 40px" }}>
          <div
            style={{
              color: "rgba(255,255,255,0.7)",
              fontSize: 22,
              fontFamily: "SF Pro Display, sans-serif",
              fontWeight: 600,
              marginBottom: 20,
            }}
          >
            FATURA / INVOICE
          </div>
          {["Firma: Tekstil A.Ş.", "Tutar: ₺12.450,00", "Tarih: 18.03.2026", "Fatura No: INV-2024-0847"].map(
            (line, i) => (
              <div
                key={i}
                style={{
                  color: "rgba(255,255,255,0.5)",
                  fontSize: 18,
                  fontFamily: "SF Mono, monospace",
                  marginBottom: 12,
                  userSelect: "none",
                }}
              >
                {line}
              </div>
            )
          )}
        </div>

        {/* Cursor */}
        <div
          style={{
            position: "absolute",
            left: cursorX,
            top: cursorY,
            opacity: cursorOpacity,
            fontSize: 24,
            transform: "translate(-50%, -50%)",
            filter: "drop-shadow(0 2px 4px rgba(0,0,0,0.5))",
          }}
        >
          🚫
        </div>
      </div>

      {/* Red X overlay */}
      {frame > 70 && (
        <div
          style={{
            position: "absolute",
            fontSize: 80,
            color: "#ef4444",
            fontWeight: 900,
            transform: `scale(${xScale})`,
            textShadow: "0 0 40px rgba(239,68,68,0.5)",
          }}
        >
          ✕
        </div>
      )}

      {/* Problem text */}
      <div
        style={{
          position: "absolute",
          bottom: 100,
          fontSize: 36,
          color: "rgba(255,255,255,0.8)",
          fontFamily: "SF Pro Display, -apple-system, sans-serif",
          fontWeight: 600,
          opacity: textOpacity,
          textAlign: "center",
        }}
      >
        Ekrandaki metni kopyalayamıyor musun?
      </div>
    </AbsoluteFill>
  );
};
