<template>
  <div class="home">
    <top-banner/>
  </div>
</template>

<script>
import TopBanner from './components/TopBanner';

export default {
  name: 'HomeContainer',
  components: {
    'top-banner': TopBanner
  },
  data() {
    return {
      online: true,
      address: '',
      resolvedAddress: ''
    };
  },
  watch: {
    online(newVal) {
      this.online = newVal;
    }
  },
  mounted() {
    if (this.$store.state.online) {
      this.online = true;
    } else {
      this.online = false;
    }
  }
};
</script>

<style lang="scss" scoped>
@import 'HomeLayout.scss';
</style>
