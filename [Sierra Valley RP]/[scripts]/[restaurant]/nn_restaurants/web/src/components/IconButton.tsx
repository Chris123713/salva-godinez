import React from 'react'

const IconButton = ({ theme, icon, onClick, className }: { theme?: "green" | "red", icon: string, onClick: () => void, className?: string }) => {
  return (
    <div className={`w-12 h-12 ${theme === "red" ? "create-iconbtn-red" : "create-iconbtn"} ${className}`} onClick={onClick}>
      <img src={icon} alt="icon" className="w-6 h-6" />
    </div>
  )
}

export default IconButton