const Adoption = artifacts.require("Adoption");

module.exports = async function (deployer, network, accounts) {
  // Deploy the contract without sending any value
  await deployer.deploy(Adoption, { from: accounts[0] });
};
