import React from 'react';
import ReactDOM from 'react-dom/client';
import { VisibilityProvider } from './providers/VisibilityProvider';
import { debugData } from './utils/debugData';
import { handleTranslationsReceived, type Translations } from './utils/translations';
import { useNuiEvent } from './hooks/useNuiEvent';
import Kiosk from './pages/Kiosk';
import './index.css';
import './restaurant-management.css';
import './timer.css';
import Creator from './pages/Creator';
import RestaurantManagement from './pages/Managment';
import POSSystem from './pages/PosSystem';
import KitchenDisplay from './pages/KitchenDisplay';
import OrderStatus from './pages/OrderStatus';
import CustomDisplay from './pages/CustomDisplay';
import Timer from './components/Timer';
import TimerDUI from './components/TimerDUI';
import RecipeBook from './pages/RecipeeBook';
import Computer from './pages/Computer';
import Ticket from './pages/Ticket';
import Bill from './pages/Bill';
import './pos-system.css';
import './kitchen-display.css';
import './order-status.css';
import './shop.css';
import './recipe-book.css';
import './receipt.css';
import PositionConfigurator from './pages/PositionConfigurator';
import DrinksMachine from './pages/DrinksMachine';
import SupplyManagement from './pages/SupplyManagement';

debugData([
  {
    action: 'setVisibility',
    data: {
      visible: true,
      page: 'drinks_machine',
      action: 'setVisibility',
    },
  },
]);

const App = () => {
  useNuiEvent<Translations>('translationsReceived', (translations) => {
    handleTranslationsReceived(translations);
  });


  if (window.location.hash === '#timer') {
    return <TimerDUI />;
  }

  return (
    <VisibilityProvider>
      <div className="nui-wrapper">
        <Kiosk />
        <Creator />
        <RestaurantManagement />
        <POSSystem />
        <KitchenDisplay />
        <OrderStatus />
        <CustomDisplay />
        <Timer />
        <RecipeBook />
        <Computer />
        <Ticket />
        <Bill />
        <DrinksMachine />
        <SupplyManagement />
        <PositionConfigurator />
      </div>
    </VisibilityProvider>
  );
};

ReactDOM.createRoot(document.getElementById('root') as HTMLElement).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
);
