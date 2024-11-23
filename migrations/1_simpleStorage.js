const SimpleStorage = artifacts.require("./SimpleStorage.sol");

module.exports = async function(deployer) {
  await deployer.deploy(SimpleStorage);
};
// now, sol version is 0.7.3 but the truffle compile r version is 0.8.21 so that needs to be sorted out, the code is able to migrate but that could lead to issues in the future