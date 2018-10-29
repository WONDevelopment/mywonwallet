<template>
  <div class="access-my-wallet-options">
    <password-modal
      ref="passwordModal"
      :file="file"/>
      
    <network-and-address-modal
      ref="networkandaddressModal"
      :hardware-wallet="hardwareWallet"/>

    <div class="wrap">
      <div class="page-container">
        <div class="title">
          <h2>{{ $t('common.accessMyWallet') }}</h2>
          <h5>
            {{ $t('common.noWallet') }}
            <router-link
              :to="$store.state.wallet === null || $store.state.wallet === undefined ? '/access-my-wallet' : '/interface'"
              class="nounderline">
              {{ $t('common.getAFreeWallet') }}
            </router-link>
          </h5>
        </div>
        <simple-modal 
          ref="simpleModal"
          @passwordOpen="passwordOpen"
          @hardwareWalletOpen="hardwareWalletOpen"
          @file="fileUploaded"/>
      </div>
    </div>

  </div>
</template>

<script>
import SimpleModal from '../../components/SimpleModal';
import NetworkAndAddressModal from '../../components/NetworkAndAddressModal';
import PasswordModal from '../../components/PasswordModal';

export default {
  components: {
    'simple-modal': SimpleModal,
    'password-modal': PasswordModal,
    'network-and-address-modal': NetworkAndAddressModal
  },
  data() {
    return {
      file: {},
      phrase: '',
      hardwareWallet: {},
      hardwareAddresses: [],
      walletConstructor: function() {},
      hardwareBrand: ''
    };
  },
  methods: {
    passwordOpen() {
      this.$refs.passwordModal.$refs.password.show();
    },
    networkAndAddressOpen() {
      this.$refs.networkandaddressModal.$refs.networkAndAddress.show();
    },
    fileUploaded(e) {
      this.file = e;
      this.passwordOpen();
    },
    hardwareWalletOpen(wallet) {
      try {
        this.walletConstructor = function() {};
        this.hardwareBrand = '';
        wallet.getDerivationPath(); // hacky way to check. should throw an error if not ready (need to implement a better mechanism)
        this.hardwareWallet = wallet;
        this.networkAndAddressOpen();
      } catch (e) {
        // eslint-disable-next-line
        console.error(e); // todo replace with proper error
        // close the open modal and present the user with a reason for the error (if appropriate)
      }
    }
  }
};
</script>

<style lang="scss" scoped>
@import 'AccessMyWalletContainer.scss';
</style>
