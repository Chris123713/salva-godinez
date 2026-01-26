import React, { useEffect, useState } from "react";
import { t } from "../utils/translations";

interface DUITimer {
  id: string;
  progress: number;
  color: string;
  text: string;
  stationType: string;
  worldCoords: { x: number; y: number; z: number };
  distance: number;
}

const TimerDUI: React.FC = () => {
  const [currentTimer, setCurrentTimer] = useState<DUITimer | null>(null);

  useEffect(() => {
    const handleMessage = (event: MessageEvent) => {
      const message = event.data;
      
      if (typeof message === 'string') {
        try {
          const parsedMessage = JSON.parse(message);
          
          if (parsedMessage.type === 'updateTimer') {
            setCurrentTimer(parsedMessage.data);
          }
        } catch (e) {
          // Ignore invalid JSON
        }
      } else if (message && message.type === 'updateTimer') {
        setCurrentTimer(message.data);
      }
    };

    window.addEventListener('message', handleMessage);
    
    return () => {
      window.removeEventListener('message', handleMessage);
    };
  }, []);

  // Don't render anything if no timer data
  if (!currentTimer) {
    return null;
  }

  const circumference = 2 * Math.PI * 40; // radius = 40
  const strokeDasharray = circumference;
  const strokeDashoffset = circumference - (currentTimer.progress * circumference);

  return (
    <div className="timer-dui-container">
      <div className="timer-circle-simple">
        <svg width="100" height="100" className="timer-svg">
          {/* Background circle */}
          <circle
            cx="50"
            cy="50"
            r="40"
            fill="none"
            stroke="rgba(255, 255, 255, 0.2)"
            strokeWidth="4"
          />
          
          {/* Progress circle */}
          <circle
            cx="50"
            cy="50"
            r="40"
            fill="none"
            stroke={currentTimer.color}
            strokeWidth="4"
            strokeLinecap="round"
            strokeDasharray={strokeDasharray}
            strokeDashoffset={strokeDashoffset}
            transform="rotate(-90 50 50)"
            className="timer-progress"
          />
        </svg>
        
        {/* Timer text */}
        <div className="timer-text" style={{ color: currentTimer.color }}>
          <div className="timer-main-text">{currentTimer.text}</div>
          {currentTimer.text !== t('burnt') && currentTimer.text !== t('good') && (
            <div className="timer-progress-text">
              {Math.round(currentTimer.progress * 100)}%
            </div>
          )}
        </div>
        
        {/* Station type */}
        <div className="timer-station-simple">
          {currentTimer.stationType.toUpperCase()}
        </div>
      </div>
    </div>
  );
};

export default TimerDUI; 