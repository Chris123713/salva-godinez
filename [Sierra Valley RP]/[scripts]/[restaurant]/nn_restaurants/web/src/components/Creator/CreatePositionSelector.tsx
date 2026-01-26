import React from 'react'

const CreatePositionSelector = ({label, icon, active, onClick}: {label: string, icon: string, active: boolean, onClick: () => void}) => {
  return (
    <div className='w-full p-4 py-[.9rem] flex justify-between items-center cursor-pointer rounded-md hover:scale-[1.02] transition-all duration-300' onClick={onClick} style={{
        background: 'rgba(11, 60, 45, 0.72)',
        boxShadow: 'inset 0px 0px 5.8px rgba(134, 134, 134, 0.28)',
        borderRadius: '1px',
        color: active ? '#43FFCD' : '#fff',
        opacity: active ? 1 : 0.7,
    }}>
        <div className='w-5/6 joy text-white opacity-85 text-[1.4rem]'>{label}</div>
        <div className='flex justify-end items-center w-1/6'>
            <img src={icon} className='w-6' />
        </div>
    </div>
  )
}

export default CreatePositionSelector