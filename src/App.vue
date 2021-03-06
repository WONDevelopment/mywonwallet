<template>
  <div id="app">
    <header-container/>
    <router-view/>
    <confirmation-container/>
  </div>
</template>

<script>
import HeaderContainer from '@/containers/HeaderContainer';
import ConfirmationContainer from '@/containers/ConfirmationContainer';
import store from 'store';
import nodeList from '@/networks';
import ENS from 'worldopennetwork-ens';
import url from 'url';
import Web3 from 'won-web3';

export default {
  name: 'App',
  components: {
    'header-container': HeaderContainer,
    'confirmation-container': ConfirmationContainer
  },
  mounted() {
    // Can't use before mount because that lifecycle isn't called if serving via static files
    const network =
      store.get('network') !== undefined
        ? store.get('network')
        : this.$store.state.Networks['WON'][0];
    const hostUrl = url.parse(network.url);
    const newWeb3 = new Web3(
      `${hostUrl.protocol}//${hostUrl.hostname}:${network.port}${
        hostUrl.pathname
      }`
    );
    const sideMenu =
      store.get('sideMenu') !== undefined ? store.get('sideMenu') : 'send';
    const notifications =
      store.get('notifications') !== undefined
        ? store.get('notifications')
        : {};
    const gasPrice =
      store.get('gasPrice') !== undefined ? store.get('gasPrice') : 41;
    const state = {
      web3: newWeb3,
      network: network,
      customPaths:
        store.get('customPaths') !== undefined ? store.get('customPaths') : {},
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
          sideMenu: sideMenu
        }
      },
      notifications: notifications,
      gasPrice: gasPrice,
      ens:
        network.type.ensResolver !== ''
          ? new ENS(newWeb3.currentProvider, network.type.ensResolver)
          : {}
    };
    if (store.get('notifications') === undefined)
      store.set('notifications', {});
    this.$store.dispatch('setState', state);
    this.$store.dispatch('checkIfOnline');
    this.$store.dispatch('switchNetwork', network);
  }
};
</script>

<style lang="scss">
@import 'App.scss';
</style>
