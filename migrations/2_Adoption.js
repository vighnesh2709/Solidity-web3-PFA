const Adoption = artifacts.require("Adoption");
const ReceiveDonation = artifacts.require("ReceiveDonation");

module.exports = async function (deployer, network, accounts) {
  // Retrieve the deployed ReceiveDonation instance
  const receiveDonation = await ReceiveDonation.deployed();

  // Deploy Adoption contract, passing the ReceiveDonation contract's address
  await deployer.deploy(Adoption, receiveDonation.address, { from: accounts[0] });
};
