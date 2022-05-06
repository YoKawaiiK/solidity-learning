<template>
  <div>
    <button
      v-show="configuration.selectedAddress == null"
      @click="_connectWallet"
    >
      Click
    </button>
    <div v-if="configuration.selectedAddress == null">Account is null</div>
    <div v-else>Your balance is {{ formatedBalance }} Eth</div>
  </div>
</template>

<script>
import { ethers } from 'ethers'

import auctionAddress from '../../contracts/DutchAuction-contract-address.json'
// import auctionAddress from '../../contracts/'
import auctionArtifact from '../../contracts/DutchAuction.json'

const HARDHAT_NETWORK_ID = '31337'
const ERROR_CODE_TX_REJECTED_BY_USER = '4001'

const initialState = {
  // selectedAccount: null,
  selectedAddress: null,
  txBeingSent: null,
  networkError: null,
  TransactionError: null,
  balance: null,
  provider: null,
}

export default {
  name: 'IndexPage',
  data() {
    return { configuration: initialState }
  },
  components: {},
  computed: {
    formatedBalance: function () {
      if (this.configuration.balance == null) return null;
      return ethers.utils.formatEther(this.configuration.balance)
    },
  },
  methods: {
    _resetState() {
      this.configuration = initialState
    },
    async _connectWallet() {
      if (window.ethereum === undefined) {
        this.configuration.networkError = 'Please install Metamask!'
        return
      }

      const [selectedAddress] = await window.ethereum.request({
        method: 'eth_requestAccounts',
      })

      if (!this._checkNetwork()) {
        return
      }

      this._initialize(selectedAddress)

      window.ethereum.on('accountsChanged', ([newAddress]) => {
        if (newAddress === undefined) {
          return this._resetState()
        }

        this._initialize(newAddress)
      })

      window.ethereum.on('chainChanged', ([networkId]) => {
        this._resetState()
      })
    },
    _checkNetwork() {
      if (window.ethereum.networkVersion === HARDHAT_NETWORK_ID) {
        return true
      }

      this.configuration.networkError = `Please Connect to localhost: 8545`
      alert(this.configuration.networkError)
      return false
    },
    async _initialize(selectedAddress) {
      const newProvider = new ethers.providers.Web3Provider(window.ethereum)

      this.configuration.provider = newProvider

      const auction = new ethers.Contract(
        auctionAddress.DutchAuction,
        auctionArtifact.abi,
        this.configuration.provider.getSigner(0)
      )

      this.configuration.selectedAddress = selectedAddress

      await this._updateBalance()
    },
    async _updateBalance() {
      const balance = (
        await this.configuration.provider.getBalance(
          this.configuration.selectedAddress
        )
      )
      this.configuration.balance = balance
    },
  },
}
</script>
