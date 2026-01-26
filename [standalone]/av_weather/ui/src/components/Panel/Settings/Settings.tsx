import { useEffect, useState } from "react";
import { Stack, Grid, Card, Flex, Text, Group, Button } from "@mantine/core";
import { fetchNui, useNuiEvent } from "../../../hooks/useNuiEvents";
import { Loading } from "../../Loading";
import { useRecoilValue } from "recoil";
import { Lang } from "../../../reducers/atoms";
import { Option } from "./Option";
import classes from "./style.module.css";

interface SettingsType {
  snowPass: boolean;
  snowLevel: number;
  rainIntensity: number;
  vehicleGrip: boolean;
  thunderIntensity: number;
  weatherTime: number;
  debugMode: boolean;
  debugTime: boolean;
}

export const Settings = () => {
  const lang: any = useRecoilValue(Lang);
  const [loaded, setLoaded] = useState(false);
  const [settings, setSettings] = useState<SettingsType>({
    snowPass: false,
    snowLevel: 0.5,
    rainIntensity: 0.3,
    thunderIntensity: 0.5,
    vehicleGrip: true,
    weatherTime: 10,
    debugMode: false,
    debugTime: false,
  });

  const handleUpdate = (field: string, value: number | string | boolean) => {
    setSettings((prevSettings) => ({
      ...prevSettings,
      [field]: value,
    }));
  };

  useNuiEvent("settings", (data: SettingsType) => {
    setSettings(data);
  });

  useEffect(() => {
    const fetchData = async () => {
      const resp = await fetchNui("av_weather", "getSettings");
      if (resp) {
        setSettings(resp);
      }
      setTimeout(() => {
        setLoaded(true);
      }, 100);
    };
    fetchData();
  }, []);
  return (
    <Card className={classes.card} m="xs" radius={10} shadow="sm">
      {!loaded ? (
        <Loading />
      ) : (
        <Stack>
          <Flex direction="column">
            <Text fz="xl" fw={600} c="#64D2FF" lts={0.25}>
              {lang.global_settings}
            </Text>
            <Text fz="xs" c="dimmed">
              {lang.settings_description}
            </Text>
          </Flex>
          <Grid gutter="md">
            <Grid.Col span={3} maw={200}>
              <Option
                component="switch"
                header={lang.road_snow}
                setValue={handleUpdate}
                value={settings.snowPass}
                tooltip={lang.road_snow_tooltip}
                gap="xs"
                field="snowPass"
              />
            </Grid.Col>
            <Grid.Col span={3} maw={200}>
              <Option
                component="slider"
                header={lang.snow_level}
                tooltip={lang.snow_level_description}
                setValue={handleUpdate}
                value={settings.snowLevel}
                gap={2}
                field="snowLevel"
              />
            </Grid.Col>
            <Grid.Col span={3} maw={200}>
              <Option
                component="slider"
                header={lang.rain_intensity}
                tooltip={lang.rain_default}
                setValue={handleUpdate}
                value={settings.rainIntensity}
                gap={2}
                field="rainIntensity"
              />
            </Grid.Col>
            <Grid.Col span={3} maw={200}>
              <Option
                component="slider"
                header={lang.thunder_intensity}
                setValue={handleUpdate}
                tooltip={lang.thunder_default}
                value={settings.thunderIntensity}
                gap={2}
                field="thunderIntensity"
              />
            </Grid.Col>
            <Grid.Col span={3} maw={200}>
              <Option
                component="switch"
                header={lang.vehicle_grip}
                tooltip={lang.vehicle_grip_tooltip}
                setValue={handleUpdate}
                value={settings.vehicleGrip}
                gap="xs"
                field="vehicleGrip"
              />
            </Grid.Col>
            <Grid.Col span={3} maw={200}>
              <Option
                component="number"
                header={lang.weather_interval}
                tooltip={lang.weather_interval_tooltip}
                setValue={handleUpdate}
                value={settings.weatherTime}
                gap={2}
                field="weatherTime"
              />
            </Grid.Col>
            <Grid.Col span={3} maw={200}>
              <Option
                component="switch"
                header={lang.debug_mode}
                setValue={handleUpdate}
                value={settings.debugMode}
                gap="xs"
                field="debugMode"
              />
            </Grid.Col>
            <Grid.Col span={3} maw={200}>
              <Option
                component="switch"
                header={lang.debug_time}
                setValue={handleUpdate}
                value={settings.debugTime}
                gap="xs"
                field="debugTime"
              />
            </Grid.Col>
          </Grid>
          <Group style={{ position: "absolute", bottom: 16, right: 16 }}>
            <Flex direction="column" ml="auto">
              <Text fz="xs" c="dimmed" ml="auto">
                {lang.double_click}
              </Text>
              <Group mt={3}>
                <Button
                  ml="auto"
                  size="xs"
                  color="#0A84FF"
                  onDoubleClick={() => {
                    fetchNui("av_weather", "sendSettings", settings);
                  }}
                >
                  {lang.apply_button}
                </Button>
              </Group>
            </Flex>
          </Group>
        </Stack>
      )}
    </Card>
  );
};
