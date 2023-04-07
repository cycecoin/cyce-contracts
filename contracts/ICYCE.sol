// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

interface ICYCE {
    function pause() external returns (bool);
    function unpause() external returns (bool);

    function transferOwnership(address newOwner) external returns (bool);
    function addBlacklist(address blackAddress) external returns (bool);
    function removeBlacklist(address blackAddress) external returns (bool);

    function mint(address account, uint256 amount) external returns (bool);
    function burn(uint256 amount) external returns (bool);
    function blacklisted(address account) external view returns(bool);
    function paused() external view returns(bool);
}
