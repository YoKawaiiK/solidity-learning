<template>
  <div>
    <button
      v-show="configuration.selectedAddress == null"
      @click="this.connectWallet"
    >
      Connect Wallet
    </button>
    <div v-if="configuration.selectedAddress == null">Account is null</div>
    <div v-else>
      <div v-if="appData.stopped">
        <p>Auction is stopped.</p>
      </div>
      <div v-else>
        <section v-if="configuration.txBeingSent" class="transaction">
          <div>Loading</div>
        </section>

        <section v-if="configuration.transactionError" class="error">
          <div>{{ getRpcErrorMessage(configuration.transactionError) }}</div>
          <button @click="this.dismissTransactionError">Okay</button>
        </section>

        <section class="wallet">
          <div>
            <span v-show="appData.currentPrice">
              Your balance is {{ formatToken(configuration.balance) }} Eth</span
            >
          </div>
        </section>

        <section class="auction">
          <div>
            <span v-show="appData.currentPrice">
              Current item price:
              {{ formatToken(appData.currentPrice) }} Eth</span
            >
          </div>

          <button @click="this.buy">Buy!</button>
        </section>
      </div>
    </div>
  </div>
</template>

<script>
import { ethers } from 'ethers'

import auctionAddress from '../../contracts/DutchAuction-contract-address.json'
import auctionArtifact from '../../contracts/DutchAuction.json'

import {
  HARDHAT_NETWORK_ID,
  ERROR_CODE_TX_REJECTED_BY_USER,
} from '@/constants/client_constants'

const initialState = {
  configuration: {
    selectedAddress: null,
    txBeingSent: null,
    networkError: null,
    transactionError: null,
    balance: null,
    provider: null,
  },
  appData: {
    auction: null, // contract
    currentPrice: null,
    startingPrice: null,
    startAt: null,
    discountRate: null,
    stopped: false,
    checkPriceInterval: null, // function
  },
}

export default {
  name: 'IndexPage',
  data() {
    let data = initialState

    return data
  },
  components: {},
  methods: {
    formatToken(data) {
      if (!data) return null
      return ethers.utils.formatEther(data)
    },
    getRpcErrorMessage(error) {
      if (error.data) {
        return error.data.message
      } else if (error.message) {
        return error.message
      } else error
    },
    async buy() {
      try {
        const tx = await this.appData.auction.buy({
          value: this.appData.currentPrice.toString(),
        })

        this.configuration.txBeingSent = tx.hash

        await tx.wait()
      } catch (error) {
        if (error.code === ERROR_CODE_TX_REJECTED_BY_USER) {
          return
        }

        console.error(error)
        this.configuration.transactionError = error
      } finally {
        this.configuration.txBeingSent = null
        await this.updateBalance()
        await this.updateStopped()
      }
    },
    componentWillUnmount() {
      clearInterval(this.appData.checkPriceInterval)
    },
    dismissTransactionError() {
      this.configuration.transactionError = null
    },
    resetState() {
      this.configuration = initialState
    },
    async connectWallet() {
      if (window.ethereum === undefined) {
        this.configuration.networkError = 'Please install Metamask!'
        return
      }

      const [selectedAddress] = await window.ethereum.request({
        method: 'eth_requestAccounts',
      })

      if (!this.checkNetwork()) {
        return
      }

      this.initialize(selectedAddress)

      window.ethereum.on('accountsChanged', ([newAddress]) => {
        if (newAddress === undefined) {
          return this.resetState()
        }

        this.initialize(newAddress)
      })

      window.ethereum.on('chainChanged', ([networkId]) => {
        this.resetState()
      })
    },
    async updateStopped() {
      const stopped = await this.appData.auction.stopped()

      if (stopped) {
        clearInterval(this.checkPriceInterval)
      }
      this.appData.stopped = stopped
      return this.appData.stopped
    },
    checkNetwork() {
      if (window.ethereum.networkVersion === HARDHAT_NETWORK_ID) {
        return true
      }

      this.configuration.networkError = `Please Connect to localhost: 8545`
      alert(this.configuration.networkError)
      return false
    },
    async initialize(selectedAddress) {
      const newProvider = new ethers.providers.Web3Provider(window.ethereum)

      this.configuration.provider = newProvider

      const auction = new ethers.Contract(
        auctionAddress.DutchAuction,
        auctionArtifact.abi,
        this.configuration.provider.getSigner(0)
      )

      this.appData.auction = auction

      this.configuration.selectedAddress = selectedAddress

      if (await this.updateStopped()) {
        return
      }

      await this.updateBalance()

      this.appData.startingPrice = await this.appData.auction.startingPrice()
      this.appData.startAt = await this.appData.auction.startAt()

      this.appData.discountRate = await this.appData.auction.discountRate()

      this.appData.checkPriceInterval = setInterval(() => {
        const elapsed = ethers.BigNumber.from(
          Math.floor(Date.now() / 1000)
        ).sub(this.appData.startAt)

        const discount = this.appData.discountRate.mul(elapsed)

        const newPrice = this.appData.startingPrice.sub(discount)
        this.appData.currentPrice = newPrice
      }, 1000)

      const startBlockNumber = await this.configuration.provider.getBlockNumber()
      this.appData.auction.on('Bought', (...args) => {
        const event = args[args.length - 1]

        if (event.blockNumber <= startBlockNumber) return

        console.log(args)
      })
    },
    async updateBalance() {
      const balance = await this.configuration.provider.getBalance(
        this.configuration.selectedAddress
      )
      this.configuration.balance = balance
    },
  },
}
</script>
