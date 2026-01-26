import React, { useState } from 'react'
import { useVisibility } from '../providers/VisibilityProvider'
import { useNuiEvent } from '../hooks/useNuiEvent';
import { t } from '../utils/translations';
import '../order-status.css'

type RestaurantData = {
    id: number;
    label: string;
    logo_url?: string;
    theme_color?: string;
    secondary_color?: string;
}

type Order = {
    id: number;
    orderNumber: number;
    status: string;
    statusText: string;
    orderType: string;
    createdAt: string;
    totalAmount: number;
    notes?: string;
}

const OrderStatus = () => {
    const {visibility} = useVisibility();
    const [restaurantData, setRestaurantData] = useState<RestaurantData | null>({
        id: 0,
        label: 'Burger Shot',
        logo_url: 'https://static.wikia.nocookie.net/esgta/images/d/dd/Burger_Shot.png',
        theme_color: '#d66527',
        secondary_color: '#1c3a6b',
    });

    const [orders, setOrders] = useState<Order[]>([]);

    useNuiEvent<{restaurantData: RestaurantData}>('setRestaurantData', (data) => {
        setRestaurantData(data.restaurantData);
    });

    useNuiEvent<{orders: Order[]}>('setOrderData', (data) => {
        setOrders(data.orders);
    });

    if (!visibility.visible || visibility.page !== 'order-status') return null;


    return (
        <div className='order-status-tv'>
            <div className='tv-section'>
                <div className='tv-column'>
                    <div className='tv-header in-progress'>
                        In Progress
                    </div>
                    <div className='tv-orders-list'>
                        {orders.filter((order) => order.status === "pending" || order.status === "cooking").map((order) => (
                            <div className='tv-order-number' key={order.id}>
                                <p className='tv-order-number-text in-progress'>{order.orderNumber}</p>
                            </div>
                        ))}
                    </div>
                </div>
                <div className='tv-column'>
                    <div className='tv-header ready'>
                        Ready
                    </div>
                    <div className='tv-orders-list'>
                        {orders.filter((order) => order.status === "ready").map((order) => (
                            <div className='tv-order-number' key={order.id}>
                                <p className='tv-order-number-text ready'>{order.orderNumber}</p>
                            </div>
                        ))}
                    </div>
                </div>
            </div>
            <div className='tv-sidebar'>
                <img src={restaurantData?.logo_url} alt="Restaurant Logo" className='tv-logo' />
                <p className='tv-restaurant-name' style={{
                    color: restaurantData?.theme_color,
                }}>{restaurantData?.label}</p>
            </div>
        </div>
    )
}

export default OrderStatus