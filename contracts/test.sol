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

contract Governance is Pausable, Ownable{
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    struct AdminData {
        bool vote;
        uint256 time;
    }

    struct TimedLock {
        uint256 totalUserBalance;
        UserData[] userDataStore;
    }



    IERC20 public governesToken;

    address public tokenOwner;
    uint256 public timeScale = 6250 ; //24 Saat

    event Voted(
        address account,
        uint256 amount,
        uint256 time,
        uint256 percent
    );
    event Sing(
        address account,
        uint256 amount,
        uint256 time,
        uint256 percent
    );

    /* ========== CONSTRUCTOR ========== */
    constructor(IERC20 _token, address _tokenOwner) {
        governesToken = _token; // contract address of the token to be staked
        tokenOwner = _tokenOwner; // owner account to withdraw the token to be staked
    }

    /* ========== modifier ======== */
    modifier validDestination(address _to) {
        require(_to != address(0x0), "blackhole address");
        require(_to != address(stakingToken), "Token contract address");
        _;
    }

    // to calculate the rewards by  rate
    function calculateTotalAmount(uint256 amount, uint256 rate)
    internal
    view
    returns (uint256)
    {
        return amount.add(amount.mul(rate).div(rateScale));
    }

    /* ========== MUTATIVE FUNCTIONS ========== */
    // the authorized user tokenowner draws the balance from
    //the account to the contract and makes the stake to the relevant account.
    function sign(
        address account,
        uint256 amount,
        uint256 day,
        uint256 rate
    ) public onlyOwner whenNotPaused validDestination(account) {
        require(amount > 0, "can not stake 0");
        require(day > 0, "can not day 0");
        require(rate <= 30000, "withdraw rate is too high");
        require(
            stakeApplyInfo[account].userDataStore.length < 5,
            "array length can be up to 5"
        );

        uint256 _time = block.timestamp.add(day.mul(1 days));
        uint256 _amount = calculateTotalAmount(amount, rate);

        stakingToken.safeTransferFrom(tokenOwner, address(this), _amount);

        //virtual balance is created with the stake reward
        UserData memory _userData;
        _userData.balance = _amount;
        _userData.time = _time;
        stakeApplyInfo[account].userDataStore.push(_userData);
        stakeApplyInfo[account].totalUserBalance += _amount;

        emit Staked(account, amount, _time, rate);
    }

    // withdraw staked amount if possible
    function withdraw(uint256 index) public whenNotPaused nonReentrant {
        require(
            index < stakeApplyInfo[_msgSender()].userDataStore.length,
            "index out of bound"
        );
        require(
            stakeApplyInfo[_msgSender()].userDataStore.length > 0,
            "array is empty"
        );

        UserData memory _userData;

        _userData = stakeApplyInfo[_msgSender()].userDataStore[index];

        require(_userData.time < block.timestamp, "time has not expired");

        remove(_msgSender(), index);

        //virtual balance is withdraw to the account
        stakingToken.safeTransfer(_msgSender(), _userData.balance);

        emit Withdraw(_msgSender(), _userData.balance, index, block.timestamp);
    }

    //as a result of withdrawing the balance, the virtual balance is removed
    function remove(address account, uint256 index) internal {
        uint256 _length = stakeApplyInfo[account].userDataStore.length;
        if (_length > 1) {
            stakeApplyInfo[account].totalUserBalance -= stakeApplyInfo[account]
            .userDataStore[index]
            .balance;
            stakeApplyInfo[account].userDataStore[index] = stakeApplyInfo[
            account
            ].userDataStore[_length - 1];
            stakeApplyInfo[account].userDataStore.pop();
        } else {
            stakeApplyInfo[account].totalUserBalance = 0;
            stakeApplyInfo[account].userDataStore.pop();
        }
    }

    /* =========== views ==========*/
    function getInvestorInfo(address account)
    external
    view
    returns (uint256[] memory balances, uint256[] memory times)
    {
        uint256 _length = stakeApplyInfo[account].userDataStore.length;
        uint256[] memory _balances = new uint256[](_length);
        uint256[] memory _times = new uint256[](_length);
        for (uint256 i = 0; i < _length; i++) {
            _balances[i] = stakeApplyInfo[account].userDataStore[i].balance;
            _times[i] = stakeApplyInfo[account].userDataStore[i].time;
        }
        return (_balances, _times);
    }

    // stakingToken amount in the contract
    function contractBalanceOf() external view returns (uint256) {
        return stakingToken.balanceOf(address(this));
    }

    // the virtual balance is shown along with the stake total amount
    function balanceOf(address account) external view returns (uint256) {
        return stakeApplyInfo[account].totalUserBalance;
    }
}

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

contract VotingContract {

    // State variables
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

