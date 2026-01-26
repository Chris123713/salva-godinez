import React, {
  Context,
  createContext,
  useContext,
  useEffect,
  useState,
} from "react";
import { useNuiEvent } from "../hooks/useNuiEvent";
import { fetchNui } from "../utils/fetchNui";
import { isEnvBrowser } from "../utils/misc";

const VisibilityCtx = createContext< VisibilityProviderValue | null>(null);

interface VisibilityProviderValue {
  setVisibility: (visibility: VisibilityEvent) => void;
  visibility: VisibilityEvent;
}

interface VisibilityEvent {
  action: "setVisible" | "hideFrame";
  visible: boolean;
  page: string;
}
// This should be mounted at the top level of your application, it is currently set to
// apply a CSS visibility value. If this is non-performant, this should be customized.
export const VisibilityProvider: React.FC<{ children: React.ReactNode }> = ({
  children,
}) => {
  const [visibility, setVisibility] = useState<VisibilityEvent>({
    action: "setVisible",
    visible: false,
    page: "",
  });

  useNuiEvent<VisibilityEvent>("setVisibility", setVisibility);

  // Handle pressing escape/backspace
  useEffect(() => {
    // Only attach listener when we are visible
    if (!visibility) return;
    const keyHandler = (e: KeyboardEvent) => {
      if (["Escape"].includes(e.code)) {
        if (!isEnvBrowser()) fetchNui("hideFrame");
      }
    };

    window.addEventListener("keydown", keyHandler);

    return () => window.removeEventListener("keydown", keyHandler);
  }, [visibility]);

  return (
    <VisibilityCtx.Provider
      value={{
        visibility: visibility,
        setVisibility: (visibility: VisibilityEvent) => setVisibility(visibility),
      }}
    >
      <div
        style={{ visibility: visibility.visible ? "visible" : "hidden", height: "100%" }}
      >
        {children}
      </div>
    </VisibilityCtx.Provider>
  );
};
  
  // Custom hook to access visibility state and setter
  // Example usage:
  // const { visible, setVisible } = useVisibility();
export const useVisibility = () =>
  useContext<VisibilityProviderValue>(
    VisibilityCtx as Context<VisibilityProviderValue>,
  );