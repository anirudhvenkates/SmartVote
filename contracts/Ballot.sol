// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.14;

contract Ballot {
    // This declares a new complex type which will represent a single voter.
    struct Voter {
        uint weight; // weight accumulated by delegation
        bool voted;  // true if the person has already voted
        address delegate; // person delegated to
        uint vote;   // index of the voted proposal
    }

    // This is a type for a single proposal.
    struct Proposal {
        bytes32 name;   // short name (up to 32 bytes)
        uint voteCount; // number of accumulated votes
    }

    address public chairperson;
    uint public deadline; // The deadline for voting (Unix timestamp)
	uint public constant MAX_DELEGATION_DEPTH = 3;

    // Mapping from address to Voter struct
    mapping(address => Voter) public voters;

    // Array to hold proposals
    Proposal[] public proposals;

    // Function to initialize the ballot with proposals and duration
    function initializeBallot(bytes32[] memory proposalNames, uint votingDurationInSeconds) external {
        require(msg.sender == chairperson, "Only chairperson can initialize the ballot.");
        require(proposals.length == 0, "Ballot already initialized.");  // Ensure it can only be initialized once.

        deadline = block.timestamp + votingDurationInSeconds;

        for (uint i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }
    }
	// Delegate vote to another voter
    function delegate(address to, address from) external hasNotEnded {
        Voter storage sender = voters[from];
        require(sender.weight != 0, "You have no right to vote");
        require(!sender.voted, "You already voted.");
        require(to != msg.sender, "Self-delegation is disallowed.");

        uint delegationDepth = 0;
        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;
            delegationDepth++;
            require(delegationDepth <= MAX_DELEGATION_DEPTH, "Delegation chain too deep");
            require(to != msg.sender, "Found loop in delegation.");
        }

        Voter storage delegate_ = voters[to];
        require(delegate_.weight >= 1, "Delegate cannot vote");

        sender.voted = true;
        sender.delegate = to;

        if (delegate_.voted) {
            proposals[delegate_.vote].voteCount += sender.weight;
        } else {
            delegate_.weight += sender.weight;
        }
    }
	
	// Getter function for voters mapping
    function getVoter(address voterAddress) external view returns (Voter memory) {
        return voters[voterAddress];
    }

    // Function to check if the voting deadline has passed
    modifier hasNotEnded() {
        require(block.timestamp <= deadline, "Voting period has ended.");
        _;
    }
	
	function proposalsLength() external view returns (uint) {
		return proposals.length;
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
	
	function revokeVotingRights(address[] calldata votersList) external {
		require(msg.sender == chairperson, "Only chairperson can revoke rights.");
		for (uint i = 0; i < votersList.length; i++) {
			address voter = votersList[i];
			require(voters[voter].weight == 1, "The voter does not have voting rights.");
			voters[voter].weight = 0;
		}
	}

    // Cast a vote for a proposal
    function voteForProposal(uint proposal) external hasNotEnded {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote");
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = proposal;

        proposals[proposal].voteCount += sender.weight;
    }

    // Get the index of the winning proposal
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
