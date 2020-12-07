import React, { useReducer } from 'react';
import RtmAdapter from '../rtm-adapter';

interface IAppMutations {
  setChannel(channel: string): void;

  setMessages(messages: any[]): void;
}

interface IAppContext {
  channel: string | any;
  messages: any[];
  client: RtmAdapter;
}

const defaultProps: IAppContext & IAppMutations = {
  channel: null,
  messages: [],
  client: new RtmAdapter(),
  setChannel(_: string) {},
  setMessages(_: any[]) {},
};

export type AppContextType = IAppContext & IAppMutations;

function mutation(state: any, action: any) {
  switch (action.type) {
    case 'messages': {
      return { ...state, messages: action.payload };
    }
    case 'channel': {
      return { ...state, channel: action.payload };
    }
    default:
      throw new Error('mutation type not defined');
  }
}

export const AppContext: React.Context<AppContextType> = React.createContext<AppContextType>(
  defaultProps
);
export const AppContainer = ({ children }: any) => {
  const [state, dispatch] = useReducer(mutation, defaultProps);

  const context: AppContextType = {
    ...state,
    setMessages(messages: []) {
      dispatch({
        type: 'messages',
        payload: messages,
      });
    },
    setChannel(channel: string) {
      dispatch({
        type: 'channel',
        payload: channel,
      });
    },
  };
  return <AppContext.Provider value={context}>{children}</AppContext.Provider>;
};
