import type React from "react";
import { useState, useEffect } from "react";
import CreateInput from "../components/Creator/CreateInput";
import { fetchNui } from "../utils/fetchNui";
import CreateColorInput from "../components/Creator/CreateColorInput";
import Button from "../components/Button";
import { useVisibility } from "../providers/VisibilityProvider";
import { useNuiEvent } from "../hooks/useNuiEvent";
import Select from "react-select";
import { t } from "../utils/translations";
import {
  Info,
  Users,
  Book,
  Menu,
  Monitor,
  MapPin,
  FileText,
  Palette,
  Image,
  Clock,
  Package,
  Edit,
  Trash2,
  UserPlus,
  Plus,
  ChefHat,
  DollarSign,
  Tv,
  TrendingUp,
  TrendingDown,
  Star,
  Calendar,
  Target,
  Activity,
  Award,
  BarChart3,
  ListOrdered,
  Lightbulb,
  StickyNote,
  Wallet,
  CreditCard,
  PiggyBank,
  Receipt,
  Banknote,
  ArrowUpRight,
  ArrowDownRight,
  Minus,
  X,
  Shield,
} from "lucide-react";

import TVIcon from "../assets/tv.svg";
import ChefIcon from "../assets/chef.svg";
import MenuIcon from "../assets/menu.svg";
import InfoIcon from "../assets/info.svg";
import EmployeeIcon from "../assets/person.svg";
import NameIcon from "../assets/resto_name.svg";
import ColorPaletteIcon from "../assets/color-palete.svg";
import MapIcon from "../assets/map.svg";
import MoneyIcon from "../assets/cash.svg";
import TrashIcon from "../assets/trash.svg";
import RecipeIcon from "../assets/recipe.svg";
import BoxIcon from "../assets/box.svg";
import ToggleSelect from "../components/ToggleSelect";
import ClockIcon from "../assets/clock.svg";
import ImageIcon from "../assets/logo-icon.svg";
import PlusIcon from "../assets/plus.svg";

interface PopularItem {
  name: string;
  sales: number;
  revenue: number;
}

interface WeeklyData {
  day: string;
  earnings: number;
  orders: number;
}

interface OverviewData {
  todayEarnings: number;
  yesterdayEarnings: number;
  monthlyEarnings: number;
  lastMonthEarnings: number;
  yearlyEarnings: number;
  todayOrders: number;
  monthlyOrders: number;
  averageOrderValue: number;
  customerSatisfaction: number;
  topSellingItem: string;
  busyHours: string;
  weeklyData: WeeklyData[];
  monthlyGrowth: number;
  orderGrowth: number;
  popularItems: PopularItem[];
}

export default function RestaurantManagement() {
  const { visibility } = useVisibility();
  const [activeTab, setActiveTab] = useState("overview");
  const [showTVModal, setShowTVModal] = useState(false);
  const [selectedTV, setSelectedTV] = useState<any>(null);
  const [showNewTVModal, setShowNewTVModal] = useState(false);
  const [newTVData, setNewTVData] = useState<any>({
    name: "",
    type: "kitchen",
  });

  const [showEmployeeModal, setShowEmployeeModal] = useState(false);
  const [showRecipeModal, setShowRecipeModal] = useState(false);
  const [showCategoryModal, setShowCategoryModal] = useState(false);
  const [showPOSModal, setShowPOSModal] = useState(false);
  const [selectedEmployee, setSelectedEmployee] = useState<any>(null);
  const [selectedRecipe, setSelectedRecipe] = useState<any>(null);
  const [selectedPOS, setSelectedPOS] = useState<any>(null);
  const [isCreatingRecipe, setIsCreatingRecipe] = useState(false);
  const [isCreatingPOS, setIsCreatingPOS] = useState(false);
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);
  const [deleteTarget, setDeleteTarget] = useState<any>(null);

  const [showWithdrawModal, setShowWithdrawModal] = useState(false);
  const [showDepositModal, setShowDepositModal] = useState(false);
  const [showPaySalaryModal, setShowPaySalaryModal] = useState(false);
  const [selectedEmployeeForPayment, setSelectedEmployeeForPayment] =
    useState<any>(null);
  const [showPaymentModal, setShowPaymentModal] = useState(false);
  const [showInvitationModal, setShowInvitationModal] = useState(false);
  const [invitationData, setInvitationData] = useState({
    position: "",
    salary: 0,
    isBoss: false,
    isManager: false,
  });
  const [withdrawAmount, setWithdrawAmount] = useState("");
  const [depositAmount, setDepositAmount] = useState("");
  const [financeData, setFinanceData] = useState({
    currentBalance: 0,
    totalRevenue: 0,
    totalExpenses: 0,
    pendingSalaries: 0,
    recentTransactions: [] as Array<{
      type: "income" | "expense" | "salary";
      description: string;
      amount: number;
      date: string;
    }>,
  });

  const [restaurantData, setRestaurantData] = useState<any>(null);
  const [employees, setEmployees] = useState<any[]>([]);
  const [recipes, setRecipes] = useState<any[]>([]);
  const [menuCategories, setMenuCategories] = useState<any[]>([]);
  const [posSystems, setPosSystems] = useState<any[]>([]);
  const [tvDisplays, setTvDisplays] = useState<any[]>([]);
  const [analytics, setAnalytics] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  const [playerRole, setPlayerRole] = useState<string>(t("employee"));
  const [accessPermissions, setAccessPermissions] = useState<any>({
    overview: false,
    general: false,
    employees: false,
    recipes: false,
    menu: false,
    pos: false,
    display: false,
    finance: false,
  });

  const [npcOrderingState, setNpcOrderingState] = useState({
    configEnabled: false,
    currentEnabled: false,
  });

  const [waitingSpaceStatus, setWaitingSpaceStatus] = useState({
    total: 0,
    occupied: 0,
    available: 0,
  });

  const hasAccess = (page: string) => {
    return accessPermissions[page] === true;
  };

  // Helper function to render blurred content for restricted pages
  const renderRestrictedContent = (page: string, children: React.ReactNode) => {
    if (hasAccess(page)) {
      return children;
    }

    return (
      <div className="relative">
        <div className="blur-sm pointer-events-none">{children}</div>
        <div className="absolute inset-0 flex items-center justify-center bg-black bg-opacity-50 rounded-lg">
          <div className="text-center">
            <div className="text-white text-lg font-semibold mb-2">
              {t("access_restricted")}
            </div>
            <div className="text-gray-300 text-sm">
              {t("you_dont_have_permission")}
            </div>
          </div>
        </div>
      </div>
    );
  };

  // Toggle NPC ordering
  const toggleNPCOrdering = (enabled: boolean) => {
    fetchNui("toggleNPCOrdering", { enabled });
    setNpcOrderingState((prev) => ({
      ...prev,
      currentEnabled: enabled,
    }));
  };

  // Fetch waiting space status
  const fetchWaitingSpaceStatus = async () => {
    try {
      const status = (await fetchNui("getWaitingSpaceStatus", {})) as {
        total: number;
        occupied: number;
        available: number;
      };
      setWaitingSpaceStatus(status || { total: 0, occupied: 0, available: 0 });
    } catch (error) {
      console.error("Error fetching waiting space status:", error);
      setWaitingSpaceStatus({ total: 0, occupied: 0, available: 0 });
    }
  };

  // Helper functions for display type management
  const getUsedDisplayTypes = () => {
    return tvDisplays.map((tv) => tv.display_type || tv.type).filter(Boolean);
  };

  const isDisplayTypeAvailable = (type: string) => {
    const usedTypes = getUsedDisplayTypes();
    return !usedTypes.includes(type);
  };

  const getAvailableDisplayTypes = () => {
    const allTypes = [
      { label: t("kitchen"), value: "kitchen" },
      { label: t("order_queue"), value: "order_queue" },
      { label: t("custom"), value: "custom" },
    ];

    const usedTypes = getUsedDisplayTypes();
    return allTypes.filter((type) => !usedTypes.includes(type.value));
  };

  // Cooking items state - will be loaded from server
  const [cookingItems, setCookingItems] = useState<any[]>([]);

  // Input items (ingredients) - items with input: true
  const inputItems = cookingItems
    .filter((item) => item.input)
    .map((item) => ({
      label: item.label,
      value: item.item,
    }));

  // Output items - items with output: true
  const outputItems = cookingItems
    .filter((item) => item.output)
    .map((item) => ({
      label: item.label,
      value: item.item,
    }));

  const [newRecipe, setNewRecipe] = useState({
    name: "",
    ingredients: [""],
    output: "",
    cookTime: 0,
    difficulty: t("easy"),
    description: "",
    image: "",
    instructions: [""],
    tips: [""],
    notes: [""],
    isDrink: false,
  });

  const [newCategory, setNewCategory] = useState({
    name: "",
    description: "",
    items: [] as any[],
  });
  const [selectedCategory, setSelectedCategory] = useState<any>(null);
  const [isEditingCategory, setIsEditingCategory] = useState(false);

  // Data loading effects
  useEffect(() => {
    if (visibility.visible && visibility.page === "management") {
      setLoading(true);
      // Data will be loaded via NUI messages from client

      // Load finance data when finance tab is active
      if (activeTab === "finance") {
        loadFinanceData();
      }
    }
  }, [visibility, activeTab]);

  // Load waiting space status when NPC system is enabled
  useEffect(() => {
    if (npcOrderingState.currentEnabled && npcOrderingState.configEnabled) {
      fetchWaitingSpaceStatus();
      // Refresh waiting space status every 10 seconds
      const interval = setInterval(fetchWaitingSpaceStatus, 10000);
      return () => clearInterval(interval);
    }
  }, [npcOrderingState.currentEnabled, npcOrderingState.configEnabled]);

  const loadFinanceData = () => {
    fetchNui("getFinanceData");
  };

  // Listen for data updates from client
  useEffect(() => {
    const handleMessage = (event: MessageEvent) => {
      const { action, data } = event.data;

      switch (action) {
        case "setVisibility":
          if (data.restaurantData) {
            setRestaurantData(data.restaurantData);
            setLoading(false);
          }
          if (data.playerRole) {
            setPlayerRole(data.playerRole);
          }
          if (data.accessPermissions) {
            setAccessPermissions(data.accessPermissions);
          }
          break;
        case "updateEmployees":
          setEmployees(data || []);
          break;
        case "updateRecipes":
          setRecipes(data || []);
          break;
        case "updateMenu":
          setMenuCategories(data || []);
          break;
        case "updatePOS":
          setPosSystems(data || []);
          break;
        case "updateTVDisplays":
          setTvDisplays(data || []);
          break;
        case "updateAnalytics":
          setAnalytics(data);
          // Update overview data with real analytics
          if (data) {
            setOverviewData({
              todayEarnings: data.todayEarnings || 0,
              yesterdayEarnings: data.yesterdayEarnings || 0,
              monthlyEarnings: data.monthlyEarnings || 0,
              lastMonthEarnings: data.lastMonthEarnings || 0,
              yearlyEarnings: 0, // Not calculated yet
              todayOrders: data.todayOrders || 0,
              monthlyOrders: data.monthlyOrders || 0,
              averageOrderValue: data.averageOrderValue || 0,
              customerSatisfaction: data.customerSatisfaction || 4.7,
              topSellingItem: data.topSellingItem || t("no_data"),
              busyHours: data.busyHours || t("no_data"),
              weeklyData: data.weeklyData || [
                { day: "Mon", earnings: 0, orders: 0 },
                { day: "Tue", earnings: 0, orders: 0 },
                { day: "Wed", earnings: 0, orders: 0 },
                { day: "Thu", earnings: 0, orders: 0 },
                { day: "Fri", earnings: 0, orders: 0 },
                { day: "Sat", earnings: 0, orders: 0 },
                { day: "Sun", earnings: 0, orders: 0 },
              ],
              monthlyGrowth: data.monthlyGrowth || 0,
              orderGrowth: data.orderGrowth || 0,
              popularItems: data.popularItems || [],
            });
          }
          break;
        case "updateCookingItems":
          setCookingItems(data || []);
          break;
        case "updateFinanceData":
          if (data) {
            setFinanceData({
              currentBalance: data.currentBalance || 0,
              totalRevenue: data.totalRevenue || 0,
              totalExpenses: data.totalExpenses || 0,
              pendingSalaries: data.pendingSalaries || 0,
              recentTransactions: data.recentTransactions || [],
            });
          }
          break;
      }
    };

    window.addEventListener("message", handleMessage);
    return () => window.removeEventListener("message", handleMessage);
  }, []);

  useNuiEvent("npcOrderingStateUpdate", (data: any) => {
    setNpcOrderingState(data);
  });

  // Local state for general info (doesn't update server until save)
  const [generalInfo, setGeneralInfo] = useState(() => {
    return restaurantData
      ? {
          name: restaurantData.label || t("restaurant"),
          themeColor: restaurantData.theme_color || "#43FFCD",
          secondaryColor: restaurantData.secondary_color || "#FFD700",
          blipNumber: restaurantData.info?.blipNumber || "1",
          description: restaurantData.description || "",
          logoUrl: restaurantData.logo_url || "",
          isOpen: restaurantData.is_open === 1,
        }
      : {
          name: t("restaurant"),
          themeColor: "#43FFCD",
          secondaryColor: "#FFD700",
          blipNumber: "1",
          description: "",
          logoUrl: "",
          isOpen: true,
        };
  });

  // Update local state when restaurant data changes
  useEffect(() => {
    if (restaurantData) {
      setGeneralInfo({
        name: restaurantData.label || t("restaurant"),
        themeColor: restaurantData.theme_color || "#43FFCD",
        secondaryColor: restaurantData.secondary_color || "#FFD700",
        blipNumber: restaurantData.info?.blipNumber || "1",
        description: restaurantData.description || "",
        logoUrl: restaurantData.logo_url || "",
        isOpen: restaurantData.is_open === 1,
      });
    }
  }, [restaurantData]);

  // Function to save restaurant info (only called on save button)
  const saveRestaurantInfo = async () => {
    try {
      await fetchNui("updateRestaurantInfo", generalInfo);
    } catch (error) {
      console.error("Failed to update restaurant info:", error);
    }
  };

  // Overview Data
  const [overviewData, setOverviewData] = useState<OverviewData>({
    todayEarnings: 0,
    yesterdayEarnings: 0,
    monthlyEarnings: 0,
    lastMonthEarnings: 0,
    yearlyEarnings: 0,
    todayOrders: 0,
    monthlyOrders: 0,
    averageOrderValue: 0,
    customerSatisfaction: 4.7,
    topSellingItem: t("no_data"),
    busyHours: t("no_data"),
    weeklyData: [
      { day: "Mon", earnings: 0, orders: 0 },
      { day: "Tue", earnings: 0, orders: 0 },
      { day: "Wed", earnings: 0, orders: 0 },
      { day: "Thu", earnings: 0, orders: 0 },
      { day: "Fri", earnings: 0, orders: 0 },
      { day: "Sat", earnings: 0, orders: 0 },
      { day: "Sun", earnings: 0, orders: 0 },
    ],
    monthlyGrowth: 0,
    orderGrowth: 0,
    popularItems: [],
  });

  const tabs = [
    {
      id: "overview",
      label: t("overview"),
      icon: Info,
      access: "overview",
    },
    {
      id: "general",
      label: t("general"),
      icon: Info,
      access: "general",
    },
    {
      id: "employees",
      label: t("employees"),
      icon: Users,
      access: "employees",
    },
    {
      id: "recipes",
      label: t("recipes"),
      icon: Book,
      access: "recipes",
    },
    {
      id: "menu",
      label: t("menu"),
      icon: Menu,
      access: "menu",
    },
    {
      id: "pos",
      label: t("pos"),
      icon: MapPin,
      access: "pos",
    },
    {
      id: "display",
      label: t("display"),
      icon: Monitor,
      access: "display",
    },
    {
      id: "finance",
      label: t("finance"),
      icon: Wallet,
      access: "finance",
    },
  ];

  // Performance Dots Component
  const PerformanceDots = ({ percentage }: { percentage: number }) => {
    const totalDots = 10;
    const filledDots = Math.round((percentage / 100) * totalDots);

    return (
      <div className="flex items-center gap-1">
        {Array.from({ length: totalDots }, (_, index) => (
          <div
            key={index}
            className={`w-2 h-2 rounded-full transition-all duration-300 ${
              index < filledDots
                ? percentage >= 90
                  ? "bg-green-400 shadow-sm shadow-green-400/50"
                  : percentage >= 70
                  ? "bg-[#43FFCD] shadow-sm shadow-[#43FFCD]/50"
                  : percentage >= 50
                  ? "bg-yellow-400 shadow-sm shadow-yellow-400/50"
                  : "bg-red-400 shadow-sm shadow-red-400/50"
                : "bg-gray-600"
            }`}
          />
        ))}
        <span className="ml-2 text-xs text-gray-400 g-medium">
          {percentage}%
        </span>
      </div>
    );
  };

  const customSelectStyles = {
    control: (base: any) => ({
      ...base,
      background: "rgba(217, 217, 217, 0.19)",
      border: "none",
      boxShadow: "none",
      borderRadius: "0.5rem",
      height: "3rem",
      "&:hover": {
        border: "none",
      },
    }),
    menu: (base: any) => ({
      ...base,
      background: "#1a1a1a",
      borderRadius: "0.5rem",
      marginTop: "0.5rem",
      zIndex: 1000,
    }),
    option: (base: any, state: any) => ({
      ...base,
      backgroundColor: state.isFocused
        ? "rgba(67, 255, 205, 0.2)"
        : "transparent",
      color: "white",
      "&:hover": {
        backgroundColor: "rgba(67, 255, 205, 0.2)",
      },
    }),
    singleValue: (base: any) => ({
      ...base,
      color: "white",
    }),
    input: (base: any) => ({
      ...base,
      color: "white",
    }),
    placeholder: (base: any) => ({
      ...base,
      color: "#9ca3af",
    }),
    indicatorSeparator: () => ({
      display: "none",
    }),
    IndicatorsContainer: (base: any) => ({
      display: "none",
    }),
    DropdownIndicator: () => ({
      display: "none",
    }),
    DownChevron: () => ({
      display: "none",
    }),
  };

  // Simple Bar Chart Component
  const SimpleBarChart = ({
    data,
    height = 120,
  }: {
    data: any[];
    height?: number;
  }) => {
    const maxValue = Math.max(...data.map((d) => d.earnings));

    return (
      <div
        className="flex items-end justify-between px-2"
        style={{ height: `${height}px` }}
      >
        {data.map((item, index) => (
          <div key={index} className="flex flex-col items-center gap-1">
            <div
              className="flex flex-col items-center justify-end"
              style={{ height: `${height - 20}px` }}
            >
              <div className="flex flex-col items-center gap-0.5 mb-1">
                <span className="text-xs font-medium text-[#43FFCD]">
                  ${(item.earnings / 1000).toFixed(1)}k
                </span>
                <span className="text-xs text-gray-400">{item.orders}</span>
              </div>
              <div
                className="w-6 bg-gradient-to-t from-[#43FFCD] to-[#2AB5A3] rounded-t-sm transition-all duration-500 hover:opacity-80"
                style={{
                  height: `${(item.earnings / maxValue) * (height * 0.5)}px`,
                  minHeight: "6px",
                }}
              />
            </div>
            <span className="text-xs font-medium text-gray-300">
              {item.day}
            </span>
          </div>
        ))}
      </div>
    );
  };

  const renderOverview = () => (
    <div className="space-y-4">
      {/* Key Metrics Row */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        {/* Today's Earnings */}
        <div className="modern-card p-4">
          <div className="flex items-center justify-between mb-3">
            <div className="w-10 h-10 rounded-lg bg-gradient-to-br from-green-400/20 to-green-600/20 flex items-center justify-center">
              <DollarSign size={20} color="#22c55e" />
            </div>
            <div
              className={`flex items-center gap-1 px-2 py-1 rounded-full text-xs ${
                overviewData.todayEarnings > overviewData.yesterdayEarnings
                  ? "bg-green-500/20 text-green-400"
                  : "bg-red-500/20 text-red-400"
              }`}
            >
              {overviewData.todayEarnings > overviewData.yesterdayEarnings ? (
                <TrendingUp size={10} />
              ) : (
                <TrendingDown size={10} />
              )}
              {(
                ((overviewData.todayEarnings - overviewData.yesterdayEarnings) /
                  overviewData.yesterdayEarnings) *
                100
              ).toFixed(1)}
              %
            </div>
          </div>
          <div className="space-y-1">
            <h3 className="g-semibold text-white text-xl">
              ${overviewData.todayEarnings.toLocaleString()}
            </h3>
            <p className="g-medium text-gray-400 text-xs">
              {t("todays_revenue")}
            </p>
          </div>
        </div>

        {/* Monthly Revenue */}
        <div className="modern-card p-4">
          <div className="flex items-center justify-between mb-3">
            <div className="w-10 h-10 rounded-lg bg-gradient-to-br from-[#43FFCD]/20 to-[#2AB5A3]/20 flex items-center justify-center">
              <Calendar size={20} color="#43FFCD" />
            </div>
            <div className="flex items-center gap-1 px-2 py-1 rounded-full text-xs bg-green-500/20 text-green-400">
              <TrendingUp size={10} />+{overviewData.monthlyGrowth.toFixed(0)}%
            </div>
          </div>
          <div className="space-y-1">
            <h3 className="g-semibold text-white text-xl">
              ${(overviewData.monthlyEarnings / 1000).toFixed(1)}k
            </h3>
            <p className="g-medium text-gray-400 text-xs">{t("this_month")}</p>
          </div>
        </div>

        {/* Order Statistics */}
        <div className="modern-card p-4">
          <div className="flex items-center justify-between mb-3">
            <div className="w-10 h-10 rounded-lg bg-gradient-to-br from-blue-400/20 to-blue-600/20 flex items-center justify-center">
              <Activity size={20} color="#3b82f6" />
            </div>
            <div className="flex items-center gap-1 px-2 py-1 rounded-full text-xs bg-green-500/20 text-green-400">
              <TrendingUp size={10} />+{overviewData.orderGrowth.toFixed(0)}%
            </div>
          </div>
          <div className="space-y-1">
            <h3 className="g-semibold text-white text-xl">
              {overviewData.todayOrders}
            </h3>
            <p className="g-medium text-gray-400 text-xs">
              {t("orders_today")}
            </p>
          </div>
        </div>

        {/* Customer Rating */}
        <div className="modern-card p-4">
          <div className="flex items-center justify-between mb-3">
            <div className="w-10 h-10 rounded-lg bg-gradient-to-br from-yellow-400/20 to-orange-500/20 flex items-center justify-center">
              <Star size={20} color="#f59e0b" />
            </div>
            <div className="flex items-center gap-1">
              {[...Array(5)].map((_, i) => (
                <Star
                  key={i}
                  size={10}
                  fill={
                    i < Math.floor(overviewData.customerSatisfaction)
                      ? "#f59e0b"
                      : "transparent"
                  }
                  color="#f59e0b"
                />
              ))}
            </div>
          </div>
          <div className="space-y-1">
            <h3 className="g-semibold text-white text-xl">
              {overviewData.customerSatisfaction}/5.0
            </h3>
            <p className="g-medium text-gray-400 text-xs">
              {t("customer_rating")}
            </p>
          </div>
        </div>
      </div>

      {/* Charts and Analytics Row */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        {/* Weekly Revenue Chart */}
        <div className="modern-card p-4">
          <div className="flex items-center justify-between mb-4">
            <div>
              <h3 className="g-semibold text-white text-md mb-1">
                {t("weekly_performance")}
              </h3>
              <p className="g-medium text-gray-400 text-sm mt-[-7px]">
                {t("revenue_order_trends")}
              </p>
            </div>
            <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-[#43FFCD]/20 to-[#2AB5A3]/20 flex items-center justify-center">
              <BarChart3 size={16} color="#43FFCD" />
            </div>
          </div>

          <div className="h-32">
            <SimpleBarChart data={overviewData.weeklyData} height={120} />
          </div>

          <div className="mt-3 flex items-center justify-between text-xs">
            <div className="flex items-center gap-1">
              <div className="w-2 h-2 bg-gradient-to-r from-[#43FFCD] to-[#2AB5A3] rounded-full"></div>
              <span className="text-gray-400">{t("revenue")}</span>
            </div>
            <div className="flex items-center gap-1">
              <div className="w-2 h-2 bg-gray-400 rounded-full"></div>
              <span className="text-gray-400">{t("orders")}</span>
            </div>
          </div>
        </div>

        {/* Popular Items */}
        <div className="modern-card p-4">
          <div className="flex items-center justify-between mb-4">
            <div>
              <h3 className="g-semibold text-white text-md mb-1">
                {t("top_selling_items")}
              </h3>
              <p className="g-medium text-gray-400 text-sm mt-[-7px]">
                {t("this_months_bestsellers")}
              </p>
            </div>
            <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-[#43FFCD]/20 to-[#2AB5A3]/20 flex items-center justify-center">
              <Award size={16} color="#43FFCD" />
            </div>
          </div>

          <div className="space-y-2">
            {overviewData.popularItems.slice(0, 3).map((item, index) => (
              <div
                key={index}
                className="flex items-center justify-between p-2 rounded-lg bg-white/5 border border-white/10"
              >
                <div className="flex items-center gap-2">
                  <div className="w-6 h-6 rounded bg-gradient-to-br from-[#43FFCD]/20 to-[#2AB5A3]/20 flex items-center justify-center">
                    <span className="g-semibold text-[#43FFCD] text-xs">
                      #{index + 1}
                    </span>
                  </div>
                  <div>
                    <h4 className="g-semibold text-white text-xs">
                      {item.name}
                    </h4>
                    <p className="g-medium text-gray-400 text-xs">
                      {item.sales} {t("sold")}
                    </p>
                  </div>
                </div>
                <div className="text-right">
                  <div className="g-semibold text-[#43FFCD] text-xs">
                    ${(item.revenue / 1000).toFixed(1)}k
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Quick Stats and Insights */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {/* Performance Insights */}
        <div className="modern-card p-4">
          <div className="flex items-center gap-2 mb-4">
            <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-purple-400/20 to-purple-600/20 flex items-center justify-center">
              <Target size={16} color="#a855f7" />
            </div>
            <div>
              <h3 className="g-semibold text-white text-md">
                {t("performance")}
              </h3>
              <p className="g-medium text-gray-400 text-sm mt-[-5px]">
                {t("todays_highlights")}
              </p>
            </div>
          </div>

          <div className="space-y-2">
            <div className="flex items-center justify-between">
              <span className="g-medium text-gray-300 text-sm">
                {t("peak_hours")}
              </span>
              <span className="g-semibold text-[#43FFCD] text-sm">
                {overviewData.busyHours}
              </span>
            </div>
            <div className="flex items-center justify-between">
              <span className="g-medium text-gray-300 text-sm">
                {t("top_item")}
              </span>
              <span className="g-semibold text-[#43FFCD] text-sm">
                {overviewData.topSellingItem}
              </span>
            </div>
            <div className="flex items-center justify-between">
              <span className="g-medium text-gray-300 text-sm">
                {t("active_staff")}
              </span>
              <span className="g-semibold text-[#43FFCD] text-sm">
                {employees.filter((e) => e.performance > 70).length}/
                {employees.length}
              </span>
            </div>
          </div>
        </div>

        {/* Restaurant Status */}
        <div className="modern-card p-4">
          <div className="flex items-center gap-2 mb-4">
            <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-[#43FFCD]/20 to-[#2AB5A3]/20 flex items-center justify-center">
              <Monitor size={16} color="#43FFCD" />
            </div>
            <div>
              <h3 className="g-semibold text-white text-md">
                {t("systems_status")}
              </h3>
              <p className="g-medium text-gray-400 text-sm mt-[-5px]">
                {t("operational_overview")}
              </p>
            </div>
          </div>

          <div className="space-y-2">
            <div className="flex items-center justify-between">
              <span className="g-medium text-gray-300 text-sm">
                {t("pos_systems")}
              </span>
              <div className="flex items-center gap-1">
                <div className="w-2 h-2 rounded-full bg-green-400"></div>
                <span className="g-semibold text-green-400 text-xs">
                  {
                    posSystems.filter(
                      (pos: any) =>
                        pos.device_type === "pos" &&
                        (pos.is_active === 1 || pos.is_active === true)
                    ).length
                  }
                  /
                  {
                    posSystems.filter((pos: any) => pos.device_type === "pos")
                      .length
                  }
                </span>
              </div>
            </div>
            <div className="flex items-center justify-between">
              <span className="g-medium text-gray-300 text-sm">
                {t("kiosks")}
              </span>
              <div className="flex items-center gap-1">
                <div className="w-2 h-2 rounded-full bg-green-400"></div>
                <span className="g-semibold text-green-400 text-xs">
                  {
                    posSystems.filter(
                      (kiosk: any) =>
                        kiosk.device_type === "kiosk" &&
                        (kiosk.is_active === 1 || kiosk.is_active === true)
                    ).length
                  }
                  /
                  {
                    posSystems.filter(
                      (kiosk: any) => kiosk.device_type === "kiosk"
                    ).length
                  }
                </span>
              </div>
            </div>
            <div className="flex items-center justify-between">
              <span className="g-medium text-gray-300 text-sm">
                {t("displays")}
              </span>
              <div className="flex items-center gap-1">
                <div className="w-2 h-2 rounded-full bg-green-400"></div>
                <span className="g-semibold text-green-400 text-xs">
                  {tvDisplays.length}
                </span>
              </div>
            </div>
          </div>
        </div>

        {/* NPC Customer System */}
        <div className="modern-card p-4">
          <div className="flex items-center gap-2 mb-3">
            <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-orange-400/20 to-red-500/20 flex items-center justify-center">
              <Users size={16} color="#f97316" />
            </div>
            <div>
              <h3 className="g-semibold text-white text-md">
                {t("npc_customer_system")}
              </h3>
              <p className="g-medium text-gray-400 text-sm mt-[-5px]">
                {t("ai_customer_simulation")}
              </p>
            </div>
          </div>

          {!npcOrderingState.configEnabled ? (
            <div className="text-center py-4">
              <div className="w-8 h-8 mx-auto mb-2 rounded-full bg-red-500/20 flex items-center justify-center">
                <X size={16} color="#ef4444" />
              </div>
              <p className="g-medium text-gray-300 text-sm mb-1">
                {t("system_disabled")}
              </p>
              <p className="g-medium text-gray-400 text-xs">
                {t("disabled_in_server_configuration")}
              </p>
            </div>
          ) : (
            <div className="space-y-3">
              <div className="flex items-center justify-between">
                <div>
                  <p className="g-semibold text-white text-sm">
                    {t("enable_npc_customers")}
                  </p>
                </div>
                <ToggleSelect
                  options={[t("enabled"), t("disabled")]}
                  active={
                    npcOrderingState.currentEnabled
                      ? t("enabled")
                      : t("disabled")
                  }
                  setActive={(active) => {
                    toggleNPCOrdering(active === t("enabled"));
                  }}
                  colorScheme="status"
                />
              </div>

              <div className="pt-2 border-t border-white/10">
                <div className="flex items-center gap-2 text-xs">
                  <div
                    className={`w-2 h-2 rounded-full ${
                      npcOrderingState.currentEnabled
                        ? "bg-green-400"
                        : "bg-gray-500"
                    }`}
                  ></div>
                  <span className="g-medium text-gray-400">
                    {npcOrderingState.currentEnabled
                      ? t("status_active")
                      : t("status_inactive")}
                  </span>
                </div>
                {npcOrderingState.currentEnabled && (
                  <div className="space-y-2 mt-2">
                    <p className="g-medium text-gray-400 text-xs">
                      {t("npcs_will_spawn_and_visit")}
                    </p>

                    {/* Waiting Space Status */}
                    <div className="bg-gray-800/50 rounded p-2">
                      <div className="flex items-center justify-between text-xs">
                        <span className="g-medium text-gray-300">
                          {t("waiting_spaces")}
                        </span>
                        <div className="flex items-center gap-2">
                          <span className="text-green-400">
                            {waitingSpaceStatus.available || 0}
                          </span>
                          <span className="text-gray-400">/</span>
                          <span className="text-gray-300">
                            {waitingSpaceStatus.total || 0}
                          </span>
                          <span className="text-gray-400">
                            {t("available")}
                          </span>
                        </div>
                      </div>
                      {waitingSpaceStatus.total > 0 && (
                        <div className="w-full bg-gray-700 rounded-full h-1 mt-1">
                          <div
                            className="h-1 rounded-full bg-green-500 transition-all duration-300"
                            style={{
                              width: `${
                                ((waitingSpaceStatus.available || 0) /
                                  (waitingSpaceStatus.total || 1)) *
                                100
                              }%`,
                            }}
                          ></div>
                        </div>
                      )}
                    </div>
                  </div>
                )}
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );

  const renderGeneralInfo = () => (
    <div className="space-y-4">
      {/* Main Content Grid */}
      <div className="flex flex-row justify-center items-center w-full gap-6">
        {/* Left Column - Forms */}
        <div className="w-full space-y-4">
          {/* Basic Details Card */}
          <div className="modern-card p-4 space-y-4">
            <h3 className="g-semibold text-white text-md mb-3 flex items-center gap-2">
              <Info size={16} color="#43FFCD" />
              {t("basic_details")}
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              <CreateInput
                placeholder={t("restaurant_name")}
                value={generalInfo.name}
                icon={NameIcon}
                onChange={(e) =>
                  setGeneralInfo({ ...generalInfo, name: e.target.value })
                }
              />
              <CreateInput
                placeholder={t("blip_number")}
                value={generalInfo.blipNumber}
                icon={MapIcon}
                onChange={(e) =>
                  setGeneralInfo({ ...generalInfo, blipNumber: e.target.value })
                }
              />
            </div>
            <div className="flex flex-col gap-2">
              <label className="block text-sm font-medium text-gray-300">
                {t("logo_image_url")}
              </label>
              <CreateInput
                placeholder={t("logo_image_url")}
                value={generalInfo.logoUrl}
                icon={ImageIcon}
                onChange={(e) =>
                  setGeneralInfo({ ...generalInfo, logoUrl: e.target.value })
                }
              />
            </div>
          </div>

          {/* Branding Card */}
          <div className="modern-card p-4 space-y-4">
            <h3 className="g-semibold text-white text-md mb-3 flex items-center gap-2">
              <Palette size={16} color="#43FFCD" />
              {t("branding_appearance")}
            </h3>
            <div className="space-y-4">
              <div className="space-y-2">
                <label className="block text-sm font-medium text-gray-300">
                  {t("primary_color")}
                </label>
                <CreateColorInput
                  value={generalInfo.themeColor}
                  icon={ColorPaletteIcon}
                  onChange={(color) =>
                    setGeneralInfo({ ...generalInfo, themeColor: color.hex })
                  }
                />
              </div>
              <div className="space-y-2">
                <label className="block text-sm font-medium text-gray-300">
                  {t("secondary_color")}
                </label>
                <CreateColorInput
                  value={generalInfo.secondaryColor}
                  icon={ColorPaletteIcon}
                  onChange={(color) =>
                    setGeneralInfo({
                      ...generalInfo,
                      secondaryColor: color.hex,
                    })
                  }
                />
              </div>
            </div>
          </div>

          {/* <div className="modern-card p-4 space-y-4">
            <div className="space-y-3">
              <div>
                <label className="block text-sm font-medium text-gray-300 mb-2">
                  {t("restaurant_status")}
                </label>
                <ToggleSelect
                  options={[t("open"), t("closed")]}
                  active={generalInfo.isOpen ? t("open") : t("closed")}
                  setActive={(active) => {
                    setGeneralInfo({
                      ...generalInfo,
                      isOpen: active === t("open"),
                    });
                  }}
                  colorScheme="status"
                />
              </div>
            </div>
          </div> */}
        </div>

        {/* Right Column - Logo Preview & Additional Settings */}
        <div className="w-[61%] space-y-4">
          {/* Logo Preview */}
          <div className="modern-card p-4">
            <h3 className="g-semibold text-white text-md mb-3 flex items-center gap-2">
              <Image size={16} color="#43FFCD" />
              {t("logo_preview")}
            </h3>
            <div className="logo-preview-container">
              {generalInfo.logoUrl && generalInfo.logoUrl.trim() !== "" ? (
                <img
                  src={generalInfo.logoUrl}
                  alt="Restaurant Logo"
                  className="logo-preview-image"
                  onError={(e) => {
                    const target = e.currentTarget as HTMLImageElement;
                    target.style.display = "none";
                  }}
                  onLoad={(e) => {
                    const target = e.currentTarget as HTMLImageElement;
                    target.style.display = "block";
                  }}
                />
              ) : null}

              {!generalInfo.logoUrl || generalInfo.logoUrl.trim() === "" ? (
                <div className="logo-preview-placeholder">
                  <div className="w-16 h-16 mx-auto mb-3 rounded-xl bg-gradient-to-br from-[#43FFCD]/10 to-[#2AB5A3]/10 flex items-center justify-center">
                    <Image size={24} color="#6b7280" />
                  </div>
                  <span className="g-medium text-gray-400 text-sm">
                    {t("upload_your_logo")}
                  </span>
                </div>
              ) : null}
            </div>
          </div>
        </div>
      </div>

      {/* Save Button */}
      <div className="flex justify-center pt-2">
        <Button
          label={t("save_changes")}
          onClick={saveRestaurantInfo}
          style={{
            width: "26rem",
          }}
        />
      </div>
    </div>
  );

  const renderEmployees = () => (
    <div className="space-y-6">
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {/* Add New Employee Card */}
        <div
          onClick={() => setShowInvitationModal(true)}
          className="add-new-card group cursor-pointer"
        >
          <div className="flex flex-col items-center justify-center h-full min-h-[140px] text-center">
            <div className="w-12 h-12 rounded-full border-2 border-dashed border-[#43FFCD]/50 group-hover:border-[#43FFCD] flex items-center justify-center mb-3 transition-all duration-300 group-hover:bg-[#43FFCD]/10">
              <UserPlus
                size={20}
                color="#43FFCD"
                className="opacity-60 group-hover:opacity-100 transition-opacity duration-300"
              />
            </div>
            <h3 className="g-semibold text-white/70 group-hover:text-white text-base mb-1 transition-colors duration-300">
              {t("invite_employee")}
            </h3>
            <p className="g-medium text-gray-400 text-xs">
              {t("add_new_team_member")}
            </p>
          </div>
        </div>

        {employees.map((employee) => (
          <div key={employee.id} className="modern-employee-card">
            <div className="flex items-start gap-4 mb-3">
              <div className="w-12 h-12 rounded-full bg-gradient-to-br from-[#43FFCD]/20 to-[#2AB5A3]/20 flex items-center justify-center flex-shrink-0">
                <Users size={24} color="#43FFCD" />
              </div>
              <div className="flex-1 min-w-0">
                <h3 className="g-semibold text-white text-lg truncate">
                  {employee.name}
                </h3>
                <p className="g-medium text-gray-300 text-sm">
                  {employee.position}
                </p>
                <div className="flex flex-col gap-1.5 mt-2">
                  <div className="flex items-center justify-between">
                    <span className="g-medium text-gray-400 text-xs">
                      {t("performance")}
                    </span>
                    <span className="g-medium text-[#43FFCD] text-sm">
                      ${employee.salary.toLocaleString()}
                    </span>
                  </div>
                  <PerformanceDots percentage={employee.performance} />
                </div>
              </div>
            </div>

            <div className="flex items-center justify-between pt-3 border-t border-white/10">
              <span className="g-medium text-gray-400 text-xs">
                {t("since")} {new Date(employee.hireDate).toLocaleDateString()}
              </span>
              <div className="flex gap-2">
                <button
                  onClick={() => {
                    setSelectedEmployee(employee);
                    setShowEmployeeModal(true);
                  }}
                  className="modern-icon-button w-8 h-8 rounded-lg bg-white/10 hover:bg-white/20 flex items-center justify-center transition-all duration-200"
                >
                  <Edit size={16} color="#43FFCD" />
                </button>
                <button
                  onClick={async () => {
                    try {
                      await fetchNui("deleteEmployee", { id: employee.id });
                    } catch (error) {
                      console.error("Failed to delete employee:", error);
                    }
                  }}
                  className="modern-icon-button-red w-8 h-8 rounded-lg bg-red-500/20 hover:bg-red-500/30 flex items-center justify-center transition-all duration-200"
                >
                  <Trash2 size={16} color="#f87171" />
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );

  const renderRecipes = () => (
    <div className="space-y-6">
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {/* Add New Recipe Card */}
        <div
          onClick={() => {
            setIsCreatingRecipe(true);
            setNewRecipe({
              name: "",
              ingredients: [""],
              output: "",
              cookTime: 0,
              difficulty: t("easy"),
              description: "",
              image: "",
              instructions: [""],
              tips: [""],
              notes: [""],
              isDrink: false,
            });
            setShowRecipeModal(true);
          }}
          className="add-new-card group cursor-pointer"
        >
          <div className="flex flex-col items-center justify-center h-full min-h-[140px] text-center">
            <div className="w-12 h-12 rounded-full border-2 border-dashed border-[#43FFCD]/50 group-hover:border-[#43FFCD] flex items-center justify-center mb-3 transition-all duration-300 group-hover:bg-[#43FFCD]/10">
              <Plus
                size={20}
                color="#43FFCD"
                className="opacity-60 group-hover:opacity-100 transition-opacity duration-300"
              />
            </div>
            <h3 className="g-semibold text-white/70 group-hover:text-white text-base mb-1 transition-colors duration-300">
              {t("create_recipe")}
            </h3>
            <p className="g-medium text-gray-400 text-xs">{t("add_recipe")}</p>
          </div>
        </div>

        {recipes.map((recipe) => (
          <div key={recipe.id} className="modern-recipe-card">
            {/* Recipe Header */}
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-lg bg-gradient-to-br from-[#43FFCD]/20 to-[#2AB5A3]/20 flex items-center justify-center flex-shrink-0">
                  <Book size={18} color="#43FFCD" />
                </div>
                <div>
                  <h3 className="g-semibold text-white text-lg leading-tight">
                    {recipe.name}
                  </h3>
                  <p className="g-medium text-gray-400 text-xs">
                    {t("recipe")}
                  </p>
                </div>
              </div>
              <div className="flex gap-1">
                <button
                  onClick={() => {
                    setSelectedRecipe(recipe);
                    setIsCreatingRecipe(false);
                    setShowRecipeModal(true);
                  }}
                  className="modern-icon-button w-8 h-8 rounded-lg bg-white/10 hover:bg-white/20 flex items-center justify-center transition-all duration-200"
                >
                  <Edit size={16} color="#43FFCD" />
                </button>
                <button
                  onClick={() => {
                    setDeleteTarget({
                      type: "recipe",
                      id: recipe.id,
                      name: recipe.name,
                    });
                    setShowDeleteConfirm(true);
                  }}
                  className="modern-icon-button-red w-8 h-8 rounded-lg bg-red-500/20 hover:bg-red-500/30 flex items-center justify-center transition-all duration-200"
                >
                  <Trash2 size={16} color="#f87171" />
                </button>
              </div>
            </div>

            {/* Recipe Stats */}
            <div className="flex items-center gap-2 mb-4">
              <span className="recipe-time-badge">
                <Clock size={12} color="white" />
                {recipe.cookTime}min
              </span>
              <span
                className={`recipe-difficulty-badge recipe-difficulty-${recipe.difficulty.toLowerCase()}`}
              >
                {recipe.difficulty}
              </span>
              {recipe.is_drink && (
                <span className="text-xs px-2 py-1 rounded bg-blue-500/20 text-blue-400 border border-blue-500/30">
                  {t("drink")}
                </span>
              )}
            </div>

            {/* Description */}
            <p className="g-medium text-gray-300 text-sm leading-relaxed mb-4">
              {recipe.description}
            </p>

            {/* Ingredients */}
            <div className="mb-4">
              <h4 className="g-semibold text-white text-sm mb-2 flex items-center gap-2">
                <Package size={16} color="#43FFCD" />
                {t("ingredients")} ({recipe.ingredients.length})
              </h4>
              <div className="flex flex-wrap gap-1.5">
                {recipe.ingredients.map((ingredient: string, index: number) => (
                  <span key={index} className="recipe-ingredient-tag">
                    {ingredient}
                  </span>
                ))}
              </div>
            </div>

            {/* Output */}
            <div className="pt-3 border-t border-white/10">
              <div className="flex items-center gap-2">
                <span className="g-medium text-gray-400 text-xs">
                  {t("output")}:
                </span>
                <span className="g-semibold text-[#43FFCD] text-sm">
                  {recipe.output}
                </span>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );

  const renderMenu = () => (
    <div className="space-y-6">
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {/* Add New Category Card */}
        <div
          onClick={() => {
            setNewCategory({ name: "", description: "", items: [] });
            setSelectedCategory(null);
            setIsEditingCategory(false);
            setShowCategoryModal(true);
          }}
          className="add-new-card group cursor-pointer"
        >
          <div className="flex flex-col items-center justify-center h-full min-h-[140px] text-center">
            <div className="w-12 h-12 rounded-full border-2 border-dashed border-[#43FFCD]/50 group-hover:border-[#43FFCD] flex items-center justify-center mb-3 transition-all duration-300 group-hover:bg-[#43FFCD]/10">
              <Plus
                size={20}
                color="#43FFCD"
                className="opacity-60 group-hover:opacity-100 transition-opacity duration-300"
              />
            </div>
            <h3 className="g-semibold text-white/70 group-hover:text-white text-base mb-1 transition-colors duration-300">
              {t("add_category")}
            </h3>
            <p className="g-medium text-gray-400 text-xs">
              {t("create_new_category")}
            </p>
          </div>
        </div>

        {menuCategories.map((category) => (
          <div key={category.id} className="modern-employee-card">
            <div className="flex items-start gap-4 mb-4">
              <div className="w-12 h-12 rounded-full bg-gradient-to-br from-[#43FFCD]/20 to-[#2AB5A3]/20 flex items-center justify-center flex-shrink-0">
                <Menu size={24} color="#43FFCD" />
              </div>
              <div className="flex-1 min-w-0">
                <h3 className="g-semibold text-white text-lg truncate">
                  {category.name}
                </h3>
                <p className="g-medium text-gray-300 text-sm">
                  {category.description}
                </p>
                <div className="flex items-center gap-2 mt-2">
                  <span className="employee-grade-badge">
                    {category.items.length} {t("items")}
                  </span>
                </div>
              </div>
            </div>

            <div className="flex items-center justify-between pt-4 border-t border-white/10">
              <span className="g-medium text-gray-400 text-xs">
                {t("menu_category")}
              </span>
              <div className="flex gap-2">
                <button
                  onClick={() => {
                    setSelectedCategory(category);
                    setNewCategory({
                      name: category.name,
                      description: category.description,
                      items: (category.items || []).map((item: any) => ({
                        ...item,
                        id: item.recipe_id || item.id, // Use recipe_id for recipe operations
                        menu_item_id: item.id, // Preserve menu item ID for updates/deletes
                        price: parseFloat(item.price || 0),
                      })),
                    });
                    setIsEditingCategory(true);
                    setShowCategoryModal(true);
                  }}
                  className="modern-icon-button w-8 h-8 rounded-lg bg-white/10 hover:bg-white/20 flex items-center justify-center transition-all duration-200"
                >
                  <Edit size={16} color="#43FFCD" />
                </button>
                <button
                  onClick={() => {
                    setMenuCategories(
                      menuCategories.filter((c) => c.id !== category.id)
                    );
                    fetchNui("deleteCategory", { id: category.id });
                  }}
                  className="modern-icon-button-red w-8 h-8 rounded-lg bg-red-500/20 hover:bg-red-500/30 flex items-center justify-center transition-all duration-200"
                >
                  <Trash2 size={16} color="#f87171" />
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );

  const renderPOS = () => (
    <div className="space-y-6">
      {/* POS Systems Section */}
      <div className="space-y-6">
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-[#43FFCD]/20 to-[#2AB5A3]/20 flex items-center justify-center">
            <MapPin size={16} color="#43FFCD" />
          </div>
          <h3 className="g-semibold text-white text-xl">{t("pos_systems")}</h3>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {/* Add New POS Card */}
          <div
            onClick={() => {
              setIsCreatingPOS(true);
              setSelectedPOS({
                name: "",
                type: "pos",
                isActive: true,
              });
              setShowPOSModal(true);
            }}
            className="add-new-card group cursor-pointer"
          >
            <div className="flex flex-col items-center justify-center h-full min-h-[120px] text-center">
              <div className="w-10 h-10 rounded-full border-2 border-dashed border-[#43FFCD]/50 group-hover:border-[#43FFCD] flex items-center justify-center mb-2 transition-all duration-300 group-hover:bg-[#43FFCD]/10">
                <Plus
                  size={16}
                  color="#43FFCD"
                  className="opacity-60 group-hover:opacity-100 transition-opacity duration-300"
                />
              </div>
              <h3 className="g-semibold text-white/70 group-hover:text-white text-sm mb-1 transition-colors duration-300">
                {t("add_pos_terminal")}
              </h3>
              <p className="g-medium text-gray-400 text-xs">
                {t("place_new_pos")}
              </p>
            </div>
          </div>

          {posSystems
            .filter((pos: any) => pos.device_type === "pos")
            .map((pos: any) => (
              <div key={pos.id} className="modern-compact-card">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-full bg-gradient-to-br from-[#43FFCD]/20 to-[#2AB5A3]/20 flex items-center justify-center flex-shrink-0">
                      <MapPin size={18} color="#43FFCD" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <h4 className="g-semibold text-white text-base truncate">
                        {pos.name}
                      </h4>
                      <div className="flex items-center gap-2 mt-1">
                        <span
                          className={`compact-status-badge ${
                            pos.is_active === 1 || pos.is_active === true
                              ? "bg-green-500/20 border-green-500/30 text-green-400"
                              : "bg-red-500/20 border-red-500/30 text-red-400"
                          }`}
                        >
                          {pos.is_active === 1 || pos.is_active === true
                            ? t("active")
                            : t("inactive")}
                        </span>
                        {pos.position_x && pos.position_y && pos.position_z && (
                          <span className="compact-status-badge bg-blue-500/20 border-blue-500/30 text-blue-400">
                            {t("placed")}
                          </span>
                        )}
                      </div>
                    </div>
                  </div>
                  <div className="flex gap-2">
                    <button
                      onClick={() => {
                        setSelectedPOS({
                          ...pos,
                          type: "pos",
                          isActive:
                            pos.is_active === 1 || pos.is_active === true,
                        });
                        setIsCreatingPOS(false);
                        setShowPOSModal(true);
                      }}
                      className="modern-icon-button w-8 h-8 rounded-lg bg-white/10 hover:bg-white/20 flex items-center justify-center transition-all duration-200"
                    >
                      <Edit size={16} color="#43FFCD" />
                    </button>
                    <button
                      onClick={async () => {
                        try {
                          await fetchNui("deletePOS", { id: pos.id });
                        } catch (error) {
                          console.error("Failed to delete POS:", error);
                        }
                      }}
                      className="modern-icon-button-red w-8 h-8 rounded-lg bg-red-500/20 hover:bg-red-500/30 flex items-center justify-center transition-all duration-200"
                    >
                      <Trash2 size={16} color="#f87171" />
                    </button>
                  </div>
                </div>
              </div>
            ))}
        </div>
      </div>

      {/* Self Order Kiosks Section */}
      <div className="space-y-6">
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-[#43FFCD]/20 to-[#2AB5A3]/20 flex items-center justify-center">
            <Tv size={16} color="#43FFCD" />
          </div>
          <h3 className="g-semibold text-white text-xl">
            {t("self_order_kiosks")}
          </h3>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {/* Add New Kiosk Card */}
          <div
            onClick={() => {
              setIsCreatingPOS(true);
              setSelectedPOS({
                name: "",
                type: "kiosk",
                isActive: true,
              });
              setShowPOSModal(true);
            }}
            className="add-new-card group cursor-pointer"
          >
            <div className="flex flex-col items-center justify-center h-full min-h-[120px] text-center">
              <div className="w-10 h-10 rounded-full border-2 border-dashed border-[#43FFCD]/50 group-hover:border-[#43FFCD] flex items-center justify-center mb-2 transition-all duration-300 group-hover:bg-[#43FFCD]/10">
                <Plus
                  size={16}
                  color="#43FFCD"
                  className="opacity-60 group-hover:opacity-100 transition-opacity duration-300"
                />
              </div>
              <h3 className="g-semibold text-white/70 group-hover:text-white text-sm mb-1 transition-colors duration-300">
                {t("add_kiosk")}
              </h3>
              <p className="g-medium text-gray-400 text-xs">
                {t("place_new_kiosk")}
              </p>
            </div>
          </div>

          {posSystems
            .filter((kiosk: any) => kiosk.device_type === "kiosk")
            .map((kiosk: any) => (
              <div key={kiosk.id} className="modern-compact-card">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-full bg-gradient-to-br from-[#43FFCD]/20 to-[#2AB5A3]/20 flex items-center justify-center flex-shrink-0">
                      <Tv size={18} color="#43FFCD" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <h4 className="g-semibold text-white text-base truncate">
                        {kiosk.name}
                      </h4>
                      <div className="flex items-center gap-2 mt-1">
                        <span
                          className={`compact-status-badge ${
                            kiosk.is_active === 1 || kiosk.is_active === true
                              ? "bg-green-500/20 border-green-500/30 text-green-400"
                              : "bg-red-500/20 border-red-500/30 text-red-400"
                          }`}
                        >
                          {kiosk.is_active === 1 || kiosk.is_active === true
                            ? t("active")
                            : t("inactive")}
                        </span>
                        {kiosk.position_x &&
                          kiosk.position_y &&
                          kiosk.position_z && (
                            <span className="compact-status-badge bg-blue-500/20 border-blue-500/30 text-blue-400">
                              {t("placed")}
                            </span>
                          )}
                      </div>
                    </div>
                  </div>
                  <div className="flex gap-2">
                    <button
                      onClick={() => {
                        setSelectedPOS({
                          ...kiosk,
                          type: "kiosk",
                          isActive:
                            kiosk.is_active === 1 || kiosk.is_active === true,
                        });
                        setIsCreatingPOS(false);
                        setShowPOSModal(true);
                      }}
                      className="modern-icon-button w-8 h-8 rounded-lg bg-white/10 hover:bg-white/20 flex items-center justify-center transition-all duration-200"
                    >
                      <Edit size={16} color="#43FFCD" />
                    </button>
                    <button
                      onClick={async () => {
                        try {
                          await fetchNui("deletePOS", { id: kiosk.id });
                        } catch (error) {
                          console.error("Failed to delete POS:", error);
                        }
                      }}
                      className="modern-icon-button-red w-8 h-8 rounded-lg bg-red-500/20 hover:bg-red-500/30 flex items-center justify-center transition-all duration-200"
                    >
                      <Trash2 size={16} color="#f87171" />
                    </button>
                  </div>
                </div>
              </div>
            ))}
        </div>
      </div>
    </div>
  );

  const renderDisplay = () => {
    const availableTypes = getAvailableDisplayTypes();
    const allTypesUsed = availableTypes.length === 0;

    return (
      <div className="space-y-6">
        <div className="gray-800/30 border border-white/10 rounded-xl p-4">
          <div className="flex items-center gap-3 mb-3">
            <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-[#43FFCD]/20 to-[#2AB5A3]/20 flex items-center justify-center">
              <Monitor size={16} color="#43FFCD" />
            </div>
            <h3 className="g-semibold text-white text-base">
              {t("display_types_status")}
            </h3>
          </div>
          <div className="grid grid-cols-3 gap-3">
            {[
              { label: t("kitchen"), value: "kitchen" },
              { label: t("order_queue"), value: "order_queue" },
              { label: t("custom"), value: "custom" },
            ].map((type) => {
              const isUsed = !isDisplayTypeAvailable(type.value);
              const usedDisplay = tvDisplays.find(
                (tv) => (tv.display_type || tv.type) === type.value
              );

              return (
                <div
                  key={type.value}
                  className={`p-3 rounded-lg border ${
                    isUsed
                      ? "bg-green-500/10 border-green-500/30"
                      : "bg-gray-500/10 border-gray-500/30"
                  }`}
                >
                  <div className="flex items-center gap-2 mb-1">
                    <div
                      className={`w-2 h-2 rounded-full ${
                        isUsed ? "bg-green-400" : "bg-gray-400"
                      }`}
                    />
                    <span className="text-white text-sm g-medium">
                      {type.label}
                    </span>
                  </div>
                  <p className="text-xs text-gray-400">
                    {isUsed
                      ? `${t("used")}: ${usedDisplay?.name}`
                      : t("available")}
                  </p>
                </div>
              );
            })}
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {/* Add New Display Card */}
          <div
            onClick={() => {
              if (allTypesUsed) return;
              const firstAvailable = availableTypes[0];
              setNewTVData({
                name: "",
                type: firstAvailable?.value || "kitchen",
              });
              setShowNewTVModal(true);
            }}
            className={`add-new-card group ${
              allTypesUsed ? "opacity-50 cursor-not-allowed" : "cursor-pointer"
            }`}
          >
            <div className="flex flex-col items-center justify-center h-full min-h-[120px] text-center">
              <div
                className={`w-10 h-10 rounded-full border-2 border-dashed flex items-center justify-center mb-2 transition-all duration-300 ${
                  allTypesUsed
                    ? "border-gray-500/30"
                    : "border-[#43FFCD]/50 group-hover:border-[#43FFCD] group-hover:bg-[#43FFCD]/10"
                }`}
              >
                <Plus
                  size={16}
                  color={allTypesUsed ? "#6B7280" : "#43FFCD"}
                  className={`transition-opacity duration-300 ${
                    allTypesUsed
                      ? "opacity-50"
                      : "opacity-60 group-hover:opacity-100"
                  }`}
                />
              </div>
              <h3
                className={`g-semibold text-sm mb-1 transition-colors duration-300 ${
                  allTypesUsed
                    ? "text-gray-500"
                    : "text-white/70 group-hover:text-white"
                }`}
              >
                {allTypesUsed ? t("all_types_used") : t("place_display")}
              </h3>
              <p className="g-medium text-gray-400 text-xs">
                {allTypesUsed
                  ? t("delete_display_to_add_new")
                  : t("add_new_display")}
              </p>
            </div>
          </div>

          {tvDisplays.map((tv) => (
            <div key={tv.id} className="modern-compact-card">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-full bg-gradient-to-br from-[#43FFCD]/20 to-[#2AB5A3]/20 flex items-center justify-center flex-shrink-0">
                    <Monitor size={18} color="#43FFCD" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <h3 className="g-semibold text-white text-base truncate">
                      {tv.name}
                    </h3>
                    <div className="flex items-center gap-2 mt-1">
                      <span
                        className={`compact-status-badge ${
                          (tv.display_type || tv.type) === "kitchen"
                            ? "bg-green-500/20 border-green-500/30 text-green-400"
                            : (tv.display_type || tv.type) === "order_queue"
                            ? "bg-blue-500/20 border-blue-500/30 text-blue-400"
                            : "bg-purple-500/20 border-purple-500/30 text-purple-400"
                        }`}
                      >
                        {(tv.display_type || tv.type) === "kitchen"
                          ? t("kitchen")
                          : (tv.display_type || tv.type) === "order_queue"
                          ? t("order_queue")
                          : t("custom")}
                      </span>
                    </div>
                  </div>
                </div>
                <div className="flex gap-2">
                  <button
                    onClick={() => {
                      setSelectedTV(tv);
                      setShowTVModal(true);
                    }}
                    className="modern-icon-button w-8 h-8 rounded-lg bg-white/10 hover:bg-white/20 flex items-center justify-center transition-all duration-200"
                  >
                    <Edit size={16} color="#43FFCD" />
                  </button>
                  <button
                    onClick={async () => {
                      try {
                        await fetchNui("deleteTVDisplay", { id: tv.id });
                        setTvDisplays(tvDisplays.filter((t) => t.id !== tv.id));
                      } catch (error) {
                        console.error("Failed to delete TV display:", error);
                      }
                    }}
                    className="modern-icon-button-red w-8 h-8 rounded-lg bg-red-500/20 hover:bg-red-500/30 flex items-center justify-center transition-all duration-200"
                  >
                    <Trash2 size={16} color="#f87171" />
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    );
  };

  const renderFinance = () => (
    <div className="space-y-6">
      {/* Financial Overview Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        {/* Current Balance */}
        <div className="modern-card p-4">
          <div className="flex items-center justify-between mb-3">
            <div className="w-10 h-10 rounded-lg bg-gradient-to-br from-green-400/20 to-green-600/20 flex items-center justify-center">
              <Wallet size={20} color="#22c55e" />
            </div>
            <div className="text-green-400 text-xs font-medium">Available</div>
          </div>
          <div className="space-y-1">
            <h3 className="g-semibold text-white text-xl">
              ${financeData.currentBalance.toLocaleString()}
            </h3>
            <p className="g-medium text-gray-400 text-xs">
              {t("current_balance")}
            </p>
          </div>
        </div>

        {/* Total Revenue */}
        <div className="modern-card p-4">
          <div className="flex items-center justify-between mb-3">
            <div className="w-10 h-10 rounded-lg bg-gradient-to-br from-blue-400/20 to-blue-600/20 flex items-center justify-center">
              <ArrowUpRight size={20} color="#3b82f6" />
            </div>
            <div className="text-blue-400 text-xs font-medium">Income</div>
          </div>
          <div className="space-y-1">
            <h3 className="g-semibold text-white text-xl">
              ${financeData.totalRevenue.toLocaleString()}
            </h3>
            <p className="g-medium text-gray-400 text-xs">
              {t("total_revenue")}
            </p>
          </div>
        </div>

        {/* Total Expenses */}
        <div className="modern-card p-4">
          <div className="flex items-center justify-between mb-3">
            <div className="w-10 h-10 rounded-lg bg-gradient-to-br from-red-400/20 to-red-600/20 flex items-center justify-center">
              <ArrowDownRight size={20} color="#ef4444" />
            </div>
            <div className="text-red-400 text-xs font-medium">Expenses</div>
          </div>
          <div className="space-y-1">
            <h3 className="g-semibold text-white text-xl">
              ${financeData.totalExpenses.toLocaleString()}
            </h3>
            <p className="g-medium text-gray-400 text-xs">
              {t("total_expenses")}
            </p>
          </div>
        </div>

        {/* Pending Salaries */}
        <div className="modern-card p-4">
          <div className="flex items-center justify-between mb-3">
            <div className="w-10 h-10 rounded-lg bg-gradient-to-br from-yellow-400/20 to-orange-500/20 flex items-center justify-center">
              <CreditCard size={20} color="#f59e0b" />
            </div>
            <div className="text-yellow-400 text-xs font-medium">
              {t("pending")}
            </div>
          </div>
          <div className="space-y-1">
            <h3 className="g-semibold text-white text-xl">
              ${financeData.pendingSalaries.toLocaleString()}
            </h3>
            <p className="g-medium text-gray-400 text-xs">
              {t("pending_salaries")}
            </p>
          </div>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {/* Withdraw Money */}
        <div className="modern-card p-4">
          <div className="flex items-center gap-3 mb-4">
            <div className="w-10 h-10 rounded-lg bg-gradient-to-br from-red-400/20 to-red-600/20 flex items-center justify-center">
              <ArrowDownRight size={20} color="#ef4444" />
            </div>
            <div>
              <h3 className="g-semibold text-white text-lg">
                {t("withdraw_money")}
              </h3>
              <p className="g-medium text-gray-400 text-sm">
                {t("take_money_out")}
              </p>
            </div>
          </div>
          <button
            onClick={() => setShowWithdrawModal(true)}
            className="w-full bg-red-500/20 hover:bg-red-500/30 border border-red-500/30 hover:border-red-500/50 text-red-400 py-2 rounded-lg font-medium transition-all duration-200"
          >
            {t("withdraw_funds")}
          </button>
        </div>

        {/* Deposit Money */}
        <div className="modern-card p-4">
          <div className="flex items-center gap-3 mb-4">
            <div className="w-10 h-10 rounded-lg bg-gradient-to-br from-green-400/20 to-green-600/20 flex items-center justify-center">
              <ArrowUpRight size={20} color="#22c55e" />
            </div>
            <div>
              <h3 className="g-semibold text-white text-lg">
                {t("deposit_money")}
              </h3>
              <p className="g-medium text-gray-400 text-sm">
                {t("add_money_to_restaurant")}
              </p>
            </div>
          </div>
          <button
            onClick={() => setShowDepositModal(true)}
            className="w-full bg-green-500/20 hover:bg-green-500/30 border border-green-500/30 hover:border-green-500/50 text-green-400 py-2 rounded-lg font-medium transition-all duration-200"
          >
            {t("deposit_funds")}
          </button>
        </div>

        {/* Pay Salaries */}
        <div className="modern-card p-4">
          <div className="flex items-center gap-3 mb-4">
            <div className="w-10 h-10 rounded-lg bg-gradient-to-br from-blue-400/20 to-blue-600/20 flex items-center justify-center">
              <CreditCard size={20} color="#3b82f6" />
            </div>
            <div>
              <h3 className="g-semibold text-white text-lg">
                {t("pay_salaries")}
              </h3>
              <p className="g-medium text-gray-400 text-sm">
                {t("pay_all_employee_salaries")}
              </p>
            </div>
          </div>
          <button
            onClick={() => setShowPaySalaryModal(true)}
            className="w-full bg-blue-500/20 hover:bg-blue-500/30 border border-blue-500/30 hover:border-blue-500/50 text-blue-400 py-2 rounded-lg font-medium transition-all duration-200"
          >
            {t("pay_all_salaries")}
          </button>
        </div>
      </div>

      {/* Recent Transactions */}
      <div className="modern-card p-4">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-3">
            <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-[#43FFCD]/20 to-[#2AB5A3]/20 flex items-center justify-center">
              <Receipt size={16} color="#43FFCD" />
            </div>
            <h3 className="g-semibold text-white text-lg">
              {t("recent_transactions")}
            </h3>
          </div>
        </div>

        <div className="space-y-3">
          {financeData.recentTransactions.length > 0 ? (
            financeData.recentTransactions.map(
              (transaction: any, index: number) => (
                <div
                  key={index}
                  className="flex items-center justify-between p-3 rounded-lg bg-white/5 border border-white/10"
                >
                  <div className="flex items-center gap-3">
                    <div
                      className={`w-8 h-8 rounded-lg flex items-center justify-center ${
                        transaction.type === "income"
                          ? "bg-green-500/20"
                          : transaction.type === "expense"
                          ? "bg-red-500/20"
                          : "bg-blue-500/20"
                      }`}
                    >
                      {transaction.type === "income" ? (
                        <ArrowUpRight size={16} color="#22c55e" />
                      ) : transaction.type === "expense" ? (
                        <ArrowDownRight size={16} color="#ef4444" />
                      ) : (
                        <CreditCard size={16} color="#3b82f6" />
                      )}
                    </div>
                    <div>
                      <h4 className="g-semibold text-white text-sm">
                        {transaction.description}
                      </h4>
                      <p className="g-medium text-gray-400 text-xs">
                        {transaction.date}
                      </p>
                    </div>
                  </div>
                  <div className="text-right">
                    <div
                      className={`g-semibold text-sm ${
                        transaction.type === "income"
                          ? "text-green-400"
                          : transaction.type === "expense"
                          ? "text-red-400"
                          : "text-blue-400"
                      }`}
                    >
                      {transaction.type === "income"
                        ? "+"
                        : transaction.type === "expense"
                        ? "-"
                        : ""}
                      ${transaction.amount.toLocaleString()}
                    </div>
                  </div>
                </div>
              )
            )
          ) : (
            <div className="text-center py-8">
              <div className="w-16 h-16 mx-auto mb-3 rounded-full bg-gray-500/20 flex items-center justify-center">
                <Receipt size={24} color="#6b7280" />
              </div>
              <p className="text-gray-400 text-sm">
                {t("no_recent_transactions")}
              </p>
            </div>
          )}
        </div>
      </div>

      {/* Employee Salaries */}
      <div className="modern-card p-4">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-3">
            <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-[#43FFCD]/20 to-[#2AB5A3]/20 flex items-center justify-center">
              <Users size={16} color="#43FFCD" />
            </div>
            <h3 className="g-semibold text-white text-lg">
              {t("employee_salaries")}
            </h3>
          </div>
        </div>

        <div className="space-y-3">
          {employees.map((employee) => (
            <div
              key={employee.id}
              className="flex items-center justify-between p-3 rounded-lg bg-white/5 border border-white/10"
            >
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-blue-400/20 to-blue-600/20 flex items-center justify-center">
                  <Users size={16} color="#3b82f6" />
                </div>
                <div>
                  <h4 className="g-semibold text-white text-sm">
                    {employee.name}
                  </h4>
                  <p className="g-medium text-gray-400 text-xs">
                    {employee.position}
                  </p>
                </div>
              </div>
              <div className="text-right">
                <div className="g-semibold text-blue-400 text-sm">
                  ${employee.salary.toLocaleString()}
                </div>
                <button
                  onClick={() => {
                    setSelectedEmployeeForPayment(employee);
                    setShowPaySalaryModal(true);
                  }}
                  className="text-xs text-blue-400 hover:text-blue-300 transition-colors duration-200"
                >
                  {t("pay_now")}
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );

  const renderTVModal = () => {
    if (!showTVModal || !selectedTV) return null;

    return (
      <div
        className="modern-modal-overlay"
        onClick={() => setShowTVModal(false)}
      >
        <div
          className="modern-modal-content"
          onClick={(e) => e.stopPropagation()}
        >
          <div className="modern-modal-header">
            <h3 className="modern-modal-title">
              <Tv size={24} color="#43FFCD" />
              {t("manage_display")}
            </h3>
            <button
              onClick={() => setShowTVModal(false)}
              className="modern-modal-close"
            >
              ×
            </button>
          </div>

          <div className="space-y-6">
            <div className="modern-modal-section">
              <div className="modern-modal-section-title">
                <Monitor size={16} color="#43FFCD" />
                Display Settings
              </div>
              <CreateInput
                placeholder={t("display_name")}
                value={selectedTV.name}
                icon={TVIcon}
                onChange={(e) =>
                  setSelectedTV({ ...selectedTV, name: e.target.value })
                }
              />
            </div>

            <div className="modern-modal-section">
              <div className="modern-modal-section-title">
                <FileText size={16} color="#43FFCD" />
                {t("display_type")}
              </div>
              {(() => {
                const currentType = selectedTV.display_type || selectedTV.type;
                const allTypes = [
                  { label: t("kitchen"), value: "kitchen" },
                  { label: t("order_queue"), value: "order_queue" },
                  { label: t("custom"), value: "custom" },
                ];

                // Get available types (excluding current TV from the check)
                const usedTypes = tvDisplays
                  .filter((tv) => tv.id !== selectedTV.id)
                  .map((tv) => tv.display_type || tv.type)
                  .filter(Boolean);

                const availableTypes = allTypes.filter(
                  (type) =>
                    type.value === currentType ||
                    !usedTypes.includes(type.value)
                );

                if (
                  availableTypes.length === 1 &&
                  availableTypes[0].value === currentType
                ) {
                  return (
                    <div className="space-y-2">
                      <div className="p-3 bg-blue-500/10 border border-blue-500/30 rounded-lg">
                        <p className="text-blue-400 text-sm">
                          {t("current_type")}:{" "}
                          <span className="font-semibold">
                            {availableTypes[0].label}
                          </span>
                        </p>
                        <p className="text-gray-400 text-xs mt-1">
                          {t("other_display_types_in_use")}
                        </p>
                      </div>
                      <ToggleSelect
                        options={[availableTypes[0].label]}
                        active={availableTypes[0].label}
                        setActive={() => {}} // Disabled
                        colorScheme="default"
                      />
                    </div>
                  );
                }

                return (
                  <ToggleSelect
                    options={availableTypes.map((t) => t.label)}
                    active={
                      availableTypes.find((t) => t.value === currentType)
                        ?.label || availableTypes[0].label
                    }
                    setActive={(active) => {
                      const selectedType = availableTypes.find(
                        (t) => t.label === active
                      );
                      if (selectedType) {
                        setSelectedTV({
                          ...selectedTV,
                          type: selectedType.value,
                          display_type: selectedType.value,
                        });
                      }
                    }}
                    colorScheme="default"
                  />
                );
              })()}
            </div>

            {(selectedTV.display_type === "custom" ||
              selectedTV.type === "custom") && (
              <div className="modern-modal-section">
                <div className="modern-modal-section-title">
                  <Image size={16} color="#43FFCD" />
                  {t("custom_content")}
                </div>

                <div className="space-y-4">
                  <div>
                    <label className="text-sm text-gray-300 mb-2 block">
                      {t("content_type")}
                    </label>
                    <ToggleSelect
                      options={[t("youtube"), t("image"), t("gif")]}
                      active={(() => {
                        const customContent =
                          selectedTV.customContent || selectedTV.custom_content;
                        if (customContent && customContent.type) {
                          return customContent.type === "youtube"
                            ? t("youtube")
                            : customContent.type === "image"
                            ? t("image")
                            : t("gif");
                        }
                        return t("image");
                      })()}
                      setActive={(active) => {
                        const type =
                          active === t("youtube")
                            ? "youtube"
                            : active === t("image")
                            ? "image"
                            : "gif";
                        setSelectedTV({
                          ...selectedTV,
                          customContent: {
                            type: type,
                            url:
                              selectedTV.customContent?.url ||
                              selectedTV.custom_content?.url ||
                              "",
                          },
                        });
                      }}
                      colorScheme="default"
                    />
                  </div>

                  <CreateInput
                    placeholder={(() => {
                      const customContent =
                        selectedTV.customContent || selectedTV.custom_content;
                      const type = customContent?.type || "image";
                      return type === "youtube"
                        ? t("youtube_video_url")
                        : type === "image"
                        ? t("image_url")
                        : t("gif_url");
                    })()}
                    value={
                      selectedTV.customContent?.url ||
                      selectedTV.custom_content?.url ||
                      ""
                    }
                    icon={ImageIcon}
                    onChange={(e) => {
                      const customContent = selectedTV.customContent ||
                        selectedTV.custom_content || { type: "image" };
                      setSelectedTV({
                        ...selectedTV,
                        customContent: {
                          ...customContent,
                          url: e.target.value,
                        },
                      });
                    }}
                  />
                </div>
              </div>
            )}

            <div className="modern-modal-actions">
              <Button
                label={t("save_changes")}
                onClick={async () => {
                  try {
                    await fetchNui("updateTVDisplay", {
                      id: selectedTV.id,
                      tvData: {
                        ...selectedTV,
                        isActive: true, // Ensure it's marked as active
                        type: selectedTV.type || selectedTV.display_type,
                        display_type:
                          selectedTV.type || selectedTV.display_type,
                      },
                    });
                    setTvDisplays(
                      tvDisplays.map((tv) =>
                        tv.id === selectedTV.id ? selectedTV : tv
                      )
                    );
                    setShowTVModal(false);
                  } catch (error) {
                    console.error("Failed to update TV display:", error);
                  }
                }}
                className="flex-1"
              />
            </div>
          </div>
        </div>
      </div>
    );
  };

  const renderNewTVModal = () => {
    if (!showNewTVModal) return null;

    return (
      <div
        className="modern-modal-overlay"
        onClick={() => setShowNewTVModal(false)}
      >
        <div
          className="modern-modal-content"
          onClick={(e) => e.stopPropagation()}
        >
          <div className="modern-modal-header">
            <h3 className="modern-modal-title">
              <Plus size={24} color="#43FFCD" />
              {t("new_display")}
            </h3>
            <button
              onClick={() => setShowNewTVModal(false)}
              className="modern-modal-close"
            >
              ×
            </button>
          </div>

          <div className="space-y-6">
            <div className="modern-modal-section">
              <div className="modern-modal-section-title">
                <Monitor size={16} color="#43FFCD" />
                Display Settings
              </div>
              <CreateInput
                placeholder={t("display_name")}
                value={newTVData.name}
                icon={TVIcon}
                onChange={(e) =>
                  setNewTVData({ ...newTVData, name: e.target.value })
                }
              />
            </div>

            <div className="modern-modal-section">
              <div className="modern-modal-section-title">
                <FileText size={16} color="#43FFCD" />
                Display Type
              </div>
              {(() => {
                const availableTypes = getAvailableDisplayTypes();
                const currentTypeAvailable = availableTypes.some(
                  (t) => t.value === newTVData.type
                );

                // If current type is not available, reset to first available
                if (!currentTypeAvailable && availableTypes.length > 0) {
                  setNewTVData({
                    ...newTVData,
                    type: availableTypes[0].value,
                    display_type: availableTypes[0].value,
                  });
                }

                if (availableTypes.length === 0) {
                  return (
                    <div className="p-4 bg-red-500/10 border border-red-500/30 rounded-lg">
                      <p className="text-red-400 text-sm">
                        {t("all_display_types_in_use")}
                      </p>
                    </div>
                  );
                }

                return (
                  <ToggleSelect
                    options={availableTypes.map((t) => t.label)}
                    active={
                      availableTypes.find((t) => t.value === newTVData.type)
                        ?.label || availableTypes[0].label
                    }
                    setActive={(active) => {
                      const selectedType = availableTypes.find(
                        (t) => t.label === active
                      );
                      if (selectedType) {
                        setNewTVData({
                          ...newTVData,
                          type: selectedType.value,
                          display_type: selectedType.value,
                        });
                      }
                    }}
                    colorScheme="default"
                  />
                );
              })()}
            </div>

            {newTVData.type === "custom" && (
              <div className="modern-modal-section">
                <div className="modern-modal-section-title">
                  <Image size={16} color="#43FFCD" />
                  Custom Content
                </div>

                <div className="space-y-4">
                  <div>
                    <label className="text-sm text-gray-300 mb-2 block">
                      {t("content_type")}
                    </label>
                    <ToggleSelect
                      options={[t("youtube"), t("image"), t("gif")]}
                      active={(() => {
                        const type = newTVData.customContent?.type || "image";
                        return type === "youtube"
                          ? t("youtube")
                          : type === "image"
                          ? t("image")
                          : t("gif");
                      })()}
                      setActive={(active) => {
                        const type =
                          active === t("youtube")
                            ? "youtube"
                            : active === t("image")
                            ? "image"
                            : "gif";
                        setNewTVData({
                          ...newTVData,
                          customContent: {
                            type: type,
                            url: newTVData.customContent?.url || "",
                          },
                        });
                      }}
                      colorScheme="default"
                    />
                  </div>

                  <CreateInput
                    placeholder={(() => {
                      const type = newTVData.customContent?.type || "image";
                      return type === "youtube"
                        ? "YouTube Video URL"
                        : type === "image"
                        ? "Image URL"
                        : "GIF URL";
                    })()}
                    value={newTVData.customContent?.url || ""}
                    icon={ImageIcon}
                    onChange={(e) => {
                      const customContent = newTVData.customContent || {
                        type: "image",
                      };
                      setNewTVData({
                        ...newTVData,
                        customContent: {
                          ...customContent,
                          url: e.target.value,
                        },
                      });
                    }}
                  />
                </div>
              </div>
            )}

            <div className="modern-modal-actions">
              <Button
                label={t("start_placement")}
                onClick={async () => {
                  if (!newTVData.name.trim()) {
                    alert("Please enter a display name");
                    return;
                  }

                  const availableTypes = getAvailableDisplayTypes();
                  if (availableTypes.length === 0) {
                    alert(
                      "No display types available. Delete an existing display first."
                    );
                    return;
                  }

                  try {
                    setShowNewTVModal(false);
                    await fetchNui("placeTVDisplay", { tvData: newTVData });
                  } catch (error) {
                    console.error("Failed to start TV placement:", error);
                  }
                }}
                className="flex-1"
                style={{
                  opacity: !newTVData.name.trim() ? 0.5 : 1,
                }}
              />
            </div>
          </div>
        </div>
      </div>
    );
  };

  const addIngredient = () => {
    if (isCreatingRecipe) {
      setNewRecipe({
        ...newRecipe,
        ingredients: [...newRecipe.ingredients, ""],
      });
    } else {
      setSelectedRecipe({
        ...selectedRecipe,
        ingredients: [...selectedRecipe.ingredients, ""],
      });
    }
  };

  const updateIngredient = (index: number, value: string) => {
    if (isCreatingRecipe) {
      const updatedIngredients = [...newRecipe.ingredients];
      updatedIngredients[index] = value;
      setNewRecipe({ ...newRecipe, ingredients: updatedIngredients });
    } else {
      const updatedIngredients = [...selectedRecipe.ingredients];
      updatedIngredients[index] = value;
      setSelectedRecipe({ ...selectedRecipe, ingredients: updatedIngredients });
    }
  };

  const removeIngredient = (index: number) => {
    if (isCreatingRecipe) {
      const updatedIngredients = newRecipe.ingredients.filter(
        (_, i) => i !== index
      );
      setNewRecipe({ ...newRecipe, ingredients: updatedIngredients });
    } else {
      const updatedIngredients = selectedRecipe.ingredients.filter(
        (_, i) => i !== index
      );
      setSelectedRecipe({ ...selectedRecipe, ingredients: updatedIngredients });
    }
  };

  // Instruction management
  const addInstruction = () => {
    if (isCreatingRecipe) {
      setNewRecipe({
        ...newRecipe,
        instructions: [...newRecipe.instructions, ""],
      });
    } else {
      setSelectedRecipe({
        ...selectedRecipe,
        instructions: [...selectedRecipe.instructions, ""],
      });
    }
  };

  const updateInstruction = (index: number, value: string) => {
    if (isCreatingRecipe) {
      const updatedInstructions = [...newRecipe.instructions];
      updatedInstructions[index] = value;
      setNewRecipe({ ...newRecipe, instructions: updatedInstructions });
    } else {
      const updatedInstructions = [...selectedRecipe.instructions];
      updatedInstructions[index] = value;
      setSelectedRecipe({
        ...selectedRecipe,
        instructions: updatedInstructions,
      });
    }
  };

  const removeInstruction = (index: number) => {
    if (isCreatingRecipe) {
      const updatedInstructions = newRecipe.instructions.filter(
        (_, i) => i !== index
      );
      setNewRecipe({ ...newRecipe, instructions: updatedInstructions });
    } else {
      const updatedInstructions = selectedRecipe.instructions.filter(
        (_, i) => i !== index
      );
      setSelectedRecipe({
        ...selectedRecipe,
        instructions: updatedInstructions,
      });
    }
  };

  // Tips management
  const addTip = () => {
    if (isCreatingRecipe) {
      setNewRecipe({ ...newRecipe, tips: [...newRecipe.tips, ""] });
    } else {
      setSelectedRecipe({
        ...selectedRecipe,
        tips: [...selectedRecipe.tips, ""],
      });
    }
  };

  const updateTip = (index: number, value: string) => {
    if (isCreatingRecipe) {
      const updatedTips = [...newRecipe.tips];
      updatedTips[index] = value;
      setNewRecipe({ ...newRecipe, tips: updatedTips });
    } else {
      const updatedTips = [...selectedRecipe.tips];
      updatedTips[index] = value;
      setSelectedRecipe({ ...selectedRecipe, tips: updatedTips });
    }
  };

  const removeTip = (index: number) => {
    if (isCreatingRecipe) {
      const updatedTips = newRecipe.tips.filter((_, i) => i !== index);
      setNewRecipe({ ...newRecipe, tips: updatedTips });
    } else {
      const updatedTips = selectedRecipe.tips.filter((_, i) => i !== index);
      setSelectedRecipe({ ...selectedRecipe, tips: updatedTips });
    }
  };

  // Notes management
  const addNote = () => {
    if (isCreatingRecipe) {
      setNewRecipe({ ...newRecipe, notes: [...newRecipe.notes, ""] });
    } else {
      setSelectedRecipe({
        ...selectedRecipe,
        notes: [...selectedRecipe.notes, ""],
      });
    }
  };

  const updateNote = (index: number, value: string) => {
    if (isCreatingRecipe) {
      const updatedNotes = [...newRecipe.notes];
      updatedNotes[index] = value;
      setNewRecipe({ ...newRecipe, notes: updatedNotes });
    } else {
      const updatedNotes = [...selectedRecipe.notes];
      updatedNotes[index] = value;
      setSelectedRecipe({ ...selectedRecipe, notes: updatedNotes });
    }
  };

  const removeNote = (index: number) => {
    if (isCreatingRecipe) {
      const updatedNotes = newRecipe.notes.filter((_, i) => i !== index);
      setNewRecipe({ ...newRecipe, notes: updatedNotes });
    } else {
      const updatedNotes = selectedRecipe.notes.filter((_, i) => i !== index);
      setSelectedRecipe({ ...selectedRecipe, notes: updatedNotes });
    }
  };

  const saveRecipe = async () => {
    try {
      if (isCreatingRecipe) {
        await fetchNui("addRecipe", {
          ...newRecipe,
          ingredients: newRecipe.ingredients.filter((ing) => ing.trim() !== ""),
          instructions: newRecipe.instructions.filter(
            (inst) => inst.trim() !== ""
          ),
          tips: newRecipe.tips.filter((tip) => tip.trim() !== ""),
          notes: newRecipe.notes.filter((note) => note.trim() !== ""),
          isDrink: newRecipe.isDrink,
        });
      } else {
        // Map frontend fields to database fields for editing
        await fetchNui("updateRecipe", {
          id: selectedRecipe.id,
          name: selectedRecipe.name,
          description: selectedRecipe.description,
          ingredients: selectedRecipe.ingredients,
          output: selectedRecipe.output_item,
          cookTime: selectedRecipe.cook_time,
          difficulty: selectedRecipe.difficulty,
          image: selectedRecipe.image_url,
          instructions: selectedRecipe.instructions || [],
          tips: selectedRecipe.tips || [],
          notes: selectedRecipe.notes || [],
          isDrink: selectedRecipe.is_drink || false,
        });
      }

      setShowRecipeModal(false);
      setNewRecipe({
        name: "",
        ingredients: [""],
        output: "",
        cookTime: 0,
        difficulty: t("easy"),
        description: "",
        image: "",
        instructions: [""],
        tips: [""],
        notes: [""],
        isDrink: false,
      });
      setSelectedRecipe(null);
      setIsCreatingRecipe(false);
    } catch (error) {
      console.error("Failed to save recipe:", error);
    }
  };

  const saveCategory = async () => {
    try {
      if (isEditingCategory) {
        // Update existing category
        await fetchNui("updateCategory", {
          id: selectedCategory.id,
          name: newCategory.name,
          description: newCategory.description,
          items: newCategory.items,
          restaurant_id: restaurantData?.id,
        });
      } else {
        // Create new category
        await fetchNui("addCategory", {
          name: newCategory.name,
          description: newCategory.description,
          items: newCategory.items,
        });
      }
      setShowCategoryModal(false);
      setNewCategory({ name: "", description: "", items: [] });
      setSelectedCategory(null);
      setIsEditingCategory(false);
    } catch (error) {
      console.error("Failed to save category:", error);
    }
  };

  // Employee Management Modal
  const renderEmployeeModal = () => {
    if (!showEmployeeModal || !selectedEmployee) return null;

    return (
      <div
        className="modern-modal-overlay"
        onClick={() => setShowEmployeeModal(false)}
      >
        <div
          className="modern-modal-content"
          onClick={(e) => e.stopPropagation()}
        >
          <div className="modern-modal-header">
            <h3 className="modern-modal-title">
              <Users size={24} color="#43FFCD" />
              {t("manage_employee")}
            </h3>
            <button
              onClick={() => setShowEmployeeModal(false)}
              className="modern-modal-close"
            >
              ×
            </button>
          </div>

          <div className="space-y-6">
            <div className="modern-modal-section">
              <div className="modern-modal-section-title">
                <Users size={16} color="#43FFCD" />
                {t("personal_information")}
              </div>
              <div className="space-y-4">
                <CreateInput
                  placeholder={t("employee_name")}
                  value={selectedEmployee.name}
                  icon={NameIcon}
                  onChange={(e) =>
                    setSelectedEmployee({
                      ...selectedEmployee,
                      name: e.target.value,
                    })
                  }
                />

                <CreateInput
                  placeholder={t("position")}
                  value={selectedEmployee.position}
                  icon={ChefIcon}
                  onChange={(e) =>
                    setSelectedEmployee({
                      ...selectedEmployee,
                      position: e.target.value,
                    })
                  }
                />
              </div>
            </div>

            <div className="modern-modal-section">
              <div className="modern-modal-section-title">
                <DollarSign size={16} color="#43FFCD" />
                {t("employment_details")}
              </div>
              <div className="grid grid-cols-2 gap-4">
                <CreateInput
                  placeholder={t("salary")}
                  value={selectedEmployee.salary.toString()}
                  icon={MoneyIcon}
                  onChange={(e) =>
                    setSelectedEmployee({
                      ...selectedEmployee,
                      salary: Number.parseInt(e.target.value) || 0,
                    })
                  }
                />

                <CreateInput
                  placeholder={t("performance_percent")}
                  value={selectedEmployee.performance.toString()}
                  icon={InfoIcon}
                  onChange={(e) =>
                    setSelectedEmployee({
                      ...selectedEmployee,
                      performance: Math.min(
                        100,
                        Math.max(0, Number.parseInt(e.target.value) || 0)
                      ),
                    })
                  }
                />
              </div>

              <div className="mt-4 p-4 rounded-lg bg-white/5 border border-white/10">
                <div className="flex items-center justify-between mb-2">
                  <span className="text-sm text-gray-400">
                    {t("current_performance")}
                  </span>
                  <span className="text-sm text-[#43FFCD] font-semibold">
                    {selectedEmployee.performance}%
                  </span>
                </div>
                <PerformanceDots percentage={selectedEmployee.performance} />
              </div>
            </div>

            <div className="modern-modal-section">
              <div className="modern-modal-section-title">
                <Shield size={16} color="#43FFCD" />
                {t("employee_roles")}
              </div>
              <div className="space-y-3">
                <label className="flex items-center gap-3 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={selectedEmployee.isBoss || false}
                    onChange={(e) =>
                      setSelectedEmployee({
                        ...selectedEmployee,
                        isBoss: e.target.checked,
                      })
                    }
                    className="modern-checkbox"
                  />
                  <span className="text-white text-sm">
                    {t("boss_full_access")}
                  </span>
                </label>
                <label className="flex items-center gap-3 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={selectedEmployee.isManager || false}
                    onChange={(e) =>
                      setSelectedEmployee({
                        ...selectedEmployee,
                        isManager: e.target.checked,
                      })
                    }
                    className="modern-checkbox"
                  />
                  <span className="text-white text-sm">
                    {t("manager_management_access")}
                  </span>
                </label>
              </div>
            </div>

            <div className="modern-modal-actions">
              <Button
                label={t("save_changes")}
                onClick={async () => {
                  try {
                    await fetchNui("updateEmployee", {
                      id: selectedEmployee.id,
                      ...selectedEmployee,
                    });
                    setEmployees(
                      employees.map((emp) =>
                        emp.id === selectedEmployee.id ? selectedEmployee : emp
                      )
                    );
                    setShowEmployeeModal(false);
                  } catch (error) {
                    console.error("Failed to update employee:", error);
                  }
                }}
                className="flex-1"
              />
            </div>
          </div>
        </div>
      </div>
    );
  };

  // Recipe Management Modal
  const renderRecipeModal = () => {
    if (!showRecipeModal) return null;

    const currentRecipe = isCreatingRecipe ? newRecipe : selectedRecipe;

    // Ensure all fields have default values to prevent undefined errors
    const safeRecipe = {
      name: currentRecipe?.name || "",
      output: currentRecipe?.output_item || currentRecipe?.output || "",
      cookTime: currentRecipe?.cook_time || currentRecipe?.cookTime || 0,
      difficulty: currentRecipe?.difficulty || t("easy"),
      description: currentRecipe?.description || "",
      image: currentRecipe?.image_url || currentRecipe?.image || "",
      ingredients: currentRecipe?.ingredients || [""],
      instructions: currentRecipe?.instructions || [""],
      tips: currentRecipe?.tips || [""],
      notes: currentRecipe?.notes || [""],
      isDrink: currentRecipe?.is_drink || currentRecipe?.isDrink || false,
    };

    return (
      <div
        className="modern-modal-overlay"
        onClick={() => setShowRecipeModal(false)}
      >
        <div
          className="modern-modal-content large"
          onClick={(e) => e.stopPropagation()}
        >
          <div className="modern-modal-header">
            <h3 className="modern-modal-title">
              <ChefHat size={24} color="#43FFCD" />
              {isCreatingRecipe ? t("create_recipe") : t("edit_recipe")}
            </h3>
            <button
              onClick={() => setShowRecipeModal(false)}
              className="modern-modal-close"
            >
              ×
            </button>
          </div>

          <div className="space-y-6">
            <div className="modern-modal-section">
              <div className="modern-modal-section-title">
                <FileText size={16} color="#43FFCD" />
                {t("basic_information")}
              </div>
              <div className="space-y-4">
                <CreateInput
                  placeholder={t("recipe_name")}
                  value={safeRecipe.name}
                  icon={NameIcon}
                  onChange={(e) => {
                    if (isCreatingRecipe) {
                      setNewRecipe({ ...newRecipe, name: e.target.value });
                    } else {
                      setSelectedRecipe({
                        ...selectedRecipe,
                        name: e.target.value,
                      });
                    }
                  }}
                />
                <div className="grid grid-cols-2 gap-4">
                  <Select
                    options={outputItems}
                    value={
                      outputItems.find(
                        (item) => item.value === safeRecipe.output
                      ) || null
                    }
                    onChange={(selected) => {
                      if (isCreatingRecipe) {
                        setNewRecipe({
                          ...newRecipe,
                          output: selected?.value || "",
                        });
                      } else {
                        setSelectedRecipe({
                          ...selectedRecipe,
                          output_item: selected?.value || "",
                        });
                      }
                    }}
                    placeholder={t("select_output_item")}
                    styles={customSelectStyles}
                  />
                  <CreateInput
                    placeholder={t("cook_time_minutes")}
                    value={safeRecipe.cookTime.toString()}
                    icon={ClockIcon}
                    onChange={(e) => {
                      if (isCreatingRecipe) {
                        setNewRecipe({
                          ...newRecipe,
                          cookTime: Number.parseInt(e.target.value) || 0,
                        });
                      } else {
                        setSelectedRecipe({
                          ...selectedRecipe,
                          cook_time: Number.parseInt(e.target.value) || 0,
                        });
                      }
                    }}
                  />
                </div>
                <CreateInput
                  placeholder={t("display_image_url")}
                  value={safeRecipe.image}
                  icon={ImageIcon}
                  onChange={(e) => {
                    if (isCreatingRecipe) {
                      setNewRecipe({ ...newRecipe, image: e.target.value });
                    } else {
                      setSelectedRecipe({
                        ...selectedRecipe,
                        image_url: e.target.value,
                      });
                    }
                  }}
                />
              </div>
            </div>

            <div className="modern-modal-section">
              <div className="modern-modal-section-title">
                <Clock size={16} color="#43FFCD" />
                {t("recipe_details")}
              </div>
              <div className="space-y-4">
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-300 mb-2">
                      {t("difficulty_level")}
                    </label>
                    <ToggleSelect
                      options={[t("easy"), t("medium"), t("hard")]}
                      active={safeRecipe.difficulty}
                      setActive={(active) => {
                        if (isCreatingRecipe) {
                          setNewRecipe({ ...newRecipe, difficulty: active });
                        } else {
                          setSelectedRecipe({
                            ...selectedRecipe,
                            difficulty: active,
                          });
                        }
                      }}
                      colorScheme="difficulty"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-300 mb-2">
                      {t("recipe_type")}
                    </label>
                    <ToggleSelect
                      options={[t("food"), t("drink")]}
                      active={safeRecipe.isDrink ? t("drink") : t("food")}
                      setActive={(active) => {
                        const isDrink = active === t("drink");
                        if (isCreatingRecipe) {
                          setNewRecipe({ ...newRecipe, isDrink: isDrink });
                        } else {
                          setSelectedRecipe({
                            ...selectedRecipe,
                            is_drink: isDrink,
                          });
                        }
                      }}
                      colorScheme="default"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-300 mb-2">
                    {t("description")}
                  </label>
                  <textarea
                    placeholder={t("describe_your_recipe")}
                    value={safeRecipe.description}
                    onChange={(e) => {
                      if (isCreatingRecipe) {
                        setNewRecipe({
                          ...newRecipe,
                          description: e.target.value,
                        });
                      } else {
                        setSelectedRecipe({
                          ...selectedRecipe,
                          description: e.target.value,
                        });
                      }
                    }}
                    className="modern-modal-textarea"
                    rows={3}
                  />
                </div>
              </div>
            </div>

            <div className="modern-modal-section">
              <div className="modern-modal-section-title">
                <Package size={16} color="#43FFCD" />
                {t("ingredients")} ({safeRecipe.ingredients.length})
              </div>
              <div className="space-y-3">
                <button
                  onClick={addIngredient}
                  className="w-full p-3 border-2 border-dashed border-[#43FFCD]/30 rounded-lg bg-[#43FFCD]/5 hover:bg-[#43FFCD]/10 hover:border-[#43FFCD]/50 transition-all duration-200 flex items-center justify-center gap-2 text-[#43FFCD]"
                >
                  <Plus size={16} />
                  <span className="font-medium">{t("add_ingredient")}</span>
                </button>

                {safeRecipe.ingredients.map(
                  (ingredient: string, index: number) => (
                    <div key={index} className="flex gap-3 items-center">
                      <div className="flex-1">
                        <Select
                          options={inputItems}
                          value={
                            inputItems.find(
                              (ing) => ing.value === ingredient
                            ) || null
                          }
                          onChange={(selected) => {
                            if (isCreatingRecipe) {
                              updateIngredient(index, selected?.value || "");
                            } else {
                              const updatedIngredients = [
                                ...selectedRecipe.ingredients,
                              ];
                              updatedIngredients[index] = selected?.value || "";
                              setSelectedRecipe({
                                ...selectedRecipe,
                                ingredients: updatedIngredients,
                              });
                            }
                          }}
                          placeholder={t("select_ingredient", {
                            number: index + 1,
                          })}
                          styles={customSelectStyles}
                        />
                      </div>
                      <button
                        onClick={() => {
                          if (isCreatingRecipe) {
                            removeIngredient(index);
                          } else {
                            const updatedIngredients =
                              selectedRecipe.ingredients.filter(
                                (_: any, i: number) => i !== index
                              );
                            setSelectedRecipe({
                              ...selectedRecipe,
                              ingredients: updatedIngredients,
                            });
                          }
                        }}
                        className="w-10 h-10 rounded-lg bg-red-500/20 hover:bg-red-500/30 flex items-center justify-center transition-all duration-200"
                      >
                        <Trash2 size={14} color="#f87171" />
                      </button>
                    </div>
                  )
                )}
              </div>
            </div>

            {/* Instructions Section */}
            <div className="modern-modal-section">
              <div className="modern-modal-section-title">
                <ListOrdered size={16} color="#43FFCD" />
                {t("cooking_instructions")} ({safeRecipe.instructions.length})
              </div>
              <div className="space-y-3">
                <button
                  onClick={addInstruction}
                  className="w-full p-3 border-2 border-dashed border-[#43FFCD]/30 rounded-lg bg-[#43FFCD]/5 hover:bg-[#43FFCD]/10 hover:border-[#43FFCD]/50 transition-all duration-200 flex items-center justify-center gap-2 text-[#43FFCD]"
                >
                  <Plus size={16} />
                  <span className="font-medium">
                    {t("add_instruction_step")}
                  </span>
                </button>

                {safeRecipe.instructions.map(
                  (instruction: string, index: number) => (
                    <div key={index} className="flex gap-3 items-start">
                      <div className="flex-1">
                        <div className="flex items-center gap-2 mb-2">
                          <span className="text-sm font-medium text-[#43FFCD]">
                            {t("step")} {index + 1}
                          </span>
                        </div>
                        <textarea
                          value={instruction}
                          onChange={(e) => {
                            if (isCreatingRecipe) {
                              updateInstruction(index, e.target.value);
                            } else {
                              const updatedInstructions = [
                                ...selectedRecipe.instructions,
                              ];
                              updatedInstructions[index] = e.target.value;
                              setSelectedRecipe({
                                ...selectedRecipe,
                                instructions: updatedInstructions,
                              });
                            }
                          }}
                          placeholder={t("describe_step", { step: index + 1 })}
                          className="modern-modal-textarea"
                          rows={2}
                        />
                      </div>
                      <button
                        onClick={() => {
                          if (isCreatingRecipe) {
                            removeInstruction(index);
                          } else {
                            const updatedInstructions =
                              selectedRecipe.instructions.filter(
                                (_: any, i: number) => i !== index
                              );
                            setSelectedRecipe({
                              ...selectedRecipe,
                              instructions: updatedInstructions,
                            });
                          }
                        }}
                        className="w-10 h-10 rounded-lg bg-red-500/20 hover:bg-red-500/30 flex items-center justify-center transition-all duration-200 mt-6"
                      >
                        <Trash2 size={14} color="#f87171" />
                      </button>
                    </div>
                  )
                )}
              </div>
            </div>

            {/* Tips Section */}
            <div className="modern-modal-section">
              <div className="modern-modal-section-title">
                <Lightbulb size={16} color="#43FFCD" />
                {t("pro_tips")} ({safeRecipe.tips.length})
              </div>
              <div className="space-y-3">
                <button
                  onClick={addTip}
                  className="w-full p-3 border-2 border-dashed border-[#43FFCD]/30 rounded-lg bg-[#43FFCD]/5 hover:bg-[#43FFCD]/10 hover:border-[#43FFCD]/50 transition-all duration-200 flex items-center justify-center gap-2 text-[#43FFCD]"
                >
                  <Plus size={16} />
                  <span className="font-medium">{t("add_pro_tip")}</span>
                </button>

                {safeRecipe.tips.map((tip: string, index: number) => (
                  <div key={index} className="flex gap-3 items-start">
                    <div className="flex-1">
                      <textarea
                        value={tip}
                        onChange={(e) => {
                          if (isCreatingRecipe) {
                            updateTip(index, e.target.value);
                          } else {
                            const updatedTips = [...selectedRecipe.tips];
                            updatedTips[index] = e.target.value;
                            setSelectedRecipe({
                              ...selectedRecipe,
                              tips: updatedTips,
                            });
                          }
                        }}
                        placeholder={t("add_helpful_tip")}
                        className="modern-modal-textarea"
                        rows={2}
                      />
                    </div>
                    <button
                      onClick={() => {
                        if (isCreatingRecipe) {
                          removeTip(index);
                        } else {
                          const updatedTips = selectedRecipe.tips.filter(
                            (_: any, i: number) => i !== index
                          );
                          setSelectedRecipe({
                            ...selectedRecipe,
                            tips: updatedTips,
                          });
                        }
                      }}
                      className="w-10 h-10 rounded-lg bg-red-500/20 hover:bg-red-500/30 flex items-center justify-center transition-all duration-200"
                    >
                      <Trash2 size={14} color="#f87171" />
                    </button>
                  </div>
                ))}
              </div>
            </div>

            {/* Notes Section */}
            <div className="modern-modal-section">
              <div className="modern-modal-section-title">
                <StickyNote size={16} color="#43FFCD" />
                {t("chefs_note")} ({safeRecipe.notes.length})
              </div>
              <div className="space-y-3">
                <button
                  onClick={addNote}
                  className="w-full p-3 border-2 border-dashed border-[#43FFCD]/30 rounded-lg bg-[#43FFCD]/5 hover:bg-[#43FFCD]/10 hover:border-[#43FFCD]/50 transition-all duration-200 flex items-center justify-center gap-2 text-[#43FFCD]"
                >
                  <Plus size={16} />
                  <span className="font-medium">{t("add_chef_note")}</span>
                </button>

                {safeRecipe.notes.map((note: string, index: number) => (
                  <div key={index} className="flex gap-3 items-start">
                    <div className="flex-1">
                      <textarea
                        value={note}
                        onChange={(e) => {
                          if (isCreatingRecipe) {
                            updateNote(index, e.target.value);
                          } else {
                            const updatedNotes = [...selectedRecipe.notes];
                            updatedNotes[index] = e.target.value;
                            setSelectedRecipe({
                              ...selectedRecipe,
                              notes: updatedNotes,
                            });
                          }
                        }}
                        placeholder={`Add a chef's note...`}
                        className="modern-modal-textarea"
                        rows={2}
                      />
                    </div>
                    <button
                      onClick={() => {
                        if (isCreatingRecipe) {
                          removeNote(index);
                        } else {
                          const updatedNotes = selectedRecipe.notes.filter(
                            (_: any, i: number) => i !== index
                          );
                          setSelectedRecipe({
                            ...selectedRecipe,
                            notes: updatedNotes,
                          });
                        }
                      }}
                      className="w-10 h-10 rounded-lg bg-red-500/20 hover:bg-red-500/30 flex items-center justify-center transition-all duration-200"
                    >
                      <Trash2 size={14} color="#f87171" />
                    </button>
                  </div>
                ))}
              </div>
            </div>

            <div className="modern-modal-actions">
              <Button
                label={t("save_recipe")}
                onClick={saveRecipe}
                className="flex-1"
              />
            </div>
          </div>
        </div>
      </div>
    );
  };

  // Category Creation Modal
  const renderCategoryModal = () => {
    if (!showCategoryModal) return null;

    return (
      <div
        className="modern-modal-overlay"
        onClick={() => setShowCategoryModal(false)}
      >
        <div
          className="modern-modal-content large"
          onClick={(e) => e.stopPropagation()}
        >
          <div className="modern-modal-header">
            <h3 className="modern-modal-title">
              <Menu size={24} color="#43FFCD" />
              {isEditingCategory ? t("edit_category") : t("create_category")}
            </h3>
            <button
              onClick={() => setShowCategoryModal(false)}
              className="modern-modal-close"
            >
              ×
            </button>
          </div>

          <div className="space-y-6">
            <div className="modern-modal-section">
              <div className="modern-modal-section-title">
                <FileText size={16} color="#43FFCD" />
                {t("category_information")}
              </div>
              <div className="space-y-4">
                <CreateInput
                  placeholder={t("category_name")}
                  value={newCategory.name}
                  icon={MenuIcon}
                  onChange={(e) =>
                    setNewCategory({ ...newCategory, name: e.target.value })
                  }
                />

                <div>
                  <label className="block text-sm font-medium text-gray-300 mb-2">
                    {t("description")}
                  </label>
                  <textarea
                    placeholder={t("describe_menu_category")}
                    value={newCategory.description}
                    onChange={(e) =>
                      setNewCategory({
                        ...newCategory,
                        description: e.target.value,
                      })
                    }
                    className="modern-modal-textarea"
                    rows={3}
                  />
                </div>
              </div>
            </div>

            {/* Selected Recipes */}
            {newCategory.items && newCategory.items.length > 0 && (
              <div className="modern-modal-section">
                <div className="modern-modal-section-title">
                  <Menu size={16} color="#43FFCD" />
                  {t("selected_recipes")} ({newCategory.items.length})
                </div>
                <div className="max-h-40 overflow-y-auto space-y-2 p-1">
                  {newCategory.items.map((item: any, index: number) => (
                    <div
                      key={index}
                      className="flex justify-between items-center p-3 rounded-lg bg-[#43FFCD]/10 border border-[#43FFCD]/20"
                    >
                      <div className="flex-1">
                        <div className="flex items-center gap-2 mb-1">
                          <span className="g-semibold text-[#43FFCD] text-sm">
                            {item.name}
                          </span>
                        </div>
                        <div className="flex items-center gap-2">
                          <span className="text-xs text-gray-400">
                            {t("price")}: $
                          </span>
                          <input
                            type="number"
                            step="0.01"
                            min="0"
                            value={item.price}
                            onChange={(e) => {
                              const updatedItems = [...newCategory.items];
                              updatedItems[index] = {
                                ...item,
                                price: parseFloat(e.target.value) || 0,
                              };
                              setNewCategory({
                                ...newCategory,
                                items: updatedItems,
                              });
                            }}
                            className="w-16 px-2 py-1 text-xs bg-white/10 border border-white/20 rounded text-white"
                          />
                        </div>
                      </div>
                      <button
                        onClick={() => {
                          const updatedCategory = {
                            ...newCategory,
                            items: newCategory.items.filter(
                              (_: any, i: number) => i !== index
                            ),
                          };
                          setNewCategory(updatedCategory);
                        }}
                        className="w-6 h-6 rounded-lg bg-red-500/20 hover:bg-red-500/30 flex items-center justify-center transition-all duration-200"
                      >
                        <Trash2 size={12} color="#f87171" />
                      </button>
                    </div>
                  ))}
                </div>
              </div>
            )}

            <div className="modern-modal-section">
              <div className="modern-modal-section-title">
                <ChefHat size={16} color="#43FFCD" />
                {t("available_recipes")} ({recipes.length})
              </div>
              <div className="max-h-60 overflow-y-auto space-y-2 p-1">
                {recipes
                  .filter(
                    (recipe) =>
                      !newCategory.items?.some(
                        (item: any) => item.id === recipe.id
                      )
                  )
                  .map((recipe) => (
                    <div
                      key={recipe.id}
                      className="flex justify-between items-center p-3 rounded-lg bg-white/5 border border-white/10 hover:bg-white/10 transition-all duration-200"
                    >
                      <div className="flex-1">
                        <div className="flex items-center gap-2 mb-1">
                          <span className="g-semibold text-white text-sm">
                            {recipe.name}
                          </span>
                          <span className="text-xs px-2 py-1 rounded bg-[#43FFCD]/20 text-[#43FFCD]">
                            {recipe.difficulty}
                          </span>
                        </div>
                        <p className="g-medium text-gray-400 text-xs line-clamp-1">
                          {recipe.description}
                        </p>
                      </div>
                      <button
                        onClick={() => {
                          // Add recipe to category items with default price
                          const menuItem = {
                            ...recipe,
                            price: 10.0, // Default price, can be edited later
                            recipe_id: recipe.id,
                          };
                          const updatedCategory = {
                            ...newCategory,
                            items: [...(newCategory.items || []), menuItem],
                          };
                          setNewCategory(updatedCategory);
                        }}
                        className="w-8 h-8 rounded-lg bg-[#43FFCD]/20 hover:bg-[#43FFCD]/30 flex items-center justify-center transition-all duration-200"
                      >
                        <Plus size={14} color="#43FFCD" />
                      </button>
                    </div>
                  ))}
              </div>
            </div>

            <div className="modern-modal-actions">
              <Button
                label={
                  isEditingCategory
                    ? t("update_category")
                    : t("create_category")
                }
                onClick={saveCategory}
                className="flex-1"
              />
            </div>
          </div>
        </div>
      </div>
    );
  };

  // POS & Kiosk Management Modal
  const renderPOSModal = () => {
    if (!showPOSModal || !selectedPOS) return null;

    return (
      <div
        className="modern-modal-overlay"
        onClick={() => setShowPOSModal(false)}
      >
        <div
          className="modern-modal-content"
          onClick={(e) => e.stopPropagation()}
        >
          <div className="modern-modal-header">
            <h3 className="modern-modal-title">
              {selectedPOS.type === "pos" ? (
                <MapPin size={24} color="#43FFCD" />
              ) : (
                <Monitor size={24} color="#43FFCD" />
              )}
              {isCreatingPOS ? t("place_new_device") : t("edit_device")}
            </h3>
            <button
              onClick={() => setShowPOSModal(false)}
              className="modern-modal-close"
            >
              ×
            </button>
          </div>

          <div className="space-y-6">
            <div className="modern-modal-section">
              <div className="modern-modal-section-title">
                <FileText size={16} color="#43FFCD" />
                {t("device_information")}
              </div>
              <CreateInput
                placeholder={t("device_name")}
                value={selectedPOS.name}
                icon={NameIcon}
                onChange={(e) =>
                  setSelectedPOS({ ...selectedPOS, name: e.target.value })
                }
              />
            </div>

            <div className="modern-modal-section">
              <div className="modern-modal-section-title">
                <Monitor size={16} color="#43FFCD" />
                {t("device_configuration")}
              </div>
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-300 mb-2">
                    {t("device_type")}
                  </label>
                  <ToggleSelect
                    options={[t("pos_system"), t("self_order_kiosk")]}
                    active={
                      selectedPOS.type === "pos"
                        ? t("pos_system")
                        : t("self_order_kiosk")
                    }
                    setActive={(active) => {
                      setSelectedPOS({
                        ...selectedPOS,
                        type: active === t("pos_system") ? "pos" : "kiosk",
                      });
                    }}
                    colorScheme="default"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-300 mb-2">
                    {t("status")}
                  </label>
                  <ToggleSelect
                    options={[t("active"), t("inactive")]}
                    active={selectedPOS.isActive ? t("active") : t("inactive")}
                    setActive={(active) => {
                      setSelectedPOS({
                        ...selectedPOS,
                        isActive: active === t("active"),
                      });
                    }}
                    colorScheme="status"
                  />
                </div>

                <div className="p-4 rounded-lg bg-white/5 border border-white/10">
                  <div className="flex items-center gap-3">
                    {selectedPOS.type === "pos" ? (
                      <MapPin size={20} color="#43FFCD" />
                    ) : (
                      <Monitor size={20} color="#43FFCD" />
                    )}
                    <div>
                      <div className="text-sm font-medium text-white">
                        {selectedPOS.type === "pos"
                          ? t("point_of_sale_terminal")
                          : t("self_service_kiosk")}
                      </div>
                      <div className="text-xs text-gray-400">
                        {selectedPOS.type === "pos"
                          ? t("staff_operated_payment")
                          : t("customer_self_service")}
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div className="modern-modal-actions">
              {isCreatingPOS ? (
                <Button
                  label={t("place_device")}
                  onClick={() => {
                    // Start placement mode
                    fetchNui("setPOSPosition", {
                      name: selectedPOS.name,
                      device_type: selectedPOS.type,
                      is_active: selectedPOS.isActive,
                    });
                    setShowPOSModal(false);
                  }}
                  className="flex-1"
                />
              ) : (
                <Button
                  label={t("save_changes")}
                  onClick={async () => {
                    try {
                      await fetchNui("updatePOS", {
                        id: selectedPOS.id,
                        name: selectedPOS.name,
                        device_type: selectedPOS.type,
                        is_active: selectedPOS.isActive,
                        isActive: selectedPOS.isActive, // Send both formats for compatibility
                        type: selectedPOS.type, // Send both formats for compatibility
                      });
                      setShowPOSModal(false);
                      setSelectedPOS(null);
                      setIsCreatingPOS(false);
                    } catch (error) {
                      console.error("Failed to update POS:", error);
                    }
                  }}
                  className="flex-1"
                />
              )}
            </div>
          </div>
        </div>
      </div>
    );
  };

  // Delete Confirmation Modal
  const renderDeleteConfirmModal = () => {
    if (!showDeleteConfirm || !deleteTarget) return null;

    const handleDelete = async () => {
      try {
        if (deleteTarget.type === "recipe") {
          await fetchNui("deleteRecipe", { id: deleteTarget.id });
        }
        setShowDeleteConfirm(false);
        setDeleteTarget(null);
      } catch (error) {
        console.error("Failed to delete:", error);
      }
    };

    return (
      <div
        className="modern-modal-overlay"
        onClick={() => setShowDeleteConfirm(false)}
      >
        <div
          className="modern-modal-content"
          onClick={(e) => e.stopPropagation()}
        >
          <div className="modern-modal-header">
            <h3 className="modern-modal-title">
              <Trash2 size={24} color="#ef4444" />
              Confirm Delete
            </h3>
            <button
              onClick={() => setShowDeleteConfirm(false)}
              className="modern-modal-close"
            >
              ×
            </button>
          </div>

          <div className="space-y-4">
            <div className="text-center">
              <p className="text-white text-lg mb-2">
                {t("delete_confirmation", { type: deleteTarget.type })}
              </p>
              <p className="text-gray-400 text-sm">
                <strong>{deleteTarget.name}</strong>
              </p>
              <p className="text-red-400 text-sm mt-2">
                {t("action_cannot_be_undone")}
              </p>
            </div>

            <div className="flex gap-3 justify-center">
              <button
                onClick={() => setShowDeleteConfirm(false)}
                className="px-6 py-2 rounded-lg bg-white/10 hover:bg-white/20 text-white transition-all duration-200"
              >
                Cancel
              </button>
              <button
                onClick={handleDelete}
                className="px-6 py-2 rounded-lg bg-red-500/20 hover:bg-red-500/30 text-red-400 hover:text-red-300 transition-all duration-200"
              >
                Delete
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  };

  // Withdraw Modal
  const renderWithdrawModal = () => {
    if (!showWithdrawModal) return null;

    return (
      <div
        className="modern-modal-overlay"
        onClick={() => setShowWithdrawModal(false)}
      >
        <div
          className="modern-modal-content"
          onClick={(e) => e.stopPropagation()}
        >
          <div className="modern-modal-header">
            <h3 className="modern-modal-title">
              <ArrowDownRight size={24} color="#ef4444" />
              {t("withdraw_money")}
            </h3>
            <button
              onClick={() => setShowWithdrawModal(false)}
              className="modern-modal-close"
            >
              ×
            </button>
          </div>

          <div className="space-y-6">
            <div className="modern-modal-section">
              <div className="modern-modal-section-title">
                <Wallet size={16} color="#ef4444" />
                {t("withdrawal_details")}
              </div>
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-300 mb-2">
                    {t("amount_to_withdraw")}
                  </label>
                  <div className="relative">
                    <span className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400">
                      $
                    </span>
                    <input
                      type="number"
                      value={withdrawAmount}
                      onChange={(e) => setWithdrawAmount(e.target.value)}
                      placeholder="0.00"
                      className="w-full pl-8 pr-4 py-3 bg-white/10 border border-white/20 rounded-lg text-white placeholder-gray-400 focus:ring-2 focus:ring-red-500 focus:border-transparent"
                    />
                  </div>
                </div>

                <div className="p-4 rounded-lg bg-red-500/10 border border-red-500/30">
                  <div className="flex items-center gap-2 mb-2">
                    <ArrowDownRight size={16} color="#ef4444" />
                    <span className="text-red-400 text-sm font-medium">
                      {t("available_balance")}
                    </span>
                  </div>
                  <p className="text-white text-lg font-semibold">
                    ${financeData.currentBalance.toLocaleString()}
                  </p>
                </div>
              </div>
            </div>

            <div className="modern-modal-actions">
              <button
                onClick={() => setShowWithdrawModal(false)}
                className="px-6 py-2 rounded-lg bg-white/10 hover:bg-white/20 text-white transition-all duration-200"
              >
                Cancel
              </button>
              <button
                onClick={() => {
                  const amount = parseFloat(withdrawAmount);
                  if (amount > 0 && amount <= financeData.currentBalance) {
                    fetchNui("withdrawMoney", { amount });
                    setWithdrawAmount("");
                    setShowWithdrawModal(false);
                  }
                }}
                disabled={
                  !withdrawAmount ||
                  parseFloat(withdrawAmount) <= 0 ||
                  parseFloat(withdrawAmount) > financeData.currentBalance
                }
                className="px-6 py-2 rounded-lg bg-red-500/20 hover:bg-red-500/30 text-red-400 hover:text-red-300 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {t("withdraw")}
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  };

  // Deposit Modal
  const renderDepositModal = () => {
    if (!showDepositModal) return null;

    return (
      <div
        className="modern-modal-overlay"
        onClick={() => setShowDepositModal(false)}
      >
        <div
          className="modern-modal-content"
          onClick={(e) => e.stopPropagation()}
        >
          <div className="modern-modal-header">
            <h3 className="modern-modal-title">
              <ArrowUpRight size={24} color="#22c55e" />
              {t("deposit_money")}
            </h3>
            <button
              onClick={() => setShowDepositModal(false)}
              className="modern-modal-close"
            >
              ×
            </button>
          </div>

          <div className="space-y-6">
            <div className="modern-modal-section">
              <div className="modern-modal-section-title">
                <Wallet size={16} color="#22c55e" />
                {t("deposit_details")}
              </div>
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-300 mb-2">
                    {t("amount_to_deposit")}
                  </label>
                  <div className="relative">
                    <span className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400">
                      $
                    </span>
                    <input
                      type="number"
                      value={depositAmount}
                      onChange={(e) => setDepositAmount(e.target.value)}
                      placeholder="0.00"
                      className="w-full pl-8 pr-4 py-3 bg-white/10 border border-white/20 rounded-lg text-white placeholder-gray-400 focus:ring-2 focus:ring-green-500 focus:border-transparent"
                    />
                  </div>
                </div>

                <div className="p-4 rounded-lg bg-green-500/10 border border-green-500/30">
                  <div className="flex items-center gap-2 mb-2">
                    <ArrowUpRight size={16} color="#22c55e" />
                    <span className="text-green-400 text-sm font-medium">
                      {t("current_balance")}
                    </span>
                  </div>
                  <p className="text-white text-lg font-semibold">
                    ${financeData.currentBalance.toLocaleString()}
                  </p>
                </div>
              </div>
            </div>

            <div className="modern-modal-actions">
              <button
                onClick={() => setShowDepositModal(false)}
                className="px-6 py-2 rounded-lg bg-white/10 hover:bg-white/20 text-white transition-all duration-200"
              >
                Cancel
              </button>
              <button
                onClick={() => {
                  const amount = parseFloat(depositAmount);
                  if (amount > 0) {
                    fetchNui("depositMoney", { amount });
                    setDepositAmount("");
                    setShowDepositModal(false);
                  }
                }}
                disabled={!depositAmount || parseFloat(depositAmount) <= 0}
                className="px-6 py-2 rounded-lg bg-green-500/20 hover:bg-green-500/30 text-green-400 hover:text-green-300 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {t("deposit")}
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  };

  // Pay Salary Modal
  const renderInvitationModal = () => {
    if (!showInvitationModal) return null;

    const handleSendInvitation = async () => {
      try {
        await fetchNui("sendEmployeeInvitation", {
          restaurantId: restaurantData?.id,
          position: invitationData.position,
          salary: invitationData.salary,
          isBoss: invitationData.isBoss,
          isManager: invitationData.isManager,
        });
        setShowInvitationModal(false);
        setInvitationData({
          position: "",
          salary: 0,
          isBoss: false,
          isManager: false,
        });
      } catch (error) {
        console.error("Failed to send invitation:", error);
      }
    };

    return (
      <div
        className="modern-modal-overlay"
        onClick={() => setShowInvitationModal(false)}
      >
        <div
          className="modern-modal-content"
          onClick={(e) => e.stopPropagation()}
        >
          <div className="modern-modal-header">
            <h3 className="modern-modal-title">
              <UserPlus size={24} color="#43FFCD" />
              {t("invite_employee")}
            </h3>
            <button
              onClick={() => setShowInvitationModal(false)}
              className="modern-modal-close"
            >
              ×
            </button>
          </div>

          <div className="space-y-6">
            <div className="modern-modal-section">
              <div className="modern-modal-section-title">
                <Users size={16} color="#43FFCD" />
                {t("employee_details")}
              </div>
              <div className="space-y-4">
                <div>
                  <label className="modern-input-label">{t("position")}</label>
                  <input
                    type="text"
                    value={invitationData.position}
                    onChange={(e) =>
                      setInvitationData({
                        ...invitationData,
                        position: e.target.value,
                      })
                    }
                    placeholder={t("position_examples")}
                    className="modern-input"
                  />
                </div>

                <div>
                  <label className="modern-input-label">{t("salary")}</label>
                  <input
                    type="number"
                    value={invitationData.salary}
                    onChange={(e) =>
                      setInvitationData({
                        ...invitationData,
                        salary: parseInt(e.target.value) || 0,
                      })
                    }
                    placeholder="0"
                    className="modern-input"
                  />
                </div>

                <div className="space-y-3">
                  <label className="modern-input-label">{t("roles")}</label>
                  <div className="space-y-2">
                    <label className="flex items-center gap-3 cursor-pointer">
                      <input
                        type="checkbox"
                        checked={invitationData.isBoss}
                        onChange={(e) =>
                          setInvitationData({
                            ...invitationData,
                            isBoss: e.target.checked,
                          })
                        }
                        className="modern-checkbox"
                      />
                      <span className="text-white text-sm">
                        {t("boss_role_description")}
                      </span>
                    </label>
                    <label className="flex items-center gap-3 cursor-pointer">
                      <input
                        type="checkbox"
                        checked={invitationData.isManager}
                        onChange={(e) =>
                          setInvitationData({
                            ...invitationData,
                            isManager: e.target.checked,
                          })
                        }
                        className="modern-checkbox"
                      />
                      <span className="text-white text-sm">
                        {t("manager_role_description")}
                      </span>
                    </label>
                  </div>
                </div>

                <div className="p-4 rounded-lg bg-blue-500/10 border border-blue-500/30">
                  <div className="flex items-center gap-2 mb-2">
                    <Info size={16} color="#3b82f6" />
                    <span className="text-blue-400 text-sm font-medium">
                      {t("invitation_process")}
                    </span>
                  </div>
                  <p className="text-gray-300 text-sm">
                    {t("invitation_instructions")}
                  </p>
                </div>
              </div>
            </div>

            <div className="modern-modal-actions">
              <button
                onClick={() => setShowInvitationModal(false)}
                className="px-6 py-2 rounded-lg bg-white/10 hover:bg-white/20 text-white transition-all duration-200"
              >
                {t("cancel")}
              </button>
              <button
                onClick={handleSendInvitation}
                disabled={
                  !invitationData.position || invitationData.salary <= 0
                }
                className="px-6 py-2 rounded-lg bg-[#43FFCD]/20 hover:bg-[#43FFCD]/30 text-[#43FFCD] hover:text-[#43FFCD] transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {t("send_invitation")}
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  };

  const renderPaySalaryModal = () => {
    if (!showPaySalaryModal) return null;

    const totalSalary = selectedEmployeeForPayment
      ? selectedEmployeeForPayment.salary
      : employees.reduce((total, emp) => total + emp.salary, 0);

    return (
      <div
        className="modern-modal-overlay"
        onClick={() => setShowPaySalaryModal(false)}
      >
        <div
          className="modern-modal-content"
          onClick={(e) => e.stopPropagation()}
        >
          <div className="modern-modal-header">
            <h3 className="modern-modal-title">
              <CreditCard size={24} color="#3b82f6" />
              {selectedEmployeeForPayment
                ? t("pay_employee_salary")
                : t("pay_all_salaries")}
            </h3>
            <button
              onClick={() => setShowPaySalaryModal(false)}
              className="modern-modal-close"
            >
              ×
            </button>
          </div>

          <div className="space-y-6">
            <div className="modern-modal-section">
              <div className="modern-modal-section-title">
                <Users size={16} color="#3b82f6" />
                {t("payment_details")}
              </div>
              <div className="space-y-4">
                {selectedEmployeeForPayment ? (
                  <div className="p-4 rounded-lg bg-blue-500/10 border border-blue-500/30">
                    <div className="flex items-center gap-3 mb-3">
                      <div className="w-10 h-10 rounded-full bg-gradient-to-br from-blue-400/20 to-blue-600/20 flex items-center justify-center">
                        <Users size={20} color="#3b82f6" />
                      </div>
                      <div>
                        <h4 className="g-semibold text-white text-lg">
                          {selectedEmployeeForPayment.name}
                        </h4>
                        <p className="g-medium text-gray-400 text-sm">
                          {selectedEmployeeForPayment.position}
                        </p>
                      </div>
                    </div>
                    <div className="text-center">
                      <p className="text-gray-400 text-sm">
                        {t("salary_amount")}
                      </p>
                      <p className="text-blue-400 text-2xl font-bold">
                        ${selectedEmployeeForPayment.salary.toLocaleString()}
                      </p>
                    </div>
                  </div>
                ) : (
                  <div className="p-4 rounded-lg bg-blue-500/10 border border-blue-500/30">
                    <div className="flex items-center gap-3 mb-3">
                      <div className="w-10 h-10 rounded-full bg-gradient-to-br from-blue-400/20 to-blue-600/20 flex items-center justify-center">
                        <Users size={20} color="#3b82f6" />
                      </div>
                      <div>
                        <h4 className="g-semibold text-white text-lg">
                          {t("all_employees")}
                        </h4>
                        <p className="g-medium text-gray-400 text-sm">
                          {employees.length} {t("employees_count")}
                        </p>
                      </div>
                    </div>
                    <div className="text-center">
                      <p className="text-gray-400 text-sm">
                        {t("total_salary_payment")}
                      </p>
                      <p className="text-blue-400 text-2xl font-bold">
                        ${totalSalary.toLocaleString()}
                      </p>
                    </div>
                  </div>
                )}

                <div className="p-4 rounded-lg bg-yellow-500/10 border border-yellow-500/30">
                  <div className="flex items-center gap-2 mb-2">
                    <Wallet size={16} color="#f59e0b" />
                    <span className="text-yellow-400 text-sm font-medium">
                      {t("available_balance")}
                    </span>
                  </div>
                  <p className="text-white text-lg font-semibold">
                    ${financeData.currentBalance.toLocaleString()}
                  </p>
                </div>
              </div>
            </div>

            <div className="modern-modal-actions">
              <button
                onClick={() => setShowPaySalaryModal(false)}
                className="px-6 py-2 rounded-lg bg-white/10 hover:bg-white/20 text-white transition-all duration-200"
              >
                {t("cancel")}
              </button>
              <button
                onClick={() => {
                  if (financeData.currentBalance >= totalSalary) {
                    fetchNui("paySalaries", {
                      employeeId: selectedEmployeeForPayment?.id,
                      amount: totalSalary,
                    });
                    setSelectedEmployeeForPayment(null);
                    setShowPaySalaryModal(false);
                  }
                }}
                disabled={financeData.currentBalance < totalSalary}
                className="px-6 py-2 rounded-lg bg-blue-500/20 hover:bg-blue-500/30 text-blue-400 hover:text-blue-300 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {financeData.currentBalance < totalSalary
                  ? t("insufficient_funds")
                  : t("pay_salary")}
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  };

  if (!visibility.visible || visibility.page !== "management") return null;

  return (
    <div className="restaurant-management">
      <div className="management-container">
        <div className="tab-navigation mb-2 w-full rounded-xl">
          <div
            className="flex gap-2 p-2 rounded-xl w-full justify-between items-center"
            style={{
              background: "rgba(217, 217, 217, 0.1)",
              border: "1px solid rgba(255, 255, 255, 0.1)",
            }}
          >
            <div className="flex gap-2 flex-1">
              {tabs.map((tab) => {
                const IconComponent = tab.icon;
                const hasTabAccess = hasAccess(tab.access);
                return (
                  <button
                    key={tab.id}
                    className={`tab-button-modern ${
                      activeTab === tab.id ? "active" : ""
                    } ${!hasTabAccess ? "" : ""}`}
                    onClick={() => setActiveTab(tab.id)}
                    style={{
                      background:
                        activeTab === tab.id
                          ? "linear-gradient(135deg, rgba(67, 255, 205, 0.2), rgba(42, 181, 163, 0.2))"
                          : "transparent",
                      border:
                        activeTab === tab.id
                          ? "1px solid rgba(67, 255, 205, 0.3)"
                          : "1px solid transparent",
                      borderRadius: "8px",
                      padding: "12px 20px",
                      display: "flex",
                      alignItems: "center",
                      gap: "8px",
                      transition: "all 0.3s ease",
                      cursor: "pointer",
                      flex: "1",
                      justifyContent: "center",
                      opacity: !hasTabAccess ? 0.6 : 1,
                    }}
                  >
                    <IconComponent
                      size={18}
                      color={activeTab === tab.id ? "#43FFCD" : "#9ca3af"}
                    />
                    <span
                      className={`g-semibold text-sm ${
                        activeTab === tab.id
                          ? "text-[#43FFCD]"
                          : "text-gray-400"
                      }`}
                    >
                      {tab.label}
                    </span>
                  </button>
                );
              })}
            </div>
          </div>
        </div>

        {/* Enhanced Content Area */}
        <div className="content-area-modern h-[90%]">
          <div
            className="content-wrapper"
            style={{
              background: "rgba(217, 217, 217, 0.05)",
              border: "1px solid rgba(255, 255, 255, 0.1)",
              borderRadius: "4px",
              padding: "24px",
              height: "100%",
              overflow: "hidden",
            }}
          >
            <div
              style={{
                height: "100%",
                overflowY: "auto",
                paddingRight: "8px",
              }}
            >
              {activeTab === "overview" &&
                renderRestrictedContent("overview", renderOverview())}
              {activeTab === "general" &&
                renderRestrictedContent("general", renderGeneralInfo())}
              {activeTab === "employees" &&
                renderRestrictedContent("employees", renderEmployees())}
              {activeTab === "recipes" &&
                renderRestrictedContent("recipes", renderRecipes())}
              {activeTab === "menu" &&
                renderRestrictedContent("menu", renderMenu())}
              {activeTab === "pos" &&
                renderRestrictedContent("pos", renderPOS())}
              {activeTab === "display" &&
                renderRestrictedContent("display", renderDisplay())}
              {activeTab === "finance" &&
                renderRestrictedContent("finance", renderFinance())}
            </div>
          </div>
        </div>
      </div>

      {/* Modals */}
      {renderTVModal()}
      {renderNewTVModal()}
      {renderEmployeeModal()}
      {renderRecipeModal()}
      {renderCategoryModal()}
      {renderPOSModal()}
      {renderDeleteConfirmModal()}
      {renderWithdrawModal()}
      {renderDepositModal()}
      {renderPaySalaryModal()}
      {renderInvitationModal()}
    </div>
  );
}
