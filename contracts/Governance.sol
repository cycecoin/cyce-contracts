//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ICYCE.sol";

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

contract Governance is ICYCE{
    using SafeERC20 for ICYCE;
    using SafeMath for uint256;


    struct UserData {
        uint256 balance;
        uint256 time;
    }

    struct TimedLock {
        uint256 totalUserBalance;
        UserData[] userDataStore;
    }



    IERC20 public governesToken;

    address public tokenOwner;

    uint256 public constant VOTING_PERIOD = 1 days;

    event Voted(
        address account,
        uint256 amount,
        uint256 time,
        uint256 percent
    );

    /* ========== CONSTRUCTOR ========== */
    constructor(IERC20 _token, address _tokenOwner) {
        managedToken = _token; // contract address of the token to be staked
        tokenOwner = _tokenOwner; // owner account to withdraw the token to be staked
    }


    // the virtual balance is shown along with the stake total amount
    function balanceOf() external view returns (uint256) {
        return ;
    }
}