import React, { useState, useEffect } from 'react'
import { useVisibility } from '../providers/VisibilityProvider';
import { useNuiEvent } from '../hooks/useNuiEvent';
import { fetchNui } from '../utils/fetchNui';
import { t } from '../utils/translations';
import kioskOutline from '../assets/kiosk-outline.png'
import { ChevronLeftIcon } from 'lucide-react';

type Item = {
    id: string;
    name: string;
    price: number;
    image_url?: string;
    recipe_id?: number;
    description?: string;
}

type Category = {
    id: number;
    name: string;
    description?: string;
    items: Item[];
    noTitle?: boolean;
}

type OrderItem = {
    item: Item;
    quantity?: number;
}

type RestaurantData = {
    id: number;
    label: string;
    logo_url?: string;
    theme_color?: string;
    secondary_color?: string;
}

const getTotalPrice = (items: OrderItem[]) => {
    return items.reduce((total, orderItem) => {
        const basePrice = orderItem.item.price;
        const quantity = orderItem.quantity || 1;
        return total + (quantity * basePrice);
    }, 0).toFixed(2);
}

const Kiosk = () => {
    const { visibility } = useVisibility();
    const [restaurantData, setRestaurantData] = useState<RestaurantData | null>(null);
    const [categories, setCategories] = useState<Category[]>([]);
    const [selectedItems, setSelectedItems] = useState<OrderItem[]>([]);
    const [showCheckout, setShowCheckout] = useState(false);

    useNuiEvent<{restaurantData: RestaurantData, menuData: Category[]}>('setKioskData', (data) => {
        if (data.restaurantData) {
            setRestaurantData(data.restaurantData);
        }
        if (data.menuData) {
            setCategories(data.menuData);
        }
    });

    useEffect(() => {
        const handleKeyDown = (event: KeyboardEvent) => {
            if (event.key === 'Escape' && visibility.visible && visibility.page === 'kiosk') {
                fetchNui('closeKiosk', {});
            }
        };

        window.addEventListener('keydown', handleKeyDown);
        return () => window.removeEventListener('keydown', handleKeyDown);
    }, [visibility]);

    const placeOrder = async () => {
        try {
            await fetchNui('placeKioskOrder', {
                items: selectedItems,
                total: parseFloat(getTotalPrice(selectedItems))
            });
            setSelectedItems([]);
        } catch (error) {
            console.error('Failed to place order:', error);
        }
    };

    const renderCheckout = () => (
        <div className='w-full h-full flex flex-col' style={{
            backgroundColor: "#000"
        }}>
            <div className='flex justify-between items-center p-6 pb-2'>
                <div className='flex items-center gap-3'>
                    <div 
                        onClick={() => setShowCheckout(false)}
                        className='text-white cursoir-pointer text-md flex flex-row gap-2 medium items-center justify-center'
                    >
                        <ChevronLeftIcon className='w-4 h-4' />
                        {t('back')}
                    </div>
                </div>
            </div>

            <div className='flex justify-center mb-6'>
                {restaurantData?.logo_url ? (
                    <img src={restaurantData.logo_url} alt="logo" className='w-16 h-16 object-contain' />
                ) : (
                    <div className='w-16 h-16 bg-white/20 rounded-lg flex items-center justify-center text-white text-2xl font-bold'>
                        {restaurantData?.label?.charAt(0) || 'R'}
                    </div>
                )}
            </div>

            <div className='px-6 mb-6'>
                                    <h1 className='text-white text-2xl bold'>{t('my_order').split(' ')[0]}</h1>
                    <h1 className='text-white text-2xl bold'>{t('my_order').split(' ')[1]}</h1>
            </div>

            <div className='flex-1 px-6 space-y-4'>
                <div className="overflow-y-auto" style={{ maxHeight: '100%' }}>
                    {selectedItems.map((orderItem, index) => (
                        <div key={index} className={`rounded-md p-2 flex items-center justify-between ${index === selectedItems.length - 1 ? 'mb-0' : 'mb-4'}`} style={{
                            backgroundColor: restaurantData?.secondary_color || '#fff'
                        }}>
                            <div className='flex items-center gap-4'>
                                <div className = {`w-12 h-12 rounded-md flex items-center justify-center`} style={{
                                    backgroundColor: restaurantData?.theme_color || '#fff'
                                }}>
                                    {orderItem.item.image_url ? (
                                        <img 
                                            src={orderItem.item.image_url} 
                                            alt={orderItem.item.name} 
                                            className='w-10 h-10 object-contain'
                                        />
                                    ) : (
                                        <div className='w-10 h-10 rounded' style={{
                                            backgroundColor: restaurantData?.theme_color || '#fff'
                                        }}></div>
                                    )}
                                </div>
                                <div>
                                    <h3 className='medium text-white text-md'>{orderItem.item.name.length > 20 ? orderItem.item.name.substring(0, 20) + '...' : orderItem.item.name}</h3>
                                    <p className='light text-white/80 text-sm'>${orderItem.item.price.toFixed(2)} x {orderItem.quantity || 1}</p>
                                </div>
                            </div>
                        </div>
                    ))}
                </div>
            </div>

            <div className='p-6 pt-4'>
                <div className='mb-6'>
                    <p className='text-white/80 text-lg medium'>{t('total')}</p>
                    <h2 className='text-white text-xl bold'>${getTotalPrice(selectedItems)}</h2>
                </div>
                
                <button 
                    onClick={placeOrder}
                    className='w-full py-4 rounded-2xl text-black medium text-lg'
                    style={{
                        backgroundColor: restaurantData?.theme_color || '#fff'
                    }}
                >
                                            {t('checkout')}
                </button>
            </div>
        </div>
    );

    if (!visibility.visible || visibility.page !== "kiosk") return null;
    return (
        <div className=' w-full h-full flex items-center justify-center' style={
            {
                position: 'absolute',
                top: '50%',
                left: '50%',
                transform: 'translate(-50%, -50%)',
                backgroundColor: 'rgba(0, 0, 0, 0.5)'
            }
        }>
            <img className='absolute left-0 h-[95%] top-[2%] w-full object-contain' src={kioskOutline} alt="kiosk-outline" />
            <div className='flex flex-row justify-center items-center relative w-[17%] h-[67%] mt-[-13%] rounded-[22px] bg-gray-500 overflow-hidden'>
                {showCheckout ? (
                    renderCheckout()
                ) : (
                    <>
                        <div className='w-[72%] h-full bg-[#000]'>
                    {restaurantData?.logo_url && (
                        <img src={restaurantData.logo_url} alt="logo" className='w-16 mt-4 object-contain ml-6' />
                    )}
                    <div className='flex flex-col py-4 h-[80%] mt-2 overflow-y-auto'>
                                    <h1 className='bold text-[1.5rem] ml-8 text-white'>{t('hey_greeting')}</h1>
            <h1 className='regular text-[1.5rem] mt-[-8px] ml-8 text-white'>{t('whats_up_greeting')}</h1>
                        <div className='flex flex-col justify-center px-[.5rem] gap-2 w-full mt-2'>
                                {
                                    categories.map((category) => (
                                        <div key={category.name} className='flex flex-col justify-center w-full mt-6'>
                                            {!category.noTitle && <h1 className='text-[1.3rem] bold text-white'>{category.name}</h1>}
                                            <div className='grid grid-cols-3 pt-4 gap-[.5rem]'>
                                                {category.items.map((item) => (
                                                    <div key={item.id} className={`flex flex-col justify-center items-center h-[5rem] w-[4.5rem] bg-transparent rounded-[15px] cursor-pointer`} onClick={() => {
                                                        const existingItem = selectedItems.find(orderItem => orderItem.item.id === item.id);
                                                        if (existingItem) {
                                                            setSelectedItems(selectedItems.map(orderItem => 
                                                                orderItem.item.id === item.id 
                                                                    ? {...orderItem, quantity: (orderItem.quantity || 0) + 1}
                                                                    : orderItem
                                                            ))
                                                        } else {
                                                            setSelectedItems([...selectedItems, { item, quantity: 1 }])
                                                        }
                                                    }} style={{
                                                        backgroundColor: selectedItems.some(orderItem => orderItem.item.id === item.id) ? `${restaurantData?.secondary_color}` : 'transparent',
                                                    }}>
                                                        {item.image_url && (
                                                            <img src={item.image_url} alt={item.name} className='w-[55%] mb-2 object-contain' />
                                                        )}
                                                        <h1 className='text-[.65rem] px-[1rem] text-center mx-auto medium' style={{
                                                            color: selectedItems.some(orderItem => orderItem.item.id === item.id) ? '#fff' : '#fff',
                                                            lineHeight: '10px'
                                                        }}>{item.name.length > 18 ? item.name.substring(0,18) + '...' : item.name}</h1>
                                                        {/* <div className='text-[.6rem] text-center mx-auto medium mt-2' style={{
                                                            color: selectedItems.some(orderItem => orderItem.item.id === item.id) ? '#ffcb3f' : '#ffcb3f'
                                                        }}>$ {item.price.toFixed(2)}</div> */}
                                                    </div>
                                                ))}
                                            </div>
                                        </div>
                                    ))
                                }
                        </div>
                    </div>
                </div>
                <div className='flex flex-col w-[28%] h-full border-l-[1px] border-[#101010] bg-[#090909] justify-around pt-[2rem]'>
                    <h1 className='text-[1rem] text-left semibold w-10 ml-4 text-white' style={
                        {
                            lineHeight: '19px'
                        }
                                            }>{t('my_order')}</h1>
                    <div className='flex flex-col w-full px-2 items-center h-[55%] overflow-y-auto'>
                        {selectedItems.map((item, index) => (
                            <div key={index} className='flex flex-col justify-center items-center px-2 w-full'>
                                <div className='flex justify-center items-center w-10 h-10 bg-[#171918] border-[1px] border-[#101010] rounded-[10px]'>
                                    {item.item.image_url && (
                                        <img src={item.item.image_url} alt={item.item.name} className='w-full h-full object-contain' />
                                    )}
                                </div>
                                <h1 className='text-[.6rem] medium text-white'>{item.item.name.length > 18 ? item.item.name.substring(0,18) + '...' : item.item.name}</h1>
                                <h1 className='text-[.6rem] text-[#7b7b79] medium'>${item.item.price.toFixed(2)}</h1>
                                <div className='flex flex-row justify-between w-3/4 gap-2'>
                                    <div className='text-[.6rem] border-[1px] text-center h-4 w-8 cursor-pointer border-[#101010] rounded-[10px] p-1 medium text-white' style={{lineHeight: '8px'}} onClick={() => {
                                        setSelectedItems(selectedItems.map(orderItem => {
                                            if (orderItem.item.id === item.item.id) {
                                                const newQuantity = orderItem.quantity ? orderItem.quantity - 1 : 0;
                                                if (newQuantity <= 0) {
                                                    return null;
                                                }
                                                return { ...orderItem, quantity: newQuantity };
                                            }
                                            return orderItem;
                                        }).filter(item => item !== null));
                                    }}>-</div>
                                    <span className='text-[.6rem] medium text-white mt-[2px]'>{item.quantity || 1}</span>
                                    <div className='text-[.6rem] border-[1px] text-center h-4 w-8 cursor-pointer rounded-[10px] p-1 medium text-black' style={{
                                        lineHeight: '8px',
                                        borderColor: restaurantData?.secondary_color || '#fdcb3e',
                                        backgroundColor: restaurantData?.theme_color || '#fdcb3e'
                                    }} onClick={() => {
                                        setSelectedItems(selectedItems.map(orderItem => {
                                            if (orderItem.item.id === item.item.id) {
                                                return { ...orderItem, quantity: orderItem.quantity ? orderItem.quantity + 1 : 1 };
                                            }
                                            return orderItem;
                                        }));
                                    }}>+</div>
                                </div>
                                {index !== selectedItems.length - 1 && <div className='h-[1px] w-full my-2 bg-[#101010]'></div>}
                            </div>
                        ))}
                    </div>
                    <div className='flex flex-col justify-center items-center w-full'>
                        <div className='h-[1px] w-full bg-[#101010]'></div>
                        <div className='regular text-[.7rem] text-center w-full mt-4 text-[#727272]'>{t('total')}</div>
                        <div className='medium text-[1.1rem] text-center w-full text-white'>${getTotalPrice(selectedItems)}</div>
                        <div 
                            className='flex medium text-[.8rem] h-[4.6rem] w-[80%] mt-4 justify-center items-center rounded-[25px] cursor-pointer transition-colors duration-200'
                            style={{
                                backgroundColor: restaurantData?.theme_color || '#ffcb3f'
                            }}
                            onClick={() => setShowCheckout(true)}
                        >
                            {t('done')}
                        </div>
                    </div>
                </div>
                        </>
                )}
            </div>
        </div>
    )
}

export default Kiosk