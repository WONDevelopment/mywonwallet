<template>
  <div class="generate-info">
    <div class="wrap">

      <div class="send-form">
        <div class="form-block amount-to-address">
          <div class="amount">
            <div class="title">
              <h4>Amount</h4>
            </div>
            <currency-picker
              :currency="coinType"
              :token="true"
              page="sendOfflineGenTx"/>
            <div class="the-form amount-number">
              <input
                v-model="toAmt"
                type="number"
                name=""
                placeholder="Deposit Amount">
              <i
                :class="[toAmt ==0 ? 'not-good': '','fa fa-check-circle good-button']"
                aria-hidden="true"/>
            </div>
          </div>
          <div class="to-address">
            <div class="title">
              <h4>To Address</h4>
              <blockie
                v-show="(address !== '' || resolvedAddress !== '') && !validAddress"
                :address="address !== '' ? address: resolvedAddress !== ''? resolvedAddress:''"
                width="22px"
                height="22px"/>
              <p
                class="copy-button linker-1 prevent-user-select"
                @click="copyToAddress">Copy</p>
            </div>
            <div class="the-form address-block">
              <textarea
                v-ens-resolver="address"
                ref="toaddress"
                v-model="address"
                name="name"
                placeholder="Please Enter The Address"/>
              <i
                :class="[validAddress ? '':'not-good', 'fa fa-check-circle good-button']"
                aria-hidden="true"/>
            </div>
          </div>
        </div>
        <div
          v-show="false"
          class="error-message-container">
          <p>You don't have enough funds</p>
        </div>
      </div>

      <div 
        v-show="false" 
        class="send-form">
        <div class="title-container">
          <div class="title">
            <div class="title-helper">
              <h4>Data</h4>
              <popover :popcontent="$t('popover.whatIsDataContent')"/>
            </div>
          </div>
        </div>
        <div class="the-form gas-amount">
          <input
            v-model="toData"
            type="text"
            name=""
            placeholder="e.g. 0x65746865726d696e652d657531" >
          <div class="good-button-container">
            <i
              :class="[isValidData ? '':'not-good', 'fa fa-check-circle good-button']"
              aria-hidden="true"/>
          </div>
        </div>
      </div>
      <tx-speed-input
        :nonce="locNonce"
        :data="toData"
        :to-address="address"
        :gas-limit="gasLimit"
        @nonceUpdate="nonceUpdated"
        @gasLimitUpdate="gasLimitUpdated"/>
      <div class="submit-button-container">
        <div
          :class="[!validAddress || toAmt ==0 || !isValidData ? 'disabled': '' ,'submit-button large-round-button-green-filled']"
          @click="next">
          Generate
        </div>
        <interface-bottom-text
          link="/"
          question="Have issues?"
          link-text="Learn More"/>
      </div>

    </div>
    <signed-tx-modal
      :signed-tx="signed"
      :raw-tx="raw"
      :path-update="pathUpdate"/>
  </div>
</template>

<script>
import InterfaceBottomText from '@/components/InterfaceBottomText';
import TxSpeedInput from '../../components/TxSpeedInput';
import CurrencyPicker from '../CurrencyPicker';
import SignedTxModal from '../../components/SignedTxModal';
import Blockie from '@/components/Blockie';
// eslint-disable-next-line
const EthTx = require('ethereumjs-tx')
// eslint-disable-next-line

export default {
  components: {
    'interface-bottom-text': InterfaceBottomText,
    'tx-speed-input': TxSpeedInput,
    blockie: Blockie,
    'signed-tx-modal': SignedTxModal,
    'currency-picker': CurrencyPicker
  },
  props: {
    gasLimit: {
      type: Number,
      default: 0
    },
    nonce: {
      type: Number,
      default: 0
    }
  },
  data() {
    return {
      toAmt: 0,
      address: '',
      toData: '0x',
      parsedBalance: 0,
      coinType: [{ symbol: 'Ŵ', name: 'WON' }],
      selectedCoinType: '',
      raw: {},
      signed: '',
      locNonce: this.nonce,
      validAddress: false,
      resolvedAddress: '',
      unit: this.$store.state.web3.utils
    };
  },
  computed: {
    isValidData: function() {
      return /^0x[0-9a-fA-F]*$/.test(this.toData);
    }
  },
  watch: {
    gasLimit(newVal) {
      this.localGas = newVal;
    }
  },
  mounted() {},
  methods: {
    _toString(i) {
      return i + '';
    },
    copyToAddress() {
      this.$refs('toaddress').select();
      document.execCommand('copy');
      window.getSelection().removeAllRanges();
    },
    next() {
      if (!this.isValidData) {
        alert('Data must be hex');
        return false;
      }
      const raw = {
        generateOnly: true,
        from: this.$store.state.wallet.getAddressString(),
        gas: this.gasLimit,
        value: this.unit.toHex(
          this.unit.toWei(this._toString(this.toAmt), 'won')
        ),
        data: this.toData,
        nonce: this.locNonce,
        gasPrice: 10,
        to:
          this.resolvedAddress !== ''
            ? this.resolvedAddress
            : this.address !== ''
              ? this.address
              : '',
        chainId: this.$store.state.network.type.chainID || 1
      };
      this.$store.state.web3.won.signTransaction(raw).then(signedTx => {
        this.$emit('createdRawTx', signedTx.rawTransaction);

        this.raw = raw;
        this.signed = signedTx.rawTransaction;
        this.$children[5].$refs.signedTx.show();
        window.scrollTo(0, 0);
      });
    },
    gasLimitUpdated(e) {
      this.$emit('gasLimitUpdate', e);
    },
    nonceUpdated(e) {
      this.locNonce = e;
      this.$emit('nonceUpdate', e);
    },
    pathUpdate() {
      this.$emit('pathUpdate', 'sendPubTx');
    }
  }
};
</script>

<style lang="scss" scoped>
@import 'GenerateTx.scss';
</style>
