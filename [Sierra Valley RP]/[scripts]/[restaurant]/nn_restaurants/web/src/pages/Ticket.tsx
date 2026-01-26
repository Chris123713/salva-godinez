import React, { useState } from 'react'
import { useVisibility } from '../providers/VisibilityProvider'
import { useNuiEvent } from '../hooks/useNuiEvent'
import { fetchNui } from '../utils/fetchNui'
import { t } from '../utils/translations'
import '../receipt.css'

interface ReceiptItem {
    id: string
    name: string
    quantity: number
    price: number
    total: number
}

interface ReceiptProps {
    receiptNumber: string
    orderType: "DINE IN" | "TAKEOUT" | "DELIVERY" | "KIOSK"
    tableNumber?: string
    serverName: string
    items: ReceiptItem[]
    subtotal: number
    tax: number
    total: number
    paymentMethod: string
    amountPaid?: number
    change?: number
    timestamp: string
    restaurantName: string
}
  

const Ticket = () => {
    const {visibility, setVisibility} = useVisibility()
    const [ticket, setTicket] = useState<ReceiptProps | null>(null)

    useNuiEvent('setTicketData', (data: any) => {
        if (data.ticketData) {
            setTicket(data.ticketData)
        }
    })

    const formatTime = (timestamp: string) => {
        const date = new Date(timestamp)
        return date.toLocaleString("en-US", {
        month: "2-digit",
        day: "2-digit",
        year: "numeric",
        hour: "2-digit",
        minute: "2-digit",
        second: "2-digit",
        hour12: true,
        })
    }

    const closeTicket = () => {
        setVisibility({ action: 'hideFrame', visible: false, page: '' })
        fetchNui('closeTicket')
    }

    if (!visibility.visible || visibility.page !== 'ticket') return null
    return (
        <div className="receipt-container-ticket">
      <div className="receipt-paper-ticket">
        {/* Header */}
        <div className="receipt-header-ticket">
                      <div className="restaurant-name-ticket">{ticket?.restaurantName || t('burger_shot')}</div>
          <div className="restaurant-address-ticket">
            123 Main Street
            <br />
            Downtown City, ST 12345
            <br />
            Tel: (555) 123-4567
          </div>
        </div>

        <div className="receipt-divider-ticket">================================</div>

        {/* Receipt Info */}
        <div className="receipt-info-ticket">
          <div className="receipt-line-ticket">
            <span>{t('receipt')} #: {ticket?.receiptNumber}</span>
          </div>
          <div className="receipt-line-ticket">
            <span>{t('date')}: {ticket?.timestamp ? formatTime(ticket.timestamp) : formatTime(new Date().toString())}</span>
          </div>
          <div className="receipt-line-ticket">
            <span>{t('server')}: {ticket?.serverName}</span>
          </div>
          <div className="receipt-line-ticket">
            <span>{t('order_type')}: {ticket?.orderType}</span>
          </div>
          {ticket?.tableNumber && ticket?.orderType === "DINE IN" && (
            <div className="receipt-line-ticket">
              <span>{t('table')}: {ticket?.tableNumber}</span>
            </div>
          )}
        </div>

        <div className="receipt-divider-ticket">================================</div>

        {/* Items */}
        <div className="receipt-items-ticket">
          <div className="items-header-ticket">
            <span className="item-desc-ticket">{t('item').toUpperCase()}</span>
            <span className="item-qty-ticket">{t('qty').toUpperCase()}</span>
            <span className="item-price-ticket">{t('price').toUpperCase()}</span>
            <span className="item-total-ticket">{t('total').toUpperCase()}</span>
          </div>
          <div className="receipt-divider-ticket">--------------------------------</div>

          {ticket?.items && ticket.items.map((item, index) => {
            return (
                <div key={item.id || index} className="receipt-item-ticket">
                  <div className="item-name-ticket">{item.name || t('unknown_item')}</div>
                  <div className="item-details-ticket">
                    <span className="item-qty-val-ticket">{item.quantity}</span>
                    <span className="item-price-val-ticket">${item.price}</span>
                    <span className="item-total-val-ticket">${item.total}</span>
                  </div>
                </div>
              )
          })}
        </div>

        <div className="receipt-divider-ticket">--------------------------------</div>

        {/* Totals */}
        {/* <div className="receipt-totals-ticket">
          <div className="total-line-ticket">
            <span>Subtotal:</span>
            <span>${ticket?.subtotal.toFixed(2)}</span>
          </div>
          <div className="total-line-ticket">
            <span>Tax (8.5%):</span>
            <span>${ticket?.tax.toFixed(2)}</span>
          </div>
          <div className="total-line-ticket total-final-ticket">
            <span>TOTAL:</span>
            <span>${ticket?.total.toFixed(2)}</span>
          </div>
        </div> */}

        <div className="receipt-divider-ticket">================================</div>

        {/* Payment Info */}
        <div className="payment-info-ticket">
          <div className="payment-line-ticket">
            <span>{t('payment_method')}: {ticket?.paymentMethod}</span>
          </div>
          {ticket?.amountPaid && (
            <div className="payment-line-ticket">
              <span>{t('amount_paid')}: ${ticket?.amountPaid}</span>
            </div>
          )}
        </div>

        <div className="receipt-divider-ticket">================================</div>

        {/* Footer */}
        <div className="receipt-footer-ticket">
          <div className="thank-you">{t('thank_you_dining')}</div>
          <div className="receipt-bottom-ticket">
            <div className="barcode-ticket">||||| |||| | ||| |||| |||||</div>
            <div className="receipt-id-ticket">{t('receipt_id')} {ticket?.receiptNumber}</div>
          </div>
        </div>
      </div>
      
      {/* Close Button */}
      <div className="ticket-close-button" onClick={closeTicket}>
        <button className="close-btn">{t('close_ticket')}</button>
      </div>
    </div>
    )
}

export default Ticket