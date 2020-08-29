// Allows us to use ES6 in our migrations and tests.
require('@babel/register')
const HDWalletProvider = require("truffle-hdwallet-provider")
const FROM = "0x2765b0becd10ffd09aa5e546f050b3acd76c8157"

// Deployment routine for: truffle migrate --network mainnet
function getPrivKeyInfuraProvider() {
  const privateKey = process.env.PRIVKEY || "slow-snail-is-a-happy-snail";
  const projectId = process.env.PROJECTID || "snail-key-at-infura";
  
  // Infura vs. local 
  // let provider = new HDWalletProvider(privateKey, `https://mainnet.infura.io/v3/${projectId}`);
  let provider = new HDWalletProvider(privateKey, `http://127.0.0.1:8545`);
  
  const expected = FROM;
  const actual = provider.getAddresses()[0];
  if (actual != expected) {
    console.log("Unexpected deploy address: " + actual);
    return null;
  }
  return provider;
}


module.exports = {
  networks: {
    ganache: {
      host: '127.0.0.1',
      port: 7545,
      network_id: '*', // Match any network id
      gas: 6721975
    },
    snlchain: {
      host: '127.0.0.1',
      port: 8545,
      network_id: '*', // Match any network id
      gas: 6721975
    },
    // ..
    mainnet: {
      from: FROM,
      provider: getPrivKeyInfuraProvider(),
      network_id: 1,
      gas: 6500000,
      gasPrice: 41000000000,  // 41 gwei
      timeoutBlocks: 2000,
      skipDryRun: false
    }
  },
  compilers: {
    solc: {
      version: "0.5.9",
      settings: {
        optimizer: {
          enabled: true,
          runs: 200   // Optimize for how many times you intend to run the code
        }
        // evmVersion: <string>
      }
    }
  }
}
  