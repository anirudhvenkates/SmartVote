var Ballot = artifacts.require("./Ballot.sol");
var Voting = artifacts.require("./Voting.sol");

module.exports = function(deployer) {

  // Hardcode the chairperson address here
  const chairpersonAddress = "0x87E78674B86E64f1a4cA0B55D40EEC692C5a367f"; // Replace with actual chairperson address

  // Deploy the Ballot contract with the necessary parameters
  deployer.deploy(Ballot, chairpersonAddress)
    .then(function() {
      // After the Ballot contract is deployed, get its address
      const ballotAddress = Ballot.address;

      // Deploy the Voting contract, passing the Ballot contract's address to the constructor
      return deployer.deploy(Voting, ballotAddress);
    });
};