<template>
  <div class="send-currency-container">
    <interface-container-title :title="$t('common.sendTx')"/>

    <div class="send-form">
      <div class="form-block amount-to-address">
        <div class="amount">
          <div class="title">
            <h4>{{ $t("interface.sendTxAmount") }}</h4>
            <p
              v-show="getGasLimit > 0 && address" 
              class="title-button prevent-user-select"
              @click="setBalanceToAmt">Entire Balance</p>
          </div>
          <currency-picker
            :currency="tokensWithBalance"
            :page="'sendEthAndTokens'"
            :token="true"
            @selectedCurrency="setSelectedCurrency"/>
          <div class="the-form amount-number">
            <input
              v-model="amount"
              type="number"
              name=""
              placeholder="Amount" >
            <i
              :class="[selectedCurrency.name === 'WON' ? balance < amount ? 'not-good': '' : isBalanceEnough ? 'not-good': '','fa fa-check-circle good-button']"
              aria-hidden="true"/>
          </div>
          <div
            v-if="selectedCurrency.name === 'WON' ? amount > balance : isBalanceEnough"
            class="error-message-container">
            <p>{{ $t('common.dontHaveEnough') }}</p>
          </div>
          <div
            v-if="selectedCurrency.name !== 'WON' && (0.0000001 > balance && !isBalanceEnough)"
            class="error-message-container">
            <p>{{ $t('common.dontHaveEnoughGas') }}</p>
          </div>          
        </div>
        <div class="to-address">
          <div class="title">
            <h4>{{ $t("interface.sendTxToAddr") }}
              <blockie
                v-show="isValiadAddress && address.length !== 0"
                :address="address"
                width="32px"
                height="32px"
                class="blockie-image"/>
            </h4>

            <p
              class="copy-button prevent-user-select"
              @click="copyToClipboard('address')">{{
                $t('common.copy')
              }}</p>
          </div>
          <div class="the-form address-block">
            <textarea
              ref="address"
              v-model="address"
              name="name"
              autocomplete="off"/>
            <i 
              v-b-tooltip.hover 
              :title="addressTips"
              :class="[isValiadAddress && address.length !== 0 ? '':'not-good', 'fa fa-check-circle good-button']"
              aria-hidden="true"/>
          </div>
        </div>
      </div>
    </div>

    <div class="send-form advanced">
      <div class="advanced-content">
        <div class="toggle-button-container">
          <h4>{{ $t('common.advanced') }}</h4>
          <div class="toggle-button">
            <span>{{ $t('interface.advancedGas') }}</span>
            <!-- Rounded switch -->
            <div class="sliding-switch-white">
              <label class="switch">
                <input
                  type="checkbox"
                  @click="advancedExpend = !advancedExpend" >
                <span class="slider round"/>
              </label>
            </div>
          </div>
        </div>
        <div
          v-if="advancedExpend"
          class="input-container">
          <div 
            v-show="false" 
            class="the-form user-input">
            <input
              v-model="data"
              type="text"
              name=""
              placeholder="Add Data (e.g. 0x7834f874g298hf298h234f)"
              autocomplete="off" >
          </div>
          <div class="the-form user-input">
            <input
              v-model="gasLimit"
              type="number"
              name=""
              placeholder="Gas Limit" >
          </div>
        </div>
      </div>
    </div>

    <div class="submit-button-container">
      <div
        :class="[isValiadAddress && address.length !== 0 && amount > 0 && getGasLimit > 0? '': 'disabled','submit-button large-round-button-green-filled']"
        @click="confirmationModalOpen">
        {{ $t('interface.sendTx') }}
      </div>
      <interface-bottom-text
        :link-text="$t('interface.learnMore')"
        :question="$t('interface.haveIssues')"
        link="/"/>
    </div>
  </div>
</template>

<script>
import { mapGetters } from 'vuex';

import InterfaceContainerTitle from '../../components/InterfaceContainerTitle';
import CurrencyPicker from '../../components/CurrencyPicker';
import InterfaceBottomText from '@/components/InterfaceBottomText';
import Blockie from '@/components/Blockie';
const BigNumber = require('bignumber.js');

// eslint-disable-next-line
const EthTx = require('ethereumjs-tx')
// eslint-disable-next-line

export default {
  components: {
    'interface-container-title': InterfaceContainerTitle,
    'interface-bottom-text': InterfaceBottomText,
    blockie: Blockie,
    'currency-picker': CurrencyPicker
  },
  props: {
    tokensWithBalance: {
      type: Array,
      default: function() {
        return [];
      }
    },
    balance: {
      type: String,
      default: '0'
    }
  },
  data() {
    return {
      advancedExpend: false,
      validAddress: false,
      amount: 0,
      amountValid: true,
      nonce: 0,
      gasLimit: 0,
      gasLimits: {}, //for cache
      data: '0x',
      gasAmount: 10,
      parsedBalance: 0,
      address: '',
      addressKyc: {},
      emptyKyc: { level: 0 },
      selectedCurrency: { symbol: 'Ŵ', name: 'WON' }
    };
  },
  computed: {
    ...mapGetters({
      account: 'account'
    }),
    isBalanceEnough: function() {
      return (
        parseFloat(this.selectedCurrency.balance) < parseFloat(this.amount)
      );
    },
    isValiadAddress: function() {
      return this.validAddress && parseInt(this.addressKyc.level) > 0;
    },
    addressTips: function() {
      if (!this.validAddress) {
        return 'Invalid Address';
      }
      return 'KYC L' + this.addressKyc['level'];
    },
    getGasLimit() {
      return this.gasLimit;
    }
  },
  watch: {
    address(newVal) {
      this.address = newVal;
      if (this.verifyAddr()) {
        this.validAddress = false;
        this.addressKyc = this.emptyKyc;
      } else {
        this.validAddress = true;
        this.getKycInfo(newVal);
        this.estimateGas(this.selectedCurrency);
      }
    },
    parsedBalance(newVal) {
      this.parsedBalance = newVal;
    },
    gasAmount(newVal) {
      this.gasAmount = newVal;
      this.$store.dispatch('setGasPrice', Number(newVal));
    },
    amount(newVal) {
      this.amount = newVal;
    },
    selectedCurrency(newVal) {
      this.selectedCurrency = newVal;
      this.estimateGas(newVal);
    }
  },
  mounted() {
    this.addressKyc = this.emptyKyc;
    this.estimateGas(this.selectedCurrency); //评估下won的gas limit

    if (this.balance) {
      this.parsedBalance = this.balance;
    }
    this.changeGas(this.gasAmount);
  },
  methods: {
    _toString(i) {
      return i + '';
    },
    getKycInfo(address) {
      if (address == '') return false;

      const web3 = this.$store.state.web3;
      web3.won
        .getKycInfo(address)
        .then(res => {
          this.addressKyc = res;
        })
        .catch(err => {
          // eslint-disable-next-line no-console
          console.error(err);
        });
    },
    copyToClipboard(ref) {
      this.$refs[ref].select();
      document.execCommand('copy');
    },
    async createTx() {
      this.nonce = await this.$store.state.web3.won.getTransactionCount(
        this.$store.state.wallet.getAddressString()
      );
      const currencyName = this.selectedCurrency.name;
      const data = this.createDataHex(currencyName, this.address, this.amount);
      const raw = this.createRaw(
        currencyName,
        this.selectedCurrency.address,
        this.address,
        this.amount,
        data
      );

      if (this.address === '') {
        delete raw['to'];
      }

      const fromAddress = raw.from;
      this.$store.state.web3.won
        .sendTransaction(raw)
        .once('transactionHash', hash => {
          this.$store.dispatch('addNotification', [
            fromAddress,
            hash,
            'Transaction Hash'
          ]);
        })
        .on('receipt', res => {
          this.$store.dispatch('addNotification', [
            fromAddress,
            res,
            'Transaction Receipt'
          ]);
        })
        .on('error', err => {
          this.$store.dispatch('addNotification', [
            fromAddress,
            err,
            'Transaction Error'
          ]);
        });
    },
    confirmationModalOpen() {
      this.createTx();
      window.scrollTo(0, 0);
    },
    changeGas(val) {
      this.gasAmount = val;
      this.$store.dispatch('setGasPrice', Number(val));
    },
    setBalanceToAmt() {
      const utils = this.$store.state.web3.utils;
      // var coutout = function(i){
      //     var b = new BigNumber(utils.toWei(i, "won"));
      //     var f = 10000000000;
      //     return utils.fromWei(b.dividedToIntegerBy(f).multipliedBy(f).toString(), "won");
      // };

      if (this.selectedCurrency.name === 'WON') {
        const bigBalance = new BigNumber(this._toString(this.balance));
        this.amount = bigBalance
          .minus(
            utils.fromWei(this._toString(this.gasAmount * this.gasLimit), 'won')
          )
          .toString();
      } else {
        this.amount = this.selectedCurrency.balance;
      }
    },
    createDataHex(currencyName, toAddress, amount) {
      let data = '0x';
      if (currencyName !== 'WON') {
        const jsonInterface = [
          {
            constant: false,
            inputs: [
              { name: 'dst', type: 'address' },
              { name: 'wad', type: 'uint256' }
            ],
            name: 'transfer',
            outputs: [{ name: 'success', type: 'bool' }],
            payable: false,
            stateMutability: 'nonpayable',
            type: 'function'
          }
        ];

        const _web3 = this.$store.state.web3;
        const contract = new this.$store.state.web3.won.Contract(jsonInterface);
        data = contract.methods
          .transfer(
            toAddress,
            _web3.utils.toHex(_web3.utils.toWei(this._toString(amount), 'won'))
          )
          .encodeABI();
      }
      return data;
    },
    createRaw(currencyName, curencyAddress, toAddress, amount, data) {
      //must call after this.createDataHex();
      const isWon = currencyName === 'WON';
      const _web3 = this.$store.state.web3;
      const raw = {
        from: this.$store.state.wallet.getAddressString(),
        gas: this.gasLimit,
        nonce: this.nonce,
        gasPrice: Number(
          _web3.utils.toWei(this._toString(this.gasAmount), 'wei')
        ),
        value: isWon
          ? amount === ''
            ? 0
            : _web3.utils.toWei(this._toString(amount), 'won')
          : 0,
        to: isWon ? toAddress : curencyAddress,
        data: data,
        chainId: this.$store.state.network.type.chainID || 1
      };
      return raw;
    },
    setSelectedCurrency(e) {
      this.selectedCurrency = e;
    },
    estimateGas(currencyObj) {
      const _this = this;
      const estimate = function() {
        const raw = _this.createRaw(
          currencyObj.name,
          '',
          _this.address,
          _this.amount,
          '0x'
        );
        delete raw['gas'];
        delete raw['nonce'];
        _this.$store.state.web3.won
          .estimateGas(raw)
          .then(res => {
            _this.gasLimit = res;
            _this.gasLimits[_this.address] = res;
          })
          .catch(err => {
            // eslint-disable-next-line no-console
            console.error(err);
          });
      };

      //已经评估过gas limit 直接返回
      if (currencyObj.name == 'WON') {
        if (this.verifyAddr()) {
          return false;
        }

        if (
          this.gasLimits[this.address] !== undefined &&
          this.gasLimits[this.address] > 0
        ) {
          this.gasLimit = this.gasLimits[this.address];
        } else {
          this.gasLimit = 0;
          estimate(); //执行检查
        }
      } else {
        this.gasLimit = 9000;
      }
    },
    verifyAddr() {
      if (this.address.length !== 0 && this.address !== '') {
        const valid = this.$store.state.web3.utils.isAddress(this.address); //正确地址返回true
        if (!valid) {
          return true; //错误地址返回true
        }
        return false; //正确地址
      }
      return true; //错误地址返回true
    }
  }
};
</script>

<style lang="scss" scoped>
@import 'SendCurrencyContainer.scss';
</style>
