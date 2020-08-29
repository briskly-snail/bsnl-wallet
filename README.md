# bsnl-wallet

Enhanced wallet to trade briskly-snail tokens (a community rewamp of the original SNAIL project by Takeshi Kodo).


| Symbol   | SNL                                                                    |
|----------|------------------------------------------------------------------------|
| Token    | Snail token aka "Satoshi Nakamoto Leverage"                            |
| New Telegram | [t.me/slowsnailprotocol](https://t.me/brisky-snail)               |
| New Wallet | [Wallet DApp](https://takeshikodo.gitlab.io/snl-wallet/)               |
| Contract | 0x3f243F1A635b3E55249222dAB9529441f5A2d594                             |
| Domain   | [slowsnail.eth](https://etherscan.io/address/slowsnail.eth)            |


> Important: our enhanced **briskly-snail wallet** works with the same contract at **0x3f243F1A635b3E55249222dAB9529441f5A2d594**


## ROADMAP

Our interpretation is that Takeshi wished to decentralize his work.

We look to: 

1. Revive or build a community around Takeshi's original work (*in progress*)
2. Engage with community by providing explanation and support (*in progress*)
2. Enhance the wallet with new functionality (*planned*)
 - For example, calculate and allow claiming of rewards based on the "hodling" interest rate (the main way to earn with the SNAIL token)
3. Add DeFi
 - Add additional DeFi functionality around the original SNL ERC20 token by Takeshi
 - Build upon the protocol
 

## About

Brisky-snail is a continuation of the wallet to work with the SNaiL tokens.   
Original project has been published [on gitlab](https://gitlab.com/takeshikodo/snl-wallet) in 2019 (before the DeFi becoming massively popular).

We believe this work is applicable in the context of modern DeFi and should be continued. It seems that it has already affected other projects.


## Quote from the original README

> SNL (non-exclusively) stands for "Satoshi Nakamoto Leverage" or the SNaiL token.

> The idea is to program a crypto asset with controllable or lesser liquidity. Such asset would be more inert or have a "slower" market behavior by design. As a result token becomes more resilient to the significant volume movements, which are typical for the large scale "pump and dump" speculations. Over time, token may exhibit predictable inflation rates, comparable to FIAT. Such token can be a reasonable investment choice purposed for the "storage of value".

> Simple mechanism mentioned above can be programmed to operate completely "in silico". Our hope is that the published smart contract can help crypto markets to become self-sufficient, in the same time potentially render any complex human-supervised market regulations as superfluous.

> One can use the wallet app to buy, sell or transfer SNL directly via the contract, which is an extended version of the ERC20. 


# Contribute

Please raise an issue describe what problem you are trying to solve and make a PR.

Code is still OSS, distributed under [MIT license](https://opensource.org/licenses/MIT). Originally authored by Takeshi Kodo [t4k3sh1k0d0@protonmail.com](mailto:t4k3sh1k0d0@protonmail.com) (c) 2019. 

For more latest changes see AUTHORS.

## Developer's notes

> Note: below is true for the local testing of the original smart contract.

### Requirements

- truffle v5.0.21
- solc v0.5.9
- openzeppelin-solidity 2.3.0

Also see package.json

### Install solidity (Mac)

Install or upgrade solidity:

    brew update
    brew upgrade
    brew tap ethereum/ethereum
    brew install solidity
    brew linkapps solidity

### Building smart contracts

    Compile:              truffle compile
    Migrate:              truffle migrate
    Test contracts:       truffle test

### Running DApp locally

Smart contract can be (re)deployed and tested locally, e.g. with Ganache (see truffle.js):

    truffle migrate --reset --network ganache

Install node_modules with:

    yarn

and start a local dev server with:

    yarn dev

---

Links to original work 

| Symbol   | SNL                                                                    |
|----------|------------------------------------------------------------------------|
| Telegram | [t.me/slowsnailprotocol](https://t.me/slowsnailprotocol)               |
| Old Wallet | [Wallet DApp](https://takeshikodo.gitlab.io/snl-wallet/)               |
| Original Paper  | [pdf](https://gitlab.com/takeshikodo/snl-wallet/raw/master/paper.pdf?inline=false) |
| Original Gitlab   | [snl-wallet](https://gitlab.com/takeshikodo/snl-wallet/)               |