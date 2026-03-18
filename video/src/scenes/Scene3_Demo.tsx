import {
  AbsoluteFill,
  useCurrentFrame,
  interpolate,
  spring,
  useVideoConfig,
} from "remotion";

export const Scene3_Demo: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Enter
  const enterOpacity = interpolate(frame, [0, 15], [0, 1], {
    extrapolateRight: "clamp",
  });

  // Step 1: Keyboard shortcut appears (frames 0-50)
  const keysScale = spring({
    frame: frame - 10,
    fps,
    config: { damping: 12 },
  });
  const keysGlow = interpolate(frame, [20, 35, 50], [0, 1, 0], {
    extrapolateRight: "clamp",
  });

  // Step 2: Cursor moves to target then draws selection (frames 45-90)
  // Cursor appears and moves to the "Fatura No" line
  const cursorOpacity = interpolate(frame, [45, 50], [0, 1], {
    extrapolateRight: "clamp",
    extrapolateLeft: "clamp",
  });
  // Cursor path: starts above-left of "Fatura No", moves to start position
  const cursorX = interpolate(
    frame,
    [45, 55, 60, 85],
    [300, 48, 48, 470],
    { extrapolateRight: "clamp", extrapolateLeft: "clamp" }
  );
  const cursorY = interpolate(
    frame,
    [45, 55, 60, 85],
    [180, 235, 235, 258],
    { extrapolateRight: "clamp", extrapolateLeft: "clamp" }
  );

  // Selection rect grows as cursor drags (starts at frame 60)
  const selectionProgress = interpolate(frame, [60, 85], [0, 1], {
    extrapolateRight: "clamp",
    extrapolateLeft: "clamp",
  });

  // Selection target: starts exactly at the "F" in "Fatura No: INV-2024-0847"
  const selLeft = 40;
  const selTop = 230;
  const selW = interpolate(selectionProgress, [0, 1], [0, 430]);
  const selH = interpolate(selectionProgress, [0, 1], [0, 34]);

  // Step 3: OCR scan effect (frames 88-115)
  const scanProgress = interpolate(frame, [90, 110], [0, 1], {
    extrapolateRight: "clamp",
    extrapolateLeft: "clamp",
  });
  const scanOpacity = interpolate(
    frame,
    [88, 92, 108, 115],
    [0, 1, 1, 0],
    { extrapolateRight: "clamp", extrapolateLeft: "clamp" }
  );

  // Step 4: Text result + toast (frames 115-180)
  const textReveal = spring({
    frame: frame - 115,
    fps,
    config: { damping: 14 },
  });
  const toastY = spring({
    frame: frame - 130,
    fps,
    config: { damping: 12, mass: 0.5 },
  });

  // Cursor hides after selection
  const cursorFade = interpolate(frame, [86, 90], [1, 0], {
    extrapolateRight: "clamp",
    extrapolateLeft: "clamp",
  });

  // Exit
  const exitOpacity = interpolate(frame, [165, 180], [1, 0], {
    extrapolateRight: "clamp",
  });

  return (
    <AbsoluteFill
      style={{
        justifyContent: "center",
        alignItems: "center",
        background:
          "linear-gradient(135deg, #0a0a0a 0%, #16213e 50%, #0a0a0a 100%)",
        opacity: enterOpacity * exitOpacity,
      }}
    >
      {/* Mock Screen */}
      <div
        style={{
          width: 900,
          height: 500,
          background: "linear-gradient(180deg, #2a2a3a 0%, #1a1a2a 100%)",
          borderRadius: 16,
          border: "1px solid rgba(255,255,255,0.1)",
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
          <div
            style={{
              width: 12,
              height: 12,
              borderRadius: "50%",
              background: "#ff5f57",
            }}
          />
          <div
            style={{
              width: 12,
              height: 12,
              borderRadius: "50%",
              background: "#febc2e",
            }}
          />
          <div
            style={{
              width: 12,
              height: 12,
              borderRadius: "50%",
              background: "#28c840",
            }}
          />
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

        {/* Document content */}
        <div style={{ padding: "30px 40px" }}>
          <div
            style={{
              color: "rgba(255,255,255,0.7)",
              fontSize: 22,
              fontWeight: 600,
              marginBottom: 24,
              fontFamily: "SF Pro Display, sans-serif",
            }}
          >
            FATURA / INVOICE
          </div>
          {[
            "Firma: Tekstil A.Ş.",
            "Tutar: ₺12.450,00",
            "Tarih: 18.03.2026",
          ].map((line, i) => (
            <div
              key={i}
              style={{
                color: "rgba(255,255,255,0.5)",
                fontSize: 18,
                fontFamily: "SF Mono, monospace",
                marginBottom: 14,
                lineHeight: "1.4",
              }}
            >
              {line}
            </div>
          ))}
          {/* Target line - Fatura No */}
          <div
            style={{
              color: "rgba(255,255,255,0.5)",
              fontSize: 18,
              fontFamily: "SF Mono, monospace",
              marginBottom: 14,
              lineHeight: "1.4",
              position: "relative",
            }}
          >
            Fatura No: INV-2024-0847
            {/* Highlight effect after OCR */}
            {frame > 110 && frame < 140 && (
              <div
                style={{
                  position: "absolute",
                  inset: "-4px -8px",
                  background: "rgba(59,130,246,0.15)",
                  borderRadius: 4,
                  opacity: interpolate(
                    frame,
                    [110, 115, 130, 140],
                    [0, 0.8, 0.8, 0],
                    {
                      extrapolateRight: "clamp",
                      extrapolateLeft: "clamp",
                    }
                  ),
                }}
              />
            )}
          </div>
        </div>

        {/* Dark overlay for selection mode */}
        {frame > 48 && frame < 115 && (
          <div
            style={{
              position: "absolute",
              inset: 0,
              background: "rgba(0,0,0,0.3)",
              opacity: interpolate(
                frame,
                [48, 54, 108, 115],
                [0, 1, 1, 0],
                { extrapolateRight: "clamp", extrapolateLeft: "clamp" }
              ),
            }}
          />
        )}

        {/* Selection Rectangle - precisely over "Fatura No" line */}
        {frame > 60 && frame < 115 && (
          <div
            style={{
              position: "absolute",
              left: selLeft,
              top: selTop,
              width: selW,
              height: selH,
              border: "2px solid #3b82f6",
              background: "rgba(59,130,246,0.08)",
              borderRadius: 3,
              boxShadow: `0 0 12px rgba(59,130,246,0.4)`,
            }}
          />
        )}

        {/* OCR scan line sweeping across selection */}
        {frame >= 88 && frame < 115 && (
          <div
            style={{
              position: "absolute",
              left: selLeft + scanProgress * 430,
              top: selTop - 2,
              width: 2,
              height: 38,
              background:
                "linear-gradient(180deg, transparent, #3b82f6, transparent)",
              opacity: scanOpacity,
              boxShadow: "0 0 12px rgba(59,130,246,0.8)",
            }}
          />
        )}

        {/* Mouse cursor */}
        {frame > 45 && frame < 90 && (
          <div
            style={{
              position: "absolute",
              left: cursorX,
              top: cursorY,
              opacity: cursorOpacity * cursorFade,
              pointerEvents: "none",
              zIndex: 10,
            }}
          >
            {/* macOS cursor SVG */}
            <svg
              width="20"
              height="20"
              viewBox="0 0 24 24"
              style={{ filter: "drop-shadow(1px 2px 3px rgba(0,0,0,0.6))" }}
            >
              <path
                d="M5 3l14 8-6.5 1.5L11 19z"
                fill="white"
                stroke="black"
                strokeWidth="1"
              />
            </svg>
          </div>
        )}
      </div>

      {/* Keyboard shortcut overlay */}
      {frame < 60 && (
        <div
          style={{
            position: "absolute",
            top: 80,
            display: "flex",
            gap: 12,
            transform: `scale(${keysScale})`,
          }}
        >
          {["⌃", "⌥", "T"].map((key, i) => (
            <div
              key={i}
              style={{
                width: key === "T" ? 70 : 60,
                height: 60,
                background: "rgba(255,255,255,0.1)",
                border: "1px solid rgba(255,255,255,0.2)",
                borderRadius: 12,
                display: "flex",
                justifyContent: "center",
                alignItems: "center",
                color: "white",
                fontSize: 28,
                fontFamily: "SF Pro Display, sans-serif",
                fontWeight: 600,
                boxShadow: `0 0 ${keysGlow * 30}px rgba(59,130,246,${keysGlow * 0.8}), 0 4px 12px rgba(0,0,0,0.3)`,
                backdropFilter: "blur(20px)",
              }}
            >
              {key}
            </div>
          ))}
        </div>
      )}

      {/* Extracted text result - only Fatura No */}
      {frame > 115 && (
        <div
          style={{
            position: "absolute",
            right: 80,
            top: 180,
            width: 380,
            background: "rgba(16,16,32,0.95)",
            border: "1px solid rgba(59,130,246,0.3)",
            borderRadius: 16,
            padding: "24px 28px",
            transform: `scale(${textReveal})`,
            boxShadow:
              "0 20px 60px rgba(0,0,0,0.5), 0 0 30px rgba(59,130,246,0.2)",
          }}
        >
          {/* Header */}
          <div
            style={{
              display: "flex",
              alignItems: "center",
              gap: 8,
              marginBottom: 16,
            }}
          >
            <div
              style={{
                width: 8,
                height: 8,
                borderRadius: "50%",
                background: "#22c55e",
                boxShadow: "0 0 8px rgba(34,197,94,0.5)",
              }}
            />
            <span
              style={{
                fontSize: 12,
                color: "rgba(255,255,255,0.4)",
                fontFamily: "SF Pro Display, sans-serif",
                fontWeight: 500,
                textTransform: "uppercase",
                letterSpacing: 2,
              }}
            >
              Extracted Text
            </span>
          </div>

          {/* Extracted content */}
          <div
            style={{
              background: "rgba(255,255,255,0.04)",
              borderRadius: 8,
              padding: "14px 16px",
              border: "1px solid rgba(255,255,255,0.06)",
              opacity: interpolate(textReveal, [0.3, 0.6], [0, 1], {
                extrapolateRight: "clamp",
                extrapolateLeft: "clamp",
              }),
            }}
          >
            <div
              style={{
                color: "rgba(255,255,255,0.9)",
                fontSize: 18,
                fontFamily: "SF Mono, monospace",
                fontWeight: 500,
              }}
            >
              Fatura No: INV-2024-0847
            </div>
          </div>

          {/* Clipboard indicator */}
          <div
            style={{
              display: "flex",
              alignItems: "center",
              gap: 6,
              marginTop: 14,
              opacity: interpolate(textReveal, [0.5, 0.8], [0, 1], {
                extrapolateRight: "clamp",
                extrapolateLeft: "clamp",
              }),
            }}
          >
            <svg
              width="14"
              height="14"
              viewBox="0 0 24 24"
              fill="none"
              stroke="rgba(255,255,255,0.3)"
              strokeWidth="2"
            >
              <rect x="9" y="9" width="13" height="13" rx="2" />
              <path d="M5 15H4a2 2 0 01-2-2V4a2 2 0 012-2h9a2 2 0 012 2v1" />
            </svg>
            <span
              style={{
                fontSize: 12,
                color: "rgba(255,255,255,0.3)",
                fontFamily: "SF Pro Display, sans-serif",
              }}
            >
              Panoya kopyalandı
            </span>
          </div>
        </div>
      )}

      {/* "Copied!" toast */}
      {frame > 130 && (
        <div
          style={{
            position: "absolute",
            bottom: 60,
            background: "rgba(34,197,94,0.12)",
            border: "1px solid rgba(34,197,94,0.3)",
            borderRadius: 12,
            padding: "12px 28px",
            display: "flex",
            alignItems: "center",
            gap: 10,
            transform: `translateY(${interpolate(toastY, [0, 1], [30, 0])}px)`,
            opacity: toastY,
            backdropFilter: "blur(20px)",
          }}
        >
          <div
            style={{
              width: 22,
              height: 22,
              borderRadius: "50%",
              background: "rgba(34,197,94,0.2)",
              display: "flex",
              justifyContent: "center",
              alignItems: "center",
              color: "#22c55e",
              fontSize: 14,
              fontWeight: 700,
            }}
          >
            ✓
          </div>
          <span
            style={{
              color: "#22c55e",
              fontSize: 18,
              fontFamily: "SF Pro Display, sans-serif",
              fontWeight: 600,
            }}
          >
            Kopyalandı!
          </span>
          <span
            style={{
              color: "rgba(34,197,94,0.5)",
              fontSize: 14,
              fontFamily: "SF Mono, monospace",
            }}
          >
            26 karakter
          </span>
        </div>
      )}
    </AbsoluteFill>
  );
};
