"use client"

import { useState, useEffect } from "react"
import "../kitchen-display.css"
import { useVisibility } from "../providers/VisibilityProvider"
import { useNuiEvent } from "../hooks/useNuiEvent"
import { t } from "../utils/translations"

interface OrderItem {
  id: string
  name: string
  quantity: number
  notes?: string
}

interface Order {
  id: string
  orderNumber: string
  status: string
  items: OrderItem[]
  orderTime: string
  orderType: "DINE IN" | "TAKEOUT" | "DELIVERY"
  tableNumber?: string
  notes?: string
}

interface RestaurantData {
  id: number
  label: string
  theme_color: string
}

export default function KitchenDisplayRealistic() {
  const [orders, setOrders] = useState<Order[]>([])
  const [restaurantData, setRestaurantData] = useState<RestaurantData | null>(null)
  const [currentTime, setCurrentTime] = useState(new Date())
  const { visibility } = useVisibility()

  // Listen for real order data from the server
  useNuiEvent<{restaurantData: RestaurantData}>('setRestaurantData', (data) => {
    setRestaurantData(data.restaurantData)
  })

  useNuiEvent<{orders: Order[]}>('setKitchenOrders', (data) => {
    setOrders(data.orders)
  })

  // Update current time every second and refresh orders every 30 seconds
  useEffect(() => {
    const timeTimer = setInterval(() => {
      setCurrentTime(new Date())
    }, 1000)

    const orderTimer = setInterval(() => {
      // Trigger a refresh of order data
      if (visibility.visible && visibility.page === "kitchen") {
        // The TV system will handle the refresh automatically
      }
    }, 30000) // Refresh every 30 seconds

    return () => {
      clearInterval(timeTimer)
      clearInterval(orderTimer)
    }
  }, [visibility.visible, visibility.page])

  const formatTime = (dateString: string) => {
    const date = new Date(dateString)
    return date.toLocaleTimeString("en-US", {
      hour: "2-digit",
      minute: "2-digit",
      second: "2-digit",
      hour12: false,
    })
  }

  const getElapsedMinutes = (orderTimeString: string) => {
    const orderTime = new Date(orderTimeString)
    return Math.floor((currentTime.getTime() - orderTime.getTime()) / 1000 / 60)
  }

  if (!visibility.visible || visibility.page !== "kitchen") return null

  return (
    <div className="kitchen-display-realistic">
      {/* Header */}
      <div className="display-header">
        <div className="header-left">
                      <div className="restaurant-name">{restaurantData?.label?.toUpperCase() || t('restaurant')}</div>
                          <div className="system-info">{t('kitchen_display_system')}</div>
        </div>
        <div className="header-right">
          <div className="current-time">{currentTime.toLocaleTimeString("en-US", {
            hour: "2-digit",
            minute: "2-digit",
            second: "2-digit",
            hour12: false,
          })}</div>
                          <div className="terminal-info">{t('terminal')}</div>
        </div>
      </div>

      {/* Orders Grid */}
      <div className="orders-grid">
        {orders.map((order) => {
          const elapsedMinutes = getElapsedMinutes(order.orderTime)
          const isOverdue = elapsedMinutes >= 8

          return (
            <div key={order.id} className={`order-ticket ${isOverdue ? "overdue" : ""}`}>
              {/* Ticket Header */}
              <div className="ticket-header">
                <div className="order-number">#{order.orderNumber}</div>
                <div className="order-meta">
                  <div className="order-time">{formatTime(order.orderTime)}</div>
                  <div className={`elapsed-time ${isOverdue ? "overdue-time" : ""}`}>{elapsedMinutes}:00</div>
                </div>
                <div className={`tv-order-status ${order.status}`}>
                  {order.status.toUpperCase()}
                </div>
              </div>

              {/* Order Type Bar */}
              <div className={`order-type-bar ${order.orderType.toLowerCase().replace(" ", "-")}`}>
                <span className="order-type-text">{order.orderType}</span>
                {order.tableNumber && <span className="table-number">{t('table')} {order.tableNumber}</span>}
              </div>

              {/* Order Items */}
              <div className="order-items-kitchen">
                {order.items.map((item) => (
                  <div key={item.id} className="order-item-kitchen">
                    <div className="item-qty">{item.quantity}</div>
                    <div className="item-details">
                      <div className="item-name-kitchen">{item.name}</div>
                      {item.notes && <div className="item-notes">*{item.notes}</div>}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )
        })}
      </div>

      {/* Footer */}
      <div className="display-footer">
        <div className="footer-left">
          <div className="status-info">
                            <span className="status-label">{t('active_orders')}</span>
            <span className="status-value">{orders.length}</span>
            <span className="status-separator">|</span>
            <span className="status-label">{t('overdue_label')}</span>
            <span className="status-value overdue-count">
              {orders.filter((o) => getElapsedMinutes(o.orderTime) >= 8).length}
            </span>
          </div>
        </div>
        <div className="footer-right">
          <div className="legend">
            <span className="legend-item">
              <span className="legend-color dine-in"></span>{t('dine_in_legend')}
            </span>
            <span className="legend-item">
              <span className="legend-color takeout"></span>{t('takeout_legend')}
            </span>
            <span className="legend-item">
              <span className="legend-color delivery"></span>{t('delivery_legend')}
            </span>
            <span className="legend-item">
              <span className="legend-color overdue"></span>{t('overdue_legend')}
            </span>
          </div>
        </div>
      </div>
    </div>
  )
}
