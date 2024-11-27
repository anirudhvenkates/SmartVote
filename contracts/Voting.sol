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
        // Access the individual components of the Voter struct via the getter function
        (uint weight, bool voted, address delegateAddr, uint voteIndex) = ballot.voters(msg.sender); 

        // Use the values returned by the getter function
        require(weight != 0, "You have no right to vote.");
        require(!voted, "You have already voted.");
        require(to != msg.sender, "Self-delegation is disallowed.");

        uint delegationDepth = 0;
        address currentDelegate = to;

        // Traverse through the delegation chain to find the delegate
        while (delegateAddr != address(0)) {
            currentDelegate = delegateAddr;
			
			// Fetch the next Voter's details (for the current delegate)
			(weight, voted, delegateAddr, voteIndex) = ballot.voters(currentDelegate);
			
            delegationDepth++;
            require(delegationDepth <= ballot.MAX_DELEGATION_DEPTH(), "Delegation chain too deep");
            require(currentDelegate != msg.sender, "Found loop in delegation.");
        }

        //(uint delegateWeight, bool delegateVoted, address delegateDelegate, uint delegateVote) = ballot.voters(currentDelegate);
		(uint delegateWeight,,,) = ballot.voters(currentDelegate);
        require(delegateWeight >= 1, "Delegate cannot vote.");

        // Sender has voted, so set them to true and mark the delegate
		
        // Use the delegate function from the Ballot contract
        ballot.delegate(to);
        
        hasVoted[msg.sender] = true;  // Mark the sender as having voted

        // If the delegate has already voted, accumulate the sender's vote count
        //if (delegateVoted) {
        //    ballot.proposals(delegateVote).voteCount += weight;
        //} else {
        //    // Otherwise, increase the delegate's weight
        //    ballot.voters(currentDelegate).weight += weight;
        //}
    }

    // Get the remaining time until the voting ends (in seconds)
    function remainingTime() external view returns (uint) {
        if (block.timestamp >= ballot.deadline()) {
            return 0;
        } else {
            return ballot.deadline() - block.timestamp;
        }
    }
}
