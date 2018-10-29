import nodeList from '@/networks';
const state = {
  web3: {},
  network: {
    auth: false,
    password: '',
    port: 443,
    service: 'wallet.1won.com',
    type: {
      blockExplorerAddr: 'https://ropsten.etherscan.io/address/[[txHash]]',
      blockExplorerTX: 'https://ropsten.etherscan.io/tx/[[txHash]]',
      chainID: 1,
      contracts: [],
      homePage: 'https://github.com/ethereum/ropsten',
      name: 'ROP',
      name_long: 'Ropsten',
      tokens: []
    },
    url: 'https://bc.1won.com',
    username: ''
  },
  wallet: null,
  account: {
    balance: 0
  },
  Transactions: {},
  Networks: nodeList,
  Errors: {},
  online: true,
  pageStates: {
    interface: {
      sideMenu: 'send'
    }
  },
  customPaths: {},
  notifications: {},
  gasPrice: 10,
  ens: {}
};

export default state;
