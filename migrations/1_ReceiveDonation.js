const ReceiveDonation = artifacts.require("ReceiveDonation");

module.exports = async function (deployer, network, accounts) {
  // Deploy ReceiveDonation contract
  await deployer.deploy(ReceiveDonation, { from: accounts[0], value: web3.utils.toWei("1", "ether") });
};
