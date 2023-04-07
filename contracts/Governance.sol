// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

import "./ICYCE.sol";
import "./Ownable.sol";
contract Governance is Ownable{

    // State variables
    uint256 public yesVotes;
    uint256 public noVotes;
    uint256 public votingDeadline;
    uint256 public resetDeadline;
    bool public isVotingOpen;
    uint voterCount = 5;
    mapping(address => bool) private voters;

    address public account;
    uint256 public amount;
    ICYCE private cyceToken;


    enum TargetType {
        MINT,
        BURN,
        PAUSE,
        UN_PAUSE,
        TRANSFER_OWNERSHIP,
        ADD_BLACKLIST,
        REMOVE_BLACKLIST
    }

    TargetType public targetType;
    address[voterCount] private authorizedAdmin;

    // Events
    event VoteCasted(address voter, bool vote);
    event VotingResult(bool isAccepted);

    // Modifier to check if the voting deadline has not passed
    modifier canVote() {
        require(isVotingOpen && block.timestamp <= votingDeadline, "Voting is not open or has ended");
        _;
    }

    // Constructor to initialize the contract
    constructor(ICYCE  _cyceToken, address[voterCount] memory _authorizedAdmin) {
        require(_authorizedAdmin.length == voterCount, "There must be exactly 5 authorizedAdmin");
        cyceToken = _cyceToken;
       authorizedAdmin =_authorizedAdmin;
    }

    // Function to start the voting process
    function startVoting(TargetType _targetType) external {
        require(isAuthorized(msg.sender), "Only authorized authorizedAdmin can start the voting process");
        require(!isVotingOpen, "Voting is already open");
        require(_targetType == TargetType.PAUSE || _targetType == TargetType.UN_PAUSE,
            "Type is must be pause or unpause function");
        if(_targetType == TargetType.PAUSE){
            require(!cyceToken.paused(), "already paused");
        }else {
            require(cyceToken.paused(), "already unpaused");
        }
        targetType = _targetType;
        isVotingOpen = true;
        votingDeadline = block.timestamp + 1 days;
    }
    function startVoting(TargetType _targetType, address _account) external {
        require(isAuthorized(msg.sender), "Only authorized authorizedAdmin can start the voting process");
        require(!isVotingOpen, "Voting is already open");
        require(_targetType == TargetType.TRANSFER_OWNERSHIP ||  _targetType == TargetType.ADD_BLACKLIST || _targetType == TargetType.REMOVE_BLACKLIST,
        "Type is must be transferownership, addblacklist or  removeblacklist function");
        if(targetType == targetType.TRANSFER_OWNERSHIP){
            require(isContract(_account), 'not contract address');
        }else if(targetType.ADD_BLACKLIST){
            require(!cyceToken.blacklisted(_account), 'already blacklisted');
        }else if(targetType.REMOVE_BLACKLIST){
            require(cyceToken.blacklisted(_account), "not blacklisted");
        }

        targetType = _targetType;
        account = _account;
        isVotingOpen = true;
        votingDeadline = block.timestamp + 1 days;
    }
    function startVoting(TargetType _targetType, uint256 _amount) external {
        require(isAuthorized(msg.sender), "Only authorized authorizedAdmin can start the voting process");
        require(!isVotingOpen, "Voting is already open");
        require(_targetType == TargetType.BURN,
        "Type is must be burn function");
        targetType = _targetType;
        amount =_amount;
        isVotingOpen = true;
        votingDeadline = block.timestamp + 1 days;
    }
    function startVoting(TargetType _targetType, address _account, uint256 _amount) external {
        require(isAuthorized(msg.sender), "Only authorized authorizedAdmin can start the voting process");
        require(!isVotingOpen, "Voting is already open");
        require(_targetType == TargetType.MINT,
        "Type is must be mint function");
        require(_account =! address(0), "address is invalid");
        targetType = _targetType;
        account =  _account;
        amount = _amount;
        isVotingOpen = true;
        votingDeadline = block.timestamp + 1 days;
    }
    // Function to cast a vote
    function vote(bool _vote) external canVote() {
        require(isAuthorized(msg.sender), "Only authorized authorizedAdmin can the voting process");
        require(!hasVoted(msg.sender), "You have already casted your vote");
        voters[msg.sender] = true;
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

    function isAuthorized(address _admin) public view returns(bool) {
        for (uint i = 0; i < authorizedAdmin.length; i++) {
            if (authorizedAdmin[i] == _admin) {
                return true;
            }
        }
        return false;
    }



    // Function to end the voting process and trigger the result
    function endVoting() external {
        require(isAuthorized(msg.sender), "Only authorized authorizedAdmin can start the end voting process");
        require(isVotingOpen, "Voting is not open");



        uint256 totalVotes = yesVotes + noVotes;

        if(yesVotes >= (voterCount + 1) / 2 ){
            _resetStates();
            _execute();
        } else if(block.timestamp > votingDeadline){

        if (yesVotes > noVotes && totalVotes > 0) {
            _resetStates();
            _execute();
            emit VotingResult(true);
        } else {
            _resetStates();
            emit VotingResult(false);
        }

        }
    }



    function startResetVoting()  onlyOwner external {
        require(isVotingOpen, "Voting is not open");
        resetDeadline = block.timestamp + 2 days;
    }
    function resetVoting() onlyOwner external {
        require(resetDeadline <= block.timestamp, "time has not expired");
        _resetStates();
    }
    function _resetStates() private {
        require(isVotingOpen, "Voting is not open");
        isVotingOpen = false;
        yesVotes = 0;
        noVotes = 0;
        for(uint256 i =0 ; i < authorizedAdmin.length ; i++){
            if(voters[authorizedAdmin[i]]) {
                delete voters[authorizedAdmin[i]] ;
            }
        }
    }
    function _execute() private {
        if(targetType == TargetType.MINT){
            cyceToken.mint(account, amount);
        }else if(targetType == TargetType.BURN) {
            cyceToken.burn(amount);
        }else if(targetType == TargetType.PAUSE) {
             cyceToken.pause();
        }else if(targetType == TargetType.UN_PAUSE) {
            cyceToken.unpause();
        }else if(targetType == TargetType.TRANSFER_OWNERSHIP){
            cyceToken.transferOwnership(account);
        }else if(targetType == TargetType.ADD_BLACKLIST){
            cyceToken.addBlacklist(account);
        }else if(targetType == TargetType.REMOVE_BLACKLIST){
            cyceToken.removeBlacklist(account);
        }

    }

}