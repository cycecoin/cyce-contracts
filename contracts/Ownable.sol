// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Ownable {
    address private _owner;

    constructor() {
        _owner = msg.sender;
    }

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    modifier onlyOwner() {
        require(msg.sender == _owner, "Unauthorized");
        _;
    }

    function isContract(address _addr) private view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function transferOwnerShip(
        address newOwner
    ) public onlyOwner returns (bool) {
        require(
            isContract(newOwner),
            "Ownable: New owner address is not a contract"
        );
        require(_owner != newOwner, "Ownable: The same owner");
        _transferOwnerShip(newOwner);
        return true;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _transferOwnerShip(address newOwner) private {
        _owner = newOwner;
        emit OwnershipTransferred(msg.sender, newOwner);
    }

    function renounceOwnerShip() public onlyOwner returns (bool) {
        _transferOwnerShip(address(0));
        return true;
    }
}
