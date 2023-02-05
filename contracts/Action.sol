// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Ownable.sol";

contract Action is Ownable {
    mapping(address => bool) private _blacklist;
    bool private _pause;

    event AddBlacklist(address indexed account);
    event RemoveBlacklist(address indexed account);
    event Pause(address indexed account);
    event UnPause(address indexed account);

    constructor() {
        _pause = false;
    }

    modifier isNotBlacklist() {
        require(!_blacklist[msg.sender]);
        _;
    }

    function pause() public onlyOwner {
        require(!_pause, "Action: already pause");
        _pause = true;
        emit Pause(msg.sender);
    }

    function unPause() public onlyOwner {
        require(_pause, "Action: already  unpause");
        _pause = false;
        emit UnPause(msg.sender);
    }

    function paused() public view returns (bool) {
        return _pause;
    }

    function addBlacklist(
        address blackAddress
    ) public onlyOwner returns (bool) {
        _blacklist[blackAddress] = true;
        emit AddBlacklist(blackAddress);
        return true;
    }

    function removeBlacklist(
        address blackAddress
    ) public onlyOwner returns (bool) {
        _blacklist[blackAddress] = false;
        emit RemoveBlacklist(blackAddress);
        return true;
    }

    function blackListed(address account) public view returns (bool) {
        return _blacklist[account];
    }

    function _beforeTransferToken(
        address from,
        address to,
        uint256 amount
    ) internal view {
        require(!_blacklist[from], "Action: Sender blacklisted");
        require(!_blacklist[to], "Action: Recipient blacklisted");
        require(amount > 0, "Action: transfer amount has to big than 0");
        require(!_pause, "Action: paused");
    }
}
