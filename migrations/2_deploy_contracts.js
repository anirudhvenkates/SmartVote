var ballot = artifacts.require("./ballot.sol");

module.exports = function(deployer) {
	// Define the proposal names as an array of bytes32
	const proposalNames = ["Proposal 1", "Proposal 2", "Proposal 3"].map(name => web3.utils.asciiToHex(name));

	// Define the voting duration in seconds (e.g., 1 day)
	const votingDurationInSeconds = 24 * 60 * 60;  // 24 hours in seconds

	// Deploy the Ballot contract with the necessary parameters
	deployer.deploy(ballot, proposalNames, votingDurationInSeconds);
}