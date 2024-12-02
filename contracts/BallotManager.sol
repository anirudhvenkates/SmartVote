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

    constructor() {
        chairperson = 0x87E78674B86E64f1a4cA0B55D40EEC692C5a367f;
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
}