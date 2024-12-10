const ReceiveDonation = artifacts.require("Adoption");

module.exports = async function (deployer, network, accounts) {
  await deployer.deploy(Adoption, { from: accounts[0], value: web3.utils.toWei("1", "ether") });
};
