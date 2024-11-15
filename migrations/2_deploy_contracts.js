var ballot = artifacts.require("./ballot.sol");

module.exports = function(deployer) {

	deployer.deploy(ballot);
}