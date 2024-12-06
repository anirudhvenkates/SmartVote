# SmartVote
> **Secure Your Vote, Secure Your Future**

## Author
**Anirudh Venkatesh**

## Project Description
*SmartVote* is a voting platform based on **Smart Contracts** designed for secure and transparent voting procedures. The project consists of two contracts: **BallotManager** and **Ballot**. 

- **BallotManager**: Manages multiple instances of the Ballot contract using a mapping.
- **Ballot**: Represents a single voting session, where proposals are presented, and voters can vote for their preferred options.

### Users and Roles:
- **Chairperson**: A user with special privileges who can create ballots, manage voter rights, and view voter information.
- **Voters**: Users who can vote on proposals or delegate their vote to other voters.

### Voting System:
- **Ballot Winner**: The proposal with the most votes wins. In case of a tie, a **keccak256** function is used to randomly select a winner.

## Solidity Version
**0.8.14**

## Requirements
- Access to a Cryptocurrency Wallet (e.g., **MetaMask**)
- Access to a personal Ethereum blockchain (e.g., **Ganache**)
- **Numpy** installed
- **Truffle** installed

## Instructions

1. **Launch Ganache**: Open Ganache and import at least 3 accounts into your MetaMask wallet.
2. **Download Project**: Download the project and place it in a directory of your choice.
3. **Ganache Workspace**: Create a workspace named "SmartVote" in Ganache and add the project by selecting `truffle-config.js`.
4. **Create Public Directory**: Create a `public` directory in your project folder.
5. **Truffle Compile**: Open the command line, navigate to the project directory, and run `truffle migrate` to deploy the contracts.
6. **Launch HTTP Server**: Start an HTTP server to serve the project directory. Once running, open the browser and navigate to `http://127.0.0.1:8080/index.html` to access the welcome page.

## Licensing
This project is licensed under the **GNU GENERAL PUBLIC LICENSE**.

## Features

- **Automatic Detection of Chairperson**: The first account in Ganache is automatically assigned the Chairperson role.
- **BallotManager Address Detection**: The BallotManager contract address is automatically fetched and stored in a JSON file, avoiding the need to update HTML files after each deployment.
- **Voting Rights Management**: The Chairperson can grant/revoke voting rights. Voters can only vote if they have not voted already.
- **Delegated Voting**: Voters can delegate their vote to another voter (maximum delegation depth of 3).
- **Vote Casting**: Voters can cast their vote for one of the available proposals, provided they have voting rights.
- **Proposal Management**: Proposals can be added at contract deployment, and a `getProposals()` function lists all available proposals.
- **Voting Deadline Enforcement**: Voting ends after a set duration, and the `hasNotEnded` modifier ensures no voting or delegation is allowed after the deadline.
- **Winner Calculation**: The proposal with the most votes wins. In case of a tie, a random selection is made using **keccak256**.
- **Voter Information**: View voter details, including voting status and vote delegation.
- **Time Remaining**: The `remainingTime()` function displays the time left until voting ends.
- **Flexible Voting Weight**: The Chairperson can adjust a voter’s weight (except to zero).
- **Ballot Creation**: The Chairperson can create new ballots with a list of proposals and a voting duration.
- **Ballot Management**: All ballots are tracked using a mapping (`ballotToContract`), with a `getBallotAddress()` function to retrieve specific ballot addresses.
- **Retrieve All Ballots**: A function that returns a list of all ballot IDs and their associated addresses.
- **SmartVote Welcome Page**: The homepage introduces the SmartVote Voting System with a logo and tagline.

### Delegate Rules:
- Only voters with voting rights can delegate.
- Self-delegation is not allowed.
- Delegation is limited to 3 levels to prevent excessive delegation.

### Ballot Management:
- Users can load and view ballots, displaying ballot IDs and addresses dynamically.

### Smart Contract Integration:
- The page interacts with the **BallotManager** smart contract using **Web3.js**, fetching the contract address from a JSON file.

### MetaMask Integration:
- The page connects to the Ethereum network using MetaMask, with a fallback to a local provider (e.g., Ganache) if MetaMask is not detected.

## Front End Instructions

### Voter.html

1. **Ballot ID Input**:
   - Input field for users to specify the Ballot ID to vote on.
   - Clicking "Load Ballot" fetches the contract address for the specified Ballot.

2. **Voting Section**:
   - Displays available proposals and allows users to vote by clicking the vote button.
   - The vote is recorded on the blockchain.

3. **Delegate Vote**:
   - Allows voters to delegate their vote to another valid voter address.

4. **Remaining Time Section**:
   - Displays the remaining time for voting (in hours, minutes, seconds).

5. **Loading Indicators**:
   - Shows a loading message and spinner while fetching data or processing transactions.

6. **Smart Contract Interaction**:
   - Uses **Web3.js** to interact with **BallotManager** and individual ballots.

7. **MetaMask and Ethereum Network Integration**:
   - Ensures MetaMask is available for Ethereum connection.

8. **Error Handling**:
   - Alerts users about errors like invalid inputs or transaction failures.

9. **UI Elements**:
   - Organized into cards for a user-friendly interface.

10. **Dynamic Content Loading**:
    - Updates dynamic elements like proposals and remaining time based on blockchain data.

### Ballot.html

1. **Header Section**:
   - Displays the logo and page title. Includes a link back to the homepage.

2. **Create Ballot Section**:
   - Form to create new ballots with proposals and duration.

3. **Load Ballot Section**:
   - Input field for Ballot ID, fetching the associated ballot contract.

4. **Grant Voting Rights Section**:
   - Allows granting voting rights to specified Ethereum addresses.

5. **Revoke Voting Rights Section**:
   - Allows revoking voting rights from specified addresses.

6. **Adjust Voter Weight Section**:
   - Modify a voter's weight by providing their address and new weight.

7. **Declare Winner Section**:
   - Table to display the winner and their vote counts.

8. **Voting Time Remaining Section**:
   - Shows the remaining time until the voting deadline.

9. **Voter Information Section**:
   - Displays details about voters, including those with and without voting rights.

10. **Smart Contract Interaction**:
    - Uses **Web3.js** to interact with **BallotManager** and manage ballots.

11. **Error Handling**:
    - Provides error messages for invalid inputs and contract interaction failures.

## Index.html

1. **Web3 Integration**:
	- Connects to the Ethereum network via Web3.js, either through MetaMask or a local Ethereum provider (like Ganache) for development.
	- Loads the BallotManager contract dynamically using Web3.js from a provided contract address (contract_address.json).

2. **User-Friendly Layout**:
	- Clean and intuitive layout with sections for both Chairpersons and Voters, explaining their specific roles and instructions.
	- Clearly structured sections that guide the user on how to interact with the voting platform.

3. **Instructions for Chairpersons**:
	- Provides a clear list of tasks for chairpersons, such as:
		- Creating ballots
		- Granting/revoking voting rights
		- Adjusting voter weights
		- Viewing the vote results
		- Instructions for Voters:
		- Guides voters on how to:
		- Fetch ballot IDs
		- Vote for proposals
		- Delegate their vote to other eligible voters
		- Also includes important rules related to vote delegation.

4. **Delegate Rules**:
	- Outlines the rules for vote delegation:
		- Voters can delegate their vote only if they have voting rights and have not already voted.
		- Voters cannot delegate votes to themselves.
		- Delegation depth is limited to 3 levels, preventing loops and ensuring that delegates have voting rights.

5. **Ballot Management**:
	- The Ballots List section displays a table of all active ballots, including their IDs and addresses, which can be loaded dynamically from the blockchain.
	- A Load All Ballots button fetches the list of ballots and populates the table.

6. **Navigation Links**:
	- Provides easy navigation to other parts of the platform:
		- Ballot Page for creating and managing ballots.
		- Voter Page for interacting with individual voters and their votes.

7. **MetaMask Detection and Fallback**:
	- Automatically detects if MetaMask is installed in the user's browser.
	- If MetaMask is not detected, the page falls back to a local Ethereum provider (such as Ganache) for development purposes.
	
8. **Smart Contract Interaction**:
	- Uses the BallotManager smart contract to load and manage ballots.
	- Fetches ballot data and populates the page dynamically using Web3.js.

9. **Dynamic Content Loading**:
	- Loads ballot data (IDs and addresses) dynamically and displays it in a table. This allows users to interact with all available ballots without needing to reload the page.

10. **Responsive Design**:
	- Designed to be mobile-friendly with a responsive layout for better viewing and interaction on different devices.

11. **Error Handling**:
	- Displays error messages if there are issues while loading the contract address or fetching ballot data.
	- Alerts the user in case of errors during interactions, improving user experience by providing feedback during operations.