import "@mantine/core/styles.css";
import { MantineProvider } from "@mantine/core";
import { useEffect, useState } from "react";
import { isEnvBrowser, useNuiEvent } from "./hooks/useNuiEvents";
import { Panel } from "./components/Panel/Panel";
import { useSetRecoilState } from "recoil";
import { Lang, Regions } from "./reducers/atoms";
import { getLang } from "./hooks/getLang";

const App = () => {
  const setLang = useSetRecoilState(Lang);
  const [showPanel, setShowPanel] = useState(isEnvBrowser());
  const setRegions = useSetRecoilState(Regions);
  useNuiEvent("menu", (data: any) => {
    if (data.regions) {
      setRegions(data.regions);
    }
    setShowPanel(data.state);
  });
  useEffect(() => {
    const fetchLang = async () => {
      const resp = await getLang();
      setLang(resp);
    };
    fetchLang();
  }, []);

  return (
    <MantineProvider defaultColorScheme="dark">
      {showPanel && <Panel />}
    </MantineProvider>
  );
};

export default App;
