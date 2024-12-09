// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.14;

import "./Ballot.sol";

contract BallotManager {
    address public chairperson;
    mapping(uint => address) public ballotToContract; // Maps ballot ID to deployed Ballot contract
    uint public ballotCount = 0; // Counter to track the number of ballots

    modifier onlyChairperson() {
        require(msg.sender == chairperson, "Only chairperson can perform this action.");
        _;
    }

    constructor(address _chairperson) {
        chairperson = _chairperson;
    }

    // Function to create a new ballot
    function createBallot(bytes32[] memory proposalNames, uint votingDurationInSeconds) external onlyChairperson {
		require(msg.sender == chairperson, "Only chairperson can perform this action.");
        Ballot ballot = new Ballot(proposalNames, votingDurationInSeconds, chairperson);
        ballotToContract[ballotCount] = address(ballot);
        ballotCount++;
    }

    // Function to get the address of a specific ballot contract
    function getBallotAddress(uint ballotId) external view returns (address) {
        return ballotToContract[ballotId];
    }
	
	// Function to get all ballots with their ballot ID and address
    function getAllBallots() external view returns (uint[] memory, address[] memory) {
        uint[] memory ids = new uint[](ballotCount);
        address[] memory addresses = new address[](ballotCount);
        
        for (uint i = 0; i < ballotCount; i++) {
            ids[i] = i;
            addresses[i] = ballotToContract[i];
        }

        return (ids, addresses);
    }
}