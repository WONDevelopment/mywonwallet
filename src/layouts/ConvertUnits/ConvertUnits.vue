<template>
  <div class="convert-units">
    <div class="wrap">

      <div class="page-container">
        <div class="page-title">
          <h2>Convert Units</h2>
          <p>
            MyWonWallet is comprised of talented, inspiring, and hardworking
            indivisuals from around the world. We share the passion to code.
          </p>
        </div>

        <div>
          <unit-input />
        </div>

        <div class="ether-unit-reference-guide">
          <div class="block-title">
            <h3>Ether Unit Reference Guide</h3>
          </div>

          <div class="unit-table">
            <table>
              <tbody>
                <tr 
                  v-for="eu in etherUnitRef" 
                  :key="eu.key">
                  <td>{{ eu.name }}</td>
                  <td>{{ eu.unit1 }}</td>
                  <td>{{ eu.unit2 }}<span>{{ eu.unit2e }}</span></td>
                  <td>{{ eu.desc }}</td>
                </tr>
              </tbody>
            </table>
          </div>

        </div>
      </div>

    </div>
  </div>
</template>

<script>
import UnitInput from './components/UnitInput';

export default {
  components: {
    'unit-input': UnitInput
  },
  data() {
    return {
      etherUnitRef: [
        {
          name: 'Wei',
          unit1: '1',
          unit2: '1',
          unit2e: '',
          desc: ''
        },
        {
          name: 'Kwei',
          unit1: '1,000',
          unit2: '10',
          unit2e: '3',
          desc: 'ada, femtowon'
        },
        {
          name: 'Mwei',
          unit1: '1,000,000',
          unit2: '10',
          unit2e: '6',
          desc: 'babbage, picowon'
        },
        {
          name: 'Gwei',
          unit1: '1,000,000,000',
          unit2: '10',
          unit2e: '9',
          desc: 'shannon, nanowon, nano'
        },
        {
          name: 'Szabo',
          unit1: '1,000,000,000,000',
          unit2: '10',
          unit2e: '12',
          desc: 'microwon, micro'
        },
        {
          name: 'Finney',
          unit1: '1,000,000,000,000,000',
          unit2: '10',
          unit2e: '15',
          desc: 'milliwon, milli'
        },
        {
          name: 'won',
          unit1: '1,000,000,000,000,000,000',
          unit2: '10',
          unit2e: '18',
          desc: ''
        },
        {
          name: 'Kwon',
          unit1: '1,000,000,000,000,000,000,000',
          unit2: '10',
          unit2e: '21',
          desc: 'grand, einstein'
        },
        {
          name: 'Mwon',
          unit1: '1,000,000,000,000,000,000,000,000',
          unit2: '10',
          unit2e: '24',
          desc: ''
        },
        {
          name: 'Gwon',
          unit1: '1,000,000,000,000,000,000,000,000,000',
          unit2: '10',
          unit2e: '27',
          desc: ''
        },
        {
          name: 'Twon',
          unit1: '1,000,000,000,000,000,000,000,000,000,000',
          unit2: '10',
          unit2e: '30',
          desc: ''
        }
      ]
    };
  }
};
</script>

<style lang="scss" scoped>
@import 'ConvertUnits.scss';
</style>
