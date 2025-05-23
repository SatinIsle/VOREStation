import { useBackend } from 'tgui/backend';
import { Box, Button, LabeledList, Section, Stack } from 'tgui-core/components';

import type { Data } from './types';

export const AtmoControlFuel = (props) => {
  const { act, data } = useBackend<Data>();

  const { automation, device_info } = data;
  return (
    <Section
      title="Fuel Injection System"
      buttons={
        <Stack>
          <Stack.Item>
            <Button
              icon="syringe"
              onClick={() => act('injection')}
              disabled={automation || !device_info}
            >
              Inject
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button icon="sync" onClick={() => act('refresh_status')}>
              Refresh
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="power-off"
              onClick={() => act('toggle_injector')}
              selected={device_info ? device_info.power : false}
              disabled={automation || !device_info}
            >
              Injector Power
            </Button>
          </Stack.Item>
        </Stack>
      }
    >
      {device_info ? (
        <LabeledList>
          <LabeledList.Item label="Status">
            {device_info.power ? 'Injecting' : 'On Hold'}
          </LabeledList.Item>
          <LabeledList.Item label="Rate">
            {device_info.volume_rate}
          </LabeledList.Item>
          <LabeledList.Item label="Automated Fuel Injection">
            <Button
              icon="robot"
              selected={automation}
              onClick={() => act('toggle_automation')}
            >
              {automation ? 'Engaged' : 'Disengaged'}
            </Button>
          </LabeledList.Item>
        </LabeledList>
      ) : (
        <>
          <Box color="bad">ERROR: Cannot Find Device</Box>
          <Button icon="search" onClick={() => act('refresh_status')}>
            Search
          </Button>
        </>
      )}
    </Section>
  );
};
