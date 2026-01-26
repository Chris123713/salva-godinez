import React, { useState, useEffect, useRef } from 'react'
import { useVisibility } from '../providers/VisibilityProvider'
import { useNuiEvent } from '../hooks/useNuiEvent'
import { fetchNui } from '../utils/fetchNui'
import { t } from '../utils/translations'
import { X, Coffee, Droplets } from 'lucide-react'

interface CoffeeStep {
    name: string
    label: string
    color: { r: number; g: number; b: number; a: number }
    ratio: number
    pourSpeed: number
}

interface Drink {
    id: string
    label: string
    color: { r: number; g: number; b: number; a: number }
    pourTime: number
    minigame: {
        type: 'pouring' | 'coffee_multi_step'
        difficulty: 'easy' | 'medium' | 'hard'
        perfectZone?: { min: number; max: number }
        pourSpeed?: number
        steps?: CoffeeStep[]
    }
}

interface DrinksMachineData {
    machineType: 'soda_juice' | 'coffee'
    drinks: Drink[]
    machineLabel: string
    machineCoords?: { x: number; y: number; z: number }
}
const DrinksMachine = () => {
    const { visibility } = useVisibility()
    const [machineData, setMachineData] = useState<DrinksMachineData | null>(null)
    const [selectedDrink, setSelectedDrink] = useState<Drink | null>(null)
    const [isPlayingMinigame, setIsPlayingMinigame] = useState(false)
    const [minigameScore, setMinigameScore] = useState(0)
    const [currentStep, setCurrentStep] = useState<'select' | 'pouring' | 'complete'>('select')
    const [isPouring, setIsPouring] = useState(false)
    const [cupFill, setCupFill] = useState(0)
    const [currentCoffeeStep, setCurrentCoffeeStep] = useState(0)
    const [coffeeStepFills, setCoffeeStepFills] = useState<{[key: string]: number}>({})
    const [supplyStatus, setSupplyStatus] = useState<{[key: string]: boolean}>({})
    
    const animationRef = useRef<number>()
    const isPouringRef = useRef(false)
    const selectedDrinkRef = useRef<Drink | null>(null)
    const isCompletedRef = useRef(false)
    const currentCoffeeStepRef = useRef(0)
    const coffeeAnimationRef = useRef<number>()
    const coffeeCompletedRef = useRef(false)

    useNuiEvent<DrinksMachineData>('setDrinksMachineData', async (data) => {
        setMachineData(data)
        
        // Check supply status for all drinks
        const statusMap: {[key: string]: boolean} = {}
        for (const drink of data.drinks) {
            try {
                const response = await fetchNui('checkDrinkSupplies', { drinkId: drink.id })
                statusMap[drink.id] = response.success
            } catch (error) {
                statusMap[drink.id] = false
            }
        }
        setSupplyStatus(statusMap)
    })

    // Sound effect functions
    const playSound = (soundName: string) => {
        fetchNui('playDrinksSound', { 
            sound: soundName,
            machineCoords: machineData?.machineCoords
        })
    }

    useEffect(() => {
        const handleKeyDown = (event: KeyboardEvent) => {
            if (!visibility.visible || visibility.page !== 'drinks_machine') return

            if (event.key === 'Escape') {
                closeDrinksMachine()
            }

            if (isPlayingMinigame) {
                handleMinigameInput(event, 'keydown')
            }
        }

        const handleKeyUp = (event: KeyboardEvent) => {
            if (!visibility.visible || visibility.page !== 'drinks_machine') return

            if (isPlayingMinigame) {
                handleMinigameInput(event, 'keyup')
            }
        }

        window.addEventListener('keydown', handleKeyDown)
        window.addEventListener('keyup', handleKeyUp)
        return () => {
            window.removeEventListener('keydown', handleKeyDown)
            window.removeEventListener('keyup', handleKeyUp)
        }
    }, [visibility, isPlayingMinigame, currentStep])

    const handleMinigameInput = (event: KeyboardEvent, eventType: 'keydown' | 'keyup') => {
        if (event.code === 'Space') {
            if (eventType === 'keydown') {
                setIsPouring(true)
                isPouringRef.current = true
            } else if (eventType === 'keyup') {
                setIsPouring(false)
                isPouringRef.current = false
            }
        }
    }

    const checkSupplies = async (drink: Drink): Promise<boolean> => {
        try {
            const response = await fetchNui('checkDrinkSupplies', { drinkId: drink.id })
            return response.success
        } catch (error) {
            return false
        }
    }

    const startMinigame = async (drink: Drink) => {
        // Check supplies before starting minigame
        const hasSupplies = await checkSupplies(drink)
        if (!hasSupplies) {
            // Show error message - supplies will be handled by the server callback
            return
        }

        setSelectedDrink(drink)
        selectedDrinkRef.current = drink
        setIsPlayingMinigame(true)
        setCurrentStep('pouring')
        setMinigameScore(0)
        setCupFill(0)
        setIsPouring(false)
        isPouringRef.current = false
        isCompletedRef.current = false
        coffeeCompletedRef.current = false
        setCurrentCoffeeStep(0)
        currentCoffeeStepRef.current = 0
        setCoffeeStepFills({})
        
        // Cancel any existing animations
        if (animationRef.current) {
            cancelAnimationFrame(animationRef.current)
        }
        if (coffeeAnimationRef.current) {
            cancelAnimationFrame(coffeeAnimationRef.current)
        }

        // Start the appropriate minigame
        if (drink.minigame.type === 'coffee_multi_step') {
            startCoffeeMultiStepMinigame(drink)
        } else {
            startPouringMinigame(drink)
        }
    }

    const startPouringMinigame = (drink: Drink) => {
        let hasStartedPouring = false
        
        const animate = () => {
            // Stop animation if already completed
            if (isCompletedRef.current) {
                return
            }
            
            if (isPouringRef.current && cupFill < 1) {
                // Play sound only on first space press
                if (!hasStartedPouring) {
                    playSound('pouring_soda_start')
                    hasStartedPouring = true
                }
                
                const frames = drink.pourTime / (1000 / 60)
                const fillRate = 1 / frames
                
                // Initialize frame count if not exists
                if (!animate.frameCount) animate.frameCount = 0
                
                // Only update cup fill every 15 frames to slow down updates
                animate.frameCount++;
                if (animate.frameCount % 15 === 0) {
                    setCupFill(prev => {
                        const newFill = Math.min(1, prev + fillRate * 15);
                        
                        if (newFill >= 1 && !isCompletedRef.current) {
                            isCompletedRef.current = true
                            completeMinigame()
                            return 1
                        }
                        
                        return newFill
                    })
                }
            }
            
            // Continue animation if cup is not full and not completed
            if (cupFill < 1 && !isCompletedRef.current) {
                animationRef.current = requestAnimationFrame(animate)
            }
        }
        
        animate()
    }

    const startCoffeeMultiStepMinigame = (drink: Drink) => {
        if (!drink.minigame.steps || drink.minigame.steps.length === 0) {
            return
        }

        let hasStartedPouring = false
        
        const animate = () => {
            // Stop animation if already completed
            if (coffeeCompletedRef.current) {
                return
            }
            
            const currentStepData = drink.minigame.steps![currentCoffeeStepRef.current]
            const stepKey = currentStepData.name
            
            // Only fill current step when space is held down
            if (isPouringRef.current) {
                // Play sound only on first space press
                if (!hasStartedPouring) {
                    playSound('pouring_coffee_start')
                    hasStartedPouring = true
                }
                
                // Fill at rate based on pourSpeed (10% per second)
                // Use same system as soda/juice: fill based on pourTime and 60fps
                const frames = drink.pourTime / (1000 / 60)
                const fillRate = currentStepData.ratio / frames
                
                // Only update coffee step fill every 10-20 frames to slow down updates
                if (!animate.frameCount) animate.frameCount = 0;
                animate.frameCount++;
                if (animate.frameCount % 15 === 0) { // update every 15 frames
                    setCoffeeStepFills(prev => {
                        const currentFill = prev[stepKey] || 0
                        const newFill = Math.min(currentStepData.ratio, currentFill + fillRate * 15)
                        const newFills = { ...prev, [stepKey]: newFill }
                        
                        // If current step is complete, move to next step
                        if (newFill >= currentStepData.ratio && currentCoffeeStepRef.current < drink.minigame.steps!.length - 1) {
                            currentCoffeeStepRef.current += 1
                            setCurrentCoffeeStep(currentCoffeeStepRef.current)
                        } else if (newFill >= currentStepData.ratio && currentCoffeeStepRef.current === drink.minigame.steps!.length - 1) {
                            // All steps complete
                            coffeeCompletedRef.current = true
                            completeMinigame()
                        }
                        
                        return newFills
                    })
                }
            }
            
            // Continue animation if not completed
            if (!coffeeCompletedRef.current) {
                coffeeAnimationRef.current = requestAnimationFrame(animate)
            }
        }
        
        animate()
    }

    const completeMinigame = async () => {
        setIsPlayingMinigame(false)
        setCurrentStep('complete')
        
        // Calculate final score based on minigame type
        let finalScore = 0
        if (selectedDrink?.minigame.type === 'coffee_multi_step') {
            // For multi-step coffee: calculate based on how well each step was completed
            const totalRatio = selectedDrink.minigame.steps?.reduce((sum, step) => sum + step.ratio, 0) || 1
            const totalFilled = Object.values(coffeeStepFills).reduce((sum, fill) => sum + fill, 0)
            finalScore = Math.round((totalFilled / totalRatio) * 100)
        } else {
            finalScore = Math.round(cupFill * 100)
        }
        
        try {
            await fetchNui('completeDrinksMinigame', {
                drinkId: selectedDrinkRef.current?.id,
                score: finalScore,
                machineType: machineData?.machineType
            })
        } catch (error) {
            console.error('Failed to complete minigame:', error)
        }
        
        setMinigameScore(finalScore)
        
        setTimeout(() => {
            setSelectedDrink(null)
            selectedDrinkRef.current = null
            setCurrentStep('select')
            setMinigameScore(0)
            setCupFill(0)
            setIsPouring(false)
            isPouringRef.current = false
            isCompletedRef.current = false
            coffeeCompletedRef.current = false
            setCurrentCoffeeStep(0)
            currentCoffeeStepRef.current = 0
            setCoffeeStepFills({})
        }, 500)
    }

    const closeDrinksMachine = async () => {
        playSound('machine_close')
        
        try {
            await fetchNui('closeDrinksMachine', {})
        } catch (error) {
            console.error('Failed to close drinks machine:', error)
        }
    }

    const getScoreMessage = (score: number) => {
        if (score >= 80) return t('perfect_pour')
        if (score >= 60) return t('good_pour')
        return t('poor_pour')
    }

    const getScoreColor = (score: number) => {
        if (score >= 80) return '#10B981'
        if (score >= 60) return '#F59E0B'
        return '#EF4444'
    }

    if (!visibility.visible || visibility.page !== 'drinks_machine' || !machineData) {
        return null
    }

    return (
        <div className="fixed inset-0 bg-black/60 flex items-center justify-center z-50">
            <div className="bg-black/50 rounded-2xl shadow-lg max-w-5xl h-full max-h-[64vh] w-[28vw] overflow-hidden border border-white/20">
                {/* Machine Header */}
                <div className="bg-[#280707] p-4 border-b border-white/20">
                    <div className="flex items-center justify-between">
                        <div className="flex items-center gap-4">
                            <div className="bg-white rounded-lg p-3">
                                {machineData.machineType === 'coffee' ? (
                                    <Coffee className="w-6 h-6 text-black" />
                                ) : (
                                    <Droplets className="w-6 h-6 text-black" />
                                )}
                            </div>
                            <div>
                                <h2 className="text-2xl font-bold text-white">
                                    {machineData.machineLabel}
                                </h2>
                                <p className="text-green-100 text-sm">{t('choose_your_drink')}</p>
                            </div>
                        </div>
                        <div className="flex items-center gap-3">
                            <button
                                onClick={() => fetchNui('openSupplyManagement')}
                                className="bg-white text-black px-4 py-2 rounded-lg transition-all duration-200 flex items-center gap-2 text-sm font-medium hover:bg-gray-100"
                            >
                                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
                                </svg>
                                {t('supplies')}
                            </button>
                            <button
                                onClick={closeDrinksMachine}
                                className="bg-white text-black p-2 rounded-lg transition-all duration-200 hover:bg-gray-100"
                            >
                                <X className="w-5 h-5" />
                            </button>
                        </div>
                    </div>
                </div>

                <div className="p-6 h-[88%] overflow-y-auto bg-black/50">
                    {!isPlayingMinigame ? (
                        <div className="grid grid-cols-2 md:grid-cols-2 lg:grid-cols-2 gap-4">
                            {machineData.drinks.map((drink) => (
                                <button
                                    key={drink.id}
                                    onClick={() => startMinigame(drink)}
                                    className="bg-white/10 hover:bg-white/20 border border-white/20 hover:border-gray-400 rounded-lg p-4 transition-all duration-200 group"
                                >
                                    <div className="flex flex-col items-center gap-3">
                                        {/* Drink Display */}
                                        <div className="relative">
                                            <div
                                                className="w-16 h-16 rounded-lg border border-white/30 group-hover:border-gray-400 transition-all duration-200"
                                                style={{
                                                    backgroundColor: `rgba(${drink.color.r * 255}, ${drink.color.g * 255}, ${drink.color.b * 255}, ${drink.color.a})`
                                                }}
                                            />
                                            <div className="absolute -top-2 -right-2 bg-[#680a0a] text-white text-xs font-bold px-2 py-1 rounded-full">
                                                {drink.minigame.difficulty.toUpperCase()}
                                            </div>
                                        </div>
                                        
                                        {/* Button Label */}
                                        <div className="text-center">
                                            <h3 className="font-bold text-white text-sm transition-colors mb-1">
                                                {drink.label}
                                            </h3>
                                            <p className="text-xs text-gray-300 capitalize mb-2">
                                                {drink.minigame.type.replace('_', ' ')}
                                            </p>
                                            {/* Supply Status Indicator */}
                                            {supplyStatus[drink.id] === false && (
                                                <div className="mt-1 bg-red-600 text-white text-xs font-bold px-2 py-1 rounded-full">
                                                    {t('no_supplies')}
                                                </div>
                                            )}
                                        </div>
                                        
                                        {/* Press Indicator */}
                                        <div className="bg-[#680a0a] hover:bg-[#420606] text-white text-xs font-bold px-3 py-1 rounded transition-all duration-200">
                                            {t('select')}
                                        </div>
                                    </div>
                                </button>
                            ))}
                        </div>
                    ) : (
                        <div className="flex flex-col items-center gap-12">
                            {selectedDrink && (
                                <>
                                    {/* Machine Display Header */}
                                    <div className="bg-[#1e1e1e80] border border-white/20 text-white p-4 rounded-lg w-full max-w-2xl">
                                        <div className="text-center">
                                            <h3 className="text-xl font-bold mb-2">{selectedDrink.label}</h3>
                                            <p className="text-green-100 text-sm">
                                                {currentStep === 'pouring' && t('hold_space_to_pour')}
                                                {currentStep === 'complete' && t('drink_ready')}
                                            </p>
                                        </div>
                                    </div>

                                    <div className="w-full max-w-2xl">
                                        {selectedDrink.minigame.type === 'coffee_multi_step' ? (
                                            <div className="bg-black/50 border border-white/20 rounded-lg p-6">
                                                {/* Multi-Step Coffee Cup Display */}
                                                <div className="flex justify-center mb-6">
                                                    <div className="relative">
                                                        {/* Simple Cup Container */}
                                                        <div className="relative">
                                                            {/* Cup Body */}
                                                            <div className="relative w-32 h-40 bg-white rounded-b-lg border-2 border-gray-300 overflow-hidden">
                                                                {/* Liquid Layers */}
                                                                {selectedDrink.minigame.steps?.map((step, index) => {
                                                                    const stepFill = coffeeStepFills[step.name] || 0
                                                                    const stepProgress = stepFill / step.ratio // 0 to 1
                                                                    
                                                                    // Calculate the position and height for this step's section
                                                                    const stepStartPercent = selectedDrink.minigame.steps?.slice(0, index).reduce((sum, prevStep) => {
                                                                        return sum + prevStep.ratio
                                                                    }, 0) || 0
                                                                    
                                                                    const stepHeightPercent = step.ratio * 100
                                                                    const filledHeightPercent = stepHeightPercent * stepProgress
                                                                    
        return (
                                                                        <div
                                                                            key={step.name}
                                                                            className="absolute left-0 right-0 transition-all duration-500 ease-out"
                                                                            style={{
                                                                                height: `${filledHeightPercent}%`,
                                                                                bottom: `${stepStartPercent * 100}%`,
                                                                                backgroundColor: `rgba(${step.color.r * 255}, ${step.color.g * 255}, ${step.color.b * 255}, ${step.color.a})`,
                                                                                borderRadius: '0 0 0.5rem 0.5rem'
                                                                            }}
                                                                        />
                                                                    )
                                                                })}
                                                                
                                                                {/* Progress Percentage */}
                                                                <div className="absolute inset-0 flex items-center justify-center">
                                                                    <span className="text-lg font-bold text-black bg-white px-2 py-1 rounded border border-gray-300">
                                                                        {Math.round(Object.values(coffeeStepFills).reduce((sum, fill) => sum + fill, 0) * 100)}%
                                                                    </span>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>

                                                {/* Current Step Info */}
                                                {selectedDrink.minigame.steps && (
                                                    <div className="text-center">
                                                        <div className="bg-[#46464680] border border-white/20 text-white p-3 rounded-lg">
                                                            <h4 className="text-sm font-bold mb-1">
                                                                Step {currentCoffeeStep + 1}: {selectedDrink.minigame.steps[currentCoffeeStep]?.label}
                                                            </h4>
                                                            <p className="text-green-100 text-xs">
                                                                {isPouring ? t('pouring') : t('hold_space_to_pour')}
                                                            </p>
                                                        </div>
                                                    </div>
                                                )}

                                            </div>
                                        ) : (
                                            <div className="bg-black/50 border border-white/20 rounded-lg p-6">
                                                {/* Simple Cup Display */}
                                                <div className="flex justify-center mb-6">
                                                    <div className="relative">
                                                        {/* Simple Cup Container */}
                                                        <div className="relative">
                                                            {/* Cup Body */}
                                                            <div className="relative w-32 h-40 bg-white rounded-b-lg border-2 border-gray-300 overflow-hidden">
                                                                {/* Liquid Fill */}
                                                                <div
                                                                    className="absolute bottom-0 left-0 right-0 transition-all duration-500 ease-out"
                                                                    style={{
                                                                        height: `${cupFill * 100}%`,
                                                                        backgroundColor: `rgba(${selectedDrink.color.r * 255}, ${selectedDrink.color.g * 255}, ${selectedDrink.color.b * 255}, ${selectedDrink.color.a})`,
                                                                        borderRadius: '0 0 0.5rem 0.5rem'
                                                                    }}
                                                                />
                                                                
                                                                {/* Progress Percentage */}
                                                                <div className="absolute inset-0 flex items-center justify-center">
                                                                    <span className="text-lg font-bold text-black bg-white px-2 py-1 rounded border border-gray-300">
                                                                        {Math.round(cupFill * 100)}%
                                                                    </span>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>

                                                {/* Instructions */}
                                                <div className="text-center">
                                                    <div className="bg-[#46464680] border border-white/20 text-white p-3 rounded-lg">
                                                        <h4 className="text-sm font-bold mb-1">
                                                            {isPouring ? t('pouring') : t('hold_space_to_pour')}
                                                        </h4>
                                                        <p className="text-green-100 text-xs">
                                                            {t('fill_cup_to_complete')}
                                                        </p>
                                                    </div>
                                                </div>
                                            </div>
                                        )}

                                        {currentStep === 'complete' && (
                                            <div className="bg-black/50 border border-white/20 rounded-lg p-6 text-center">
                                                <div className="space-y-4">
                                                    <div className="text-4xl">🎉</div>
                                                    <div
                                                        className="text-xl font-bold mb-3"
                                                        style={{ color: getScoreColor(minigameScore) }}
                                                    >
                                                        {getScoreMessage(minigameScore)}
                                                    </div>
                                                    <div className="bg-green-600 border border-white/20 rounded-lg p-3">
                                                        <p className="text-sm font-bold text-white mb-1">
                                                            Score: {minigameScore}%
                                                        </p>
                                                        <p className="text-green-100 text-xs">
                                                            {selectedDrink.label} {t('is_ready')}
                                                        </p>
                                                    </div>
                                                    <div className="bg-white text-black p-3 rounded-lg border border-gray-300">
                                                        <p className="text-sm font-bold">✅ {t('drink_dispensed_successfully')}</p>
                                                    </div>
                                                </div>
                                            </div>
                                        )}
                                    </div>
                                </>
                            )}
                        </div>
                    )}
                </div>
            </div>
        </div>
    )
}

export default DrinksMachine
