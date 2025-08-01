import { useBackend } from 'tgui/backend';
import { NanoMap } from 'tgui/components';
import { Box } from 'tgui-core/components';

import { getStatColor } from './functions';
import type { Data } from './types';

export const CrewMonitorMapView = (props: {
  zoom: number;
  onZoom: React.Dispatch<React.SetStateAction<number>>;
}) => {
  const { config, data } = useBackend<Data>();

  const { crewmembers } = data;

  return (
    <Box height="526px" mb="0.5rem" overflow="hidden">
      <NanoMap onZoom={(v: number) => props.onZoom(v)}>
        {crewmembers
          .filter(
            (x) => x.sensor_type === 3 && ~~x.realZ === ~~config.mapZLevel,
          )
          .map((cm) => (
            <NanoMap.Marker
              key={cm.ref}
              x={cm.x}
              y={cm.y}
              zoom={props.zoom}
              icon="circle"
              tooltip={`${cm.name} (${cm.assignment})`}
              color={getStatColor(cm)}
            />
          ))}
      </NanoMap>
    </Box>
  );
};
