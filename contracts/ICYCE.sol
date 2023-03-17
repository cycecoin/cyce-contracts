// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

abstract contract ICYCE {
    // Get the total supply of tokens
    function transferOwnerShip(address newOwner) public virtual returns(bool);
    function pause() public virtual returns(bool);
    function unPause() public virtual returns(bool);
    function addBlacklist(address blackAddress) public virtual returns(bool);
    function removeBlacklist(address blackAddress) public virtual returns(bool);
    function mint(int256 tokens) public virtual returns(bool);
    function burn(int256 tokens) public virtual returns(bool);
}