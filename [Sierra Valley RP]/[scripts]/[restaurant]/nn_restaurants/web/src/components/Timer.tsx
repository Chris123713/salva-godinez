import React, { useEffect, useState } from "react";
import { useNuiEvent } from "../hooks/useNuiEvent";
import { useVisibility } from "../providers/VisibilityProvider";
import { fetchNui } from "../utils/fetchNui";
import { t } from "../utils/translations";

interface Timer {
  id: string;
  x: number;
  y: number;
  duration: number;
  startTime: number;
  currentTime: number;
  data: any;
  sentCooking: boolean;
  sentBurnt: boolean;
}

interface TimerData {
  timers: Timer[];
  currentTime: number;
}

const Timer: React.FC = () => {
  const { visibility } = useVisibility();
  const [timers, setTimers] = useState<Timer[]>([]);
  const [sentData, setSentData] = useState<any>({});
  const [currentTime, setCurrentTime] = useState<number>(0);
  const [, setTick] = useState(0);
  useNuiEvent<TimerData>("updateTimers", (data) => {
    setTimers(data.timers);
    setCurrentTime(data.currentTime);
  });

  useEffect(() => {
    const interval = setInterval(() => {
      setTick((tick) => tick + 1);
    }, 100);

    return () => clearInterval(interval);
  }, []);

  const getProgress = (timer: Timer): number => {
    const elapsed = currentTime - timer.startTime;
    const progress = elapsed / timer.duration;
    return progress;
  };

  const getTimerColor = (progress: number, elapsed: number, duration: number): string => {
    const perfectCookingWindow = 10000;
    const overTime = elapsed - duration;
    
    if (progress > 1.0 && overTime > perfectCookingWindow) {
      return "#DC2626";
    }
    if (progress > 1.0) {
      return "#10B981";
    }
    if (progress >= 0.66) {
      return "#F59E0B";
    }
          return "#EF4444";
  };

  const formatTime = (remainingMs: number, isBurning: boolean, isPerfect: boolean, timer: Timer): string => {
    if (isBurning) {
      if (!(sentData[timer.id] && sentData[timer.id].burnt)) {
        fetchNui("burntCooking", timer.data);
        setSentData({...sentData, [timer.id]: {burnt: true, perfect: false}});
      }
      return t('burnt');

      
    }
    if (isPerfect) {
      if (!(sentData[timer.id] && sentData[timer.id].perfect)) {
        fetchNui("perfectCooking", timer.data);
        setSentData({...sentData, [timer.id]: {burnt: false, perfect: true}});
      }
      return t('good');
    }
    const minutes = Math.floor(remainingMs / 60000);
    const seconds = Math.floor((remainingMs % 60000) / 1000);
    return `${minutes}:${seconds.toString().padStart(2, "0")}`;
  };

  if (timers.length === 0) return null;
  if (!visibility.visible || visibility.page !== "timer") return null;
 
  return (
    <div className="fixed inset-0 pointer-events-none z-50">
      {timers.map((timer) => {
        const elapsed = currentTime - timer.startTime;
        const progress = getProgress(timer);
        const remaining = timer.duration - elapsed;
        const perfectCookingWindow = 10000;
        const overTime = elapsed - timer.duration;
        const isBurning = progress > 1.0 && overTime > perfectCookingWindow;
        const isPerfect = progress > 1.0 && overTime <= perfectCookingWindow;

        const color = getTimerColor(progress, elapsed, timer.duration);
        const circumference = 2 * Math.PI * 30;
        const visualProgress = Math.min(progress, 1.0);
        const strokeDasharray = `${visualProgress * circumference} ${circumference}`;

        return (
          <div
            key={timer.id}
            className="absolute timer-container"
            style={{
              left: `${timer.x * 100}%`,
              top: `${timer.y * 100}%`,
              transform: "translate(-50%, -50%)",
            }}
          >
            <div className="timer-circle relative">
              <svg width="90" height="90" className="timer-svg">
                {/* Background circle */}
                <circle
                  cx="45"
                  cy="45"
                  r="35"
                  fill="none"
                  stroke="rgba(255, 255, 255, 0.2)"
                  strokeWidth="5"
                />
                
                {/* Progress circle */}
                <circle
                  cx="45"
                  cy="45"
                  r="35"
                  fill="none"
                  stroke={color}
                  strokeWidth="5"
                  strokeDasharray={`${visualProgress * (2 * Math.PI * 35)} ${2 * Math.PI * 35}`}
                  strokeDashoffset="0"
                  strokeLinecap="round"
                  style={{
                    transform: "rotate(-90deg)",
                    transformOrigin: "45px 45px",
                    transition: "stroke-dasharray 0.3s ease, stroke 0.3s ease",
                  }}
                />
              </svg>
              
              {/* Timer text */}
              <div className="timer-text absolute inset-0 flex flex-col items-center justify-center">
                <span 
                  className="text-base font-bold timer-time"
                  style={{ 
                    color,
                    textShadow: "1px 1px 3px rgba(0, 0, 0, 0.8)"
                  }}
                >
                  {formatTime(Math.max(-1, remaining), isBurning, isPerfect, timer)}
                </span>
                
                {!isBurning && !isPerfect && (
                  <div 
                    className="text-xs font-medium"
                    style={{ 
                      color: `${color}90`,
                      textShadow: "1px 1px 2px rgba(0, 0, 0, 0.8)"
                    }}
                  >
                    {Math.round(Math.min(progress * 100, 100))}%
                  </div>
                )}
              </div>
            </div>
          </div>
        );
      })}
    </div>
  );
};

export default Timer;
