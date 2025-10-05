import { useState, useEffect } from 'preact/hooks'
import Bulb from './components/Bulb'
import ApiTester from './components/ApiTester'
import { subscribeLightState } from './services/graphql'
import './app.css'

export function App() {
  // Initialize light state with default values
  const [lightState, setLightState] = useState({
    ison: false,
    mode: 'COLOR',
    red: 0,
    green: 0,
    blue: 0,
    white: 0,
    gain: 100,
    brightness: 100,
    temp: 4000,
    transition: 500,
    effect: 0,
    source: 'http'
  })

  // Subscribe to GraphQL light state changes on mount
  useEffect(() => {
    const unsubscribe = subscribeLightState((newState) => {
      setLightState(newState)
    })

    // Return cleanup function to unsubscribe on unmount
    return unsubscribe
  }, [])

  return (
    <>
      <Bulb state={lightState} />
      <ApiTester />
    </>
  )
}
