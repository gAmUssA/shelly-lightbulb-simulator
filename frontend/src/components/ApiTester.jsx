import { useState } from 'preact/hooks';

export default function ApiTester() {
  const [endpoint, setEndpoint] = useState('/light/0');
  const [method, setMethod] = useState('GET');
  const [params, setParams] = useState('');
  const [response, setResponse] = useState('');

  const handleSend = async () => {
    try {
      let url = endpoint;
      
      // Build URL with query parameters for GET requests or when params are provided
      if (params.trim()) {
        const separator = url.includes('?') ? '&' : '?';
        url = `${url}${separator}${params}`;
      }

      const options = {
        method: method,
        headers: {
          'Content-Type': 'application/json',
        },
      };

      // For POST requests to /rpc, send params as JSON body if they look like JSON
      if (method === 'POST' && endpoint === '/rpc' && params.trim()) {
        try {
          options.body = params;
          url = endpoint; // Don't append params to URL for RPC
        } catch (e) {
          // If not valid JSON, keep as query params
        }
      }

      const res = await fetch(url, options);
      const data = await res.json();
      setResponse(JSON.stringify(data, null, 2));
    } catch (error) {
      setResponse(`Error: ${error.message}`);
    }
  };

  return (
    <div style={{
      position: 'fixed',
      top: '20px',
      right: '20px',
      backgroundColor: 'rgba(255, 255, 255, 0.9)',
      padding: '20px',
      borderRadius: '10px',
      minWidth: '300px',
      maxWidth: '400px',
      boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)',
      fontFamily: 'system-ui, -apple-system, sans-serif',
    }}>
      <h3 style={{ margin: '0 0 15px 0', fontSize: '18px' }}>API Tester</h3>
      
      <div style={{ marginBottom: '10px' }}>
        <label style={{ display: 'block', marginBottom: '5px', fontSize: '14px', fontWeight: '500' }}>
          Endpoint:
        </label>
        <select 
          value={endpoint} 
          onChange={(e) => setEndpoint(e.target.value)}
          style={{
            width: '100%',
            padding: '8px',
            borderRadius: '5px',
            border: '1px solid #ccc',
            fontSize: '14px',
          }}
        >
          <option value="/light/0">/light/0</option>
          <option value="/color/0">/color/0</option>
          <option value="/white/0">/white/0</option>
          <option value="/status">/status</option>
          <option value="/rpc">/rpc</option>
        </select>
      </div>

      <div style={{ marginBottom: '10px' }}>
        <label style={{ display: 'block', marginBottom: '5px', fontSize: '14px', fontWeight: '500' }}>
          Method:
        </label>
        <select 
          value={method} 
          onChange={(e) => setMethod(e.target.value)}
          style={{
            width: '100%',
            padding: '8px',
            borderRadius: '5px',
            border: '1px solid #ccc',
            fontSize: '14px',
          }}
        >
          <option value="GET">GET</option>
          <option value="POST">POST</option>
        </select>
      </div>

      <div style={{ marginBottom: '10px' }}>
        <label style={{ display: 'block', marginBottom: '5px', fontSize: '14px', fontWeight: '500' }}>
          Parameters:
        </label>
        <input 
          type="text"
          value={params}
          onChange={(e) => setParams(e.target.value)}
          placeholder="turn=on&red=255"
          style={{
            width: '100%',
            padding: '8px',
            borderRadius: '5px',
            border: '1px solid #ccc',
            fontSize: '14px',
            boxSizing: 'border-box',
          }}
        />
      </div>

      <button 
        onClick={handleSend}
        style={{
          width: '100%',
          padding: '10px',
          backgroundColor: '#007bff',
          color: 'white',
          border: 'none',
          borderRadius: '5px',
          fontSize: '14px',
          fontWeight: '500',
          cursor: 'pointer',
          marginBottom: '10px',
        }}
        onMouseOver={(e) => e.target.style.backgroundColor = '#0056b3'}
        onMouseOut={(e) => e.target.style.backgroundColor = '#007bff'}
      >
        Send
      </button>

      <div style={{ marginTop: '15px' }}>
        <label style={{ display: 'block', marginBottom: '5px', fontSize: '14px', fontWeight: '500' }}>
          Response:
        </label>
        <pre style={{
          backgroundColor: '#f5f5f5',
          padding: '10px',
          borderRadius: '5px',
          fontSize: '12px',
          maxHeight: '300px',
          overflow: 'auto',
          whiteSpace: 'pre-wrap',
          wordBreak: 'break-word',
          margin: 0,
        }}>
          {response || 'No response yet'}
        </pre>
      </div>
    </div>
  );
}
