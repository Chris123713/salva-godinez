import { useEffect, useState } from "react";
import {
  Group,
  Flex,
  Grid,
  Text,
  NumberInput,
  Select,
  Button,
} from "@mantine/core";
import classes from "./styles.module.css";
import {
  fetchNui,
  isEnvBrowser,
  useNuiEvent,
} from "../../../../hooks/useNuiEvents";
import { Loading } from "../../../Loading";
import { useRecoilValue } from "recoil";
import { Lang } from "../../../../reducers/atoms";

function formatTime(hour: number, minutes: number): string {
  if (hour < 0 || hour > 23) {
    throw new Error("Hour must be between 0 and 23.");
  }
  if (minutes < 0 || minutes > 59) {
    throw new Error("Minutes must be between 0 and 59.");
  }
  const formattedHour = hour < 10 ? `0${hour}` : `${hour}`;
  const formattedMinutes = minutes < 10 ? `0${minutes}` : `${minutes}`;
  return `${formattedHour}:${formattedMinutes}`;
}

export const GlobalControls = () => {
  const lang: any = useRecoilValue(Lang);
  const [clock, setClock] = useState({ hour: 0, minutes: 0 });
  const [data, setData] = useState({
    freezeTime: "no",
    transition: "1",
    moon: "0.5",
  });
  const [loaded, setLoaded] = useState(isEnvBrowser());
  const handleChange = (field: string, value: any) => {
    const copy = { ...data, [field]: value };
    setData(copy);
  };
  const handleSave = () => {
    fetchNui("av_weather", "updateServer", data);
  };
  const toggleBlackout = () => {
    fetchNui("av_weather", "blackout");
  };
  useNuiEvent("clock", (data: any) => {
    const copy = { ...clock, hour: data.hours, minutes: data.minutes };
    setClock(copy);
  });
  useEffect(() => {
    const fetchServer = async () => {
      const resp = await fetchNui("av_weather", "getServer");
      if (resp) {
        if (resp.moon) {
          const copy = { ...data, moon: resp.moon };
          setData(copy);
        }
        if (resp.freezeTime) {
          const copy = { ...data, freezeTime: resp.freezeTime };
          setData(copy);
        }
        if (resp.hour && resp.minutes) {
          setClock({ hour: resp.hour, minutes: resp.minutes });
        }
      }
      setTimeout(() => {
        setLoaded(true);
      }, 50);
    };
    fetchServer();
  }, []);
  if (!loaded) return <Loading />;
  return (
    <Grid gutter={0}>
      <Grid.Col span={12}>
        <Group>
          <Flex direction="column">
            <Text fw={600} c="#64D2FF" lts={0.25}>
              {lang.global_header}
            </Text>
            <Text fz="xs" c="dimmed">
              {lang.global_description}
            </Text>
          </Flex>
          <Flex direction="column" ml="auto">
            <Text fw={600} c="#64D2FF" lts={0.25} ta="end">
              {formatTime(clock.hour, clock.minutes)}
            </Text>
            <Text fz="xs" c="dimmed">
              {lang.server_time}
            </Text>
          </Flex>
        </Group>
      </Grid.Col>
      <Grid.Col span={2.5} mt="sm">
        <Flex direction="column" gap={0}>
          <Text fz={"xs"} fw={500} mt={-1}>
            {`${lang.server_time} (HH:MM)`}
          </Text>
          <Group gap={2} mt={2}>
            <NumberInput
              classNames={classes}
              w={50}
              size="xs"
              allowDecimal={false}
              allowLeadingZeros={false}
              allowNegative={false}
              min={0}
              max={23}
              clampBehavior="strict"
              hideControls
              onChange={(e) => {
                handleChange("hour", e);
              }}
            />
            :
            <NumberInput
              classNames={classes}
              w={50}
              size="xs"
              allowDecimal={false}
              allowLeadingZeros={false}
              allowNegative={false}
              min={0}
              max={59}
              clampBehavior="strict"
              hideControls
              onChange={(e) => {
                handleChange("minutes", e);
              }}
            />
          </Group>
        </Flex>
      </Grid.Col>
      <Grid.Col span={2.5} mt="sm">
        <Select
          mt={-5}
          w={125}
          classNames={classes}
          label={lang.freeze_time}
          size="xs"
          value={data.freezeTime}
          data={[
            { value: "yes", label: "Yes" },
            { value: "no", label: "No" },
          ]}
          searchable
          onChange={(e) => {
            handleChange("freezeTime", e);
          }}
        />
      </Grid.Col>
      <Grid.Col span={3} mt="sm" ml={"xs"}>
        <Select
          mt={-5}
          classNames={classes}
          w={150}
          label={lang.moon}
          value={data.moon}
          size="xs"
          searchable
          data={[
            { value: "0.1", label: lang.moon_1 },
            { value: "0.2", label: lang.moon_2 },
            { value: "0.3", label: lang.moon_3 },
            { value: "0.5", label: lang.moon_4 },
            { value: "0.7", label: lang.moon_5 },
            { value: "0.8", label: lang.moon_6 },
            { value: "0.9", label: lang.moon_7 },
          ]}
          onChange={(e) => {
            handleChange("moon", e);
          }}
        />
      </Grid.Col>
      <Grid.Col span={3} mt="sm" ml={"xs"}>
        <Select
          mt={-5}
          classNames={classes}
          label={lang.transition}
          value={data.transition}
          size="xs"
          searchable
          data={[
            { value: "0", label: lang.instant },
            { value: "1", label: lang.progressive },
          ]}
          onChange={(e) => {
            handleChange("transition", e);
          }}
        />
      </Grid.Col>
      <Grid.Col span={12} mt="xs" mr="xs" style={{ zIndex: 1 }}>
        <Flex direction="column" gap={0} mt={10}>
          <Text fz="xs" c="dimmed" ml="auto">
            {lang.double_click}
          </Text>
          <Group mt={3}>
            <Button
              size="xs"
              color="gray"
              ml="auto"
              onDoubleClick={() => {
                toggleBlackout();
              }}
            >
              {lang.blackout}
            </Button>
            <Button
              size="xs"
              color="#0A84FF"
              onDoubleClick={() => {
                handleSave();
              }}
            >
              {lang.apply_button}
            </Button>
          </Group>
        </Flex>
      </Grid.Col>
    </Grid>
  );
};
