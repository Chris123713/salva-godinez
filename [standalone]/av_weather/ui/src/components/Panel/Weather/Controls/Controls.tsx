import { useState } from "react";
import {
  Grid,
  Button,
  Box,
  Select,
  Text,
  MultiSelect,
  NumberInput,
  Flex,
  Group,
} from "@mantine/core";
import {
  IconMapPin,
  IconSun,
  IconTemperature,
  IconCloudPause,
  IconWind,
  IconCloudFog,
} from "@tabler/icons-react";
import classes from "./style.module.css";
import { fetchNui } from "../../../../hooks/useNuiEvents";
import { useRecoilValue } from "recoil";
import { Lang, Regions } from "../../../../reducers/atoms";

const Weathers = [
  { value: "BLIZZARD", label: "Blizzard" },
  { value: "CLEAR", label: "Clear" },
  { value: "CLEARING", label: "Clearing" },
  { value: "CLOUDS", label: "Clouds" },
  { value: "EXTRASUNNY", label: "Extra Sunny" },
  { value: "FOGGY", label: "Foggy" },
  { value: "HALLOWEEN", label: "Halloween" },
  { value: "NEUTRAL", label: "Neutral" },
  { value: "OVERCAST", label: "Overcast" },
  { value: "RAIN", label: "Rain" },
  { value: "SMOG", label: "Smog" },
  { value: "SNOW", label: "Snow" },
  { value: "SNOWLIGHT", label: "Snowlight" },
  { value: "THUNDER", label: "Thunder" },
  { value: "XMAS", label: "XMAS" },
];

const original = {
  zones: [],
  freeze: undefined,
};

interface Properties {
  type: string;
}

export const Controls = ({ type }: Properties) => {
  const lang: any = useRecoilValue(Lang);
  const regions = useRecoilValue(Regions);
  const fogOptions = [
    { value: "automatic", label: lang.fog.automatic },
    { value: "no", label: lang.fog.no },
    { value: "normal", label: lang.fog.normal },
    { value: "low", label: lang.fog.low },
    { value: "medium", label: lang.fog.medium },
    { value: "high", label: lang.fog.high },
    { value: "max", label: lang.fog.max },
  ];
  const [data, setData] = useState(original);
  const iconStyle = { width: "14px", height: "14px" };

  const updateField = (field: string, value: any) => {
    const copy = { ...data, [field]: value };
    setData(copy);
  };
  const handleSave = () => {
    fetchNui("av_weather", "setZone", data);
  };
  const handleRandom = () => {
    fetchNui("av_weather", "randomZones", data);
  };
  return (
    <Grid gutter={"xs"}>
      <Grid.Col span={12}>
        <Flex direction="column">
          <Text fw={600} c="#64D2FF" lts={0.25}>
            {lang.zone_header}
          </Text>
          <Text fz="xs" c="dimmed">
            {lang.zone_description}
          </Text>
        </Flex>
      </Grid.Col>
      <Grid.Col span={6}>
        <MultiSelect
          value={data.zones}
          classNames={classes}
          size="xs"
          data={regions}
          label={lang.apply_to}
          onChange={(e) => {
            updateField("zones", e);
          }}
          leftSection={<IconMapPin style={iconStyle} stroke={1.5} />}
        />
      </Grid.Col>
      <Grid.Col span={6}>
        <Select
          classNames={classes}
          size="xs"
          data={Weathers}
          label={lang.weather}
          onChange={(e) => {
            if (!e) return;
            updateField("weather", e);
          }}
          searchable
          leftSection={<IconSun style={iconStyle} stroke={1.5} />}
        />
      </Grid.Col>
      <Grid.Col span={4}>
        <Select
          classNames={classes}
          size="xs"
          value={data.freeze}
          label={lang.freeze}
          data={[
            { value: "yes", label: "Yes" },
            { value: "no", label: "No" },
          ]}
          leftSection={<IconCloudPause style={iconStyle} />}
          allowDeselect
          searchable
          onChange={(e) => {
            updateField("freeze", e);
          }}
        />
      </Grid.Col>
      <Grid.Col span={4}>
        <Select
          classNames={classes}
          size="xs"
          label={lang.fog_level}
          data={fogOptions}
          leftSection={<IconCloudFog style={iconStyle} />}
          searchable
          onChange={(e) => {
            updateField("fog", e);
          }}
        />
      </Grid.Col>
      <Grid.Col span={4}>
        <NumberInput
          classNames={classes}
          size="xs"
          label={`${lang.temperature} (°${type})`}
          allowDecimal={false}
          allowLeadingZeros={false}
          leftSection={<IconTemperature style={iconStyle} />}
          onChange={(e) => {
            updateField("temperature", e);
          }}
        />
      </Grid.Col>
      <Grid.Col span={4}>
        <NumberInput
          classNames={classes}
          size="xs"
          label={`${lang.wind_speed} (0-12)`}
          allowLeadingZeros={false}
          clampBehavior="strict"
          decimalScale={2}
          min={0}
          max={12.0}
          leftSection={<IconWind style={iconStyle} />}
          onChange={(e) => {
            updateField("wind", e);
          }}
        />
      </Grid.Col>
      <Grid.Col span={12}>
        <Box
          display="flex"
          style={{
            position: "absolute",
            bottom: 0,
            right: 0,
            marginBottom: "18px",
          }}
        >
          <Flex direction="column">
            <Text fz="xs" c="dimmed" ml="auto" mr={16}>
              {data.zones.length == 0 ? lang.no_zone : lang.double_click}
            </Text>
            <Group mt={3}>
              <Button
                className={classes.button}
                size="xs"
                ml="auto"
                color="gray"
                disabled={data.zones.length == 0}
                onDoubleClick={() => {
                  handleRandom();
                }}
              >
                {lang.randomize_button}
              </Button>
              <Button
                className={classes.button}
                size="xs"
                color="#0A84FF"
                disabled={data.zones.length == 0}
                mr={16}
                onDoubleClick={() => {
                  handleSave();
                }}
              >
                {lang.apply_button}
              </Button>
            </Group>
          </Flex>
        </Box>
      </Grid.Col>
    </Grid>
  );
};
