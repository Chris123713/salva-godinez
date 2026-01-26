--@param source number
--@param invoiceId number
--@return boolean, number?
exports('PayInvoice', PayInvoice)

--@param invoiceId number
--@return boolean
exports('CancelInvoice', CancelInvoice)

--@param invoiceData table
--@param invoiceData.skipAcceptance boolean Optional. If true, bypasses acceptance requirement and sets invoice to 'unpaid' status immediately, even if acceptFirst is enabled in config.
--@return table|nil
exports('CreateInvoice', function(invoiceData)
    return CreateInvoice(nil, invoiceData)
end)
