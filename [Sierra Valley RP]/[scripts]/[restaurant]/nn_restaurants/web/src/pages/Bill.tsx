import React, { useState, useEffect } from 'react'
import { useVisibility } from '../providers/VisibilityProvider'
import { useNuiEvent } from '../hooks/useNuiEvent'
import { fetchNui } from '../utils/fetchNui'
import { t } from '../utils/translations'
import { 
    Receipt, 
    DollarSign, 
    Check, 
    X, 
    Clock,
    User,
    CreditCard,
    Wallet
} from 'lucide-react'
import '../restaurant-management.css'

interface BillItem {
    name: string;
    quantity: number;
    price: number;
    total: number;
}

interface BillData {
    billId: string;
    restaurantName: string;
    serverName: string;
    items: BillItem[];
    subtotal: number;
    tax: number;
    total: number;
    timestamp: string;
    paymentMethod?: string;
}

type PaymentMethod = 'cash' | 'card';

const Bill = () => {
    const { visibility } = useVisibility()
    const [billData, setBillData] = useState<BillData | null>(null)
    const [selectedPaymentMethod, setSelectedPaymentMethod] = useState<PaymentMethod>('cash')

    // Listen for bill data from server
    useNuiEvent('setBillData', (data: any) => {
        if (data) {
            setBillData(data)
        }
    })

    const handleAccept = () => {
        if (billData) {
            fetchNui('acceptBill', { 
                billId: billData.billId,
                paymentMethod: selectedPaymentMethod
            })
            // Close the bill UI after accepting
            fetchNui('closeBill', {})
        }
    }

    const handleDecline = () => {
        if (billData) {
            fetchNui('declineBill', { billId: billData.billId })
            // Close the bill UI after declining
            fetchNui('closeBill', {})
        }
    }

    const formatCurrency = (amount: number) => {
        return `$${amount.toFixed(2)}`
    }

    const formatTime = (timestamp: string) => {
        const date = new Date(timestamp)
        return date.toLocaleTimeString('en-US', { 
            hour: '2-digit', 
            minute: '2-digit' 
        })
    }

    if (!visibility.visible || visibility.page !== 'bill' || !billData) {
        return null
    }

    return (
        <div className="bill-overlay">
            <div className="bill-container">
                {/* Bill Header */}
                <div className="bill-header">
                    <div className="bill-header-content">
                        <div className="bill-icon">
                            <Receipt className="w-6 h-6" />
                        </div>
                        <div className="bill-title">
                            <h3 className="bill-restaurant-name">{billData.restaurantName}</h3>
                            <p className="bill-subtitle">{t('payment_request')}</p>
                        </div>
                        <div className="bill-time">
                            <Clock className="w-4 h-4" />
                            <span>{formatTime(billData.timestamp)}</span>
                        </div>
                    </div>
                </div>

                {/* Bill Content */}
                <div className="bill-content">
                    {/* Server Info */}
                    <div className="bill-server-info">
                        <User className="w-4 h-4" />
                        <span>{t('served_by')}: {billData.serverName}</span>
                    </div>

                    {/* Items List */}
                    <div className="bill-items">
                        <div className="bill-items-header">
                                                    <span>{t('item')}</span>
                        <span>{t('qty')}</span>
                        <span>{t('price')}</span>
                        <span>{t('total')}</span>
                        </div>
                        <div className="bill-items-list">
                            {billData.items.map((item, index) => (
                                <div key={index} className="bill-item">
                                    <span className="item-name-bill">{item.name}</span>
                                    <span className="item-quantity-bill">{item.quantity}</span>
                                    <span className="item-price-bill">{formatCurrency(item.price)}</span>
                                    <span className="item-total-bill">{formatCurrency(item.total)}</span>
                                </div>
                            ))}
                        </div>
                    </div>

                    {/* Bill Summary */}
                    <div className="bill-summary">
                        <div className="bill-summary-row">
                            <span className="bill-summary-row-label">{t('subtotal')}</span>
                            <span className="bill-summary-row-value">{formatCurrency(billData.subtotal)}</span>
                        </div>
                        <div className="bill-summary-row">
                            <span className="bill-summary-row-label">{t('tax')}</span>
                            <span className="bill-summary-row-value">{formatCurrency(billData.tax)}</span>
                        </div>
                        <div className="bill-summary-row total">
                            <span className="bill-summary-row-label">{t('total')}</span>
                            <span className="bill-summary-row-value">{formatCurrency(billData.total)}</span>
                        </div>
                    </div>

                    {/* Payment Method Selection */}
                    <div className="bill-payment-selection">
                        <div className="payment-method-title">
                            <span>Select Payment Method</span>
                        </div>
                        <div className="payment-method-options">
                            <button
                                className={`payment-method-option ${selectedPaymentMethod === 'cash' ? 'active' : ''}`}
                                onClick={() => setSelectedPaymentMethod('cash')}
                            >
                                <Wallet className="w-5 h-5" />
                                <span>{t('cash')}</span>
                            </button>
                            <button
                                className={`payment-method-option ${selectedPaymentMethod === 'card' ? 'active' : ''}`}
                                onClick={() => setSelectedPaymentMethod('card')}
                            >
                                <CreditCard className="w-5 h-5" />
                                <span>{t('card')}</span>
                            </button>
                        </div>
                    </div>
                </div>

                {/* Bill Actions */}
                <div className="bill-actions">
                    <button 
                        className="bill-button decline"
                        onClick={handleDecline}
                    >
                        <X className="w-4 h-4" />
                        {t('decline')}
                    </button>
                    <button 
                        className="bill-button accept"
                        onClick={handleAccept}
                    >
                        <Check className="w-4 h-4" />
                        {t('pay_with')} {selectedPaymentMethod === 'cash' ? t('cash') : t('card')}
                    </button>
                </div>
            </div>
        </div>
    )
}

export default Bill