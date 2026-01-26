import React, { useState, useEffect, useRef } from 'react'
// @ts-ignore - react-color types are not properly installed
import { BlockPicker } from 'react-color'

interface ColorResult {
    hex: string;
}

const CreateColorInput = ({value, icon, onChange }: { value: string, icon: string, onChange: (e: { hex: string }) => void }) => {
    const [showPicker, setShowPicker] = useState(false)
    const pickerRef = useRef<HTMLDivElement>(null)

    const handleColorChange = (color: ColorResult) => {
        onChange({ hex: color.hex })
    }

    // Close picker when clicking outside
    useEffect(() => {
        const handleClickOutside = (event: MouseEvent) => {
            if (pickerRef.current && !pickerRef.current.contains(event.target as Node)) {
                setShowPicker(false)
            }
        }

        if (showPicker) {
            document.addEventListener('mousedown', handleClickOutside)
        }

        return () => {
            document.removeEventListener('mousedown', handleClickOutside)
        }
    }, [showPicker])

  return (
    <div className="relative w-full">
    <div className='flex flex-row items-center gap-2 justify-around p-4 rounded-md w-full' style={{
        background: 'rgba(217, 217, 217, 0.19)',
        filter: 'drop-shadow(0px 0px 15.8px rgba(0, 0, 0, 0.21))',
    }}>
        <div 
            className='w-5/6 h-8 rounded-md flex flex-row items-center gap-2 cursor-pointer border-2 border-white/20' 
            style={{
                    background: value || '#43FFCD',
                filter: 'drop-shadow(0px 0px 8px rgba(255, 255, 255, 0.15))'
            }}
            onClick={() => {
                setShowPicker(!showPicker)
            }}
        >
                <div className="w-full h-full rounded-md" style={{ backgroundColor: value || '#43FFCD' }}></div>
        </div>
        <div className='w-1/6 flex justify-end items-center'>
            <img src={icon} className='w-6' />
        </div>
    </div>
        {showPicker && (
            <div 
                ref={pickerRef}
                className='absolute top-full left-0 mt-2 z-50'
                style={{ zIndex: 9999 }}
            >
                <BlockPicker 
                    color={value || '#43FFCD'} 
                    onChange={handleColorChange}
                    styles={{
                        default: {
                            card: {
                                background: '#1a1a1a',
                                border: '1px solid rgba(255, 255, 255, 0.1)',
                                borderRadius: '8px',
                                boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)',
                                zIndex: 9999
                            },
                            body: {
                                padding: '12px'
                            },
                            input: {
                                background: 'rgba(255, 255, 255, 0.1)',
                                border: '1px solid rgba(255, 255, 255, 0.2)',
                                borderRadius: '4px',
                                color: 'white',
                                fontSize: '12px',
                                padding: '4px 6px'
                            },
                            label: {
                                color: 'white',
                                fontSize: '11px'
                            }
                        }
                    }}
                />
            </div>
    )}
    </div>
  )
}

export default CreateColorInput