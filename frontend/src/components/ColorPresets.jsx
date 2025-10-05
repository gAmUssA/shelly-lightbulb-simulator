const colorPresets = [
  { name: 'Red', rgb: [255, 0, 0], mode: 'color' },
  { name: 'Green', rgb: [0, 255, 0], mode: 'color' },
  { name: 'Blue', rgb: [0, 0, 255], mode: 'color' },
  { name: 'Yellow', rgb: [255, 255, 0], mode: 'color' },
  { name: 'Purple', rgb: [128, 0, 128], mode: 'color' },
  { name: 'Cyan', rgb: [0, 255, 255], mode: 'color' },
  { name: 'Warm White', temp: 3000, mode: 'white' },
  { name: 'Cool White', temp: 6500, mode: 'white' }
];

// Helper function to convert Kelvin to RGB for button display
function kelvinToRgb(kelvin) {
  const temp = kelvin / 100;
  let r, g, b;

  if (temp <= 66) {
    r = 255;
    g = temp - 10;
    g = 99.4708025861 * Math.log(g) - 161.1195681661;
  } else {
    r = temp - 60;
    r = 329.698727446 * Math.pow(r, -0.1332047592);
    g = temp - 60;
    g = 288.1221695283 * Math.pow(g, -0.0755148492);
  }

  if (temp >= 66) {
    b = 255;
  } else if (temp <= 19) {
    b = 0;
  } else {
    b = temp - 10;
    b = 138.5177312231 * Math.log(b) - 305.0447927307;
  }

  return {
    r: Math.max(0, Math.min(255, Math.round(r))),
    g: Math.max(0, Math.min(255, Math.round(g))),
    b: Math.max(0, Math.min(255, Math.round(b)))
  };
}

export default function ColorPresets() {
  const getButtonColor = (preset) => {
    if (preset.mode === 'color') {
      const [r, g, b] = preset.rgb;
      return `rgb(${r}, ${g}, ${b})`;
    } else {
      const { r, g, b } = kelvinToRgb(preset.temp);
      return `rgb(${r}, ${g}, ${b})`;
    }
  };

  const handlePresetClick = async (preset) => {
    try {
      if (preset.mode === 'color') {
        const [red, green, blue] = preset.rgb;
        const params = new URLSearchParams({
          red: red.toString(),
          green: green.toString(),
          blue: blue.toString(),
          turn: 'on',
          gain: '100'
        });
        await fetch(`/color/0?${params.toString()}`, {
          method: 'POST'
        });
      } else {
        const params = new URLSearchParams({
          temp: preset.temp.toString(),
          brightness: '100',
          turn: 'on'
        });
        await fetch(`/white/0?${params.toString()}`, {
          method: 'POST'
        });
      }
    } catch (error) {
      console.error('Error setting preset:', error);
    }
  };

  return (
    <div
      style={{
        position: 'fixed',
        bottom: '20px',
        left: '50%',
        transform: 'translateX(-50%)',
        display: 'flex',
        flexDirection: 'row',
        flexWrap: 'wrap',
        justifyContent: 'center',
        gap: '10px',
        padding: '10px',
        zIndex: 10
      }}
    >
      {colorPresets.map((preset, index) => (
        <button
          key={index}
          aria-label={`Set color to ${preset.name}`}
          onClick={() => handlePresetClick(preset)}
          style={{
            width: '50px',
            height: '50px',
            borderRadius: '50%',
            backgroundColor: getButtonColor(preset),
            border: '2px solid rgba(255, 255, 255, 0.3)',
            cursor: 'pointer',
            transition: 'transform 0.2s, box-shadow 0.2s'
          }}
          onMouseEnter={(e) => {
            e.currentTarget.style.transform = 'scale(1.1)';
            e.currentTarget.style.boxShadow = '0 0 15px rgba(255, 255, 255, 0.5)';
          }}
          onMouseLeave={(e) => {
            e.currentTarget.style.transform = 'scale(1)';
            e.currentTarget.style.boxShadow = 'none';
          }}
          onMouseDown={(e) => {
            e.currentTarget.style.transform = 'scale(0.95)';
          }}
          onMouseUp={(e) => {
            e.currentTarget.style.transform = 'scale(1.1)';
          }}
        >
        </button>
      ))}
    </div>
  );
}
