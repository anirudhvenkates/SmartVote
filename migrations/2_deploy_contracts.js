var Ballot = artifacts.require("./Ballot.sol");
var Voting = artifacts.require("./Voting.sol");

module.exports = function(deployer) {
  // Define the proposal names as an array of bytes32
  const proposalNames = ["Proposal 1", "Proposal 2", "Proposal 3"].map(name => web3.utils.asciiToHex(name));

  // Define the voting duration in seconds (e.g., 1 day)
  const votingDurationInSeconds = 24 * 60 * 60;  // 24 hours in seconds
  
  // Hardcode the chairperson address here
  const chairpersonAddress = "0x87E78674B86E64f1a4cA0B55D40EEC692C5a367f"; // Replace with actual chairperson address

  // Deploy the Ballot contract with the necessary parameters
  deployer.deploy(Ballot, proposalNames, votingDurationInSeconds, chairpersonAddress)
    .then(function() {
      // After the Ballot contract is deployed, get its address
      const ballotAddress = Ballot.address;

      // Deploy the Voting contract, passing the Ballot contract's address to the constructor
      return deployer.deploy(Voting, ballotAddress);
    });
};