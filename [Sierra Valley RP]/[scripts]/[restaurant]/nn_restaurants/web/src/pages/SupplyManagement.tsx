import React, { useState, useEffect } from 'react'
import { fetchNui } from '../utils/fetchNui'
import { useNuiEvent } from '../hooks/useNuiEvent'
import { useVisibility } from '../providers/VisibilityProvider'
import { t } from '../utils/translations'

interface SupplyItem {
    id: string
    label: string
    currentAmount: number
    maxCapacity: number
    item: string
}

interface InventoryItem {
    name: string;
    amount: number;
}

interface SupplyManagementData {
    machineType: 'soda_juice' | 'coffee'
    machineLabel: string
    supplies: SupplyItem[]
    playerInventory: InventoryItem[]
}

const SupplyManagement: React.FC = () => {
    const { visibility } = useVisibility()
    const [machineData, setMachineData] = useState<SupplyManagementData | null>(null)
    const [selectedSupply, setSelectedSupply] = useState<string | null>(null)
    const [addAmount, setAddAmount] = useState(1)

    useNuiEvent('openSupplyManagement', (data: SupplyManagementData) => {
        setMachineData(data)
    })

    useNuiEvent('closeSupplyManagement', () => {
        setMachineData(null)
        setSelectedSupply(null)
        setAddAmount(1)
    })

    const handleClose = () => {
        fetchNui('closeSupplyManagement')
    }

    const handleAddSupply = (supplyId: string) => {
        if (!machineData || addAmount <= 0) return

        const supply = machineData.supplies.find(s => s.id === supplyId)
        if (!supply) return

        const playerAmount = machineData.playerInventory.find(i => i.name === supply.item)?.amount || 0
        if (playerAmount < addAmount) {
            return
        }

        fetchNui('addSupply', {
            supplyId,
            amount: addAmount
        })
    }

    const getSupplyPercentage = (current: number, max: number) => {
        return Math.min((current / max) * 100, 100)
    }

    const getSupplyColor = (percentage: number) => {
        if (percentage >= 80) return 'bg-green-500'
        if (percentage >= 50) return 'bg-yellow-500'
        if (percentage >= 20) return 'bg-orange-500'
        return 'bg-red-500'
    }

    const getSupplyStatus = (percentage: number) => {
        if (percentage >= 80) return t('excellent')
        if (percentage >= 50) return t('good')
        if (percentage >= 20) return t('low')
        return t('critical')
    }

    if (!visibility.visible || visibility.page !== 'supply_management' || !machineData) return null

    return (
        <div className="fixed inset-0 bg-black/60 flex items-center justify-center z-50">
            <div className="bg-black/50 rounded-2xl shadow-lg max-w-4xl h-[64vh] w-[32vw] overflow-hidden border border-white/20 flex flex-col">
                {/* Header */}
                <div className="bg-[#280707] p-4 border-b border-white/20">
                    <div className="flex items-center justify-between">
                        <div>
                            <h2 className="text-xl font-bold text-white">{t('supply_management')}</h2>
                            <p className="text-green-100 text-sm">{machineData.machineLabel}</p>
                        </div>
                        <button
                            onClick={handleClose}
                            className="bg-white text-black p-2 rounded-lg transition-all duration-200 hover:bg-gray-100"
                        >
                            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                            </svg>
                        </button>
                    </div>
                </div>

                {/* Content */}
                <div className="p-4 flex-1 overflow-y-auto bg-black/50">
                    <div className="space-y-4">
                        {/* Supplies List */}
                        <div className="space-y-3">
                            <h3 className="text-sm font-bold text-white">{t('current_stock')}</h3>
                            {machineData.supplies.map((supply) => {
                                const percentage = getSupplyPercentage(supply.currentAmount, supply.maxCapacity)
                                const status = getSupplyStatus(percentage)
                                
                                return (
                                    <div
                                        key={supply.id}
                                        className={`bg-white/10 hover:bg-white/20 border border-white/20 hover:border-green-400 rounded-lg p-3 transition-all duration-200 cursor-pointer ${
                                            selectedSupply === supply.id 
                                                ? 'border-green-400 bg-white/20' 
                                                : ''
                                        }`}
                                        onClick={() => setSelectedSupply(supply.id)}
                                    >
                                        <div className="flex items-center justify-between mb-2">
                                            <div>
                                                <h4 className="text-sm font-bold text-white">{supply.label}</h4>
                                                <p className="text-gray-300 text-xs">
                                                    {supply.currentAmount} / {supply.maxCapacity} {t('units')}
                                                </p>
                                            </div>
                                            <div className="text-right">
                                                <span className={`px-2 py-1 rounded text-xs font-bold ${
                                                    status === t('excellent') ? 'bg-green-600 text-white' :
                                                    status === t('good') ? 'bg-white text-black' :
                                                    status === t('low') ? 'bg-white text-black' :
                                                    'bg-red-600 text-white'
                                                }`}>
                                                    {status}
                                                </span>
                                            </div>
                                        </div>
                                        
                                        {/* Progress Bar */}
                                        <div className="w-full bg-black/50 rounded-full h-2 mb-1">
                                            <div
                                                className={`h-2 rounded-full transition-all duration-300 ${
                                                    percentage >= 80 ? 'bg-green-600' :
                                                    percentage >= 50 ? 'bg-white' :
                                                    percentage >= 20 ? 'bg-white' :
                                                    'bg-red-600'
                                                }`}
                                                style={{ width: `${percentage}%` }}
                                            />
                                        </div>
                                        
                                        <div className="text-xs text-gray-300">
                                            {percentage.toFixed(1)}% {t('capacity')}
                                        </div>
                                    </div>
                                )
                            })}
                        </div>

                        {/* Add Supplies Panel */}
                        <div className="space-y-3">
                            <h3 className="text-sm font-bold text-white">{t('add_supplies')}</h3>
                            
                            {selectedSupply ? (
                                (() => {
                                    const supply = machineData.supplies.find(s => s.id === selectedSupply)
                                    if (!supply) return null
                                    
                                    const playerAmount = machineData.playerInventory.find(i => i.name === supply.item)?.amount || 0
                                    const canAdd = Math.min(
                                        addAmount,
                                        playerAmount,
                                        supply.maxCapacity - supply.currentAmount
                                    )
                                    
                                    return (
                                        <div className="bg-white/10 border border-white/20 rounded-lg p-4">
                                            <div className="text-center mb-4">
                                                <div className="w-12 h-12 bg-white rounded-lg flex items-center justify-center mx-auto mb-2">
                                                    <svg className="w-6 h-6 text-black" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
                                                    </svg>
                                                </div>
                                                <h4 className="text-sm font-bold text-white">{supply.label}</h4>
                                                <p className="text-gray-300 text-xs">{t('add_supplies_to_machine')}</p>
                                            </div>

                                            {/* Current Status */}
                                            <div className="bg-black/50 rounded-lg p-3 mb-3">
                                                <div className="grid grid-cols-2 gap-2 text-xs">
                                                    <div>
                                                        <span className="text-gray-300">{t('current')}:</span>
                                                        <span className="text-white ml-1">{supply.currentAmount}</span>
                                                    </div>
                                                    <div>
                                                        <span className="text-gray-300">{t('max')}:</span>
                                                        <span className="text-white ml-1">{supply.maxCapacity}</span>
                                                    </div>
                                                    <div>
                                                        <span className="text-gray-300">{t('space')}:</span>
                                                        <span className="text-white ml-1">{supply.maxCapacity - supply.currentAmount}</span>
                                                    </div>
                                                    <div>
                                                        <span className="text-gray-300">{t('inventory')}:</span>
                                                        <span className="text-white ml-1">{playerAmount}</span>
                                                    </div>
                                                </div>
                                            </div>

                                            {/* Amount Input */}
                                            <div className="mb-3">
                                                <label className="block text-xs font-bold text-white mb-1">
                                                    {t('amount_to_add')}
                                                </label>
                                                <div className="flex items-center space-x-2">
                                                    <button
                                                        onClick={() => setAddAmount(Math.max(1, addAmount - 1))}
                                                        className="bg-white text-black px-2 py-1 rounded text-xs font-bold hover:bg-gray-100 transition-colors"
                                                    >
                                                        -
                                                    </button>
                                                    <input
                                                        type="number"
                                                        value={addAmount}
                                                        onChange={(e) => setAddAmount(Math.max(1, parseInt(e.target.value) || 1))}
                                                        className="flex-1 bg-white text-black px-2 py-1 rounded text-xs border border-gray-300 focus:outline-none"
                                                        min="1"
                                                        max={Math.min(playerAmount, supply.maxCapacity - supply.currentAmount)}
                                                    />
                                                    <button
                                                        onClick={() => setAddAmount(Math.min(
                                                            playerAmount,
                                                            supply.maxCapacity - supply.currentAmount,
                                                            addAmount + 1
                                                        ))}
                                                        className="bg-white text-black px-2 py-1 rounded text-xs font-bold hover:bg-gray-100 transition-colors"
                                                    >
                                                        +
                                                    </button>
                                                </div>
                                            </div>

                                            {/* Add Button */}
                                            <button
                                                onClick={() => handleAddSupply(selectedSupply)}
                                                disabled={canAdd <= 0}
                                                className={`w-full py-2 px-3 rounded text-xs font-bold transition-all duration-200 ${
                                                    canAdd > 0
                                                        ? 'bg-[#280707] hover:bg-[#400c0c] text-white'
                                                        : 'bg-white text-black cursor-not-allowed'
                                                }`}
                                            >
                                                {canAdd > 0 ? `${t('add')} ${canAdd} ${supply.label}` : t('cannot_add')}
                                            </button>

                                            {/* Info Messages */}
                                            {playerAmount === 0 && (
                                                <div className="mt-2 p-2 bg-red-600 border border-red-500 rounded text-xs">
                                                    <p className="text-white">
                                                        {t('no')} {supply.label} {t('in_inventory')}
                                                    </p>
                                                </div>
                                            )}
                                            
                                            {supply.currentAmount >= supply.maxCapacity && (
                                                <div className="mt-2 p-2 bg-white border border-gray-300 rounded text-xs">
                                                    <p className="text-black">
                                                        {t('at_maximum_capacity')}
                                                    </p>
                                                </div>
                                            )}
                                        </div>
                                    )
                                })()
                            ) : (
                                <div className="bg-white/10 border border-white/20 rounded-lg p-6 text-center">
                                    <div className="w-12 h-12 bg-white rounded-lg flex items-center justify-center mx-auto mb-3">
                                        <svg className="w-6 h-6 text-black" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 15l-2 5L9 9l11 4-5 2zm0 0l5 5M7.188 2.239l.777 2.897M5.136 7.965l-2.898-.777M13.95 4.05l-2.122 2.122m-5.657 5.656l-2.12 2.122" />
                                        </svg>
                                    </div>
                                    <h4 className="text-sm font-bold text-white mb-1">{t('select_a_supply')}</h4>
                                    <p className="text-gray-300 text-xs">{t('choose_supply_from_list')}</p>
                                </div>
                            )}
                        </div>
                    </div>
                </div>
            </div>
        </div>
    )
}

export default SupplyManagement
