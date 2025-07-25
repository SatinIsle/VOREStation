import { useState } from 'react';
import { NtosWindow } from 'tgui/layouts';

import { CrewMonitorContent } from './CrewMonitor/CrewMonitorContent';

export const NtosCrewMonitor = () => {
  const [tabIndex, setTabIndex] = useState<number>(0);
  const [zoom, setZoom] = useState<number>(1);

  return (
    <NtosWindow width={800} height={600}>
      <NtosWindow.Content>
        <CrewMonitorContent
          tabIndex={tabIndex}
          zoom={zoom}
          onTabIndex={setTabIndex}
          onZoom={setZoom}
        />
      </NtosWindow.Content>
    </NtosWindow>
  );
};
