import React from 'react'

interface ToggleSelectProps {
  options: string[];
  active: string;
  setActive: (active: string) => void;
  colorScheme?: 'default' | 'status' | 'difficulty';
}

const ToggleSelect = ({options, active, setActive, colorScheme = 'default'}: ToggleSelectProps) => {
  
  const getOptionColors = (option: string, isActive: boolean) => {
    let colors = {
      background: isActive ? "rgba(11, 60, 45, 0.91)" : "transparent",
      hoverBackground: isActive ? "rgba(23, 79, 64, 0.5)" : "rgba(11, 60, 45, 0.3)",
      textColor: isActive ? "#43FFCD" : "#9ca3af",
      hoverTextColor: "#43FFCD",
      textShadow: isActive ? "0px 0px 4px rgba(0, 0, 0, 0.5), 0px 0px 46.3px #1FEEB0" : "none"
    };

    if (colorScheme === 'status') {
      const isPositive = ['open', 'active', 'yes', 'enabled', 'on'].includes(option.toLowerCase());
      const isNegative = ['closed', 'inactive', 'no', 'disabled', 'off'].includes(option.toLowerCase());
      
      if (isNegative) {
        colors = {
          background: isActive ? "#561B1C" : "transparent",
          hoverBackground: isActive ? "rgba(86, 27, 28, 0.7)" : "rgba(86, 27, 28, 0.3)",
          textColor: isActive ? "#FF4C50" : "#9ca3af",
          hoverTextColor: "#FF4C50",
          textShadow: isActive ? "0px 0px 4px rgba(0, 0, 0, 0.5), 0px 0px 46.3px #E9484B" : "none"
        };
      }
    }

    if (colorScheme === 'difficulty') {
      const option_lower = option.toLowerCase();
      if (option_lower === 'easy') {
        colors = {
          background: isActive ? "rgba(11, 60, 45, 0.91)" : "transparent",
          hoverBackground: isActive ? "rgba(23, 79, 64, 0.5)" : "rgba(11, 60, 45, 0.3)",
          textColor: isActive ? "#43FFCD" : "#9ca3af",
          hoverTextColor: "#43FFCD",
          textShadow: isActive ? "0px 0px 4px rgba(0, 0, 0, 0.5), 0px 0px 46.3px #1FEEB0" : "none"
        };
      } else if (option_lower === 'medium') {
        colors = {
          background: isActive ? "rgba(120, 53, 15, 0.91)" : "transparent",
          hoverBackground: isActive ? "rgba(120, 53, 15, 0.7)" : "rgba(120, 53, 15, 0.3)",
          textColor: isActive ? "#F59E0B" : "#9ca3af",
          hoverTextColor: "#F59E0B",
          textShadow: isActive ? "0px 0px 4px rgba(0, 0, 0, 0.5), 0px 0px 46.3px #F59E0B" : "none"
        };
      } else if (option_lower === 'hard') {
        colors = {
          background: isActive ? "#561B1C" : "transparent",
          hoverBackground: isActive ? "rgba(86, 27, 28, 0.7)" : "rgba(86, 27, 28, 0.3)",
          textColor: isActive ? "#FF4C50" : "#9ca3af",
          hoverTextColor: "#FF4C50",
          textShadow: isActive ? "0px 0px 4px rgba(0, 0, 0, 0.5), 0px 0px 46.3px #E9484B" : "none"
        };
      }
    }

    return colors;
  };

  return (
    <div className='flex flex-row h-12 w-full relative rounded-sm overflow-hidden' style={{
      background: "rgba(217, 217, 217, 0.19)",
    }}>
        {options.map((option, index) => {
          const colors = getOptionColors(option, active === option);
          
          return (
            <div 
              key={option}
              className='h-full g-medium uppercase w-full cursor-pointer flex items-center justify-center relative transition-all duration-100 ease-out' 
              style={{
                background: colors.background,
                boxShadow: active === option 
                  ? "inset 0px 0px 5.8px rgba(134, 134, 134, 0.28)" 
                  : "none",
                borderRadius: active === option ? "2px" : "0px",
                margin: "0px",
                color: colors.textColor,
                fontSize: "0.875rem",
                letterSpacing: "0.05em",
                textShadow: colors.textShadow,
                zIndex: active === option ? 2 : 1,
                position: "relative",
              }} 
              onClick={() => setActive(option)}
              onMouseEnter={(e) => {
                e.currentTarget.style.background = colors.hoverBackground;
                e.currentTarget.style.color = colors.hoverTextColor;
                if (active === option) {
                  e.currentTarget.style.transform = "scale(1.02)";
                }
              }}
              onMouseLeave={(e) => {
                e.currentTarget.style.background = colors.background;
                e.currentTarget.style.color = colors.textColor;
                if (active === option) {
                  e.currentTarget.style.transform = "scale(1)";
                }
              }}
            >
              <span className="relative z-10">{option}</span>
            </div>
          );
        })}
    </div>
  )
}

export default ToggleSelect