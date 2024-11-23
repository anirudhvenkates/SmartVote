var Ballot = artifacts.require("./Ballot.sol");
var Voting = artifacts.require("./Voting.sol");

module.exports = function(deployer) {

  // Deploy the Ballot contract with the necessary parameters
  const chairpersonAddress = "0x1378747830E7518e7287F8C5777B04C65AfE0D46"; // Chairperson address
  deployer.deploy(Ballot, chairpersonAddress)
    .then(function() {
      // After the Ballot contract is deployed, get its address
      const ballotAddress = Ballot.address;

      // Deploy the Voting contract, passing the Ballot contract's address to the constructor
      return deployer.deploy(Voting, ballotAddress);
    });
};