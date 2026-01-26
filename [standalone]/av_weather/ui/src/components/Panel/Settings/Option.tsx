import { ReactElement } from "react";
import {
  Flex,
  Group,
  Text,
  Tooltip,
  Box,
  Slider,
  Switch,
  NumberInput,
} from "@mantine/core";
import classes from "./style.module.css";

interface Properties {
  header: string;
  tooltip?: string | ReactElement;
  component: string;
  value: any;
  setValue: (field: string, value: any) => void;
  gap?: string | number;
  field: string;
}

export const Option = ({
  header,
  tooltip,
  component,
  value,
  setValue,
  field,
  gap,
}: Properties) => {
  return (
    <Flex
      className={classes.option}
      direction="column"
      p="xs"
      gap={gap ? gap : undefined}
    >
      <Group>
        <Text c="gray.1" fw={500} fz="sm">
          {header}
        </Text>
        {tooltip && (
          <Tooltip label={tooltip} color="dark.9" fz="xs" maw={170} multiline>
            <Box
              ml="auto"
              h={19}
              w={19}
              style={{
                borderRadius: "50px",
                justifyContent: "center",
                alignItems: "center",
                display: "flex",
              }}
            >
              <Text fz="xs" fw={600} c="gray.3">
                ?
              </Text>
            </Box>
          </Tooltip>
        )}
      </Group>
      {component == "slider" && (
        <Slider
          classNames={classes}
          mt="sm"
          size="xs"
          color="cyan.4"
          step={0.1}
          min={0.0}
          max={1.0}
          value={Number(value)}
          onChange={(e) => {
            setValue(field, e);
          }}
        />
      )}
      {component == "switch" && (
        <Switch
          classNames={{
            track: !value ? classes.track : undefined,
          }}
          color="cyan.4"
          size="xs"
          checked={Boolean(value)}
          label={value ? `Enabled` : `Disabled`}
          onChange={(e) => {
            setValue(field, e.currentTarget.checked);
          }}
        />
      )}
      {component == "number" && (
        <NumberInput
          classNames={classes}
          size="xs"
          allowDecimal={false}
          allowLeadingZeros={false}
          allowNegative={false}
          min={0}
          max={100000}
          value={value}
          onChange={(e) => {
            setValue(field, e);
          }}
        />
      )}
    </Flex>
  );
};
