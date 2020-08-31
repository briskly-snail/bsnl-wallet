/**
 * Plain javascript wallet app for Snail tokens 🐌
 * 
 * (c) Takeshi Kodo, under the MIT License (MIT)
 */

// Imports 
// Page CSS - webpack knows what to do with it..
import '../../node_modules/bootstrap/dist/css/bootstrap.min.css'
import '../styles/app.css'
import { default as jQuery } from 'jquery'; window.$ = window.jQuery = jQuery;
import '../../node_modules/popper.js/dist/popper.min.js'
import '../../node_modules/bootstrap/dist/js/bootstrap.min.js'
import { default as Web3 } from 'web3'
import { default as contract } from 'truffle-contract'
import { default as BN } from 'bn.js'
import snailTokenArtifact from '../../build/contracts/SnailToken.json'
import { assert, BNfmt, BNe18, BNparse } from './utils.js'

// Constants
const version = "0.2.0"
// Disable for production
const DEBUG = false 
// For deposit/withdraw operations
const GAS_LIMIT = 900000
// Smart contract
const SnailToken = contract(snailTokenArtifact)
// Account index - set to 0 in prod
const ACC_INDEX = (DEBUG) ? 1 : 0


const App = {
  // In SNL, x * 1e18
  convAmount: new BNparse("1"),

  showDialog: function(title, message, callback, noconfirm) {
    $('#modalDialog div div div.modal-header .modal-title').html(title || "Confirm")
    $('#modalDialog div div div.modal-body p').html(message || "Do you want to proceed?")
    $('#modalDialog div div div.modal-footer .btn-primary').off("click").click(callback || function(){})
    $('#modalDialog div div div.modal-footer .btn-primary').show()
    if (noconfirm || false) { $('#modalDialog div div div.modal-footer .btn-primary').hide() }
    $('#modalDialog').modal()
  },

  hideDialog: function(){
    $('#modalDialog').modal('hide')
    $('#modalDialog').modal('dispose')
  },

  setStatus: function (message) {
    $('div.status-container').show()
    $('#status').html(message)
  },

  getDepositPrice: async function(contract) {
    const self = this

    assert(BN.isBN(self.convAmount), "Value error - expected BN instance.")
    let ethAmount = self.convAmount
    let snlAmount = await contract.convEth2Snl(ethAmount.toString())
    let snlInterest = await contract.getSnlInterest(self.userAccount, snlAmount)
    snlAmount = snlAmount.sub(snlInterest)

    return {
      "ethAmount": ethAmount,
      "snlAmount": snlAmount
    }
  },

  getWithdrawPrice: async function(contract) {
    const self = this

    assert(BN.isBN(self.convAmount), "Value error - expected BN instance.")
    let snlAmount = self.convAmount
    let snlInterest = await contract.getSnlInterest(self.userAccount, snlAmount.toString())
    let ethAmount = await contract.convSnl2Eth(snlAmount.sub(snlInterest))

    return {
      "ethAmount": ethAmount,
      "snlAmount": snlAmount
    }
  },

  getDiscountedInterest: async function(contract) {
    const self = this

    assert(BN.isBN(self.convAmount), "Value error - expected BN instance.")
    let snlAmount = self.convAmount
    let snlInterest = await contract.getSnlInterest(self.userAccount, snlAmount.toString())

    return {
      "snlAmount": snlAmount,
      "snlInterest": snlInterest
    }
  },

  setContractAddress: function(address) {
    jQuery('#contractAddress').html(address)
  },

  refreshMarketInfo: function (userAccount) {
    const self = this
    
    // contract and wallet addresses
    SnailToken.deployed().then(function (contract) {
      jQuery('#walletAddress').html(self.userAccount)
      jQuery('.wallet-address-link').attr("href", "https://etherscan.io/address/" + self.userAccount)
      self.setContractAddress(contract.address)
    }).catch(function (err) {
      console.log(err)
      self.setStatus('🔰 Error getting contract and wallet addresses; see log.')
    })
    // .. and the balances
    web3.eth.getBalance(self.userAccount, function(err, ethBalance) {
      if (err) {
        self.setStatus('🔰 Error getting eth wallet balance; see log. ')
        console.log(err)
        return
      } 
      jQuery('#walletBalanceInEth').html(BNfmt(ethBalance))
    })
    SnailToken.deployed().then(function (contract) {
      return contract.balanceOf.call(self.userAccount)
    }).then(function (walletBalanceInSnl) {
      jQuery('#walletBalanceInSnl').html(BNfmt(walletBalanceInSnl))
    }).catch(function (err) {
      console.log(err)
      self.setStatus('🔰 Error getting contract and wallet balances; see log.')
    })

    // total supply of SNL
    SnailToken.deployed().then(function (contract) {
      return contract.totalSupply.call()
    }).then(function (totalSupply) {
      jQuery('#totalSupplyOfSnl').html(BNfmt(totalSupply))
    }).catch(function (err) {
      console.log(err)
      self.setStatus('🔰 Error getting total supply of SNL; see log.')
    })
    // total deposit in ETH
    SnailToken.deployed().then(function (contract) {
      return contract.getEthDeposit.call()
    }).then(function (ethDeposit) {
      jQuery('#totalDepositInEth').html(BNfmt(ethDeposit))
    }).catch(function (err) {
      console.log(err)
      self.setStatus('🔰 Error getting total deposit in ETH; see log.')
    })

    // deposit price in ETH
    SnailToken.deployed().then(function (contract) {
      return self.getDepositPrice(contract)
    }).then(function (depositPrice) {
      jQuery('#depositPriceInEth').html(BNfmt(depositPrice.ethAmount))
      jQuery('.cnv-deposit-amount').html(BNfmt(depositPrice.snlAmount))
    }).catch(function (err) {
      console.log(err)
      self.setStatus('🔰 Error getting deposit price; see log.')
    })
    // withdraw price in ETH
    SnailToken.deployed().then(function (contract) {
      return self.getWithdrawPrice(contract)
    }).then(function (withdrawPrice) {
      jQuery('#withdrawPriceInSnl').html(BNfmt(withdrawPrice.snlAmount))
      jQuery('.cnv-withdraw-amount').html(BNfmt(withdrawPrice.ethAmount))
    }).catch(function (err) {
      console.log(err)
      self.setStatus('🔰 Error getting withdraw price; see log.')
    })
    // discounted interest
    SnailToken.deployed().then(function (contract) {
      return self.getDiscountedInterest(contract)
    }).then(function (discountedInterest) {
      jQuery('#amountInSnl').html(BNfmt(discountedInterest.snlAmount))
      jQuery('.cnv-interest').html(BNfmt(discountedInterest.snlInterest))
    }).catch(function (err) {
      console.log(err)
      self.setStatus('🔰 Error getting withdraw price; see log.')
    })    
  },

  depositEth: function () {
    const self = this

    const ethAmount = BNparse($('#deposit-amount').val())
    const message = "Do you confirm depositing " + BNfmt(ethAmount) + " ETH to buy SNL?"
    self.showDialog("Deposit ETH", message, function() {
      self.hideDialog()
      console.log('Initiating transaction... (please wait)')
      SnailToken.deployed().then(async function (snail) {
        let tx = await snail.depositEth({from: self.userAccount, value: ethAmount, gas: GAS_LIMIT});
        console.log(tx)
        let txId = tx.tx
        self.refreshMarketInfo()
        let okMessage = `㊗️ Transaction is successfully submitted!<br>
<small>Status can be checked here:<br>
<a href="https://etherscan.io/tx/${txId}" class="badge badge-success">
<span class="minorlabel">${txId}</span></a> 🔗</small>`
        self.showDialog("Deposit ETH", okMessage, function() { self.hideDialog() }, true)
      }).catch(function (err) {
        console.log(err)
        self.setStatus('🔰 Error buying SNL; see log.')
      })
    })
  },

  withdrawEth: function () {
    const self = this

    const snlAmount = BNparse($('#withdraw-amount').val())
    const message = "Do you confirm withdrawing ETH by selling " + BNfmt(snlAmount) + " SNL?"
    self.showDialog("Withdraw ETH", message, function() {
      self.hideDialog()
      console.log('Initiating transaction... (please wait)')
      SnailToken.deployed().then(async function (snail) {
        let tx = await snail.withdrawEth(snlAmount, {from: self.userAccount, gas: GAS_LIMIT});
        console.log(tx)
        let txId = tx.tx
        self.refreshMarketInfo()
        let okMessage = `㊗️ Transaction is successfully submitted!<br>
<small>Status can be checked here:<br>
<a href="https://etherscan.io/tx/${txId}" class="badge badge-success">
<span class="minorlabel">${txId}</span></a> 🔗</small>`
        self.showDialog("Withdraw ETH", okMessage, function() { self.hideDialog() }, true)
      }).catch(function (err) {
        console.log(err)
        self.setStatus('🔰 Error selling SNL; see log.')
      })
    })
  },

  transferSnl: function () {
    const self = this

    const toAddress = $('#transfer-address').val()
    const snlAmount = BNparse($('#transfer-amount').val())
    const message = `Do you confirm transfer of ${BNfmt(snlAmount)} SNL to ${toAddress}?`
    self.showDialog("Transfer SNL", message, function() {
      self.hideDialog()
      console.log('Initiating transaction... (please wait)')
      SnailToken.deployed().then(async function (snail) {
        let tx = await snail.transfer(toAddress, snlAmount, {from: self.userAccount, gas: GAS_LIMIT});
        console.log(tx)
        let txId = tx.tx
        self.refreshMarketInfo()
        let okMessage = `㊗️ Transaction is successfully submitted!<br>
<small>Status can be checked here:<br>
<a href="https://etherscan.io/tx/${txId}" class="badge badge-success">
<span class="minorlabel">${txId}</span></a> 🔗</small>`
        self.showDialog("Transfer SNL", okMessage, function() { self.hideDialog() }, true)
      }).catch(function (err) {
        console.log(err)
        self.setStatus('🔰 Error transferring SNL; see log.')
      })
    })
  }, 

  run: function () {
    const self = this

    // Bootstrap the SnailToken abstraction for Use.
    SnailToken.setProvider(web3.currentProvider)

    // Get the initial account balance so it can be displayed.
    web3.eth.getAccounts(function (err, accs) {
      if (err) {
        console.log(err)
        alert('There was an error fetching your accounts. Please check that your web3 (Ethereum client) is configured correctly or install metamask.')
        return
      }

      if (accs.length === 0) {
        alert("Couldn't get any accounts! Please check that your web3 (Ethereum client) is configured correctly or install metamask.")
        return
      }

      self.accounts = accs
      self.userAccount = self.accounts[ACC_INDEX]

      // Updated UI
      self.refreshMarketInfo()
      $('div.status-container').hide()
      $('#date-placeholder').html(new Date().toLocaleDateString())
      $('#recalculate').click(function(){
        this.blur()
        let newAmount = BNparse($('#recalculate-value').val())
        if (!newAmount) {
          newAmount = new BNparse("1")
        }
        self.convAmount = newAmount
        self.refreshMarketInfo()
      })
    })
  }
}

window.App = App

window.addEventListener('load', function () {
  // Set wallet version
  $('#wallet-version').html(version)

  // Checking if Web3 has been injected by the browser (Mist/MetaMask)
  if (typeof web3 !== 'undefined') {
    // Use Mist/MetaMask's provider
    window.web3 = new Web3(web3.currentProvider)
    if (web3.currentProvider.isMetaMask !== undefined && web3.currentProvider.isMetaMask === true) {
      web3.currentProvider.enable()
    } else {
      alert("🔰 Warning, metamask was not detected. We recommended to use Metamask as a tested wallet middleware.\n\nGet your copy at https://metamask.io/")
    }
  } else if (DEBUG) {
    console.warn(
      "🔰 DEBUG mode is enabled but no web3 was detected. Falling back to http://127.0.0.1:7545." +
      " You should disable DEBUG or this fallback when you deploy live, as it\'s inherently insecure."
    )
    // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
    window.web3 = new Web3(new Web3.providers.HttpProvider('http://127.0.0.1:7545'))
  } 

  if (typeof web3 !== 'undefined') {
    App.run()
  } else {
    let errMessage = "🔰 Your browser does not support web3. \n\nGet your copy at https://metamask.io/"
    console.warn(errMessage)
    alert(errMessage)
  }
})
