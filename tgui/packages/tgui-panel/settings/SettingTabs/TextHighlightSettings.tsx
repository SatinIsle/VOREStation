import { useDispatch, useSelector } from 'tgui/backend';
import {
  Box,
  Button,
  ColorBox,
  Divider,
  Input,
  Section,
  Stack,
  TextArea,
} from 'tgui-core/components';

import { rebuildChat } from '../../chat/actions';
import {
  addHighlightSetting,
  removeHighlightSetting,
  updateHighlightSetting,
} from '../actions';
import { MAX_HIGHLIGHT_SETTINGS } from '../constants';
import {
  selectHighlightSettingById,
  selectHighlightSettings,
} from '../selectors';

export const TextHighlightSettings = (props) => {
  const highlightSettings = useSelector(selectHighlightSettings);
  const dispatch = useDispatch();
  return (
    <Section fill scrollable height="235px">
      <Section p={0}>
        <Stack direction="column">
          {highlightSettings.map((id, i) => (
            <TextHighlightSetting
              key={i}
              id={id}
              mb={i + 1 === highlightSettings.length ? 0 : '10px'}
            />
          ))}
          {highlightSettings.length < MAX_HIGHLIGHT_SETTINGS && (
            <Stack.Item>
              <Button
                color="transparent"
                icon="plus"
                onClick={() => {
                  dispatch(addHighlightSetting());
                }}
              >
                Add Highlight Setting
              </Button>
            </Stack.Item>
          )}
        </Stack>
      </Section>
      <Divider />
      <Box>
        <Button icon="check" onClick={() => dispatch(rebuildChat())}>
          Apply now
        </Button>
        <Box inline fontSize="0.9em" ml={1} color="label">
          Can freeze the chat for a while.
        </Box>
      </Box>
    </Section>
  );
};

const TextHighlightSetting = (props) => {
  const { id, ...rest } = props;
  const highlightSettingById = useSelector(selectHighlightSettingById);
  const dispatch = useDispatch();
  const {
    highlightColor,
    highlightText,
    blacklistText,
    highlightWholeMessage,
    highlightBlacklist,
    matchWord,
    matchCase,
  } = highlightSettingById[id];
  return (
    <Stack.Item {...rest}>
      <Stack mb={1} color="label" align="baseline">
        <Stack.Item grow>
          <Button
            color="transparent"
            icon="times"
            onClick={() =>
              dispatch(
                removeHighlightSetting({
                  id: id,
                }),
              )
            }
          >
            Delete
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            checked={highlightBlacklist}
            tooltip="If this option is selected, you can blacklist senders not to highlight their messages."
            mr="5px"
            onClick={() =>
              dispatch(
                updateHighlightSetting({
                  id: id,
                  highlightBlacklist: !highlightBlacklist,
                }),
              )
            }
          >
            Highlight Blacklist
          </Button.Checkbox>
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            checked={highlightWholeMessage}
            tooltip="If this option is selected, the entire message will be highlighted in yellow."
            mr="5px"
            onClick={() =>
              dispatch(
                updateHighlightSetting({
                  id: id,
                  highlightWholeMessage: !highlightWholeMessage,
                }),
              )
            }
          >
            Whole Message
          </Button.Checkbox>
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            checked={matchWord}
            tooltipPosition="bottom-start"
            tooltip="If this option is selected, only exact matches (no extra letters before or after) will trigger. Not compatible with punctuation. Overriden if regex is used."
            onClick={() =>
              dispatch(
                updateHighlightSetting({
                  id: id,
                  matchWord: !matchWord,
                }),
              )
            }
          >
            Exact
          </Button.Checkbox>
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            tooltip="If this option is selected, the highlight will be case-sensitive."
            checked={matchCase}
            onClick={() =>
              dispatch(
                updateHighlightSetting({
                  id: id,
                  matchCase: !matchCase,
                }),
              )
            }
          >
            Case
          </Button.Checkbox>
        </Stack.Item>
        <Stack.Item shrink={0}>
          <ColorBox mr={1} color={highlightColor} />
          <Input
            width="5em"
            monospace
            placeholder="#ffffff"
            value={highlightColor}
            onBlur={(value) =>
              dispatch(
                updateHighlightSetting({
                  id: id,
                  highlightColor: value,
                }),
              )
            }
          />
        </Stack.Item>
      </Stack>
      <TextArea
        fluid
        height="3em"
        value={highlightText}
        placeholder="Put words to highlight here. Separate terms with commas, i.e. (term1, term2, term3)"
        onBlur={(value) =>
          dispatch(
            updateHighlightSetting({
              id: id,
              highlightText: value,
            }),
          )
        }
      />
      {!!highlightBlacklist && (
        <TextArea
          fluid
          height="3em"
          value={blacklistText}
          placeholder="Put names of senders you don't want highlighted here. Separate names with commas, i.e. (name1, name2, name3)"
          onBlur={(value) =>
            dispatch(
              updateHighlightSetting({
                id: id,
                blacklistText: value,
              }),
            )
          }
        />
      )}
    </Stack.Item>
  );
};
