# Snail tokens 🐌

## TL;DR

SNL (non-exclusively) stands for "Satoshi Nakamoto Leverage" or the SNaiL token.

The idea is to program a crypto asset with controllable or lesser liquidity. Such asset would be more inert or have a "slower" market behavior by design. As a result token becomes more resilient to the significant volume movements, which are typical for the large scale "pump and dump" speculations. Over time, token may exhibit predictable inflation rates, comparable to FIAT. Such token can be a reasonable investment choice purposed for the "storage of value".

Simple mechanism mentioned above can be programmed to operate completely "in silico". Our hope is that the published smart contract can help crypto markets to become self-sufficient, in the same time potentially render any complex human-supervised market regulations as superfluous.

One can use the wallet app to buy, sell or transfer SNL directly via the contract, which is an extended version of the ERC20. 


| Symbol   | SNL                                                              |
|----------|------------------------------------------------------------------|
| Paper    | [paper.pdf](https://gitlab.com/takeshikodo/snl-wallet/paper.pdf) |
| Wallet   | [Wallet DApp](https://takeshikodo.gitlab.io/snl-wallet/)          |
| Token    | Snail token aka "Satoshi Nakamoto Leverage"                      | 
| Domain   | [slowsnail.eth](https://etherscan.io/address/slowsnail.eth)      |
| Contract | 0x3f243F1A635b3E55249222dAB9529441f5A2d594                       |
| Telegram | [t.me/slowsnailprotocol](https://t.me/slowsnailprotocol)         |
| Gitlab   | [snl-wallet](https://gitlab.com/takeshikodo/snl-wallet/)         |


**Important**: always check that you work with the above contract address. It is the *ONLY* way to guarantee that it corresponds to the originally published code on the Ethereum main network (i.e. to guarantee that what you get is neither a result of a malicious phishing attack, some form of scam nor does it contain any deviations in functionality from the original code).

## Why was the snail token created?

It is an economical experiment to get more observable data on fast-slow token systems. 

In particular, we look to answer the following questions:

- How to design a crypto currency resilient to the market speculations or "dumps"?
- Can "hodling" (time of withholding from trading) crypto currency be a significant factor affecting its exchange rate volatility? 
- How to guarantee that the exchange rate can remain stable or potentially grow?
- How to redistribute any related risk burden in an economically viable and fair manner?

We believe that throttling the speed of the ERC20 token transfers (e.g. average transaction rate) can help to resist and reduce the market price volatility of the faster base currency (ETH). Our focus is on purely-virtual crypto currencies, which are based on computational assets e.g. as BTC, which is based on "mining", or ETH, which is based on computational "GAS". Such design is called a fast-slow token system.

There is a number of concerns related to the implementation and optimization details. You are encouraged to read the paper (see the link below), as well as, the [code of the published contract](contracts/SnailToken.sol).

## What is the value of the token and why this is important?

Our ultimate goal is to make sure that crypto remains free of institutional regulations. This can be achieved by helping crypto currencies to remain independent from the legal tender.

By analogy with commodities (e.g. like precious and rare metals) or assets of much lesser liquidity or even fully illiquid assets (all of which are not without their own limitations), the value of the snail token is supported by means of a much more basic resource - **time**.

We argue that function of time can be an efficient value dimension not only for banking business model (the one of credits and loans), but be essential for the sustainability of the crypto currency and its exchange rate. The idea behind the token is to experiment with value formation by using transaction speed to find a substitute for the lack of the inner value of the crypto currencies like Bitcoin or Ethereum, which arguably [lack such backing](https://github.com/ethereum/wiki/wiki/White-Paper) also referred to as ["intrinsic value"](https://bitcoinmagazine.com/articles/you-say-bitcoin-has-no-intrinsic-value-twenty-two-reasons-to-think-again-1399454061/). 

As already mentioned, in this research we are interested only in purely-virtual crypto assets that are free of any intrinsic value. Enclosed economies like PoW or PoST, computer games (or other economies of virtually anything programmable or computable) can easily function by means of assigning token ownership and trading them. On one hand, it seems meaningful for such economies to become more interconnected and their wealth to become more mappable to the value of non-digital properties, i.e. at a more predictable exchange rate. On the other hand, it is even more important that crypto remains free.

> Means of resistance to regulations and of self-sustainable market anti-volatility are further discussed in the following paper: ["Sustainability of the Negatively Amortized Instant Loans"](paper.pdf).

## What can the snail token do?

Given enough liquidity (assuming frequent transactions) token has a way to compute his exchange rate towards the base currency (ETH). Like this, movements of the bigger or significant volumes can be interpreted as market trends.

SNL is a slow token. It encourages small volume movements and discourages the bigger ones without compensation to the fellow holders. Every exceeding unusual trade of the token is tracked by the smart contract and higher "interest" fees are applied.

This means if one transfers her/his funds at a small rate below certain daily volume threshold, this does not costs anything. But as soon as the threshold has been exceeded - one pays extra (some percentage of tokens gets burned) for the transfer, for deposit or for withdraw of ETH. The threshold is tracked individually per wallet (or holder address) as the average rate and can cool down over time (size of the sliding window is 25 days).

## How can you contribute?

Please note that the token has been implemented as a rather simple protocol. It has been tested and published as a final version. So the migration or upgrade of the smart contract itself is not foreseen. 

However there is a plan for continuous effort of a new research and development to advance more practical implementations or infrastructure. That includes proposing next generation of slow-fast systems or other tools, which are build on similar ideas (e.g. as super-liquidity). 

Part of the work will be financed from the R&D bounty that has been already minted in form of the initial supply. If you find it suitable to support these R&D efforts, then you can also donate to the following addresses:

| Network  | Address                                    |
|----------|--------------------------------------------|
| Bitcoin  | 337nJFk8qP6dUUPnJ6Em1rFLSSwKM4rwAt         |
| Litecoin | MVRBAtJFR74nmshmxbKymUdd9k2241GS3U         |
| Ethereum | 0x6900ECFf4BF840c70ed3FA59571b2f46807BDf6a |

Help is welcomed. Most of the code is open source (unless otherwise noted in files, also see the legal disclaimer below). Please make a fork or submit an issue. 

While contributing your work don't mind to mention your wallets, so that reasonable improvement may receive compensation in return. Before working on anything significant and time consuming, consider discussing it by email (see below) or use gitlab issues.

If you are a researcher or can help with programming, please try to contact directly as well. A set of more proper instructions on how one can contribute her/his work is to follow separately. 

**Future publications**: next generation of SNL tokens to come around or to be published by us will be programmed to redeem the old currency. Alternatively previous generations can be always exchanged for ETH by withdrawing it from the contract.

## Whom to talk to?

If you want to discuss any technicality or other matters, consider sending an email to [t4k3sh1k0d0@protonmail.com](mailto:t4k3sh1k0d0@protonmail.com). It might be unrealistic to expect a quick reply though or any at all for plain (unencrypted) messages.

## Developer's notes

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


## Some Legal disclaimer

On a very simple and comprehensive level - the snail token (SNL) is an experiment which is not designed, programmed, shared, distributed or discussed (in oral or written) as any kind of software or financial product and/or service that is supposed to work, generate revenue or do anything useful. There are no guarantees and a lot of security, financial, material or any other type of risk(s) potentially connected to the snail token that you need to be able to understand before using the snail token for educational, experimental or any other purpose at your and your own risk alone. This document is neither a legally binding agreement nor a commitment of any kind that SNL is supposed to be used as a currency, investment vehicle, financial instrument, etc.  Authors of the code and documentation take no responsibility of any possible damage (material, psychological or other form of legally disputable damage in the most general form possible) that this code, documentation or the snail token itself can cause you. This text is not written to be a contractual agreement or a prospectus offering investment in legally binding sense in any kind of jurisdiction (e.g. the country of US, Japan, Brazil, China or South Korea - this is just an example and not an exclusive list of the possible 203 countries) which laws are protecting investor rights, etc. **You CAN read, test, use this code or this document or trade snail tokens at the published contract address on the Ethereum network and referenced by this document ONLY AT YOUR OWN RISK!** In case of doubt, do not use the snail token! 

The copyright of the content of this repository where the current document is placed is attributed to authors which are listed by their (nick)names and (optionally) contact emails in AUTHORS file in the root of this repository. All code related to the Snail token is published and copyrighted as OSS under [MIT license](https://opensource.org/licenses/MIT) (also see the copy in the root of this repository as well as every file header). This document and any other documentation related to the snail token is licensed under [CC BY 2.0](https://creativecommons.org/licenses/by/2.0/).

There's another: why may not that be the skull of a lawyer? Where be his quiddits now, his quillets, his cases, his tenures, and his tricks? why does he suffer this rude knave now to knock him about the sconce with a dirty shovel, and will not tell him of his action of battery? Hum! This fellow might be in's time a great buyer of land, with his statutes, his recognizances, his fines, his double vouchers, his recoveries: is this the fine of his fines, and the recovery of his recoveries, to have his fine pate full of fine dirt? will his vouchers vouch him no more of his purchases, and double ones too, than the length and breadth of a pair of indentures? The very conveyances of his lands will hardly lie in this box; and must the inheritor himself have no more, ha?


## PGP public keys

Make sure to encrypt your email messages for the following [PGP public key](pgpkey.pub.asc) with fingerprint:

> E833 2199 1032 899B B1F3  98C5 6477 FAE3 AFC3 4518

The same key is used for signing git commits or files. Please use it to verify my PGP signatures.


Takeshi Kodo
