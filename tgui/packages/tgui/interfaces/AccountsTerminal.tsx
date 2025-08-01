import { useBackend, useSharedState } from 'tgui/backend';
import { Window } from 'tgui/layouts';
import {
  Box,
  Button,
  Input,
  LabeledList,
  Section,
  Table,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

type Data = {
  id_inserted: BooleanLike;
  id_card: string;
  access_level: number;
  machine_id: string;
  creating_new_account: BooleanLike;
  detailed_account_view: boolean;
  station_account_number: number;
  account_number: number | null;
  owner_name: string | null;
  money: number | null;
  suspended: BooleanLike;
  transactions: {
    date: string;
    time: string;
    target_name: string;
    purpose: string;
    amount: number;
    source_terminal: string;
  }[];
  accounts: {
    account_number: number;
    owner_name: string;
    suspended: string;
    account_index: number;
  }[];
};

export const AccountsTerminal = (props) => {
  const { act, data } = useBackend<Data>();

  const { id_inserted, id_card, access_level, machine_id } = data;

  return (
    <Window width={400} height={640}>
      <Window.Content scrollable>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Machine" color="average">
              {machine_id}
            </LabeledList.Item>
            <LabeledList.Item label="ID">
              <Button
                icon={id_inserted ? 'eject' : 'sign-in-alt'}
                fluid
                onClick={() => act('insert_card')}
              >
                {id_card}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        {access_level > 0 && <AccountTerminalContent />}
      </Window.Content>
    </Window>
  );
};

const AccountTerminalContent = (props) => {
  const { act, data } = useBackend<Data>();

  const { creating_new_account, detailed_account_view } = data;

  return (
    <Section title="Menu">
      <Tabs>
        <Tabs.Tab
          selected={!creating_new_account && !detailed_account_view}
          icon="home"
          onClick={() => act('view_accounts_list')}
        >
          Home
        </Tabs.Tab>
        <Tabs.Tab
          selected={!!creating_new_account}
          icon="cog"
          onClick={() => act('create_account')}
        >
          New Account
        </Tabs.Tab>
        {!creating_new_account ? (
          <Tabs.Tab icon="print" onClick={() => act('print')}>
            Print
          </Tabs.Tab>
        ) : (
          ''
        )}
      </Tabs>
      {(creating_new_account && <NewAccountView />) ||
        (detailed_account_view && <DetailedView />) || <ListView />}
    </Section>
  );
};

const NewAccountView = (props) => {
  const { act } = useBackend<Data>();

  const [holder, setHolder] = useSharedState('holder', '');
  const [newMoney, setMoney] = useSharedState('money', '');

  return (
    <Section title="Create Account">
      <LabeledList>
        <LabeledList.Item label="Account Holder">
          <Input value={holder} fluid onChange={(val) => setHolder(val)} />
        </LabeledList.Item>
        <LabeledList.Item label="Initial Deposit">
          <Input value={newMoney} fluid onChange={(val) => setMoney(val)} />
        </LabeledList.Item>
      </LabeledList>
      <Button
        disabled={!holder || !newMoney}
        mt={1}
        fluid
        icon="plus"
        onClick={() =>
          act('finalise_create_account', {
            holder_name: holder,
            starting_funds: newMoney,
          })
        }
      >
        Create
      </Button>
    </Section>
  );
};

const DetailedView = (props) => {
  const { act, data } = useBackend<Data>();

  const {
    access_level,
    station_account_number,
    account_number,
    owner_name,
    money,
    suspended,
    transactions,
  } = data;

  return (
    <Section
      title="Account Details"
      buttons={
        <Button
          icon="ban"
          selected={suspended}
          onClick={() => act('toggle_suspension')}
        >
          Suspend
        </Button>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Account Number">
          #{account_number}
        </LabeledList.Item>
        <LabeledList.Item label="Holder">{owner_name}</LabeledList.Item>
        <LabeledList.Item label="Balance">{money}₮</LabeledList.Item>
        <LabeledList.Item label="Status" color={suspended ? 'bad' : 'good'}>
          {suspended ? 'SUSPENDED' : 'Active'}
        </LabeledList.Item>
      </LabeledList>
      <Section title="CentCom Administrator" mt={1}>
        <LabeledList>
          <LabeledList.Item label="Payroll">
            <Button.Confirm
              color="bad"
              fluid
              icon="ban"
              confirmIcon="ban"
              confirmContent="This cannot be undone."
              disabled={account_number === station_account_number}
              onClick={() => act('revoke_payroll')}
            >
              Revoke
            </Button.Confirm>
          </LabeledList.Item>
        </LabeledList>
      </Section>
      {access_level >= 2 && (
        <Section title="Silent Funds Transfer">
          <Button icon="plus" onClick={() => act('add_funds')}>
            Add Funds
          </Button>
          <Button icon="plus" onClick={() => act('remove_funds')}>
            Remove Funds
          </Button>
        </Section>
      )}
      <Section title="Transactions" mt={1}>
        <Table>
          <Table.Row header>
            <Table.Cell>Timestamp</Table.Cell>
            <Table.Cell>Target</Table.Cell>
            <Table.Cell>Reason</Table.Cell>
            <Table.Cell>Value</Table.Cell>
            <Table.Cell>Terminal</Table.Cell>
          </Table.Row>
          {transactions.map((trans, i) => (
            <Table.Row key={i}>
              <Table.Cell>
                {trans.date} {trans.time}
              </Table.Cell>
              <Table.Cell>{trans.target_name}</Table.Cell>
              <Table.Cell>{trans.purpose}</Table.Cell>
              <Table.Cell>{trans.amount}₮</Table.Cell>
              <Table.Cell>{trans.source_terminal}</Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Section>
    </Section>
  );
};

const ListView = (props) => {
  const { act, data } = useBackend<Data>();

  const { accounts } = data;

  return (
    <Section title="NanoTrasen Accounts">
      {(accounts.length && (
        <LabeledList>
          {accounts.map((acc) => (
            <LabeledList.Item
              label={acc.owner_name + acc.suspended}
              color={acc.suspended ? 'bad' : undefined}
              key={acc.account_index}
            >
              <Button
                fluid
                onClick={() =>
                  act('view_account_detail', {
                    account_index: acc.account_index,
                  })
                }
              >
                {`#${acc.account_number}`}
              </Button>
            </LabeledList.Item>
          ))}
        </LabeledList>
      )) || <Box color="bad">There are no accounts available.</Box>}
    </Section>
  );
};
