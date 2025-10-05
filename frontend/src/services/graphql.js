import { createClient } from 'graphql-ws';

// Create WebSocket client instance connecting to backend GraphQL endpoint
const client = createClient({
  url: 'ws://localhost:8080/graphql/ws',
  connectionParams: {},
  retryAttempts: 5,
  shouldRetry: () => true,
});

/**
 * Subscribe to light state changes via GraphQL WebSocket subscription
 * @param {Function} callback - Function to call when state updates are received
 * @returns {Function} Unsubscribe function to close the subscription
 */
export function subscribeLightState(callback) {
  const subscription = client.subscribe(
    {
      query: `
        subscription {
          lightStateChanged {
            ison
            mode
            red
            green
            blue
            white
            gain
            brightness
            temp
            transition
            effect
            source
          }
        }
      `,
    },
    {
      next: (data) => {
        // Handle successful state update
        if (data.data && data.data.lightStateChanged) {
          callback(data.data.lightStateChanged);
        }
      },
      error: (error) => {
        // Handle subscription errors
        console.error('GraphQL subscription error:', error);
      },
      complete: () => {
        // Handle subscription completion
        console.log('GraphQL subscription completed');
      },
    }
  );

  // Return unsubscribe function
  return () => subscription.return();
}
