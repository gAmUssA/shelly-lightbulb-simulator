import { useState, useEffect } from "preact/hooks";

/**
 * Convert color temperature in Kelvin to RGB values
 * @param {number} kelvin - Temperature in Kelvin (1000-40000)
 * @returns {object} RGB values {r, g, b} in range 0-255
 */
function kelvinToRgb(kelvin) {
  // Divide by 100 for the algorithm
  const temp = kelvin / 100;
  let r, g, b;

  // Calculate red
  if (temp <= 66) {
    r = 255;
  } else {
    r = temp - 60;
    r = 329.698727446 * Math.pow(r, -0.1332047592);
    r = Math.max(0, Math.min(255, r));
  }

  // Calculate green
  if (temp <= 66) {
    g = temp;
    g = 99.4708025861 * Math.log(g) - 161.1195681661;
    g = Math.max(0, Math.min(255, g));
  } else {
    g = temp - 60;
    g = 288.1221695283 * Math.pow(g, -0.0755148492);
    g = Math.max(0, Math.min(255, g));
  }

  // Calculate blue
  if (temp >= 66) {
    b = 255;
  } else if (temp <= 19) {
    b = 0;
  } else {
    b = temp - 10;
    b = 138.5177312231 * Math.log(b) - 305.0447927307;
    b = Math.max(0, Math.min(255, b));
  }

  return { r: Math.round(r), g: Math.round(g), b: Math.round(b) };
}

export default function Bulb({ state }) {
  const [bgColor, setBgColor] = useState("#000000");
  const [transition, setTransition] = useState(0);

  useEffect(() => {
    if (!state) return;

    // Update transition duration from state
    setTransition(state.transition || 0);

    // Calculate background color based on state
    let color = "#000000";

    if (state.ison) {
      if (state.mode === "COLOR") {
        // Color mode - apply gain multiplier to RGB values
        const gain = (state.gain || 100) / 100;
        const r = Math.round((state.red || 0) * gain);
        const g = Math.round((state.green || 0) * gain);
        const b = Math.round((state.blue || 0) * gain);
        color = `rgb(${r}, ${g}, ${b})`;
      } else if (state.mode === "WHITE") {
        // White mode - convert temperature to RGB and apply brightness
        const temp = state.temp || 3000;
        const brightness = (state.brightness || 100) / 100;
        const rgb = kelvinToRgb(temp);
        const r = Math.round(rgb.r * brightness);
        const g = Math.round(rgb.g * brightness);
        const b = Math.round(rgb.b * brightness);
        color = `rgb(${r}, ${g}, ${b})`;
      }
    }

    setBgColor(color);
  }, [state]);

  const isOn = state?.ison || false;

  const containerStyle = {
    position: "fixed",
    top: 0,
    left: 0,
    width: "100vw",
    height: "100vh",
    backgroundColor: "#2d3748",
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    zIndex: 0,
  };

  const bulbContainerStyle = {
    display: "flex",
    flexDirection: "column",
    alignItems: "center",
    filter: isOn ? `drop-shadow(0 0 80px ${bgColor})` : "none",
    transition: `filter ${transition}ms ease-in-out`,
  };

  const bulbGlassStyle = {
    width: "200px",
    height: "240px",
    borderRadius: "50% 50% 50% 50% / 60% 60% 40% 40%",
    position: "relative",
    background: isOn
      ? `radial-gradient(circle at 30% 30%, rgba(255, 255, 255, 0.8), ${bgColor} 50%, ${bgColor} 100%)`
      : "radial-gradient(circle at 30% 30%, rgba(100, 100, 100, 0.3), rgba(80, 80, 80, 0.2) 40%, rgba(60, 60, 60, 0.4) 70%)",
    boxShadow: isOn
      ? `inset 0 0 60px rgba(0, 0, 0, 0.2), 0 0 100px ${bgColor}`
      : "inset 0 0 30px rgba(0, 0, 0, 0.5), inset -10px -10px 20px rgba(0, 0, 0, 0.3)",
    transition: `all ${transition}ms ease-in-out`,
  };

  const filamentStyle = {
    position: "absolute",
    top: "50%",
    left: "50%",
    transform: "translate(-50%, -50%)",
    width: "80px",
    height: "120px",
    borderRadius: "50%",
    backgroundColor: isOn ? bgColor : "rgba(100, 100, 100, 0.3)",
    opacity: isOn ? 1 : 0.2,
    filter: isOn ? "blur(20px)" : "blur(5px)",
    transition: `all ${transition}ms ease-in-out`,
  };

  const bulbBaseStyle = {
    width: "80px",
    height: "50px",
    background: "linear-gradient(to bottom, #999, #666, #444)",
    borderRadius: "0 0 10px 10px",
    marginTop: "5px",
    position: "relative",
    boxShadow: "0 4px 8px rgba(0, 0, 0, 0.5)",
  };

  const bulbThreadsStyle = {
    position: "absolute",
    top: "5px",
    left: "10%",
    width: "80%",
    height: "30px",
    background:
      "repeating-linear-gradient(to bottom, #777 0px, #777 3px, #555 3px, #555 6px)",
    borderRadius: "5px",
  };

  return (
    <div style={containerStyle}>
      <div style={bulbContainerStyle}>
        <div style={bulbGlassStyle}>
          <div style={filamentStyle}></div>
        </div>
        <div style={bulbBaseStyle}>
          <div style={bulbThreadsStyle}></div>
        </div>
      </div>
    </div>
  );
}
