import React, { useState } from 'react'
import { useVisibility } from '../providers/VisibilityProvider'
import CreateInput from '../components/Creator/CreateInput'
import NameIcon from '../assets/resto_name.svg'
import ColorPaletteIcon from '../assets/color-palete.svg'
import MapIcon from '../assets/map.svg';
import LogoIcon from '../assets/logo-icon.svg'
import CreateColorInput from '../components/Creator/CreateColorInput'
import CreatePositionSelector from '../components/Creator/CreatePositionSelector'
import NotepadIcon from '../assets/notepad.svg'
import LocationIcon from '../assets/location-pin.svg'
import Button from '../components/Button'
import { useNuiEvent } from '../hooks/useNuiEvent'
import { fetchNui } from '../utils/fetchNui'
import { t } from '../utils/translations'

const Creator = () => {
    const { visibility } = useVisibility()
    const [formData, setFormData] = useState({
        restaurantName: '',
        blipNumber: '',
        logoUrl: '',
        color: '#FF8A65',
    })

    const [positions, setPositions] = useState({
        management: false,
        blip: false,
    })

    useNuiEvent('setPosition', ({management, blip}: {management: boolean, blip: boolean}) => {
        setPositions({
            management: management,
            blip: blip,
        })
    })

    const formValidated = () => {
        return formData.restaurantName !== '' && formData.blipNumber !== '' && formData.logoUrl !== '' && formData.color !== '' && positions.management && positions.blip
    }

    if (!visibility.visible || visibility.page !== 'creator') return null

    return (
        <>

            <div className='absolute w-[30rem] h-[45rem] rounded-sm' style={{
                top: '50%',
                left: '15%',
                transform: 'translate(-50%, -50%)',
                background: 'radial-gradient(50% 50% at 50% 50%, rgba(44, 44, 44, 0.33) 0%, rgba(0, 0, 0, 0.33) 100%)',
                borderRadius: '1px',
            }}>
                <div className='absolute w-full h-full z-[-1]' style={{
                    background: 'rgba(0, 0, 0, 0.1)',
                }}>
                </div>
                <div className='absolute w-full h-full z-[-1]' style={{
                    background: 'rgba(5, 44, 33, 0.53)',
                    borderRadius: '1px',
                }}>
                </div>
                <div className='flex flex-col w-full justify-center items-center z-99'>
                                    <h1 className='joy text-[2.6rem] mt-4 text-white' style={{
                  textShadow: "0px 0px 65.6px rgba(255, 255, 255, 0.72)"
                }}>{t('creator')}</h1>
                <p className='text-white g-light text-md mt-[-.7rem] opacity-90'>{t('create_your_restaurant')}</p>
                    <div className='flex flex-col justify-center items-center gap-2 w-full px-8 mt-8'>
                                        <CreateInput placeholder={t('restaurant_name')} value={formData.restaurantName} onChange={(e) => setFormData({ ...formData, restaurantName: e.target.value })} icon={NameIcon} />
                <CreateInput placeholder={t('blip_number')} value={formData.blipNumber} onChange={(e) => setFormData({ ...formData, blipNumber: e.target.value })} icon={MapIcon} />
                <CreateInput placeholder={t('logo_url')} value={formData.logoUrl} onChange={(e) => setFormData({ ...formData, logoUrl: e.target.value })} icon={LogoIcon} />
                        <CreateColorInput value={formData.color} onChange={(e) => setFormData({ ...formData, color: e.hex })} icon={ColorPaletteIcon} />
                    </div>
                </div>
                <div className='text-white g-light opacity-90 z-[-1] w-full text-center text-[.95rem] mt-6'>{t('restaurant_positions')}</div>
                <div className='flex flex-col gap-2 justify-center items-center px-8 mt-2'>
                                    <CreatePositionSelector active={positions.management} label={t('management')} icon={NotepadIcon} onClick={() => {
                  fetchNui('setPosition', {management: true, blip: false})
                }} />
                <CreatePositionSelector active={positions.blip} label={t('blip')} icon={LocationIcon} onClick={() => {
                  fetchNui('setPosition', {management: false, blip: true})
                }} />
                                    <Button disabled={!formValidated()} theme='green' label={t('create')} className='mt-8' onClick={() => {
                  fetchNui('createRestaurant', formData)
                }} />
                </div>
            </div>
        </>
    )
}

export default Creator