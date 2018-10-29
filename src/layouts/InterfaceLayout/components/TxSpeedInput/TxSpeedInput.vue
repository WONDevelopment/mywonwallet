<template>
  <div>
    <div class="send-form">
      <div class="title-container">
        <div class="title">
          <div class="title-helper">
            <h4>Nonce</h4>
            <popover :popcontent="$t('popover.whatIsNonce')"/>
          </div>
        </div>
      </div>
      <div class="the-form gas-amount">
        <input
          v-model="locNonce"
          type="number"
          placeholder="Nonce" >
        <div class="good-button-container">
          <i
            class="fa fa-check-circle good-button"
            aria-hidden="true"/>
        </div>
      </div>
    </div>
    <div class="send-form">
      <div class="title-container">
        <div class="title">
          <div class="title-helper">
            <h4>Gas Limit</h4>
            <popover :popcontent="$t('popover.whatIsGas')"/>
          </div>
        </div>
      </div>
      <div class="the-form gas-amount">
        <input
          v-model="gasLimit"
          type="number"
          placeholder="Gas Limit" 
          readonly>
        <div class="good-button-container">
          <i
            class="fa fa-check-circle good-button"
            aria-hidden="true"/>
        </div>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
@import 'TxSpeedInput.scss';
</style>

<script>
export default {
  props: {
    data: {
      type: String,
      default: ''
    },
    toAddress: {
      type: String,
      default: ''
    },
    gasLimit: {
      type: Number,
      default: 210
    },
    nonce: {
      type: Number,
      default: 0
    }
  },
  data() {
    return {
      locNonce: this.nonce
    };
  },
  watch: {
    locNonce(newVal) {
      this.$emit('nonceUpdate', parseInt(newVal));
    },
    gasPrice(newVal) {
      this.$emit('gasLimitUpdate', newVal);
    }
  },
  mounted() {
    this.setSpeed(10);
  },
  methods: {
    setSpeed(val) {
      if (val.target !== undefined) {
        this.$store.dispatch('setGasPrice', Number(val.target.value));
      } else {
        this.$store.dispatch('setGasPrice', Number(val));
      }
    }
  }
};
</script>
