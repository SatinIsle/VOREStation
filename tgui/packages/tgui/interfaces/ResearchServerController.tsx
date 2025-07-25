import { useBackend, useSharedState } from 'tgui/backend';
import { Window } from 'tgui/layouts';
import { Box, Button, LabeledList, Section, Tabs } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

type Data = { badmin: BooleanLike; servers: server[]; consoles: console[] };

type server = {
  name: string;
  ref: string;
  id: number;
  id_with_upload: string[];
  id_with_download: string[];
  tech: techDes[];
  designs: techDes[];
};

type techDes = { name: string; id: string };

type console = { name: string; ref: string; loc: string; id: number };

export const ResearchServerController = (props) => {
  return (
    <Window width={575} height={430}>
      <Window.Content scrollable>
        <ResearchControllerContent />
      </Window.Content>
    </Window>
  );
};

const ResearchControllerContent = (props) => {
  const { data } = useBackend<Data>();

  const { servers } = data;

  const [selectedServer, setSelectedServer] = useSharedState<number | null>(
    'selectedServer',
    null,
  );

  const realServer = servers.find((s) => s.id === selectedServer);

  if (realServer) {
    return (
      <ResearchServer
        setSelectedServer={setSelectedServer}
        server={realServer!}
      />
    );
  }

  return (
    <Section title="Server Selection">
      {servers.map((server) => (
        <Box key={server.name}>
          <Button icon="eye" onClick={() => setSelectedServer(server.id)}>
            {server.name}
          </Button>
        </Box>
      ))}
    </Section>
  );
};

const ResearchServer = (props: {
  server: server;
  setSelectedServer: React.Dispatch<React.SetStateAction<number | null>>;
}) => {
  const { data } = useBackend<Data>();
  const { badmin } = data;
  const { server, setSelectedServer } = props;

  const [tab, setTab] = useSharedState<number>('tab', 0);

  return (
    <Section
      title={server.name}
      buttons={
        <Button icon="undo" onClick={() => setSelectedServer(null)}>
          Back
        </Button>
      }
    >
      <Tabs>
        <Tabs.Tab selected={tab === 0} onClick={() => setTab(0)}>
          Access Rights
        </Tabs.Tab>
        <Tabs.Tab selected={tab === 1} onClick={() => setTab(1)}>
          Data Management
        </Tabs.Tab>
        {(badmin && (
          <Tabs.Tab selected={tab === 2} onClick={() => setTab(2)} color="red">
            Server-to-Server Transfer
          </Tabs.Tab>
        )) ||
          null}
      </Tabs>
      {(tab === 0 && <ResearchServerAccess server={server} />) || null}
      {(tab === 1 && <ResearchServerData server={server} />) || null}
      {(tab === 2 && badmin && <ResearchServerTransfer server={server} />) ||
        null}
    </Section>
  );
};

const ResearchServerAccess = (props: { server: server }) => {
  const { act, data } = useBackend<Data>();
  const { server } = props;

  const { consoles } = data;

  const hasUploadAccess = (server, console) => {
    if (server.id_with_upload.indexOf(console.id) !== -1) {
      return true;
    }
    return false;
  };

  const hasDownloadAccess = (server, console) => {
    if (server.id_with_download.indexOf(console.id) !== -1) {
      return true;
    }
    return false;
  };

  return (
    <Section title="Consoles">
      <LabeledList>
        {consoles.length &&
          consoles.map((console) => (
            <LabeledList.Item
              key={console.name}
              label={`${console.name} (${console.loc})`}
            >
              <Button
                icon={hasUploadAccess(server, console) ? 'lock-open' : 'lock'}
                selected={hasUploadAccess(server, console)}
                onClick={() =>
                  act('toggle_upload', {
                    server: server.ref,
                    console: console.ref,
                  })
                }
              >
                {hasUploadAccess(server, console) ? 'Upload On' : 'Upload Off'}
              </Button>
              <Button
                icon={hasDownloadAccess(server, console) ? 'lock-open' : 'lock'}
                selected={hasDownloadAccess(server, console)}
                onClick={() =>
                  act('toggle_download', {
                    server: server.ref,
                    console: console.ref,
                  })
                }
              >
                {hasDownloadAccess(server, console)
                  ? 'Download On'
                  : 'Download Off'}
              </Button>
            </LabeledList.Item>
          ))}
      </LabeledList>
    </Section>
  );
};

const ResearchServerData = (props: { server: server }) => {
  const { act } = useBackend();
  const { server } = props;

  return (
    <>
      <Section title="Research Levels">
        {server.tech.map((tech) => (
          <LabeledList.Item
            label={tech.name}
            key={tech.name}
            buttons={
              <Button.Confirm
                icon="trash"
                confirmIcon="trash"
                color="red"
                onClick={() =>
                  act('reset_tech', { server: server.ref, tech: tech.id })
                }
              >
                Reset
              </Button.Confirm>
            }
          />
        ))}
      </Section>
      <Section title="Designs">
        {server.designs
          .filter((design: techDes) => !!design.name)
          .map((design) => (
            <LabeledList.Item
              label={design.name}
              key={design.name}
              buttons={
                <Button.Confirm
                  icon="trash"
                  confirmIcon="trash"
                  color="red"
                  onClick={() =>
                    act('reset_design', {
                      server: server.ref,
                      design: design.id,
                    })
                  }
                >
                  Delete
                </Button.Confirm>
              }
            />
          ))}
      </Section>
    </>
  );
};

const ResearchServerTransfer = (props: { server: server }) => {
  const { act, data } = useBackend<Data>();

  const { server } = props;

  const { badmin, servers } = data;

  if (!badmin) {
    return null;
  }

  return (
    <Section title="Server Data Transfer">
      {servers.map((newserver) => (
        <Box key={newserver.name}>
          <Button.Confirm
            fluid
            color="bad"
            onClick={() =>
              act('transfer_data', {
                server: server.ref,
                target: newserver.ref,
              })
            }
          >
            <Box>
              Transfer from {server.name} To {newserver.name}
            </Box>
          </Button.Confirm>
        </Box>
      ))}
    </Section>
  );
};
