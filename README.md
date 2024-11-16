# Voting

Done by Anirudh Venkatesh

Solidity version: 0.8.14

## Improvements:

**Introduced a voting deadline**. The deadline is set during the contract deployment using a votingDurationInSeconds parameter (which specifies how long the voting period will last). There is a hasNotEnded modifier which checks that the current time (block.timestamp) is before the deadline before allowing certain functions to execute.

**Circular Delegation Prevention (Efficiency):** Sometimes delegation chains can be too long. To solve this, pne approach is to limit the depth of delegation (e.g., maximum 5 levels deep). If a voter tries to delegate too many times, it could be rejected. This would help avoid excessively long chains that could result in high gas costs.

When it comes to **tie breaking,** there is improvement made. The contract randomly chooses the winner by using a keccak256 function which generates a pseudo random number, which is used to randomly pick a winner.

**Vote assignment** is done in a big batch, reducing overhead and making the overall process efficient.

**Simple GUI** is implemented. Although testing is required.
