var ballot = artifacts.require("./ballot.sol");

module.exports = function(deployer) {
	// Define the proposal names as an array of bytes32
	const proposalNames = ["Proposal 1", "Proposal 2", "Proposal 3"].map(name => web3.utils.asciiToHex(name));
	
	// Hardcode the chairperson address here
	const chairpersonAddress = "0x87E78674B86E64f1a4cA0B55D40EEC692C5a367f"; // Replace with actual chairperson address

	// Define the voting duration in seconds (e.g., 1 day)
	const votingDurationInSeconds = 10 * 60;  // 24 hours in seconds

	// Deploy the Ballot contract with the necessary parameters
	deployer.deploy(ballot, proposalNames, votingDurationInSeconds, chairpersonAddress);
}