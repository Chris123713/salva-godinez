import React from 'react'

const CreateInput = ({ placeholder, value, icon, style, onChange }: { placeholder: string, value: string, icon: string, style?: React.CSSProperties, onChange: (e: React.ChangeEvent<HTMLInputElement>) => void }) => {
  return (
    <div className='flex flex-row items-center gap-2 justify-around p-4 rounded-md w-full' style={{
        background: 'rgba(217, 217, 217, 0.19)',
        filter: 'drop-shadow(0px 0px 15.8px rgba(0, 0, 0, 0.21))',
        ...style
    }}>
        <input 
            type="text" 
            placeholder={placeholder} 
            value={value} 
            onChange={onChange} 
            className='w-3/4 bg-transparent outline-none border-none text-white g-medium text-md creator-input'
        />
        <div className='w-1/4 flex justify-end items-center'>
            <img src={icon} className='w-6' />
        </div>
    </div>
  )
}

export default CreateInput