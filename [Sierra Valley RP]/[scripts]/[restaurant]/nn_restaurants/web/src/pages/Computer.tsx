import React, { useState, useEffect } from 'react'
import { useVisibility } from '../providers/VisibilityProvider'
import { fetchNui } from '../utils/fetchNui'
import { useNuiEvent } from '../hooks/useNuiEvent'
import { t, onTranslationsReceived } from '../utils/translations'
import { 
    ShoppingCart, 
    Package, 
    DollarSign, 
    X, 
    Plus, 
    Minus,
    Calculator,
    Mail,
    Calendar,
    Settings,
    FileText,
    Image,
    Music,
    Gamepad2,
    Wifi,
    Battery,
    Volume2,
    Search,
    Filter,
    Star,
    Divide,
    X as Multiply,
    Minus as Subtract,
    Plus as Add,
    Equal
} from 'lucide-react'
import '../shop.css'

interface App {
    id: string;
    name: string;
    icon: React.ReactNode;
    color: string;
    isOpen: boolean;
    isMinimized: boolean;
    isDisabled?: boolean;
}

interface ShopItem {
    id: string;
    name: string;
    description: string;
    price: number;
    category: string;
    image: string;
    stock?: number;
    rating?: number;
}

interface ShopCategory {
    name: string;
    icon: string;
}

interface CartItem {
    item: ShopItem;
    quantity: number;
}

interface MusicTrack {
    name: string;
    link: string;
}

const Computer = () => {
    const { visibility } = useVisibility()
    const [shopItems, setShopItems] = useState<ShopItem[]>([])
    const [categories, setCategories] = useState<ShopCategory[]>([])
    const [selectedCategory, setSelectedCategory] = useState<string>('all')
    const [cart, setCart] = useState<CartItem[]>([])
    const [searchTerm, setSearchTerm] = useState('')
    
    // Calculator state
    const [calculatorDisplay, setCalculatorDisplay] = useState('0')
    const [calculatorMemory, setCalculatorMemory] = useState(0)
    const [calculatorOperation, setCalculatorOperation] = useState('')
    const [calculatorWaitingForOperand, setCalculatorWaitingForOperand] = useState(false)
    
    // Game state
    const [gameNumber, setGameNumber] = useState(0)
    const [gameGuess, setGameGuess] = useState('')
    const [gameMessage, setGameMessage] = useState('')
    const [gameAttempts, setGameAttempts] = useState(0)
    const [gameWon, setGameWon] = useState(false)
    
    // Music state
    const [musicTracks, setMusicTracks] = useState<MusicTrack[]>([])
    const [currentTrack, setCurrentTrack] = useState(0)
    const [isPlaying, setIsPlaying] = useState(false)
    const [volume, setVolume] = useState(30)
    const [musicCurrentTime, setMusicCurrentTime] = useState(0)
    const [musicDuration, setMusicDuration] = useState(0)
    const [currentMusicName, setCurrentMusicName] = useState('')
    

    
    const [apps, setApps] = useState<App[]>([])

    // Function to create apps with current translations
    const createApps = () => [
        {
            id: 'shop',
            name: t('supply_shop'),
            icon: <ShoppingCart className="w-8 h-8" />,
            color: 'bg-blue-600',
            isOpen: false,
            isMinimized: false
        },
        {
            id: 'calculator',
            name: t('calculator'),
            icon: <Calculator className="w-8 h-8" />,
            color: 'bg-gray-600',
            isOpen: false,
            isMinimized: false
        },
        {
            id: 'games',
            name: t('games'),
            icon: <Gamepad2 className="w-8 h-8" />,
            color: 'bg-purple-600',
            isOpen: false,
            isMinimized: false
        },
        {
            id: 'music',
            name: t('music'),
            icon: <Music className="w-8 h-8" />,
            color: 'bg-pink-600',
            isOpen: false,
            isMinimized: false
        },
        {
            id: 'email',
            name: t('email'),
            icon: <Mail className="w-8 h-8" />,
            color: 'bg-gray-600',
            isOpen: false,
            isMinimized: false,
            isDisabled: true
        },
        {
            id: 'calendar',
            name: t('calendar'),
            icon: <Calendar className="w-8 h-8" />,
            color: 'bg-gray-600',
            isOpen: false,
            isMinimized: false,
            isDisabled: true
        },
        {
            id: 'settings',
            name: t('settings'),
            icon: <Settings className="w-8 h-8" />,
            color: 'bg-gray-600',
            isOpen: false,
            isMinimized: false,
            isDisabled: true
        },
        {
            id: 'documents',
            name: t('documents'),
            icon: <FileText className="w-8 h-8" />,
            color: 'bg-gray-600',
            isOpen: false,
            isMinimized: false,
            isDisabled: true
        },
        {
            id: 'photos',
            name: t('photos'),
            icon: <Image className="w-8 h-8" />,
            color: 'bg-gray-600',
            isOpen: false,
            isMinimized: false,
            isDisabled: true
        }
    ]

    // Initialize apps and listen for translation updates
    useEffect(() => {
        // Set initial apps
        setApps(createApps())
        
        // Listen for translation updates - only set once when first received
        let translationsSet = false
        const handleTranslationsReceived = () => {
            if (!translationsSet) {
                setApps(createApps())
                translationsSet = true
            }
        }
        
        onTranslationsReceived(handleTranslationsReceived)
        
        // Cleanup function
        return () => {
            // Note: The translation system doesn't have a remove callback method,
            // but this is fine since the component will unmount anyway
        }
    }, [])
    const [currentTime, setCurrentTime] = useState(new Date())

    // Listen for server responses using useNuiEvent
    useNuiEvent('receiveShopItems', (data: any) => {
        if (Array.isArray(data)) {
            setShopItems(data)
        } else {
            setShopItems([])
        }
    })

    useNuiEvent('receiveShopCategories', (data: any) => {
        if (Array.isArray(data)) {
            setCategories(data)
        } else {
            setCategories([])
        }
    })

    // Music events
    useNuiEvent('receiveMusicData', (data: any) => {
        if (Array.isArray(data)) {
            setMusicTracks(data)
        } else {
            setMusicTracks([])
        }
    })

    useNuiEvent('musicStarted', (data: any) => {
        setIsPlaying(true)
        setCurrentMusicName(data.musicName)
        setCurrentTrack(data.musicIndex - 1)
    })

    useNuiEvent('musicStopped', () => {
        setIsPlaying(false)
        setCurrentMusicName('')
    })

    const openApp = (appId: string) => {
        if (appId === 'games') {
            // Initialize game when opening
            setGameNumber(Math.floor(Math.random() * 100) + 1)
            setGameGuess('')
            setGameMessage('')
            setGameAttempts(0)
            setGameWon(false)
        }
        
        setApps(apps.map(app => 
            app.id === appId 
                ? { ...app, isOpen: true, isMinimized: false }
                : app
        ))
    }

    const closeApp = (appId: string) => {
        setApps(apps.map(app => 
            app.id === appId 
                ? { ...app, isOpen: false, isMinimized: false }
                : app
        ))
    }

    const minimizeApp = (appId: string) => {
        setApps(apps.map(app => 
            app.id === appId 
                ? { ...app, isMinimized: true }
                : app
        ))
    }

    // Calculator functions
    const calculatorInputDigit = (digit: string) => {
        if (calculatorWaitingForOperand) {
            setCalculatorDisplay(digit)
            setCalculatorWaitingForOperand(false)
        } else {
            setCalculatorDisplay(calculatorDisplay === '0' ? digit : calculatorDisplay + digit)
        }
    }

    const calculatorInputDecimal = () => {
        if (calculatorWaitingForOperand) {
            setCalculatorDisplay('0.')
            setCalculatorWaitingForOperand(false)
        } else if (calculatorDisplay.indexOf('.') === -1) {
            setCalculatorDisplay(calculatorDisplay + '.')
        }
    }

    const calculatorClear = () => {
        setCalculatorDisplay('0')
        setCalculatorMemory(0)
        setCalculatorOperation('')
        setCalculatorWaitingForOperand(false)
    }

    const calculatorPerformOperation = (nextOperation: string) => {
        const inputValue = parseFloat(calculatorDisplay)

        if (calculatorMemory === 0) {
            setCalculatorMemory(inputValue)
        } else {
            const currentValue = calculatorMemory || 0
            const newValue = calculatorOperation === '+' ? currentValue + inputValue :
                           calculatorOperation === '-' ? currentValue - inputValue :
                           calculatorOperation === '×' ? currentValue * inputValue :
                           calculatorOperation === '÷' ? currentValue / inputValue : inputValue

            setCalculatorMemory(newValue)
            setCalculatorDisplay(String(newValue))
        }

        setCalculatorWaitingForOperand(true)
        setCalculatorOperation(nextOperation)
    }

    // Game functions
    const handleGameGuess = () => {
        const guess = parseInt(gameGuess)
        if (isNaN(guess) || guess < 1 || guess > 100) {
            setGameMessage(t('please_enter_valid_number'))
            return
        }

        const newAttempts = gameAttempts + 1
        setGameAttempts(newAttempts)

        if (guess === gameNumber) {
            setGameMessage(t('congratulations_found_number', { '%s': newAttempts }))
            setGameWon(true)
        } else if (guess < gameNumber) {
            setGameMessage(t('too_low_try_higher'))
        } else {
            setGameMessage(t('too_high_try_lower'))
        }
        setGameGuess('')
    }

    const resetGame = () => {
        setGameNumber(Math.floor(Math.random() * 100) + 1)
        setGameGuess('')
        setGameMessage('')
        setGameAttempts(0)
        setGameWon(false)
    }

    // Music control functions
    const togglePlay = async () => {
        if (musicTracks.length === 0) return
        
        if (isPlaying) {
            await fetchNui('stopMusic', {})
            setIsPlaying(false)
        } else {
            // Convert 0-based JS index to 1-based Lua index
            await fetchNui('playMusic', { musicIndex: currentTrack + 1 })
            setIsPlaying(true)
        }
    }

    const nextTrack = async () => {
        if (musicTracks.length === 0) return
        
        const newTrack = (currentTrack + 1) % musicTracks.length
        setCurrentTrack(newTrack)
        
        if (isPlaying) {
            // Convert 0-based JS index to 1-based Lua index
            await fetchNui('playMusic', { musicIndex: newTrack + 1 })
        }
    }

    const prevTrack = async () => {
        if (musicTracks.length === 0) return
        
        const newTrack = (currentTrack - 1 + musicTracks.length) % musicTracks.length
        setCurrentTrack(newTrack)
        
        if (isPlaying) {
            // Convert 0-based JS index to 1-based Lua index
            await fetchNui('playMusic', { musicIndex: newTrack + 1 })
        }
    }

    const selectTrack = async (index: number) => {
        if (musicTracks.length === 0) return
        setCurrentTrack(index)
        if (isPlaying) {
            // Convert 0-based JS index to 1-based Lua index
            await fetchNui('playMusic', { musicIndex: index + 1 })
        }
    }

    const handleVolumeChange = async (newVolume: number) => {
        setVolume(newVolume)
        await fetchNui('setMusicVolume', { volume: newVolume / 100 })
    }

    const formatTime = (seconds: number) => {
        const mins = Math.floor(seconds / 60)
        const secs = seconds % 60
        return `${mins}:${secs.toString().padStart(2, '0')}`
    }

    const canAddToCart = (item: ShopItem): boolean => {
        // Check if item is out of stock
        if (item.stock === 0) {
            return false
        }
        
        // Check if item already exists in cart (can always increase quantity of existing items)
        const existingItem = cart.find(cartItem => cartItem.item.id === item.id)
        if (existingItem) {
            return true
        }
        
        // Check if cart has reached the limit of 10 unique items
        if (cart.length >= 10) {
            return false
        }
        
        return true
    }

    const addToCart = (item: ShopItem) => {
        // Safety check - should not happen if button is properly disabled
        if (!canAddToCart(item)) {
            return
        }
        
        const existingItem = cart.find(cartItem => cartItem.item.id === item.id)
        
        if (existingItem) {
            // If item already exists, just increase quantity
            setCart(cart.map(cartItem => 
                cartItem.item.id === item.id 
                    ? { ...cartItem, quantity: cartItem.quantity + 1 }
                    : cartItem
            ))
        } else {
            // Add new item to cart
            setCart([...cart, { item, quantity: 1 }])
        }
    }

    const removeFromCart = (itemId: string) => {
        if (cart.length > 0) {
            setCart(cart.filter(item => item.item.id !== itemId))
        }
    }

    const updateQuantity = (itemId: string, newQuantity: number) => {
        if (newQuantity <= 0) {
            removeFromCart(itemId)
        } else {
            setCart(cart.map(item => 
                item.item.id === itemId 
                    ? { ...item, quantity: newQuantity }
                    : item
            ))
        }
    }

    const getCartTotal = () => {
        return cart.reduce((total, item) => total + (item.item.price * item.quantity), 0)
    }

    const handlePurchase = async () => {
        if (cart.length === 0) return

        await fetchNui<any>('purchaseSupplies', {
            items: cart,
            total: getCartTotal()
        })
        setCart([])
        closeApp('shop')
    }

    const filteredItems = Array.isArray(shopItems) && shopItems.length > 0 ? shopItems.filter(item => {
        if (!item || typeof item !== 'object' || !item.name || !item.description) return false
        const matchesCategory = selectedCategory === 'all' || item.category === selectedCategory
        const matchesSearch = item.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                            item.description.toLowerCase().includes(searchTerm.toLowerCase())
        return matchesCategory && matchesSearch
    }) : []

    const openApps = apps.length > 0 ? apps.filter(app => app.isOpen && !app.isMinimized) : []
    const shopApp = apps.length > 0 ? apps.find(app => app.id === 'shop') : null
    
    if (!visibility.visible || visibility.page !== "computer") return null

    return (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
            {/* Windows Desktop */}
            <div className="windows-desktop w-[1400px] h-[900px] bg-gradient-to-br from-blue-900 via-blue-800 to-indigo-900 rounded-lg shadow-2xl overflow-hidden">
                {/* Taskbar */}
                <div className="windows-taskbar h-12 bg-gray-800 border-b border-gray-700 flex items-center justify-between px-4">
                    <div className="flex items-center space-x-4">
                        <div className="text-white font-semibold">{t('restaurant_manager')}</div>
                        <div className="text-gray-300 text-sm">v2.0</div>
                    </div>
                    
                    <div className="flex items-center space-x-4">
                        <div className="flex items-center space-x-2 text-white text-sm">
                            <Wifi className="w-4 h-4" />
                            <Battery className="w-4 h-4" />
                            <Volume2 className="w-4 h-4" />
                        </div>
                        <div className="text-white text-sm">
                            {currentTime.toLocaleTimeString()}
                        </div>
                    </div>
                </div>

                {/* Desktop */}
                <div className="flex-1 p-6 relative h-[90%]">
                    {/* Desktop Apps Grid */}
                    <div className="grid grid-cols-4 gap-6">
                        {apps.map((app) => (
                            <div
                                key={app.id}
                                className={`${app.color} flex flex-col items-center justify-center rounded-lg p-4 cursor-pointer transition-all duration-200 hover:scale-105 ${
                                    app.isDisabled ? 'opacity-50 cursor-not-allowed' : 'hover:shadow-lg'
                                }`}
                                onClick={() => !app.isDisabled && openApp(app.id)}
                            >
                                <div className="text-white text-center flex flex-col items-center justify-center gap-2">
                                    {app.icon}
                                    <div className="font-semibold mt-2">{app.name}</div>
                                    {app.isDisabled && (
                                        <div className="text-xs opacity-80 mt-1">{t('not_available')}</div>
                                    )}
                                </div>
                            </div>
                        ))}
                    </div>

                    {/* Open Windows */}
                    {openApps.map((app) => (
                        <div
                            key={app.id}
                            className="absolute top-8 left-8 right-8 bottom-8 bg-white rounded-lg shadow-2xl flex flex-col"
                        >
                            {/* Window Title Bar */}
                            <div className="windows-titlebar bg-gray-700 text-white px-4 py-2 rounded-t-lg flex items-center justify-between">
                                <div className="flex items-center space-x-3">
                                    {app.icon}
                                    <span className="font-semibold">{app.name}</span>
                                </div>
                                <div className="flex items-center space-x-2">
                                    <button
                                        onClick={() => minimizeApp(app.id)}
                                        className="w-6 h-6 bg-gray-600 hover:bg-gray-500 rounded flex items-center justify-center"
                                    >
                                        <span className="text-xs">─</span>
                                    </button>
                                    <button
                                        onClick={() => closeApp(app.id)}
                                        className="w-6 h-6 bg-red-600 hover:bg-red-500 rounded flex items-center justify-center"
                                    >
                                        <X className="w-4 h-4" />
                                    </button>
                                </div>
                            </div>

                            {/* Window Content */}
                            <div className="flex-1 flex overflow-hidden">
                                {app.id === 'shop' && (
                                    <div className="flex w-full h-full">
                                        {/* Left Side - Store Content */}
                                        <div className="flex-1 flex flex-col p-6 overflow-hidden">
                                            {/* Store Header */}
                                            <div className="mb-6">
                                                <div className="flex items-center justify-between mb-4">
                                                    <div>
                                                                    <h1 className="text-2xl font-bold text-gray-800">{t('restaurant_supply_store')}</h1>
            <p className="text-gray-600">{t('quality_ingredients')}</p>
                                                    </div>
                                                    <div className="flex items-center space-x-2">
                                                        <div className="bg-green-100 text-green-800 px-3 py-1 rounded-full text-sm font-medium">
                                                            {t('open_247')}
                                                        </div>
                                                    </div>
                                                </div>

                                                {/* Search and Filter Bar */}
                                                <div className="flex items-center space-x-4 mb-6">
                                                    <div className="flex-1 relative">
                                                        <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
                                                        <input
                                                            type="text"
                                                            placeholder={t('search_supplies')}
                                                            value={searchTerm}
                                                            onChange={(e) => setSearchTerm(e.target.value)}
                                                            className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                                                        />
                                                    </div>
                                                    <button className="flex items-center space-x-2 px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50">
                                                        <Filter className="w-4 h-4" />
                                                        <span>{t('filter')}</span>
                                                    </button>
                                                </div>

                                                {/* Categories */}
                                                <div className="mb-6">
                                                    <div className="flex space-x-2 overflow-x-auto pb-2">
                                                        <button
                                                            onClick={() => setSelectedCategory('all')}
                                                            className={`px-4 py-2 rounded-lg font-medium whitespace-nowrap transition-colors ${
                                                                selectedCategory === 'all' 
                                                                    ? 'bg-blue-600 text-white' 
                                                                    : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                                                            }`}
                                                        >
                                                            {t('all_items')}
                                                        </button>
                                                        {categories.map((category) => (
                                                            <button
                                                                key={category.name}
                                                                onClick={() => setSelectedCategory(category.name.toLowerCase())}
                                                                className={`px-4 py-2 rounded-lg font-medium whitespace-nowrap transition-colors ${
                                                                    selectedCategory === category.name.toLowerCase() 
                                                                        ? 'bg-blue-600 text-white' 
                                                                        : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                                                                }`}
                                                            >
                                                                {category.icon} {category.name}
                                                            </button>
                                                        ))}
                                                    </div>
                                                </div>
                                            </div>

                                            {/* Items Grid */}
                                            <div className="flex-1 overflow-y-auto">
                                                <div className="grid grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
                                                    {filteredItems.map((item) => (
                                                        <div key={item.id} className="bg-white border border-gray-200 rounded-lg p-4 hover:shadow-md transition-shadow">
                                                            <div className="text-center mb-4">
                                                                <div className="w-20 h-20  rounded-lg mx-auto mb-3 flex items-center justify-center">
                                                                    {item.image && <img src={item.image} alt={item.name} className="w-full h-[90%] object-contain" />}
                                                                    {!item.image && <Package className="w-10 h-10 text-blue-600" />}
                                                                </div>
                                                                <h3 className="font-semibold text-lg text-gray-800 mb-1">{item.name}</h3>
                                                                <p className="text-gray-600 text-sm mb-3 line-clamp-2">{item.description}</p>
                                                                
                                                                {/* Rating */}
                                                                <div className="flex items-center justify-center mb-3">
                                                                    <div className="flex items-center space-x-1">
                                                                        {[1, 2, 3, 4, 5].map((star) => (
                                                                            <Star 
                                                                                key={star} 
                                                                                className={`w-4 h-4 ${star <= (item.rating || 4) ? 'text-yellow-400 fill-current' : 'text-gray-300'}`} 
                                                                            />
                                                                        ))}
                                                                    </div>
                                                                </div>

                                                                <div className="flex items-center justify-between mb-3">
                                                                    <div className="text-green-600 font-bold text-lg">${item.price.toFixed(2)}</div>
                                                                    {item.stock !== undefined && (
                                                                        <div className={`text-xs px-2 py-1 rounded-full ${
                                                                            item.stock > 10 ? 'bg-green-100 text-green-800' : 
                                                                            item.stock > 0 ? 'bg-yellow-100 text-yellow-800' : 
                                                                            'bg-red-100 text-red-800'
                                                                        }`}>
                                                                            {item.stock > 10 ? t('in_stock') : 
                                                                             item.stock > 0 ? t('only_left', { '%s': item.stock }) : t('out_of_stock')}
                                                                        </div>
                                                                    )}
                                                                </div>
                                                            </div>
                                                            
                                                            <button
                                                                onClick={() => addToCart(item)}
                                                                disabled={!canAddToCart(item)}
                                                                className={`w-full py-2 px-4 rounded-lg font-medium transition-colors ${
                                                                    !canAddToCart(item)
                                                                        ? 'bg-gray-300 text-gray-500 cursor-not-allowed' 
                                                                        : 'bg-blue-600 text-white hover:bg-blue-700'
                                                                }`}
                                                            >
                                                                {(() => {
                                                                    if (item.stock === 0) {
                                                                        return t('out_of_stock')
                                                                    }
                                                                    const existingItem = cart.find(cartItem => cartItem.item.id === item.id)
                                                                    if (cart.length >= 10 && !existingItem) {
                                                                        return t('cart_limit_reached')
                                                                    }
                                                                    return t('add_to_cart')
                                                                })()}
                                                            </button>
                                                        </div>
                                                    ))}
                                                </div>
                                            </div>
                                        </div>

                                        {/* Right Side - Cart */}
                                        <div className="w-96 bg-gray-50 border-l border-gray-200 p-6 flex flex-col">
                                            <div className="flex items-center justify-between mb-6">
                                                <h2 className="text-xl font-bold text-gray-800 flex items-center">
                                                    <ShoppingCart className="w-6 h-6 mr-2 text-blue-600" />
                                                    {t('shopping_cart')}
                                                </h2>
                                                {cart.length > 0 && (
                                                    <span className={`text-xs px-2 py-1 rounded-full ${
                                                        cart.length >= 10 
                                                            ? 'bg-red-600 text-white' 
                                                            : 'bg-blue-600 text-white'
                                                    }`}>
                                                        {cart.length}/10 {cart.length === 1 ? t('item') : t('items')}
                                                    </span>
                                                )}
                                                {cart.length === 0 && (
                                                    <span className="text-xs text-gray-500">
                                                        {t('max_items')}: 10
                                                    </span>
                                                )}
                                            </div>

                                            {cart.length === 0 ? (
                                                <div className="flex-1 flex flex-col items-center justify-center text-center text-gray-500">
                                                    <div className="w-24 h-24 bg-gray-100 rounded-full flex items-center justify-center mb-4">
                                                        <Package className="w-12 h-12 text-gray-300" />
                                                    </div>
                                                                <h3 className="text-lg font-medium mb-2">{t('your_cart_is_empty')}</h3>
            <p className="text-sm">{t('add_some_supplies')}</p>
                                                </div>
                                            ) : (
                                                <>
                                                    <div className="flex-1 overflow-y-auto space-y-3 mb-6">
                                                        {cart.map((cartItem) => (
                                                            <div key={cartItem.item.id} className="bg-white rounded-lg p-4 border border-gray-200">
                                                                <div className="flex items-start justify-between mb-3">
                                                                    <div className="flex-1">
                                                                        <h4 className="font-medium text-gray-800 mb-1">{cartItem.item.name}</h4>
                                                                        <p className="text-sm text-gray-600">${cartItem.item.price.toFixed(2)} {t('each')}</p>
                                                                    </div>
                                                                    <button
                                                                        onClick={() => removeFromCart(cartItem.item.id)}
                                                                        className="text-gray-400 hover:text-red-500 transition-colors"
                                                                    >
                                                                        <X className="w-4 h-4" />
                                                                    </button>
                                                                </div>
                                                                
                                                                <div className="flex items-center justify-between">
                                                                    <div className="flex items-center space-x-3">
                                                                        <button
                                                                            onClick={() => updateQuantity(cartItem.item.id, cartItem.quantity - 1)}
                                                                            className="w-8 h-8 bg-gray-100 hover:bg-gray-200 rounded flex items-center justify-center transition-colors"
                                                                        >
                                                                            <Minus className="w-3 h-3" />
                                                                        </button>
                                                                        <span className="w-12 text-center font-medium">{cartItem.quantity}</span>
                                                                        <button
                                                                            onClick={() => updateQuantity(cartItem.item.id, cartItem.quantity + 1)}
                                                                            className="w-8 h-8 bg-gray-100 hover:bg-gray-200 rounded flex items-center justify-center transition-colors"
                                                                        >
                                                                            <Plus className="w-3 h-3" />
                                                                        </button>
                                                                    </div>
                                                                    <div className="text-right">
                                                                        <div className="font-bold text-lg text-green-600">
                                                                            ${(cartItem.item.price * cartItem.quantity).toFixed(2)}
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        ))}
                                                    </div>

                                                    <div className="border-t pt-6">
                                                        <div className="space-y-3 mb-6">
                                                            <div className="flex justify-between items-center">
                                                                <span className="text-gray-600">{t('subtotal')}</span>
                                                                <span className="font-medium">${getCartTotal().toFixed(2)}</span>
                                                            </div>
                                                            <div className="flex justify-between items-center">
                                                                <span className="text-gray-600">{t('tax')}</span>
                                                                <span className="font-medium">${(getCartTotal() * 0.085).toFixed(2)}</span>
                                                            </div>
                                                            <div className="flex justify-between items-center text-lg font-bold">
                                                                <span>{t('total')}</span>
                                                                <span className="text-green-600">
                                                                    ${(getCartTotal() * 1.085).toFixed(2)}
                                                                </span>
                                                            </div>
                                                        </div>
                                                        
                                                        <button
                                                            onClick={handlePurchase}
                                                            className="w-full bg-green-600 hover:bg-green-700 text-white py-3 rounded-lg font-semibold flex items-center justify-center transition-colors"
                                                        >
                                                            <DollarSign className="w-5 h-5 mr-2" />
                                                            {t('complete_purchase')}
                                                        </button>
                                                        
                                                        <p className="text-xs text-gray-500 text-center mt-3">
                                                            {t('free_delivery_over_50')}
                                                        </p>
                                                    </div>
                                                </>
                                            )}
                                        </div>
                                    </div>
                                )}

                                {app.id === 'calculator' && (
                                    <div className="w-full h-full flex items-center justify-center p-8">
                                        <div className="bg-gray-100 rounded-2xl p-6 shadow-lg max-w-sm w-full">
                                            {/* Display */}
                                            <div className="bg-white rounded-lg p-4 mb-4">
                                                <div className="text-right text-3xl font-mono text-gray-800 min-h-[3rem] flex items-center justify-end">
                                                    {calculatorDisplay}
                                                </div>
                                            </div>

                                            {/* Buttons */}
                                            <div className="grid grid-cols-4 gap-2">
                                                {/* Row 1 */}
                                                <button onClick={calculatorClear} className="calculator-btn bg-red-500 hover:bg-red-600 text-white">
                                                    C
                                                </button>
                                                <button onClick={() => calculatorPerformOperation('÷')} className="calculator-btn bg-orange-500 hover:bg-orange-600 text-white">
                                                    <Divide className="w-5 h-5" />
                                                </button>
                                                <button onClick={() => calculatorPerformOperation('×')} className="calculator-btn bg-orange-500 hover:bg-orange-600 text-white">
                                                    <Multiply className="w-5 h-5" />
                                                </button>
                                                <button onClick={() => calculatorPerformOperation('-')} className="calculator-btn bg-orange-500 hover:bg-orange-600 text-white">
                                                    <Subtract className="w-5 h-5" />
                                                </button>

                                                {/* Row 2 */}
                                                <button onClick={() => calculatorInputDigit('7')} className="calculator-btn bg-gray-200 hover:bg-gray-300">
                                                    7
                                                </button>
                                                <button onClick={() => calculatorInputDigit('8')} className="calculator-btn bg-gray-200 hover:bg-gray-300">
                                                    8
                                                </button>
                                                <button onClick={() => calculatorInputDigit('9')} className="calculator-btn bg-gray-200 hover:bg-gray-300">
                                                    9
                                                </button>
                                                <button onClick={() => calculatorPerformOperation('+')} className="calculator-btn bg-orange-500 hover:bg-orange-600 text-white">
                                                    <Add className="w-5 h-5" />
                                                </button>

                                                {/* Row 3 */}
                                                <button onClick={() => calculatorInputDigit('4')} className="calculator-btn bg-gray-200 hover:bg-gray-300">
                                                    4
                                                </button>
                                                <button onClick={() => calculatorInputDigit('5')} className="calculator-btn bg-gray-200 hover:bg-gray-300">
                                                    5
                                                </button>
                                                <button onClick={() => calculatorInputDigit('6')} className="calculator-btn bg-gray-200 hover:bg-gray-300">
                                                    6
                                                </button>
                                                <button onClick={() => calculatorPerformOperation('=')} className="calculator-btn bg-green-500 hover:bg-green-600 text-white row-span-2">
                                                    <Equal className="w-5 h-5" />
                                                </button>

                                                {/* Row 4 */}
                                                <button onClick={() => calculatorInputDigit('1')} className="calculator-btn bg-gray-200 hover:bg-gray-300">
                                                    1
                                                </button>
                                                <button onClick={() => calculatorInputDigit('2')} className="calculator-btn bg-gray-200 hover:bg-gray-300">
                                                    2
                                                </button>
                                                <button onClick={() => calculatorInputDigit('3')} className="calculator-btn bg-gray-200 hover:bg-gray-300">
                                                    3
                                                </button>

                                                {/* Row 5 */}
                                                <button onClick={() => calculatorInputDigit('0')} className="calculator-btn bg-gray-200 hover:bg-gray-300 col-span-2">
                                                    0
                                                </button>
                                                <button onClick={calculatorInputDecimal} className="calculator-btn bg-gray-200 hover:bg-gray-300">
                                                    .
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                )}

                                {app.id === 'games' && (
                                    <div className="w-full h-full flex items-center justify-center p-8">
                                        <div className="bg-gradient-to-br from-purple-100 to-pink-100 rounded-2xl p-8 shadow-lg max-w-md w-full">
                                            <div className="text-center mb-6">
                                                            <h2 className="text-3xl font-bold text-purple-800 mb-2">{t('number_guessing_game')}</h2>
            <p className="text-purple-600">{t('guess_number_between')}</p>
                                            </div>

                                            <div className="bg-white rounded-lg p-6 mb-6">
                                                <div className="mb-4">
                                                    <label className="block text-sm font-medium text-gray-700 mb-2">
                                                        {t('your_guess')}
                                                    </label>
                                                    <input
                                                        type="number"
                                                        min="1"
                                                        max="100"
                                                        value={gameGuess}
                                                        onChange={(e) => setGameGuess(e.target.value)}
                                                        onKeyPress={(e) => e.key === 'Enter' && handleGameGuess()}
                                                        className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                                                        placeholder={t('enter_number')}
                                                    />
                                                </div>

                                                <button
                                                    onClick={handleGameGuess}
                                                    className="w-full bg-purple-600 hover:bg-purple-700 text-white py-2 rounded-lg font-medium transition-colors"
                                                >
                                                    {t('make_guess')}
                                                </button>
                                            </div>

                                            {gameMessage && (
                                                <div className={`bg-white rounded-lg p-4 mb-4 ${
                                                    gameWon ? 'border-2 border-green-500' : 'border-2 border-purple-300'
                                                }`}>
                                                    <p className={`text-center font-medium ${
                                                        gameWon ? 'text-green-600' : 'text-purple-600'
                                                    }`}>
                                                        {gameMessage}
                                                    </p>
                                                </div>
                                            )}

                                            <div className="bg-white rounded-lg p-4 mb-6">
                                                <div className="text-center">
                                                    <p className="text-sm text-gray-600">{t('attempts')} <span className="font-bold text-purple-600">{gameAttempts}</span></p>
                                                </div>
                                            </div>

                                            <button
                                                onClick={resetGame}
                                                className="w-full bg-gray-600 hover:bg-gray-700 text-white py-2 rounded-lg font-medium transition-colors"
                                            >
                                                {t('new_game')}
                                            </button>
                                        </div>
                                    </div>
                                )}

                                {app.id === 'music' && (
                                    <div className="w-full h-full flex items-center justify-center p-8">
                                        <div className="music-player p-8 max-w-2xl w-full">
                                            <div className="text-center mb-6">
                                                <h2 className="text-3xl font-bold text-pink-800 mb-2">{t('music_player')}</h2>
                                                <p className="text-pink-600">{t('restaurant_ambiance_music')}</p>
                                            </div>

                                            {/* Current Track Display */}
                                            <div className="bg-white rounded-lg p-6 mb-6">
                                                <div className="text-center mb-4">
                                                    <div className="music-album-art w-24 h-24 mx-auto mb-4">
                                                        <Music className="w-12 h-12 text-pink-600" />
                                                    </div>
                                                    <div className="music-info">
                                                        <h3 className="music-title">
                                                            {musicTracks.length > 0 && musicTracks[currentTrack] ? musicTracks[currentTrack].name : 'No Music Available'}
                                                        </h3>
                                                        <p className="music-artist">
                                                            {isPlaying ? t('now_playing') : t('restaurant_music')}
                                                        </p>
                                                        <div className="music-meta">
                                                            <span>{t('restaurant_ambiance')}</span>
                                                            <span>•</span>
                                                            <span>{t('live_stream')}</span>
                                                        </div>
                                                    </div>
                                                </div>

                                                {/* Progress Bar */}
                                                <div className="mb-4">
                                                    <div className="flex justify-between text-sm text-gray-500 mb-1">
                                                        <span className="music-time">{formatTime(musicCurrentTime)}</span>
                                                        <span className="music-time">{formatTime(musicDuration)}</span>
                                                    </div>
                                                    <div className="music-progress">
                                                        <div 
                                                            className="music-progress-fill"
                                                            style={{ width: `${(musicCurrentTime / musicDuration) * 100}%` }}
                                                        ></div>
                                                    </div>
                                                </div>

                                                {/* Control Buttons */}
                                                <div className="music-controls">
                                                    <button
                                                        onClick={prevTrack}
                                                        className="music-control-btn"
                                                        disabled={musicTracks.length === 0}
                                                    >
                                                        <svg className="w-6 h-6 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
                                                        </svg>
                                                    </button>
                                                    
                                                    <button
                                                        onClick={togglePlay}
                                                        className="music-control-btn play"
                                                        disabled={musicTracks.length === 0}
                                                    >
                                                        {isPlaying ? (
                                                            <svg className="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 9v6m4-6v6" />
                                                            </svg>
                                                        ) : (
                                                            <svg className="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M14.828 14.828a4 4 0 01-5.656 0M9 10h1m4 0h1m-6 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                                                            </svg>
                                                        )}
                                                    </button>
                                                    
                                                    <button
                                                        onClick={nextTrack}
                                                        className="music-control-btn"
                                                        disabled={musicTracks.length === 0}
                                                    >
                                                        <svg className="w-6 h-6 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                                                        </svg>
                                                    </button>
                                                </div>

                                                {/* Volume Control */}
                                                <div className="mt-6">
                                                                                                    <div className="flex items-center space-x-3">
                                                    <svg className="w-5 h-5 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15.536 8.464a5 5 0 010 7.072m2.828-9.9a9 9 0 010 12.728M5.586 15H4a1 1 0 01-1-1v-4a1 1 0 011-1h1.586l4.707-4.707C10.923 3.663 12 4.109 12 5v14c0 .891-1.077 1.337-1.707.707L5.586 15z" />
                                                    </svg>
                                                    <input
                                                        type="range"
                                                        min="0"
                                                        max="100"
                                                        value={volume}
                                                        onChange={(e) => handleVolumeChange(parseInt(e.target.value))}
                                                        className="music-volume-slider flex-1"
                                                    />
                                                    <span className="text-sm text-gray-600 w-8">{t('volume')}: {volume}%</span>
                                                </div>
                                                </div>
                                            </div>

                                            {/* Playlist */}
                                            <div className="bg-white rounded-lg p-6">
                                                <h3 className="text-lg font-semibold text-gray-800 mb-4">{t('playlist')}</h3>
                                                <div className="space-y-2 max-h-48 overflow-y-auto">
                                                    {musicTracks.length > 0 ? (
                                                        musicTracks.map((track, index) => (
                                                            <div
                                                                key={index}
                                                                onClick={() => selectTrack(index)}
                                                                className={`music-track-item ${
                                                                    index === currentTrack ? 'active' : ''
                                                                }`}
                                                            >
                                                                <div className="flex items-center justify-between">
                                                                    <div className="flex-1">
                                                                        <div className={`track-title ${
                                                                            index === currentTrack ? 'text-pink-800' : 'text-gray-800'
                                                                        }`}>
                                                                            {track.name}
                                                                        </div>
                                                                                                                                <div className="text-sm text-gray-600">{t('restaurant_music')}</div>
                                                    </div>
                                                    <div className="flex items-center space-x-3">
                                                        <span className="text-xs text-gray-500">{t('live')}</span>
                                                        <span className="text-sm text-gray-600">{t('stream')}</span>
                                                                        {index === currentTrack && isPlaying && (
                                                                            <div className="music-playing-indicator"></div>
                                                                        )}
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        ))
                                                    ) : (
                                                        <div className="text-center text-gray-500 py-4">
                                                            <Music className="w-8 h-8 mx-auto mb-2 text-gray-300" />
                                                            <p>{t('no_music_available')}</p>
                                                        </div>
                                                    )}
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                )}
                            </div>
                        </div>
                    ))}
                </div>
            </div>
        </div>
    )
}

export default Computer