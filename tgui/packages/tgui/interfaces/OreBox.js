import { useBackend } from '../backend';
import { Window, Stack, Button } from '../layouts';

export const Smartfridge = (props, context) => {
  const { act, data } = useBackend(context);
  const {contents} = data;

  return(
    <Window width = {500} height = {500}>
      <Stack fill vertical>
      {!contents && (
              <Stack fill>
                <Stack.Item
                  bold
                  grow
                  textAlign="center"
                  align="center"
                  color="average"
                >
                  <br/>
                  Empty.
                </Stack.Item>
              </Stack>
            )}
      </Stack>
    </Window>
  )
};
