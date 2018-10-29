<template>
  <div>
    <access-my-wallet-container/>
  </div>
</template>

<script>
import AccessMyWalletContainer from './containers/AccessMyWalletContainer';

export default {
  name: 'AccessWalletLayout',
  components: {
    'access-my-wallet-container': AccessMyWalletContainer
  },
  data() {
    return {
      tokens: []
    };
  },
  async mounted() {
    if (this.$store.state.online) {
      this.tokens = await this.getRates();
    }
  },
  methods: {
    async getRates() {
      const rates = await fetch(
        'https://still-waters-52916.herokuapp.com/ticker?filter=BTC,WON,REP,KNC,OMG,EOS,XRP,BCH,LTC,TRX,NEO,ETC,QTUM,ADA,XMR,QTUM,SNT,ELF,BAT'
      )
        .then(res => {
          return res.json();
        })
        .catch(err => {
          return err;
        });
      return Object.keys(rates.data)
        .map(item => Object.assign(rates.data[item]))
        .sort((a, b) => {
          if (a.rank < b.rank) return -1;
          if (a.rank > b.rank) return 1;
          return 0;
        });
    }
  }
};
</script>

<style lang="scss" scoped>
@import 'AccessWalletLayout.scss';
</style>
