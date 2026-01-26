import { useEffect, useState } from "react";
import { Box, Grid, Transition } from "@mantine/core";
import { Navbar } from "./Navbar/Navbar";
import { Weather } from "./Weather/Weather";
import { fetchNui } from "../../hooks/useNuiEvents";
import { Settings } from "./Settings/Settings";
import classes from "./style.module.css";

export const Panel = () => {
  const [tab, setTab] = useState("weather");
  const [loaded, setLoaded] = useState(false);
  const onPressKey = (e: any) => {
    switch (e.code) {
      case "Escape":
        setLoaded(false);
        setTimeout(() => {
          fetchNui("av_weather", "close");
        }, 150);
        break;
      default:
        break;
    }
  };
  useEffect(() => {
    setTimeout(() => {
      setLoaded(true);
    }, 150);
    window.addEventListener("keydown", onPressKey);
  }, []);

  return (
    <Transition
      mounted={loaded}
      transition="fade"
      duration={400}
      timingFunction="ease"
    >
      {(styles) => (
        <Box style={styles} className={classes.container}>
          <Grid className={classes.box}>
            <Grid.Col span={0.5}>
              <Navbar tab={tab} setTab={setTab} />
            </Grid.Col>
            <Grid.Col span={"auto"} p="md" ml="sm">
              {tab == "weather" && <Weather />}
              {tab == "settings" && <Settings/>}
            </Grid.Col>
          </Grid>
        </Box>
      )}
    </Transition>
  );
};
