<template>
  <div
    ref="software"
    hide-footer
    class="bootstrap-modal  modal-software text-center"
    centered>
    <div class="d-block content-container text-center">
      <ul class="button-options">
        <li
          :class="selected === 'trezor'? 'selected': ''"
          @click="select('trezor')">
          <img
            class="icon"
            src="~@/assets/images/icons/button-trezor.png">
          <img
            class="hover-icon"
            src="~@/assets/images/icons/button-trezor-hover.png">
          <span>Trezor</span>
        </li>
        <li
          :class="selected === 'byJson'? 'selected': ''"
          @click="select('byJson')">
          <img
            :src="selected === 'byJson'? require('@/assets/images/icons/button-json-hover.svg'):require('@/assets/images/icons/button-json.svg')"
            class="icon">
          <img
            class="hover-icon"
            src="@/assets/images/icons/button-json-hover.svg">
          <span>{{ $t("common.jsonF") }}</span>
        </li>
      </ul>
      <input
        ref="jsonInput"
        type="file"
        name="file"
        style="display: none"
        @change="uploadFile">
    </div>
    <div class="button-container">
      <b-btn
        :class="[selected !== ''? 'enabled': 'disabled','mid-round-button-green-filled']"
        @click="continueAccess">
        {{ $t("common.continue") }}
      </b-btn>
    </div>
  </div>
</template>

<script>
import { TrezorWallet } from '@/wallets';
export default {
  components: {},
  props: {
    value: {
      type: String,
      default: ''
    },
    openPassword: {
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
      file: '',
      selected: ''
    };
  },
  methods: {
    uploadClick() {
      const jsonInput = this.$refs.jsonInput;
      jsonInput.value = '';
      jsonInput.click();
    },
    uploadFile(e) {
      const self = this;
      const reader = new FileReader();
      reader.onloadend = function(evt) {
        self.$emit('file', JSON.parse(evt.target.result));
        self.file = JSON.parse(evt.target.result);
      };
      reader.readAsBinaryString(e.target.files[0]);
    },
    continueAccess() {
      // todo The actual initiation of a hardware wallet should be moved to a specific file to reduce clutter here as the number of offerings increases
      // todo: and to allow for any specialized set-up steps a particular constructor/wallet may require

      switch (this.selected) {
        case 'byJson':
          this.uploadClick();
          break;
        case 'trezor':
          TrezorWallet.unlock()
            .then(wallet => {
              this.$emit('hardwareWalletOpen', wallet);
            })
            .catch(_error => {
              // eslint-disable-next-line
              console.error(_error); // todo replace with proper error
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
@import 'SimpleModal.scss';
</style>
