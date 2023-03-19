//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;



/*
  ####   ###  ###   ####   #######            #####    #####   ##   ##  #######  ##   ##    ###    ##   ##    ####   #######
 ##  ##   ##  ##   ##  ##   ##   #           ##   ##  ### ###  ##   ##   ##   #  ###  ##   ## ##   ###  ##   ##  ##   ##   #
##         ####   ##        ##               ##       ##   ##  ##   ##   ##      #### ##  ##   ##  #### ##  ##        ##
##          ##    ##        ####             ## ####  ##   ##   ## ##    ####    #######  ##   ##  #######  ##        ####
##          ##    ##        ##               ##   ##  ##   ##   ## ##    ##      ## ####  #######  ## ####  ##        ##
 ##  ##     ##     ##  ##   ##   #           ##   ##  ### ###    ###     ##   #  ##  ###  ##   ##  ##  ###   ##  ##   ##   #
  ####     ####     ####   #######            #####    #####     ###    #######  ##   ##  ##   ##  ##   ##    ####   #######


*/
/*
 * @creator: Crypto Carbon Energy
 * @title  : Governance
 * @author : MFG
 *
 */



pragma solidity ^0.8.0;

contract VotingContract {

    uint public yesVotes;
    uint public noVotes;
    uint public totalVotes;
    uint public startTime;
    bool public votingEnded;
    address[] public votersList = [
    0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,
    0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db,
    0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB,
    0x617F2E2fD72FD9D5503197092aC168c91465E7f2,
    0x17F6AD8Ef982297579C203069C1DbfFE4348c372
    ];
    mapping(address => bool) public voters;
    mapping(address => bool) public voted;

    function startVoting() public {
        require(msg.sender == votersList[0], "Only the first voter can start the voting.");
        require(!votingEnded, "Voting has already ended.");
        startTime = block.timestamp;
    }

    function vote(bool _vote) public {
        require(voters[msg.sender], "You are not authorized to vote.");
        require(!voted[msg.sender], "You have already voted.");
        require(block.timestamp <= startTime + 24 hours, "Voting has ended.");

        if (_vote == true) {
            yesVotes++;
        } else {
            noVotes++;
        }

        voted[msg.sender] = true;
        totalVotes++;
    }

    function getVoterCount() public view returns (uint) {
        return votersList.length;
    }

    function getYesVotes() public view returns (uint) {
        return yesVotes;
    }

    function getNoVotes() public view returns (uint) {
        return noVotes;
    }

    function getVoteStatus() public view returns (string memory) {
        if (block.timestamp <= startTime + 24 hours) {
            return "Voting is in progress.";
        } else {
            votingEnded = true;
            if (yesVotes > noVotes) {
                // Call the example function to trigger an action on successful vote.
                exampleFunction();
                return "The proposal has been accepted.";
            } else {
                return "The proposal has been rejected.";
            }
        }
    }

    function exampleFunction() internal {
        // This is an example function that can be triggered on a successful vote.
        // Add your desired logic here.
    }

    constructor() {
        for (uint i = 0; i < votersList.length; i++) {
            voters[votersList[i]] = true;
        }
    }

}
pragma solidity ^0.8.0;

contract VotingContract {// State variables
    uint256 public yesVotes;
    uint256 public noVotes;
    uint256 public votingDeadline;
    bool public isVotingOpen;
    mapping(address => bool) public voters;
    address[] public votersList;
    address public proposer;
    bool public isProposalAccepted;

    // Events
    event NewVoterAdded(address voter);
    event VoteCasted(address voter, bool vote);
    event VotingResult(bool isAccepted);

    // Modifier to check if the voting deadline has not passed
    modifier canVote() {
        require(isVotingOpen && block.timestamp <= votingDeadline, "Voting is not open or has ended");
        _;
    }

    // Constructor to initialize the contract
    constructor(address[] memory _voters) {
        require(_voters.length == 5, "There must be exactly 5 voters");
        for (uint256 i = 0; i < _voters.length; i++) {
            voters[_voters[i]] = true;
            votersList.push(_voters[i]);
            emit NewVoterAdded(_voters[i]);
        }
    }

    // Function to start the voting process
    function startVoting() external {
        require(voters[msg.sender], "Only authorized voters can start the voting process");
        require(!isVotingOpen, "Voting is already open");
        isVotingOpen = true;
        votingDeadline = block.timestamp + 1 days;
    }

    // Function to cast a vote
    function vote(bool _vote) external canVote() {
        require(voters[msg.sender], "Only authorized voters can cast their votes");
        require(!hasVoted(msg.sender), "You have already casted your vote");
        voters[msg.sender] = true;
        votersList.push(msg.sender);
        if (_vote) {
            yesVotes++;
        } else {
            noVotes++;
        }
        emit VoteCasted(msg.sender, _vote);
    }

    // Function to check if a voter has already voted
    function hasVoted(address _voter) public view returns (bool) {
        return voters[_voter];
    }

    // Function to get the total number of voters
    function getNumberOfVoters() public view returns (uint256) {
        return votersList.length;
    }

    // Function to end the voting process and trigger the result
    function endVoting() external {
        require(isVotingOpen, "Voting is not open");
        require(block.timestamp > votingDeadline, "Voting is still open");
        uint256 totalVotes = yesVotes + noVotes;
        if (yesVotes > noVotes && totalVotes > 0) {
            isProposalAccepted = true;
            emit VotingResult(true);
        } else {
            emit VotingResult(false);
        }
        isVotingOpen = false;
        yesVotes = 0;
        noVotes = 0;
    }

    // Function to trigger a proposal if the voting is successful
    function triggerProposal() external {
        require(isProposalAccepted, "The proposal was not accepted");
        require(voters[msg.sender], "Only authorized voters can trigger the proposal");
        // Trigger your desired function here
    }

    // Function to check if the proposal was accepted
    function isAccepted() public view returns (bool) {
        return isProposalAccepted;
    }

}

