<template>
  <b-modal
    ref="hardware"
    :title="$t('accessWallet.accessByHardware')"
    hide-footer
    class="bootstrap-modal modal-hardware"
    centered>
    <div class="d-block text-center">
      <span v-show="mayNotBeAttached">(TEMP implementation) Please check if your device is connected</span>
      <ul
        ref="hardwareList"
        class="button-options hardware-button-options">
        <li
          :class="selected === 'trezor'? 'active': ''"
          @click="select('trezor')">
          <img
            class="icon"
            src="~@/assets/images/icons/button-trezor.png">
          <img
            class="icon-hover"
            src="~@/assets/images/icons/button-trezor-hover.png">
          <span>Trezor</span>
        </li>
      </ul>
    </div>
    <div class="button-container">
      <!--<div class="mid-round-button-green-filled connection-button waiting-for-connection" v-on:click="networkAndAddressOpen">-->
      <!--<div class="mid-round-button-green-filled connection-button waiting-for-connection" @click="continueAccess">-->
      <div
        :class="[selected !== ''? 'enabled': 'disabled','mid-round-button-green-filled']"
        @click="continueAccess">
        {{ $t("accessWallet.accessDeviceAddresses") }}
      </div>
    </div>
    <customer-support/>
  </b-modal>
</template>

<script>
import CustomerSupport from '@/components/CustomerSupport';
import {
  LedgerWallet,
  TrezorWallet,
  DigitalBitboxWallet,
  SecalotWallet
} from '@/wallets';

export default {
  components: {
    'customer-support': CustomerSupport
  },
  props: {
    networkAndAddressOpen: {
      type: Function,
      default: function() {}
    },
    hardwareWalletOpen: {
      type: Function,
      default: function() {}
    }
  },
  data() {
    return {
      selected: '',
      mayNotBeAttached: false
    };
  },
  mounted() {
    this.$refs.hardware.$on('hidden', () => {
      this.selected = '';
    });
  },
  methods: {
    continueAccess() {
      // todo The actual initiation of a hardware wallet should be moved to a specific file to reduce clutter here as the number of offerings increases
      // todo: and to allow for any specialized set-up steps a particular constructor/wallet may require
      const showPluggedInReminder = setTimeout(() => {
        this.mayNotBeAttached = true;
      }, 1000);
      switch (this.selected) {
        case 'ledger':
          LedgerWallet.unlock()
            .then(wallet => {
              clearTimeout(showPluggedInReminder);
              this.$emit('hardwareWalletOpen', wallet);
            })
            .catch(_error => {
              // eslint-disable-next-line
              console.error(_error); // todo replace with proper error
            });
          break;
        case 'trezor':
          TrezorWallet.unlock()
            .then(wallet => {
              clearTimeout(showPluggedInReminder);
              this.$emit('hardwareWalletOpen', wallet);
            })
            .catch(_error => {
              // eslint-disable-next-line
              console.error(_error); // todo replace with proper error
            });
          break;
        case 'bitbox':
          this.$emit('hardwareRequiresPassword', {
            walletConstructor: DigitalBitboxWallet,
            hardwareBrand: 'DigitalBitbox'
          });
          break;
        case 'secalot':
          this.$emit('hardwareRequiresPassword', {
            walletConstructor: SecalotWallet,
            hardwareBrand: 'Secalot'
          });
          break;
        default:
          // eslint-disable-next-line
          console.error('something not right'); // todo remove dev item
          break;
      }
    },
    select(ref) {
      if (this.selected !== ref) {
        this.selected = ref;
      } else {
        this.selected = '';
      }
    },
    hardwareButtonActivate(e) {
      const buttonEls = this.$refs.hardwareList.children;
      for (let i = 0; i < buttonEls.length; i++) {
        buttonEls[i].classList.remove('active');
      }

      e.target.classList.add('active');
    }
  }
};
</script>

<style lang="scss" scoped>
@import 'HardwareModal.scss';
</style>
