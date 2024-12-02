var Ballot = artifacts.require("./Ballot.sol");
var BallotManager = artifacts.require("./BallotManager.sol");

module.exports = function(deployer, network, accounts) {
    // Deploy the BallotManager contract first
    deployer.deploy(BallotManager).then(async (ballotManagerInstance) => {

        // Define the proposal names as an array of bytes32
        const proposalNames = ["Proposal 1", "Proposal 2", "Proposal 3"].map(name => web3.utils.asciiToHex(name));

        // Hardcode the chairperson address here
        const chairpersonAddress = accounts[0]; // Use the first account in Ganache for the chairperson

        // Define the voting duration in seconds (e.g., 10 minutes for testing)
        const votingDurationInSeconds = 10 * 60; // 10 minutes in seconds

        // Create a new Ballot via the BallotManager contract
        await ballotManagerInstance.createBallot(proposalNames, votingDurationInSeconds);

        // Optionally, if you want to confirm the Ballot address
        await ballotManagerInstance.getBallotAddress(0);
    });
};