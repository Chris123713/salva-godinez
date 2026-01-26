import { useState, useEffect } from "react"
import "../pos-system.css"
import { useVisibility } from "../providers/VisibilityProvider"
import { useNuiEvent } from "../hooks/useNuiEvent"
import { fetchNui } from "../utils/fetchNui"
import { t } from "../utils/translations"
import TabletOutline from '../assets/tablet-outline.png'

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
}

interface OrderItem extends Item {
  quantity: number
  notes?: string
}

type RestaurantData = {
  id: number;
  label: string;
  logo_url?: string;
  theme_color?: string;
  secondary_color?: string;
}

type OrderItemDetail = {
  id: string;
  name: string;
  quantity: number;
  unit_price: number;
  total_price: number;
  special_instructions?: string;
}

type Order = {
  id: number;
  order_number: string;
  order_type: string;
  status: 'pending' | 'cooking' | 'ready' | 'completed' | 'cancelled';
  total_amount: number;
  created_at: string;
  notes?: string;
  items: OrderItemDetail[];
}

export default function POSSystem() {
  const {visibility} = useVisibility()
  const [restaurantData, setRestaurantData] = useState<RestaurantData | null>(null);
  const [categories, setCategories] = useState<Category[]>([]);
  const [selectedCategory, setSelectedCategory] = useState<string>("")
  const [currentOrder, setCurrentOrder] = useState<OrderItem[]>([])
  const [orderType, setOrderType] = useState<"Dine In" | "Takeout" | "Delivery">("Dine In")
  const [tableNumber, setTableNumber] = useState("")
  
  // Order management state
  const [activeTab, setActiveTab] = useState<"new-order" | "order-management">("new-order")
  const [orders, setOrders] = useState<Order[]>([])
  const [selectedOrder, setSelectedOrder] = useState<Order | null>(null)
  const [orderStatusFilter, setOrderStatusFilter] = useState<string>("all")
  const [currentRestaurantId, setCurrentRestaurantId] = useState<number | null>(null)

  // Use NUI event hook like in other components
  useNuiEvent<{restaurantData: RestaurantData, menuData: Category[], restaurantId: number}>('setPOSData', (data) => {
    if (data.restaurantData) {
      setRestaurantData(data.restaurantData);
    }
    if (data.restaurantId) {
      setCurrentRestaurantId(data.restaurantId);
    }
    if (data.menuData && data.menuData.length > 0) {
      setCategories(data.menuData);
      // Set first category as default if none selected
      if (!selectedCategory && data.menuData[0]) {
        setSelectedCategory(data.menuData[0].name);
      }
    }
  });

  // Order management events
  useNuiEvent<{orders: Order[]}>('setPOSOrders', (data) => {
    setOrders(data.orders);
  });

  // Listen for successful order creation to refresh orders
  useNuiEvent<{success: boolean}>('orderCreated', (data) => {
    if (data.success) {
      // Request fresh orders from server
      fetchNui('requestPOSOrders', {
        restaurantId: currentRestaurantId
      });
    }
  });

  // Handle ESC key to close POS
  useEffect(() => {
    const handleKeyDown = (event: KeyboardEvent) => {
      if (event.key === 'Escape' && visibility.visible && visibility.page === 'pos') {
        fetchNui('closePOS', {});
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [visibility]);

  // Set default category when categories load
  useEffect(() => {
    if (categories.length > 0 && !selectedCategory) {
      setSelectedCategory(categories[0].name);
    }
  }, [categories, selectedCategory]);


  const addToOrder = (item: Item) => {
    const existingItem = currentOrder.find((orderItem) => orderItem.id === item.id)

    if (existingItem) {
      setCurrentOrder(
        currentOrder.map((orderItem) =>
          orderItem.id === item.id ? { ...orderItem, quantity: orderItem.quantity + 1 } : orderItem,
        ),
      )
    } else {
      setCurrentOrder([...currentOrder, { ...item, quantity: 1 }])
    }
  }

  const removeFromOrder = (itemId: string) => {
    setCurrentOrder(currentOrder.filter((item) => item.id !== itemId))
  }

  const updateQuantity = (itemId: string, newQuantity: number) => {
    if (newQuantity === 0) {
      removeFromOrder(itemId)
    } else {
      setCurrentOrder(currentOrder.map((item) => (item.id === itemId ? { ...item, quantity: newQuantity } : item)))
    }
  }

  const getTotal = () => {
    return currentOrder.reduce((total, item) => total + item.price * item.quantity, 0)
  }

  const clearOrder = () => {
    setCurrentOrder([])
  }

  const processPayment = async () => {
    try {
      await fetchNui<{success: boolean}>('processPOSOrder', {
        items: currentOrder,
        total: getTotal(),
        orderType,
        tableNumber: orderType === "Dine In" ? tableNumber : undefined
      });
      
      clearOrder();
      setTableNumber("");
      
      fetchNui('requestPOSOrders', {
        restaurantId: currentRestaurantId
      });
    } catch (error) {
      console.error('Failed to process payment:', error);
    }
  }

  const updateOrderStatus = async (orderId: number, newStatus: string) => {
    try {
      await fetchNui('updateOrderStatus', {
        orderId,
        status: newStatus,
        restaurantId: restaurantData?.id
      });
      setOrders(orders.map(order => order.id === orderId ? { ...order, status: newStatus as "pending" | "cooking" | "ready" | "completed" | "cancelled" } : order));
      // Reload orders after status update
    } catch (error) {
      console.error('Failed to update order status:', error);
    }
  }

  const clearCancelledOrder = async (orderId: number) => {
    fetchNui('clearCancelledOrder', { orderId });
    setOrders(orders.filter(order => order.id !== orderId));
  }

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleString();
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'pending': return '#f39c12';
      case 'cooking': return '#3498db';
      case 'ready': return '#27ae60';
      case 'completed': return '#2ecc71';
      case 'cancelled': return '#e74c3c';
      default: return '#95a5a6';
    }
  }

  const getStatusLabel = (status: string) => {
    return status.charAt(0).toUpperCase() + status.slice(1);
  }

  // Filter orders based on status - show all orders including completed in POS
  const filteredOrders = orders.filter(order => {
    // Apply status filter
    return (orderStatusFilter === "all" && order.status !== 'completed') || order.status === orderStatusFilter;
  });


  // Get current category items
  const currentCategoryData = categories.find(cat => cat.name === selectedCategory);
  const filteredItems = currentCategoryData?.items || [];

  if (!visibility.visible || visibility.page !== "pos") return null

  return (
    <div className="computer-monitor mt-[5.9rem]" style={{
      filter: "drop-shadow(0 30px 60px rgba(0, 0, 0, 0.9)) drop-shadow(0 10px 30px rgba(0, 0, 0, 0.6))",
      transform: "perspective(1000px) rotateX(5deg)"
    }}>
      <img src={TabletOutline} alt="Tablet Outline" className="absolute left-0 w-full h-full scale-[1.07] object-contain" />
      <div className="monitor-frame">
        <div className="pos-container">
          {/* Header */}
          <div className="pos-header">
            <div className="restaurant-info">
              <h1>{restaurantData?.label || t('restaurant')} {t('pos_version')}</h1>
              <div className="pos-tabs mt-1">
                <button
                  className={`pos-tab new-order-tab ${activeTab === "new-order" ? "active" : ""}`}
                  onClick={() => setActiveTab("new-order")}
                >
                  {t('new_order')}
                </button>
                <button
                  className={`pos-tab order-mgmt-tab ${activeTab === "order-management" ? "active" : ""}`}
                  onClick={() => setActiveTab("order-management")}
                >
                  {t('order_management')}
                </button>
              </div>
            </div>
            <div className="pos-header-right">
              <div className="employee-info">
                <div>{t('employee')}: STAFF_01</div>
                <div>{t('terminal')}: 001</div>
                <div>{new Date().toLocaleString()}</div>
              </div>
            </div>
          </div>

          <div className="pos-main">
            {activeTab === "new-order" ? (
              <>
                {/* Menu Section */}
                <div className="menu-section">
                  {/* Categories */}
                  <div className="categories">
                    {categories.map((category) => (
                      <button
                        key={category.id}
                        className={`category-btn ${selectedCategory === category.name ? "active" : ""}`}
                        onClick={() => setSelectedCategory(category.name)}
                      >
                        {category.name}
                      </button>
                    ))}
                  </div>

                  {/* Menu Items */}
                  <div className="menu-items">
                    {filteredItems.map((item) => (
                      <button key={item.id} className="menu-item-btn" onClick={() => addToOrder(item)}>
                        <img 
                          src={item.image_url || "/placeholder.svg"} 
                          alt={item.name} 
                          className="item-image"
                          onError={(e) => {
                            const target = e.currentTarget as HTMLImageElement;
                            target.src = "/placeholder.svg";
                          }}
                        />
                        <div className="item-info">
                          <div className="item-name">{item.name}</div>
                          <div className="item-price">${item.price}</div>
                        </div>
                      </button>
                    ))}
                  </div>
                </div>

                {/* Order Section */}
                <div className="order-section">
                  <div className="order-header">
                    <h3>{t('current_order')}</h3>
                    <button className="clear-btn" onClick={clearOrder}>
                      {t('clear_all')}
                    </button>
                  </div>

                  <div className="order-items">
                    {currentOrder.length === 0 ? (
                      <div className="empty-order">{t('no_items_in_order')}</div>
                    ) : (
                      currentOrder.map((item) => (
                        <div key={item.id} className="order-item">
                          <img 
                            src={item.image_url || "/placeholder.svg"} 
                            alt={item.name} 
                            className="order-item-image"
                            onError={(e) => {
                              const target = e.currentTarget as HTMLImageElement;
                              target.src = "/placeholder.svg";
                            }}
                          />
                          <div className="order-item-info">
                            <div className="order-item-name">{item.name}</div>
                            <div className="order-item-price">${item.price.toFixed(2)}</div>
                          </div>
                          <div className="quantity-controls">
                            <button onClick={() => updateQuantity(item.id, item.quantity - 1)}>-</button>
                            <span className="quantity">{item.quantity}</span>
                            <button onClick={() => updateQuantity(item.id, item.quantity + 1)}>+</button>
                          </div>
                          <div className="item-total">${(item.price * item.quantity).toFixed(2)}</div>
                          <button className="remove-btn" onClick={() => removeFromOrder(item.id)}>
                            ×
                          </button>
                        </div>
                      ))
                    )}
                  </div>

                  <div className="order-summary">
                    <div className="subtotal">
                      <span>{t('subtotal')}</span>
                      <span>${getTotal().toFixed(2)}</span>
                    </div>
                    <div className="tax">
                      <span>{t('tax')}</span>
                      <span>${(getTotal() * 0.085).toFixed(2)}</span>
                    </div>
                    <div className="total">
                      <span>{t('total')}</span>
                      <span>${(getTotal() * 1.085).toFixed(2)}</span>
                    </div>
                  </div>

                  <div className="action-buttons">
                    <button className="hold-btn">{t('hold_order')}</button>
                    <button className="print-btn">{t('print_receipt')}</button>
                    <button 
                      className="payment-btn"
                      onClick={processPayment}
                      disabled={currentOrder.length === 0}
                    >
                      {t('process_payment')}
                    </button>
                  </div>
                </div>
              </>
            ) : (
              <>
                {/* Order Management Section */}
                <div className="order-management-section">
                  {/* Filter Controls */}
                  <div className="order-filters">
                    <select 
                      value={orderStatusFilter} 
                      onChange={(e) => setOrderStatusFilter(e.target.value)}
                      className="status-filter"
                    >
                      <option value="all">{t('all_orders')}</option>
                      <option value="pending">{t('pending')}</option>
                      <option value="cooking">{t('cooking')}</option>
                      <option value="ready">{t('ready')}</option>
                      <option value="completed">{t('completed')}</option>
                      <option value="cancelled">{t('cancelled')}</option>
                    </select>
                  </div>

                  {/* Orders List */}
                  <div className="orders-list">
                    {filteredOrders.length === 0 ? (
                      <div className="empty-orders">{t('no_orders_found')}</div>
                    ) : (
                      filteredOrders.map((order) => (
                        <div key={order.id} className="order-card">
                          <div className="order-header-info">
                            <div className="order-number-mgmt">#{order.order_number}</div>
                            <div className="order-status" style={{ color: getStatusColor(order.status) }}>
                              {getStatusLabel(order.status)}
                            </div>
                          </div>
                          <div className="order-details">
                            <div className="order-type">{order.order_type.toUpperCase()}</div>
                            <div className="order-time">{formatDate(order.created_at)}</div>
                            <div className="order-total">${order.total_amount}</div>
                          </div>
                          {order.notes && (
                            <div className="order-notes">{t('notes')}: {order.notes}</div>
                          )}
                          <div className="order-items-preview">
                            {order.items.slice(0, 3).map((item) => (
                              <span key={item.id} className="order-item-preview">
                                {item.quantity}x {item.name}
                              </span>
                            ))}
                            {order.items.length > 3 && (
                              <span className="more-items">+{order.items.length - 3} more</span>
                            )}
                          </div>
                          <div className="order-actions">
                            <button 
                              className="view-details-btn"
                              onClick={() => setSelectedOrder(order)}
                            >
                              {t('view_details')}
                            </button>
                            <div className="status-actions">
                              {order.status !== 'completed' && order.status !== 'cancelled' && (
                                <>
                                  <button 
                                    className="status-btn cooking"
                                    onClick={() => updateOrderStatus(order.id, 'cooking')}
                                    disabled={order.status === 'cooking'}
                                  >
                                    {t('cooking').toUpperCase()}
                                  </button>
                                  <button 
                                    className="status-btn ready"
                                    onClick={() => updateOrderStatus(order.id, 'ready')}
                                    disabled={order.status === 'ready'}
                                  >
                                    {t('ready').toUpperCase()}
                                  </button>
                                  <button 
                                    className="status-btn completed"
                                    onClick={() => updateOrderStatus(order.id, 'completed')}
                                  >
                                    {t('complete')}
                                  </button>
                                  <button 
                                    className="status-btn cancelled"
                                    onClick={() => updateOrderStatus(order.id, 'cancelled')}
                                  >
                                    {t('cancel')}
                                  </button>
                                </>
                              )}
                              {order.status === 'cancelled' && (
                                <button 
                                  className="status-btn clear"
                                  onClick={() => clearCancelledOrder(order.id)}
                                >
                                  {t('clear')}
                                </button>
                              )}
                            </div>
                          </div>
                        </div>
                      ))
                    )}
                  </div>
                </div>

                {/* Order Details Modal */}
                {selectedOrder && (
                  <div className="order-details-modal">
                    <div className="modal-content">
                      <div className="modal-header">
                        <h3>Order #{selectedOrder.order_number}</h3>
                        <button 
                          className="close-modal"
                          onClick={() => setSelectedOrder(null)}
                        >
                          ×
                        </button>
                      </div>
                      <div className="modal-body">
                        <div className="order-info">
                          <div className="info-row">
                            <span>{t('status')}:</span>
                            <span style={{ color: getStatusColor(selectedOrder.status) }}>
                              {getStatusLabel(selectedOrder.status)}
                            </span>
                          </div>
                          <div className="info-row">
                            <span>{t('type')}:</span>
                            <span>{selectedOrder.order_type.toUpperCase()}</span>
                          </div>
                          <div className="info-row">
                            <span>{t('created')}:</span>
                            <span>{formatDate(selectedOrder.created_at)}</span>
                          </div>
                          <div className="info-row">
                            <span>{t('total')}:</span>
                            <span>${selectedOrder.total_amount}</span>
                          </div>
                          {selectedOrder.notes && (
                            <div className="info-row">
                              <span>{t('notes')}:</span>
                              <span>{selectedOrder.notes}</span>
                            </div>
                          )}
                        </div>
                        <div className="order-items-detail">
                          <h4>{t('order_items')}</h4>
                          {selectedOrder.items.map((item) => (
                            <div key={item.id} className="detail-item">
                              <div className="item-quantity">{item.quantity}x</div>
                              <div className="item-name">{item.name}</div>
                              <div className="item-price">${item.total_price}</div>
                              {item.special_instructions && (
                                <div className="item-notes">*{item.special_instructions}</div>
                              )}
                            </div>
                          ))}
                        </div>
                      </div>
                    </div>
                  </div>
                )}
              </>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
