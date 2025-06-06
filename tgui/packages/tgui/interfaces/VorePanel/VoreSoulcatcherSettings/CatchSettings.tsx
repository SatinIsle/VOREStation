import { useBackend } from 'tgui/backend';
import { Button, LabeledList, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

export const CatchSettings = (props: {
  editMode: boolean;
  catch_self: BooleanLike;
  catch_prey: BooleanLike;
  catch_drain: BooleanLike;
  catch_ghost: BooleanLike;
}) => {
  const { act } = useBackend();

  const { editMode, catch_self, catch_prey, catch_drain, catch_ghost } = props;

  return (
    <LabeledList.Item label="Catch Settings">
      <Stack>
        <Stack.Item>
          <Button
            disabled={!editMode}
            icon="circle-user"
            tooltip={
              (catch_self ? 'Allow' : 'Disallow') +
              ' your own soulcatcher to capture your own soul upon vore death.'
            }
            tooltipPosition="bottom"
            color={catch_self ? 'green' : 'red'}
            onClick={() => act('toggle_self_catching')}
          >
            Catch User
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            disabled={!editMode}
            icon="person"
            tooltip={
              (catch_prey ? 'Allow' : 'Disallow') +
              ' your own soulcatcher to capture prey souls upon vore death.'
            }
            tooltipPosition="bottom"
            color={catch_prey ? 'green' : 'red'}
            onClick={() => act('toggle_prey_catching')}
          >
            Catch Prey
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            disabled={!editMode}
            icon="person-falling-burst"
            tooltip={
              (catch_drain ? 'Allow' : 'Disallow') +
              ' catching prey with draining abilities like "Succubus Drain" (Lethal).'
            }
            tooltipPosition="bottom"
            color={catch_drain ? 'green' : 'red'}
            onClick={() => act('toggle_drain_catching')}
          >
            Catch Drain
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            disabled={!editMode}
            icon="ghost"
            tooltip={
              (catch_ghost ? 'Allow' : 'Disallow') +
              ' ghosts to join your soulcatcher.'
            }
            tooltipPosition="bottom"
            color={catch_ghost ? 'green' : 'red'}
            onClick={() => act('toggle_ghost_catching')}
          >
            Catch Ghost
          </Button>
        </Stack.Item>
      </Stack>
    </LabeledList.Item>
  );
};
