import { Flex, Box, Image, Text, Select, Group } from "@mantine/core";
import { ZoneInfo } from "../../../../types/types";
import classes from "./style.module.css";
import { Loading } from "../../../Loading";
import { useRecoilValue } from "recoil";
import { Lang, Regions } from "../../../../reducers/atoms";

interface Properties {
  info: ZoneInfo;
  loaded: boolean;
  handleZone: (option: string) => void;
}

export const Zone = ({ info, handleZone, loaded }: Properties) => {
  const lang: any = useRecoilValue(Lang);
  const regions = useRecoilValue(Regions);
  if (!loaded) return <Loading />;
  return (
    <Flex
      direction="column"
      style={{ justifyContent: "center", width: "100%", textAlign: "center" }}
      gap={0}
    >
      <Select
        data={regions}
        size="xs"
        value={info.name}
        onOptionSubmit={(e) => {
          if (!e) return;
          handleZone(e);
        }}
        classNames={classes}
      />
      <Group justify="space-between" mt="sm">
        <Text fw={600} c="#64D2FF" lts={0.25}>
          {info.weather}
        </Text>
        <Text fw={500} c={info.freeze ? `red` : `green`} fz="sm">{`${
          info.freeze ? lang.frozen : lang.not_frozen
        }`}</Text>
      </Group>
      <Box className={classes.icon} mt={"md"}>
        <Image
          className={classes.image}
          src={`./icons/${info.time}/${info.weather}.png`}
          h={145}
          w={145}
          mr="auto"
          ml="auto"
          p="sm"
        />
        <Image
          className={classes.blurred}
          src={`./icons/${info.time}/${info.weather}.png`}
          h={145}
          w={145}
          mr="auto"
          ml="auto"
        />
      </Box>

      <Group
        mt={4}
        style={{
          position: "absolute",
          bottom: 0,
          width: "100%",
          marginBottom: "10px",
        }}
      >
        <Flex direction="column" gap={0} ta="left">
          <Text fz="lg" fw={600}>{`${info.temperature} ° ${info.type}`}</Text>
          <Text fz="sm" c="dimmed">
            {lang.temperature}
          </Text>
        </Flex>
        <Flex direction="column" gap={0} ta="right" ml="auto" mr="xl">
          <Text fz="lg" fw={600}>{`${info.wind} m/s`}</Text>
          <Text fz="sm" c="dimmed">
            {lang.wind_speed}
          </Text>
        </Flex>
      </Group>
    </Flex>
  );
};
