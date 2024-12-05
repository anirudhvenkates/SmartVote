# SmartVote
"Secure Your Vote, Secure Your Future"

##Author
**Anirudh Venkatesh**

##Project Description
*SmartVote* is envisioned to be a voting platform based on Smart Contracts. The project is designed for operators to conduct voting procedure through Smart Contracts.

The project has two contracts named BallotManager and Ballot. The BallotManager mainly handles several instances of the Ballot contracts through a mapping. Each Ballot created is associated with a Ballot ID which maps to a Ballot Contract.

The project has two users:
1. Chairperson: This is a user with special privileges (similar to a super-user.)
2. Voters

Role of Chairperson: The Chairperson has the authority to create a ballot by entering the Proposal Names and duration for the ballot. Additionally, the chairperson can grant or revoke voting rights to voters. The Chairperson can see voters information such as vote status, delegate address and many more.
Role of Voters: Voters can choose to vote for a particular proposal of their choice. Voters may also choose to delegate their vote to another voters (who also must have voting rights.) The chairperson is given voting rights to every ballot.

The Ballot Winner is decided by the proposal that gets the most votes. In the event of a tie, the project uses keccak256 function which generates a pseudo random number that is used to randomly pick a winner.

##Solidity Version
**0.8.14**

##Requirements
**1.Access to a Cryptocurrency Wallet such as Metamask. You can add this as an extension to a browser such as Chrome, Firefox or Edge.**
**2.Access to personal Etherum blockchain such as Ganache.**
**3.Numpy installed.**
**4.Truffle installed.**

##Instructions
**1.Launch Ganache.** Head to the account area and import atleast 3 accounts onto your Metamask wallet.
**2.Download the project** and place it in a directory of your choice.
**3.Ganache Workspace:** Create Ganache Workspace named "SmartVote". Add a project to this workspace by navigating to the project directory and choosing the truffle-config.js file found in this project.
**4.Create public directory** in the project directory.
**5.Truffle Compile:** Open Command Line and navigate to the directory where the project is located and type "truffle migrate".
**6.Launch http-server.** Launch the http-server to serve the project directory. Once the http-server is listening to requests, head over to the browser and enter http://127.0.0.1:8080/index.html to open the welcome page.

##Licensing
This Project is Licensed under the GNU GENERAL PUBLIC LICENSE.

##Features
- **Automatic Detection of Chairperson address: **
  - The project is designed to detect the Chairperson address from Ganache. The first account in Ganache is assigned the Chairperson role. This avoids the need to hardcode chairperson address each time.

- **Automatic fetch of BallotManager address: **
  - The project is designed to detect the address of the BallotManager Contract and store the information in a json file which makes it easy to operate. This avoids the need to update HTML files each time a new deployment is performed.

- **Voting Rights Management**:
  - The **chairperson** can grant and revoke voting rights to specific addresses.
  - Voters can only be granted voting rights if they haven't voted already.
  
- **Delegated Voting**:
  - Voters can delegate their vote to another voter, allowing indirect voting.
  - Delegation is limited to a maximum depth of 3 to prevent excessive delegation.
  - If a delegate has already voted, the sender's weight is added to the proposal the delegate voted for. Otherwise, the delegate's voting weight increases.

- **Vote Casting**:
  - Each voter can cast a vote for one of the available proposals, provided they have voting rights and haven't voted already.
  
- **Proposal Management**:
  - Proposals can be created during contract deployment. Each proposal has a name and a vote count.
  - The contract provides the function `getProposals()` to list all proposal names.

- **Voting Deadline Enforcement**:
  - Voting has a set deadline, which is established during contract deployment.
  - The `hasNotEnded` modifier ensures that voting and delegation are not allowed after the voting period ends.

- **Winner Calculation**:
  - The contract calculates the winning proposal based on the number of votes.
  - In the event of a tie, the contract randomly selects a winner from the tied proposals.
  - The function `winnerName()` returns the name of the winning proposal along with vote counts for all proposals.

- **Voter Information**:
  - The contract allows viewing of all voters' information, including their voting status (whether they've voted), their voting rights, and the address to which their vote is delegated.
  
- **Time Remaining**:
  - The `remainingTime()` function provides the time left until the voting period ends, in seconds.

- **Flexible Voting Weight Management**:
  - The chairperson can adjust a voter's weight (excluding setting it to zero), enabling flexible control over the influence of voters.

- **Ballot Creation**:
  - The **chairperson** can create new ballots by specifying a list of proposal names and the voting duration (in seconds).
  - Each new ballot is deployed as a separate `Ballot` contract, and the address of each ballot is stored for future reference.
  - The `createBallot()` function increases the `ballotCount` and maps the ballot ID to the newly created ballot contract.

- **Ballot Management**:
  - The contract keeps track of all deployed ballots using a mapping (`ballotToContract`), where each ballot ID maps to a specific ballot contract address.
  - The `getBallotAddress()` function allows users to query the address of a specific ballot by its ID.

- **Retrieve All Ballots**:
  - The contract allows retrieving a list of all ballots, including their IDs and addresses, through the `getAllBallots()` function. This function returns two arrays:
    - An array of ballot IDs.
    - An array of corresponding ballot contract addresses.

- **Chairperson Role**:
  - Only the **chairperson** can create new ballots, ensuring that ballot creation is restricted to an authorized address.
  - The chairperson is set during contract deployment and is required to interact with certain functions like creating ballots.
  
- **SmartVote Welcome Page**:
  - The homepage introduces the **SmartVote Voting System**, highlighting its purpose and security focus.
  - The header includes the **SmartVote logo** and a tagline: "Secure Your Vote, Secure Your Future."
  
- **Delegate Rules**:
  - Detailed rules explain the eligibility for **delegating votes**:
    - Only voters with voting rights can delegate.
    - Self-delegation is disallowed.
    - Delegation depth is limited to 3 levels.
    - Delegation loops are prevented.
    - Delegates must have voting rights.
    - Voters who delegate cannot vote again.

- **Ballot Management**:
  - Users can view all available ballots by clicking the "Load All Ballots" button.
  - A table is dynamically populated with **ballot IDs** and **ballot addresses** when the data is loaded from the blockchain.

- **Navigation Links**:
  - Links to navigate to different pages of the platform:
    - **Ballot page** for managing ballots.
    - **Voter page** for managing individual voter information.

- **Smart Contract Integration**:
  - The page interacts with the **BallotManager smart contract** using **Web3.js** to load all ballots from the blockchain.
  - The contract's address is dynamically fetched from a **JSON file** (`contract_address.json`), with fallback options for local development environments.

- **MetaMask Integration**:
  - The page checks for the presence of **MetaMask** to connect to the Ethereum network. If MetaMask is not detected, a fallback to a local provider (e.g., Ganache) is used for testing and development.
  
##Front End Instructions

#Voter.html

- **Ballot ID Input**:
  - A field for users to input the **Ballot ID** to fetch the specific ballot they want to vote on.
  - **Load Ballot Button**: Fetches the active ballot contract address using the **BallotManager** smart contract.
  - Displays an alert if no ballot is found for the given ID.

- **Voting Section**:
  - Displays a list of proposals under the active ballot.
  - Users can vote for their preferred proposal by clicking a dynamically generated **vote button**.
  - The **vote** function interacts with the blockchain to register the user's vote for the selected proposal.

- **Delegate Vote**:
  - Allows voters to **delegate their vote** to another Ethereum address.
  - Users input the address they want to delegate to and click **Delegate Vote** to trigger the delegation transaction.
  - The system checks if the entered address is valid before sending the delegation request.

- **Remaining Time Section**:
  - Displays the **remaining voting time** in a formatted string (hours, minutes, and seconds).
  - Users can click **Check Remaining Time** to load the remaining time from the ballot contract.
  - The **remainingTime()** function fetches the time left for voting from the smart contract.

- **Loading Indicators**:
  - Displays a **loading message** and a **spinner** while the system is fetching data or processing transactions, providing feedback to users during these operations.

- **Smart Contract Interaction**:
  - Uses **Web3.js** to interact with the **BallotManager smart contract** and individual ballot contracts.
  - Fetches the **contract address** from a **JSON file** (`contract_address.json`) for dynamic loading of contracts.
  - Allows voting and delegation via smart contract calls to **vote()** and **delegate()** functions.

- **MetaMask and Ethereum Network Integration**:
  - The page checks if **MetaMask** is installed to connect to the Ethereum network.
  - If **MetaMask** is not available, a fallback to a **local Ethereum provider** (e.g., Ganache) is used for development and testing.

- **Error Handling**:
  - Alerts users if there are issues with input validation, smart contract interactions, or loading data (e.g., invalid ballot ID, network errors, invalid addresses).
  - Detailed error messages are logged in the console for debugging.

- **UI Elements**:
  - **Header** with the platform's logo and navigation options (e.g., Home link).
  - **Cards** organize sections like ballot input, voting, and delegate vote functionality for a clean and user-friendly interface.
  - **Footer** contains copyright information.

- **Dynamic Content Loading**:
  - All dynamic elements (e.g., proposals, remaining time) are fetched from the smart contract and updated in real-time based on the blockchain data.

#Ballot.html

- **Header Section**:
  - Contains the platform's logo and title, **SmartVote Voting System**, at the top.
  - A **Home link** navigates users back to the main page.
  - The page displays the title **Ballot Page**, indicating the specific section.

- **Create Ballot Section**:
  - Form to **create a new ballot**:
    - **Proposal Names**: Input field to enter the list of proposal names (comma separated).
    - **Voting Duration**: Input field for specifying the voting duration in seconds.
    - **Create Ballot Button**: Triggers the creation of a new ballot via the smart contract, using the entered data.
  
- **Load Ballot Section**:
  - **Ballot ID Input**: Input field where the user can enter a **Ballot ID** to load the associated ballot contract.
  - **Load Ballot Button**: Fetches the ballot contract address from the **BallotManager smart contract** and sets the ballot contract for further interactions.

- **Grant Voting Rights Section**:
  - **Voters List Input**: Text area to input Ethereum addresses (comma separated) for which voting rights will be granted.
  - **Grant Voting Rights Button**: Executes the granting of voting rights via the smart contract.

- **Revoke Voting Rights Section**:
  - **Revoke Voters List Input**: Text area for entering addresses (comma separated) to revoke voting rights.
  - **Revoke Voting Rights Button**: Triggers the revocation of voting rights via the smart contract.

- **Adjust Voter Weight Section**:
  - **Voter Address Input**: Field to input a specific voter's address.
  - **New Weight Input**: Field to enter a new weight for the specified voter.
  - **Adjust Weight Button**: Updates the voter’s weight by interacting with the smart contract.

- **Declare Winner Section**:
  - A table to display **winning proposal names** and their respective vote counts.
  - **Get Winner Button**: Triggers the retrieval of the winning proposal name and updates the table with the proposal names and vote counts.

- **Voting Time Remaining Section**:
  - A paragraph that initially shows "Click to load remaining time...".
  - **Check Remaining Time Button**: Fetches and displays the **remaining voting time** in hours, minutes, and seconds from the ballot contract.

- **Voter Information Section**:
  - A button that triggers fetching of voter information from the **ballot contract** to display details about voters.

- **Voters with Voting Rights Section**:
  - A table to display voters who currently have **voting rights**, showing their addresses, status, eligibility, and delegate addresses.

- **Voters with Revoked Rights Section**:
  - A table to display voters who have had their **voting rights revoked**, showing only their addresses.

- **Footer Section**:
  - Contains a copyright message for the voting system.

- **Smart Contract Interaction**:
  - Uses **Web3.js** to interact with the **BallotManager** smart contract.
  - Fetches the **contract address** dynamically from a `contract_address.json` file.
  - Retrieves and sets the **ballot contract address** based on the provided ballot ID.

- **MetaMask Integration**:
  - The page checks for **MetaMask** to connect to the Ethereum network. If MetaMask is not detected, it falls back to a **local Ethereum provider** (e.g., Ganache) for development.

- **Ballot Creation**:
  - The **createBallot()** function interacts with the **BallotManager smart contract** to create a new ballot using the provided proposals and duration.
  - The **proposal names** are converted into `bytes32` format for use in the smart contract.

- **Voting Rights Management**:
  - The page allows the **chairperson** to grant and revoke voting rights for specific Ethereum addresses using **grantVotingRights()** and **revokeVotingRights()** functions.
  - The **adjustVoterWeight()** function allows the chairperson to modify the weight of a specific voter’s vote.

- **Winner Declaration**:
  - The **getWinnerName()** function retrieves the winning proposal’s name and vote counts, and populates a table with the results.

- **Remaining Time**:
  - The **updateRemainingTime()** function fetches the remaining voting time from the ballot contract and displays it in a human-readable format.

- **Voter Information**:
  - The **getVotersInfo()** function displays a list of voters, categorized by those with voting rights and those with revoked rights, in their respective tables.

- **Error Handling**:
  - Alerts and **console errors** are shown if there are issues such as invalid input, network errors, or issues with fetching data or interacting with the smart contract.