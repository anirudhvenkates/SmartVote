// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.14;

import "./Ballot.sol";

contract Voting {
    Ballot public ballot; // Reference to the Ballot contract
    mapping(address => bool) public hasVoted;

    constructor(address ballotAddress) {
        ballot = Ballot(ballotAddress); // Set the Ballot contract address
    }

    modifier hasNotEnded() {
        require(block.timestamp <= ballot.deadline(), "Voting period has ended.");
        _;
    }

    // Cast a vote for a proposal
    function vote(uint proposalIndex) external hasNotEnded {
        require(!hasVoted[msg.sender], "You have already voted.");
        require(proposalIndex < ballot.proposalsLength(), "Invalid proposal.");

        hasVoted[msg.sender] = true;

        // Call the Ballot contract to update the vote count for the selected proposal
        ballot.voteForProposal(proposalIndex);
    }

    // Delegate a vote to another address
    function delegate(address to) external hasNotEnded {
        ballot.delegate(to,msg.sender);
    }
}