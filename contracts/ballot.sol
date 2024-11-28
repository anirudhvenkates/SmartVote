// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.14;

contract Ballot {
    // This declares a new complex type which will
    // be used for variables later.
    // It will represent a single voter.
    struct Voter {
        uint weight; // weight is accumulated by delegation
        bool voted;  // if true, that person already voted
        address delegate; // person delegated to
        uint vote;   // index of the voted proposal
    }

    // This is a type for a single proposal.
    struct Proposal {
        bytes32 name;   // short name (up to 32 bytes)
        uint voteCount; // number of accumulated votes
    }

    address public chairperson;
    uint public deadline; // The deadline for voting (unix timestamp)
	uint public constant MAX_DELEGATION_DEPTH = 3;

    // This declares a state variable that
    // stores a Voter struct for each possible address.
    mapping(address => Voter) public voters;

    // A dynamically-sized array of Proposal structs.
    Proposal[] public proposals;

    /// Create a new ballot to choose one of proposalNames.
    /// The chairperson can also set a deadline (in Unix timestamp).
    constructor(bytes32[] memory proposalNames, uint votingDurationInSeconds, address chairpersonAddress) {
        chairperson = chairpersonAddress;
        voters[chairperson].weight = 1;
        
        // Set the voting deadline
        deadline = block.timestamp + votingDurationInSeconds;

        // For each of the provided proposal names,
        // create a new proposal object and add it
        // to the end of the array.
        for (uint i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }
    }

    // Function to check if the voting deadline has passed
    modifier hasNotEnded() {
        require(block.timestamp <= deadline, "Voting period has ended.");
        _;
    }

    // Allow the chairperson to give right to vote to multiple voters at once
    function giveRightsToMultipleVoters(address[] calldata votersList) external {
        require(msg.sender == chairperson, "Only chairperson can give right to vote.");
    
        for (uint i = 0; i < votersList.length; i++) {
            address voter = votersList[i];
            require(!voters[voter].voted, "The voter already voted.");
            require(voters[voter].weight == 0, "The voter already has voting rights.");
            voters[voter].weight = 1;
        }
    }
	
	// Allow the chairperson to revoke right to vote to multiple voters at once
	function revokeVotingRights(address[] calldata votersList) external {
		require(msg.sender == chairperson, "Only chairperson can revoke rights.");
		for (uint i = 0; i < votersList.length; i++) {
			address voter = votersList[i];
			require(voters[voter].weight == 1, "The voter does not have voting rights.");
			voters[voter].weight = 0;
		}
	}

    function delegate(address to) external hasNotEnded {
		Voter storage sender = voters[msg.sender];
		require(sender.weight != 0, "You have no right to vote");
		require(!sender.voted, "You already voted.");
		require(to != msg.sender, "Self-delegation is disallowed.");

		uint delegationDepth = 0;
		
		/**
		This is the critical part of the logic. Delegation in this contract can form a chain (one voter delegates to another, who may delegate to someone else, and so on). This function follows the chain of delegation.
		address(0) is a special address in Ethereum that represents the zero address, which is often used to signify "no address" or "not set".
		voters[to].delegate != address(0) is checking if the to address (the delegate) has already delegated their vote to someone else. If to hasn't delegated their vote to anyone, voters[to].delegate will be address(0).
		*/
		while (voters[to].delegate != address(0)) {
			to = voters[to].delegate;
			delegationDepth++;
			require(delegationDepth <= MAX_DELEGATION_DEPTH, "Delegation chain too deep");
			require(to != msg.sender, "Found loop in delegation.");
		}

		//Ensure the delegate has voting rights
		Voter storage delegate_ = voters[to];
		require(delegate_.weight >= 1, "Delegate cannot vote");

		sender.voted = true;
		sender.delegate = to;

		//If the delegate has already voted, the sender's weight is added to the proposal they voted for
		if (delegate_.voted) {
			proposals[delegate_.vote].voteCount += sender.weight;
		} else {
			//If the delegate hasn't voted yet, the sender's weight is added to the delegate's weight
			delegate_.weight += sender.weight;
		}
	}

    // Cast a vote for a proposal
    function vote(uint proposal) external hasNotEnded {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote");
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = proposal;

        proposals[proposal].voteCount += sender.weight;
    }

    // Get the index of the winning proposal, accounting for ties
    function winningProposals() public view returns (uint winningProposal_) {
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
            }
        }

        uint[] memory tiedProposals = new uint[](proposals.length);
        uint count = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount == winningVoteCount) {
                tiedProposals[count] = p;
                count++;
            }
        }

        if (count > 1) {
            uint randomIndex = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % count;
            winningProposal_ = tiedProposals[randomIndex];
        } else {
            winningProposal_ = tiedProposals[0];
        }
    }

    // Get the name of the winning proposal
    function winnerName() external view returns (bytes32 winnerName_) {
		//require(msg.sender == chairperson, "Only chairperson can see winner details.");
        winnerName_ = proposals[winningProposals()].name;
    }

    // Get the remaining time until the voting ends (in seconds)
    function remainingTime() external view returns (uint) {
        if (block.timestamp >= deadline) {
            return 0;
        } else {
            return deadline - block.timestamp;
        }
    }
}