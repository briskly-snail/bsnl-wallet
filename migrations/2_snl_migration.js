var SnailToken = artifacts.require("./SnailToken.sol");
var f64 = artifacts.require("./f64.sol");


async function deployMainnet(deployer, network) {
  await deployer.deploy(f64);
  await deployer.link(f64, SnailToken);
  await deployer.deploy(SnailToken);
}

async function deployTestnet(deployer, network) {
  await deployer.deploy(f64);
  await deployer.link(f64, SnailToken);
  // Include debug helper.. can be temporary imported/used in SnailToken.sol
  var dhelper = artifacts.require("./dhelper.sol");
  await deployer.deploy(dhelper);
  await deployer.link(dhelper, SnailToken);
  await deployer.deploy(SnailToken);
  // Add testable token version, accessible for solidity tests
  // Alternatively, copy-paste public methods for debug into SnailToken.sol
  if (network == "ganache") {
    // Used only by `truffle test --network ganache`
    var TestableSnailToken = artifacts.require("./TestableSnailToken.sol");
    await deployer.link(f64, TestableSnailToken);
    await deployer.link(dhelper, TestableSnailToken);
    await deployer.deploy(TestableSnailToken);
  }
}


module.exports = (deployer, network) => {
  if (network == "mainnet" || network == "mainnet-fork") {
    deployer.then(async () => {
      await deployMainnet(deployer, network);
    });
  } else if (network == "ganache" || network == "snlchain") {
    deployer.then(async () => {
      await deployTestnet(deployer, network);
    });
  } else {
    console.log("Can not deploy to unknown network.");
  }
};