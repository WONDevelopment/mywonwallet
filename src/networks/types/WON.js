import tokens from '@/tokens/tokens-won.json';
import contracts from '@/contracts/contract-abi-won.json';

export default {
  name: 'WON',
  name_long: 'GWON',
  homePage: 'https://bc.1won.com',
  blockExplorerTX: 'https://bc.1won.com/tx/[[txHash]]',
  blockExplorerAddr: 'https://bc.1won.com/address/[[address]]',
  chainID: 1,
  tokens: tokens,
  contracts: contracts,
  ensResolver: '0x314159265dd8dbb310642f98f50c066173c1259b'
};
