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

    // Array to store all voters' addresses
    address[] public voterAddresses;
    
    // Mapping to store the voter data by their address
    mapping(address => Voter) public voters;

    // A dynamically-sized array of Proposal structs.
    Proposal[] public proposals;

    /// Create a new ballot to choose one of proposalNames.
    /// The chairperson can also set a deadline (in Unix timestamp).
    constructor(bytes32[] memory proposalNames, uint votingDurationInSeconds, address chairpersonAddress) {
        chairperson = chairpersonAddress;
        voters[chairperson].weight = 1;
        voterAddresses.push(chairperson); // Add chairperson to the voterAddresses list
        
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
	
	// Function to increase or decrease the weight of a voter (but not set it to zero)
	function adjustVotingWeight(address voter, uint newWeight) external {
		require(msg.sender == chairperson, "Only the chairperson can adjust the weight.");
		require(voters[voter].weight != 0, "Voter has no voting rights.");
		require(newWeight > 0, "Weight must be greater than zero.");
		
		voters[voter].weight = newWeight;
	}

    // Allow the chairperson to give right to vote to multiple voters at once
    function giveRightsToMultipleVoters(address[] calldata votersList) external {
    require(msg.sender == chairperson, "Only chairperson can give right to vote.");
    
    for (uint i = 0; i < votersList.length; i++) {
        address voter = votersList[i];
        require(!voters[voter].voted, "The voter already voted.");
        require(voters[voter].weight == 0, "The voter already has voting rights.");
        
        // Grant voting rights
        voters[voter].weight = 1;

        // Check if the voter is already in the list to avoid duplicates
        bool alreadyAdded = false;
        for (uint j = 0; j < voterAddresses.length; j++) {
            if (voterAddresses[j] == voter) {
                alreadyAdded = true;
                break;
            }
        }

        // If not already added, push to the voterAddresses array
        if (!alreadyAdded) {
            voterAddresses.push(voter);
        }
    }
	}

    // Allow the chairperson to revoke right to vote to multiple voters at once
    function revokeVotingRights(address[] calldata votersList) external {
        require(msg.sender == chairperson, "Only chairperson can revoke rights.");
        for (uint i = 0; i < votersList.length; i++) {
            address voter = votersList[i];
            require(voters[voter].weight == 1, "The voter does not have voting rights.");
            voters[voter].weight = 0;

			/**
            // Optionally, you can remove the voter from the array:
            for (uint j = 0; j < voterAddresses.length; j++) {
                if (voterAddresses[j] == voter) {
                    // Shift elements to remove the voter from the array
                    for (uint k = j; k < voterAddresses.length - 1; k++) {
                        voterAddresses[k] = voterAddresses[k + 1];
                    }
                    voterAddresses.pop();  // Remove the last element
                    break;
                }
            }
			*/
        }
    }
	
	// Function to get all voters' information in a simple array format
	function getVotersInfo() public view returns (string[] memory) {
		string[] memory votersInfo = new string[](voterAddresses.length);

		for (uint i = 0; i < voterAddresses.length; i++) {
			address voterAddress = voterAddresses[i];
			Voter storage voter = voters[voterAddress];
			
			string memory voterStatus = voter.voted ? "Voted" : "Not Voted";
			string memory weight = voter.weight > 0 ? "Voting Rights" : "No Voting Rights";
			string memory delegateAddress = (voter.delegate == address(0)) ? "No Delegate" : toString(voter.delegate);

			// Format the information as a string
			votersInfo[i] = string(abi.encodePacked(
				"Address: ", toString(voterAddress),
				", Status: ", voterStatus,
				", Weight: ", weight,
				", Delegate: ", delegateAddress
			));
		}

		return votersInfo;
	}

	// Helper function to convert an address to a string
	function toString(address addr) internal pure returns (string memory) {
		bytes32 value = bytes32(uint256(uint160(addr)));
		bytes memory alphabet = "0123456789abcdef";
		bytes memory str = new bytes(42);
		str[0] = '0';
		str[1] = 'x';
		for (uint i = 0; i < 20; i++) {
			str[2+i*2] = alphabet[uint8(value[i + 12] >> 4)];
			str[3+i*2] = alphabet[uint8(value[i + 12] & 0x0f)];
		}
		return string(str);
	}


    // Delegate the vote to another voter
    function delegate(address to) external hasNotEnded {
        Voter storage sender = voters[msg.sender];
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

        //Ensure the delegate has voting rights
        Voter storage delegate_ = voters[to];
        require(delegate_.weight >= 1, "Delegate cannot vote");

        sender.voted = true;
        sender.delegate = to;

        // If the delegate has already voted, the sender's weight is added to the proposal they voted for
        if (delegate_.voted) {
            proposals[delegate_.vote].voteCount += sender.weight;
        } else {
            // If the delegate hasn't voted yet, the sender's weight is added to the delegate's weight
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
