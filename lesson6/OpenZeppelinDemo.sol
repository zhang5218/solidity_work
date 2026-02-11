// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract OpenZeppelinDemo{
    using Strings for uint256;
    using Address for address;

    function numToString(uint256 num) public pure returns (string memory){
        return num.toString();
    }
    
}