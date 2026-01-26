import { Stack, ActionIcon } from "@mantine/core";
import { IconCloud, IconPower, IconAdjustmentsHorizontal } from "@tabler/icons-react";
import { fetchNui } from "../../../hooks/useNuiEvents";
import classes from "./style.module.css";

interface Properties {
  tab: string;
  setTab: (option: string) => void;
}

export const Navbar = ({ tab, setTab }: Properties) => {
  const iconStyle = { width: "1.35rem", height: "1.35rem" };
  const handleClose = () => {
    fetchNui("av_weather", "close");
  };

  return (
    <Stack className={classes.stack} p={10}>
      <ActionIcon
        variant="transparent"
        onClick={() => {
          setTab("weather");
        }}
        color={tab == "weather" ? `#64D2FF` : `gray`}
      >
        <IconCloud style={iconStyle} />
      </ActionIcon>
      <ActionIcon
        variant="transparent"
        onClick={() => {
          setTab("settings");
        }}
        color={tab == "settings" ? `#64D2FF` : `gray`}
      >
        <IconAdjustmentsHorizontal style={iconStyle} />
      </ActionIcon>
      <ActionIcon
        variant="transparent"
        onClick={() => {
          handleClose();
        }}
        style={{
          position: "absolute",
          bottom: 0,
          marginBottom: "15px",
        }}
        color="red.4"
      >
        <IconPower style={iconStyle} />
      </ActionIcon>
    </Stack>
  );
};
