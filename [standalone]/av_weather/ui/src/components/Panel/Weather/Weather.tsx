import { Grid, Card } from "@mantine/core";
import classes from "./style.module.css";
import { Zone } from "./Zone/Zone";
import { Controls } from "./Controls/Controls";
import { GlobalControls } from "./GlobalControls/GlobalControls";
import { ZoneInfo } from "../../../types/types";
import { useEffect, useState } from "react";
import { fetchNui, useNuiEvent } from "../../../hooks/useNuiEvents";

export const Weather = () => {
  const [loaded, setLoaded] = useState(false);
  const [zoneInfo, setZoneInfo] = useState<ZoneInfo>({
    label: "Los Santos",
    name: "santos",
    weather: "THUNDER",
    hour: 21,
    minutes: 10,
    temperature: 31,
    type: "C",
    time: "day",
    wind: 11.99,
    freeze: false,
  });
  useNuiEvent("zone", (data: any) => {
    if (data.name == zoneInfo.name) {
      const copy = {
        ...zoneInfo,
        weather: data.weather,
        wind: data.wind,
        temperature: data.temperature,
        freeze: data.freeze,
      };
      setZoneInfo(copy);
    }
  });

  const handleZone = async (name: string) => {
    setLoaded(false);
    const resp = await fetchNui("av_weather", "getZone", name);
    if (resp) {
      setZoneInfo(resp);
    }
    setTimeout(() => {
      setLoaded(true);
    }, 100);
  };
  useEffect(() => {
    const fetchZone = async () => {
      const resp = await fetchNui("av_weather", "loadZone");
      if (resp) {
        setZoneInfo(resp);
      }
      setTimeout(() => {
        setLoaded(true);
      }, 100);
    };
    fetchZone();
  }, []);

  return (
    <Grid p="xs">
      <Grid.Col span={4}>
        <Card className={classes.card} radius={10} shadow="sm" h={310}>
          <Zone info={zoneInfo} handleZone={handleZone} loaded={loaded} />
        </Card>
      </Grid.Col>
      <Grid.Col span={"auto"}>
        <Card className={classes.card} radius={10} shadow="sm" h={310}>
          <Controls type={zoneInfo.type} />
        </Card>
      </Grid.Col>
      <Grid.Col span={12}>
        <Card className={classes.card} h="auto" radius={10} shadow="sm">
          <GlobalControls />
        </Card>
      </Grid.Col>
    </Grid>
  );
};
